public class ScheduledStalledSMSDetectorBatch implements Database.Batchable<SObject>, Database.Stateful {
    private SMSDetectionRuleSet rule;
    List<String> csvFile;
    Integer count = 0;
    Boolean ranOutOfHeapSpace = false;
    Datetime startTime;

    // Flags to force error behavior in tests
    @TestVisible
    private static Boolean FORCE_WASTE_HEAP_SPACE = false; // force to run out of heap space

    public ScheduledStalledSMSDetectorBatch(SMS_Stall_Detection_Rule__mdt metadatum) {
        rule = new SMSDetectionRuleSet(metadatum);
        csvFile = new List<String>();
        csvFile.add(rule.describeSMSHeader());
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        try {
            startTime = System.now();
            String query = rule.getQuery().toString();
            return Database.getQueryLocator(query);
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertIdToJSON('bc.getJobId()', bc.getJobId()));
            vars.add(ErrorLogger.convertStringToJSON('rule', rule.toString()));
            ErrorLogger.log(ex, vars, false);
            return null;
        }
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        try {
            // Track count
            count += scope.size();

            // We ran out of heap space earlier and lost our work so don't bother, we will instead be generating a summary report in the finish function
            if (ranOutOfHeapSpace == true)
                return;

            // consume heap memory
            if (Test.isRunningTest() && FORCE_WASTE_HEAP_SPACE) {
                GovernorLimitForceHelper.wasteHeap(0.8);
            }

            // add each to CSV file while detecting if we have too many records
            while (!scope.isEmpty()) {
                csvFile.add(rule.describeSMS((smagicinteract__smsMagic__c) scope[0]));
                scope.remove(0);

                GovernorLimitPreemptException.assertHasHeapSpaceRemaining(
                    0.8,
                    'Ran out of heap space while generating file for SMS Stall Detection'
                );
            }
        } catch (GovernorLimitPreemptException ex) {
            csvFile.clear();
            ranOutOfHeapSpace = true;

            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertIdToJSON('bc.getJobId()', bc.getJobId()));
            vars.add(ErrorLogger.convertIdToJSON('bc.getChildJobId()', bc.getChildJobId()));
            vars.add(ErrorLogger.convertStringToJSON('rule', rule.toString()));
            ErrorLogger.log(ex, vars, false);
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertIdToJSON('bc.getJobId()', bc.getJobId()));
            vars.add(ErrorLogger.convertIdToJSON('bc.getChildJobId()', bc.getChildJobId()));
            vars.add(ErrorLogger.convertStringToJSON('rule', rule.toString()));
            ErrorLogger.log(ex, vars, false);
        }
    }

    public void finish(Database.BatchableContext bc) {
        try {
            if (count > 0) {
                String countStr = count == 5000 ? '5000+' : String.valueOf(count);

                String emailTitle = 'Stalled SMS Messages';
                String emailBody = '';
                Messaging.EmailFileAttachment att = null;

                if (!ranOutOfHeapSpace) {
                    // Ideal happy path
                    emailTitle = 'Stalled SMS Messages for ' + rule.label + ' - ' + countStr + ' SMS are stalled';
                    emailBody =
                        'Report for stalled SMS for rule ' +
                        rule.label +
                        '.\nRan at ' +
                        startTime.format('YYYY-MM-dd HH:mm:ss zzz') +
                        '.\nThere are ' +
                        countStr +
                        ' SMS stalled.\n' +
                        'Attached file contains a list of all related records.';

                    att = new Messaging.EmailFileAttachment();
                    att.setFileName('SMS for ' + rule.label + '.csv');

                    try {
                        //scope block to allow grabage collection to free csvFileStr quickly
                        String csvFileStr = String.join(csvFile, '\n');
                        att.setBody(Blob.valueOf(csvFileStr));
                    } catch (StringException ex) {
                        // Can throw StringException if string length exceeeds 12MB
                        // in terms of how to recover, this is basically the same as running out of heap space
                        ranOutOfHeapSpace = true;
                    }
                    csvFile.clear(); // free memory
                    att.setContentType('text/csv');
                }

                // This should NOT be an else since ranOutOfHeapSpace could be set as a result of the previous if statement
                if (ranOutOfHeapSpace) {
                    /**
                     * If we ran out of heap space, usually that is because we included text body in the query and had lots of SMS stalled
                     * If this happens, make an abbreviated report and send that instead
                     */
                    emailTitle = 'Stalled SMS Messages for ' + rule.label + ' - ' + countStr + ' SMS are stalled';
                    emailBody =
                        'Report for stalled SMS for rule ' +
                        rule.label +
                        '.\nRan at ' +
                        startTime.format('YYYY-MM-dd HH:mm:ss zzz') +
                        '.\nThere are ' +
                        countStr +
                        ' SMS stalled.\n' +
                        'Ran out of memory and could not generate full report. Abbreviated report attached.';

                    // create summary report
                    rule.queryFields.clear();
                    rule.queryFields.add(Schema.SObjectType.smagicinteract__smsMagic__c.fields.Id.getName());
                    rule.queryFields.add(
                        Schema.SObjectType.smagicinteract__smsMagic__c.fields.smagicinteract__PhoneNumber__c.getName()
                    );
                    rule.queryFields.add(
                        Schema.SObjectType.smagicinteract__smsMagic__c.fields.smagicinteract__Status__c.getName()
                    );
                    rule.queryFields.add(
                        Schema.SObjectType.smagicinteract__smsMagic__c.fields.smagicinteract__statusMessage__c.getName()
                    );

                    csvFile.add(rule.describeSMSHeader());

                    List<smagicinteract__smsMagic__c> allSms = rule.getQuery().query();
                    while (!allSms.isEmpty()) {
                        csvFile.add(rule.describeSMS((smagicinteract__smsMagic__c) allSms[0]));
                        allSms.remove(0);
                    }
                    att = new Messaging.EmailFileAttachment();
                    att.setFileName('SMS for ' + rule.label + '.csv');
                    {
                        //scope block to allow grabage collection to free csvFileStr quickly
                        String csvFileStr = String.join(csvFile, '\n');
                        att.setBody(Blob.valueOf(csvFileStr));
                    }
                    csvFile.clear(); // free memory
                    att.setContentType('text/csv');
                }

                // Send the email!
                Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
                emailMsg.setSubject(emailTitle);
                emailMsg.setToAddresses(new List<String>(rule.emailsSet));
                emailMsg.setPlainTextBody(emailBody);
                emailMsg.setFileAttachments(new List<Messaging.EmailFileAttachment>{ att });

                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ emailMsg });

                if (Test.isRunningTest()) {
                    /**
                     * If we are running a test, we can't really see emails that we send out, so we make EmailMessage records in Salesforce with the same values
                     */
                    Case c = new Case(Subject = 'Scheduled SMS Emails for ' + rule.label);
                    insert c;

                    EmailMessage sfEmailRecord = new EmailMessage(
                        ParentId = c.Id,
                        FromAddress = 'scheduled.sms.detector@asu.edu',
                        ToAddress = String.join(rule.emailsSet, ','),
                        Subject = emailTitle,
                        textBody = emailBody,
                        Status = '3', // Sent
                        Incoming = false
                    );
                    insert sfEmailRecord;

                    ContentVersion cv = new ContentVersion(
                        Title = att.getFileName(),
                        PathOnClient = att.getFileName(),
                        VersionData = att.getBody()
                    );
                    insert cv;

                    cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];

                    ContentDocumentLink cdl = new ContentDocumentLink(
                        ContentDocumentId = cv.ContentDocumentId,
                        LinkedEntityId = sfEmailRecord.Id
                    );
                    insert cdl;
                }
            }
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertIdToJSON('bc.getJobId()', bc.getJobId()));
            vars.add(ErrorLogger.convertStringToJSON('rule', rule.toString()));
            ErrorLogger.log(ex, vars, false);
        }
    }

    public class SMSDetectionRuleSet {
        public final String label;
        public final Integer maxDaysOld;
        public final Integer minHoursOld;
        public final Set<String> emailsSet;
        public final Set<String> queryFields;
        public final Set<String> constraintSenderIdUnits;
        public final Set<String> constraintStatuses;

        // Normal constructor
        public SMSDetectionRuleSet(SMS_Stall_Detection_Rule__mdt rule) {
            // Which metadatum does this represent?
            label = rule.MasterLabel;

            // Optional n hours old minimum
            if (rule.At_Least_N_Hours_Old__c != null) {
                minHoursOld = Integer.valueOf(rule.At_Least_N_Hours_Old__c);
            }
            // Optional max n days old
            if (rule.Number_Of_Days__c != null) {
                maxDaysOld = Integer.valueOf(rule.Number_Of_Days__c);
            }

            // Make email list
            emailsSet = new Set<String>();
            for (String s : rule.Email_Addresses__c.split(',')) {
                if (s.trim().length() > 0) {
                    emailsSet.add(s.trim());
                }
            }
            // Make field name list
            queryFields = new Set<String>();
            for (String s : rule.Report_Fields__c.split(',')) {
                if (s.trim().length() > 0) {
                    queryFields.add(s.trim());
                }
            }
            // Make sender id list
            constraintSenderIdUnits = new Set<String>();
            if (rule.Sender_Id_Units__c != null) {
                for (String s : rule.Sender_Id_Units__c.split(',')) {
                    if (s.trim().length() > 0) {
                        constraintSenderIdUnits.add(s.trim());
                    }
                }
            }
            // Make status list
            constraintStatuses = new Set<String>();
            if (rule.Statuses__c != null) {
                for (String s : rule.Statuses__c.split(',')) {
                    if (s.trim().length() > 0) {
                        constraintStatuses.add(s.trim());
                    }
                }
            }
        }

        // Generates the query for this rule
        public DynamicSoqlBuilder getQuery() {
            DynamicSoqlBuilder queryBuilder = new DynamicSoqlBuilder(Schema.SObjectType.smagicinteract__smsMagic__c);

            for (String field : queryFields)
                queryBuilder.returnField(field);

            queryBuilder.restrictEqual(
                Schema.SObjectType.smagicinteract__smsMagic__c.fields.smagicinteract__Direction__c,
                'OUT'
            );

            // Minimum hours old
            if (minHoursOld != null) {
                Datetime newestDateAccepted = System.now().addHours(-1 * minHoursOld);
                queryBuilder.restrictLessThan(
                    Schema.SObjectType.smagicinteract__smsMagic__c.fields.CreatedDate,
                    newestDateAccepted
                );
            }

            // Max days old
            if (maxDaysOld != null) {
                Datetime oldestDateAccepted = System.now().addDays(-1 * maxDaysOld);
                // get start of that day
                oldestDateAccepted = oldestDateAccepted.addHours(-1 * oldestDateAccepted.hour())
                    .addMinutes(-1 * oldestDateAccepted.minute())
                    .addSeconds(-1 * oldestDateAccepted.second());

                queryBuilder.restrictGreaterThan(
                    Schema.SObjectType.smagicinteract__smsMagic__c.fields.CreatedDate,
                    oldestDateAccepted
                );
            }

            // Sender Id Units
            if (!constraintSenderIdUnits.isEmpty()) {
                queryBuilder.restrictIn(
                    Schema.SObjectType.smagicinteract__smsMagic__c.fields.SenderIdUnit__c,
                    new List<String>(constraintSenderIdUnits)
                );
            }

            // Status
            if (!constraintStatuses.isEmpty()) {
                queryBuilder.restrictIn(
                    Schema.SObjectType.smagicinteract__smsMagic__c.fields.smagicinteract__Status__c,
                    new List<String>(constraintStatuses)
                );
            }

            // Max of 5000 records
            queryBuilder.setLimit(5000);

            return queryBuilder;
        }

        // List this rule set's fields - use for first row of CSV
        public String describeSMSHeader() {
            return String.join(queryFields, ',');
        }

        // Describe this SMS object using this rule set's queryFields
        public String describeSMS(smagicinteract__smsMagic__c sms) {
            List<String> columns = new List<String>();
            for (String field : queryFields) {
                String value = '';
                if (field.equals('CreatedDate') || field.equals('smagicinteract__CreatedOn__c')) {
                    value = sms.get(field) == null ? '' : ((Datetime) sms.get(field)).format('M/d/YYYY h:mm:ss a');
                } else {
                    value = sms.get(field) == null ? '' : '' + sms.get(field);
                }

                if (value.contains('"') || value.contains(',') || value.contains('\n')) {
                    value = '"' + value.replace('"', '""') + '"';
                }

                columns.add(value);
            }
            return String.join(columns, ',');
        }
    }
}
