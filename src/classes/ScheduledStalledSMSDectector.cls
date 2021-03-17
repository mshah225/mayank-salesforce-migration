global with sharing class ScheduledStalledSMSDectector implements Schedulable {
    List<SMSDetectionRuleSet> ruleSets;
    SMSDetectionRuleSet ruleSuperset; // used for the query so we can use just one query

    global void execute(SchedulableContext SC) {
        initializeFromMetadata();

        List<smagicinteract__smsMagic__c> allSMSToReportOn = Database.query(ruleSuperset.getQuery());

        // Report about the stalled SMS
        if (!allSMSToReportOn.isEmpty()) {
            List<Messaging.SingleEmailMessage> allEmails = new List<Messaging.SingleEmailMessage>();

            // For each rule set create a separate email about different SMS
            for (SMSDetectionRuleSet ruleSet : ruleSets) {
                List<smagicinteract__smsMagic__c> smsForThisRule = ruleSet.filter(allSMSToReportOn);

                String description = smsForThisRule.size() + ' SMS are stalled.\n';
                for (smagicinteract__smsMagic__c sms : smsForThisRule) {
                    description += ruleSet.describeSMS(sms);
                    description += '\n';
                }
                allEmails.add(createEmail(new List<String>(ruleSet.emailsSet), description));
            }

            Messaging.sendEmail(allEmails);
        }
    }

    private void initializeFromMetadata() {
        ruleSets = new List<SMSDetectionRuleSet>();

        for (SMS_Stall_Detection_Rule__mdt rule : [
            SELECT
                MasterLabel,
                At_Least_N_Hours_Old__c,
                Number_Of_Days__c,
                Email_Addresses__c,
                Fields__c,
                Sender_Id_Units__c,
                Statuses__c
            FROM SMS_Stall_Detection_Rule__mdt
            WHERE Enabled__c = TRUE
        ]) {
            ruleSets.add(new SMSDetectionRuleSet(rule));
        }

        ruleSuperset = new SMSDetectionRuleSet(ruleSets);
    }

    private Messaging.SingleEmailMessage createEmail(List<String> toWho, String description) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setSubject('Stalled SMS Messages');
        mail.setToAddresses(toWho);
        mail.setPlainTextBody(description);

        return mail;
    }

    @TestVisible
    private class SMSDetectionRuleSet {
        public final Integer maxDaysOld;
        public final Integer minHoursOld;
        public final Set<String> emailsSet;
        public final Set<String> queryFields;
        public final Set<String> constraintSenderIdUnits;
        public final Set<String> constraintStatuses;

        // Normal constructor
        public SMSDetectionRuleSet(SMS_Stall_Detection_Rule__mdt rule) {
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
            for (String s : rule.Fields__c.split(',')) {
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
        // Superset constructor to allow easy super query construction
        public SMSDetectionRuleSet(List<SMSDetectionRuleSet> subsets) {
            emailsSet = new Set<String>();
            queryFields = new Set<String>();
            constraintSenderIdUnits = new Set<String>();
            constraintStatuses = new Set<String>();

            for (SMSDetectionRuleSet ruleset : subsets) {
                // largest max hours
                if (ruleset.maxDaysOld != null && (maxDaysOld == null || ruleset.maxDaysOld > maxDaysOld)) {
                    maxDaysOld = ruleset.maxDaysOld;
                }
                // smallest min hours
                if (ruleset.minHoursOld != null && (minHoursOld == null || ruleset.minHoursOld < minHoursOld)) {
                    minHoursOld = ruleset.minHoursOld;
                }

                emailsSet.addAll(ruleset.emailsSet);
                queryFields.addAll(ruleset.queryFields);
                constraintSenderIdUnits.addAll(ruleset.constraintSenderIdUnits);
                constraintStatuses.addAll(ruleset.constraintStatuses);
            }
        }

        // Filter a List of smagicinteract__smsMagic__c based on the rules of this rule set
        public List<smagicinteract__smsMagic__c> filter(List<smagicinteract__smsMagic__c> smsList) {
            Datetime newestDateAccepted, oldestDateAccepted;
            List<smagicinteract__smsMagic__c> newList = new List<smagicinteract__smsMagic__c>();

            if (minHoursOld != null) {
                newestDateAccepted = System.now().addHours(minHoursOld);
            }
            if (maxDaysOld != null) {
                oldestDateAccepted = System.now().addDays(maxDaysOld);
            }

            for (Integer i = 0; i < smsList.size(); i++) {
                smagicinteract__smsMagic__c sms = smsList[i];

                if (
                    (oldestDateAccepted == null ||
                    sms.CreatedDate > oldestDateAccepted) &&
                    (newestDateAccepted == null ||
                    sms.CreatedDate < newestDateAccepted) &&
                    (constraintSenderIdUnits.isEmpty() || constraintSenderIdUnits.contains(sms.SenderIdUnit__c)) &&
                    (constraintStatuses.isEmpty() || constraintStatuses.contains(sms.smagicinteract__Status__c))
                ) {
                    newList.add(sms);
                }
            }

            return newList;
        }
        // Generates the query as a string
        public String getQuery() {
            Datetime newestDateAccepted, oldestDateAccepted;

            if (minHoursOld != null) {
                newestDateAccepted = System.now().addHours(-1 * minHoursOld);
            }
            if (maxDaysOld != null) {
                oldestDateAccepted = System.now().addDays(-1 * maxDaysOld);
            }

            // Contruct the query
            String query = 'SELECT ';
            for (String field : queryFields) {
                query += field + ',';
            }
            query = query.substring(0, query.length() - 1); // cut off final comma
            query += ' FROM smagicinteract__smsMagic__c';
            query += ' WHERE smagicinteract__Direction__c = \'OUT\'';

            if (!constraintSenderIdUnits.isEmpty()) {
                query += ' AND (';
                for (String senderId : constraintSenderIdUnits) {
                    query += ' SenderIdUnit__c=\'' + senderId + '\' OR';
                }
                query = query.substring(0, query.length() - 2); // cut off final OR
                query += ')';
            }

            if (!constraintStatuses.isEmpty()) {
                query += ' AND (';
                for (String status : constraintStatuses) {
                    query += ' smagicinteract__Status__c=\'' + status + '\' OR';
                }
                query = query.substring(0, query.length() - 2); // cut off final OR
                query += ')';
            }

            if (oldestDateAccepted != null) {
                query += ' AND CreatedDate > ' + oldestDateAccepted.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
            }
            if (newestDateAccepted != null) {
                query += ' AND CreatedDate < ' + newestDateAccepted.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
            }
            return query;
        }
        // Describe this SMS object using this rule set's queryFields
        public String describeSMS(smagicinteract__smsMagic__c sms) {
            String constructed = '{';
            for (String field : queryFields) {
                constructed += '"' + field + '" : "' + sms.get(field) + '",';
            }
            constructed = constructed.substring(0, constructed.length() - 1); // remove trailing comma
            constructed += '}';

            return constructed;
        }
    }
}
