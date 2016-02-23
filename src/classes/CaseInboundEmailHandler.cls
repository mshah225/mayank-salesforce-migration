global class CaseInboundEmailHandler implements Messaging.InboundEmailHandler
{
    private Static Boolean TRACE = true;

    private Map<String, String> configMap = new Map<String, String>();
    private Id queueId;
    private Id templateId;
    private Id caseFeedTemplateId;
    private String categoryName;
    private String subCategoryName;
    private String origin;
    private String campus;
    private String functionalGroup;
    private String replyToAddress;
    private String emailFromName;
    private Id defaultCaseRecordTypeId;
    private Id caseRecordTypeId;
    private Id fallbackQueueId;
    private String typeOfAdditionalAssignmentNeeded;
    private boolean associateCaseToActiveOpportunity;
    protected Case theCase = null;
    protected Messaging.InboundEmail inboundEmail;
    protected String defaultCaseOwnerId;

    public CaseInboundEmailHandler() {}

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env)
    {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        result.success = true;
        this.inboundEmail = email;
        Boolean sendAutoReply = false;
        Contact emailContact = new Contact();

        try
        {
            // Load the configuration info from Custom Settings
            loadConfigurationSettings();

            // Retrieves the sender's first and last names
            String fName = '';
            String lName = '';

            if (email.fromname != null && email.fromname != '')
            {
                if (email.fromname.indexof(' ') == -1 )
                {
                    fName = '';
                    lName = email.fromname;
                }
                else
                {
                    fName = email.fromname.substring(0,email.fromname.indexOf(' '));
                    lName = email.fromname.substring(email.fromname.indexOf(' '));
                }
            }
            else
            {
                fname = '';
                lname = email.fromAddress;
            }

            // If the parsed first name ends with a comma, assume it's actually the last name and swap them, sans comma
            if (fname.endsWith(','))
            {
                String newLname = fname.substring(0, fname.length()-1);
                fName = lName;
                lName = newLname;
            }

            // Check the inbound email for filtered terms; if found, no do nothing
            if (filteredTermFound())
            {
                // If we want to send a reply with a failure message, the result props can be changed
                return result;
            }

            String caseId = extractIdRefNew(email.plainTextBody);

            if (caseId == null)
            {
                caseId = extractIdRefNew(email.htmlBody);
            }

            if (caseId == null)
            {
                caseId = extractIdRefNew(email.subject);
            }

            if (caseId != null)
            {
                if (TRACE)
                {
                    System.debug(Logginglevel.ERROR,'CaseEmailInBoundUtilities.  extracted case id: "' + caseId + '"');
                }

                Case caseSearch = CaseService.getCaseInformation(caseId);

                if (caseSearch != null)
                {
                    Integer iReopenClosedCaseThreshold;
                    String reopenClosedCaseThreshold = getConfigurationSetting('Reopen Closed Case Threshold');

                    if (reopenClosedCaseThreshold != null && Integer.valueOf(reopenClosedCaseThreshold)>0)
                    {
                        iReopenClosedCaseThreshold = Integer.valueOf(reopenClosedCaseThreshold) * -1;
                    }
                    else
                    {
                        iReopenClosedCaseThreshold = 0;
                    }

                    Boolean caseCanBeReopened = iReopenClosedCaseThreshold != 0 && caseSearch.Status.startsWith('Closed') && caseSearch.ClosedDate != null && caseSearch.ClosedDate > DateTime.Now().addDays(iReopenClosedCaseThreshold);
                    Boolean caseStatusIsNotNull = caseSearch.Status != null;
                    Boolean caseStatusIsNotClosed = !caseSearch.Status.startsWith('Closed');

                    // If the case was closed within the last n days set in custom settings, re-open it.  Otherwise, create a new case below
                    if (caseStatusIsNotNull && (caseStatusIsNotClosed || caseCanBeReopened))
                    {
                        this.theCase = caseSearch;

                        Id serviceRecordType = [SELECT Id FROM RecordType WHERE Name = 'ASU Service'].Id;

                        // Assign service cases back to the most recently associated Queue
                        if (this.theCase.RecordTypeId == serviceRecordType)
                        {
                            String groupName = this.theCase.Most_Recent_Queue__c;
                            Group groupToReopen;

                            // Case will reopen to the currently associated user if no group can be found
                            try
                            {
                                groupToReopen = GroupService.getGroupDetails(groupName);

                                this.theCase.OwnerId = groupToReopen.Id;
                            }
                            catch (Exception e)
                            {
                                // Option to do something else
                            }


                            if (String.isEmpty(this.theCase.Most_Recent_Functional_Group__c))
                            {
                                // Handle NPE on Most_Recent_Functional_Group__c
                                this.theCase.Most_Recent_Functional_Group__c = this.theCase.Functional_Group__c;
                            }
                            else if (this.theCase.Functional_Group__c.equals('External Unit'))
                            {
                                this.theCase.Functional_Group__c = this.theCase.Most_Recent_Functional_Group__c;
                            }
                        }

                        if (this.theCase.Status.startsWith('Closed'))
                        {
                            this.theCase.Status = 'Re-Opened';
                            update this.theCase;
                        }
                    }
                }
            }

            List<String> toAddressList = new List<String>();
            List<String> ccAddressList = new List<String>();

            if (email.ToAddresses != null)
            {
                toAddressList = email.ToAddresses;
            }

            if (email.CCAddresses != null)
            {
                ccAddressList = email.CcAddresses;
            }

            setCaseAssignmentRule(toAddressList, ccAddressList);

            // If this email was sent to multiple addresses, check to be sure we aren't about to create
            // a duplicate case
            if (email.ToAddresses != null && email.ToAddresses.size() > 1)
            {
                DateTime dtOneMinuteAgo = DateTime.now().addMinutes(-1);
                String suppliedEmail = email.fromAddress;
                Case[] dupeCases = [SELECT Id
                FROM Case
                WHERE Subject = :email.Subject
                AND SuppliedEMail = :suppliedEmail
                AND CreatedDate >= :dtOneMinuteAgo];

                if (dupeCases.size() > 0)
                {
                    // Found one; let's stop here
                    return result;
                }
            }

            Case recentCase = new Case();

            //Create a brand new case
            if (this.theCase == null)
            {
                if (fallbackQueueId != null)
                {
                    if (isUserActive(queueId) == false)
                    {
                        queueId = fallbackQueueId;
                    }
                }

                sendAutoReply = true;
                this.theCase = new Case();

                if (caseRecordTypeId != null)
                {
                    theCase.RecordTypeId = caseRecordTypeId;
                }

                theCase.Category__c = categoryName;
                theCase.Sub_Category__c = subCategoryName;
                theCase.Campus__c = campus;
                theCase.Functional_Group__c = functionalGroup;
                theCase.SuppliedEmail = email.fromAddress;
                theCase.SuppliedName = fname + ' ' + lname;
                theCase.Status = 'New';
                theCase.Priority = 'Normal';
                theCase.Case_Feed_Email__c = replyToAddress;
                theCase.Case_Feed_Email_Template_Id__c = caseFeedTemplateId;

                // The Queue ID should be set as long as a Cse Assignment Rule was found; just in case, adding
                // and else clause to be sure the Owner is not set to null, which would prevent the insert
                if (queueId != null)
                {
                    theCase.OwnerId = queueId;
                }
                else
                {
                    theCase.OwnerId = UserInfo.getUserId();
                }

                if (origin != null)
                {
                    theCase.Origin__c = origin;
                }
                else
                {
                    theCase.Origin__c = 'Email';
                }

                theCase.Subject = email.Subject;
                theCase.Description = email.plainTextBody;
                if(theCase.Description == null)
                {
                    theCase.Description = '';
                }

                String toAddressConcat = '';
                String ccAddressConcat = '';

                if (email.ToAddresses != null && email.ToAddresses.size() > 0)
                {
                    for (String a: email.ToAddresses)
                    {
                        toAddressConcat += (a + ',');
                    }

                    toAddressConcat = toAddressConcat.subString(0,toAddressConcat.length()-1);
                }

                if (email.CCAddresses != null && email.CCAddresses.size() > 0)
                {
                    for (String a: email.CCAddresses)
                    {
                        ccAddressConcat += (a + ',');
                    }

                    ccAddressConcat = ccAddressConcat.subString(0,ccAddressConcat.length()-1);
                }

                if (ccAddressConcat != '')
                {
                    toAddressConcat+=', ' + ccAddressConcat;
                }

                theCase.Initial_Request_Sent_To_Addresses__c = toAddressConcat;
                theCase.Type_of_Additional_Assignment_Needed__c = typeOfAdditionalAssignmentNeeded;

                if (associateCaseToActiveOpportunity == null)
                {
                    theCase.Associate_Case_to_Active_Opportunity__c = false;
                }
                else
                {
                    theCase.Associate_Case_to_Active_Opportunity__c = associateCaseToActiveOpportunity;
                }

                Contact[] contacts = [
                    SELECT Id, FirstName, LastName, Name, AccountId, Email, Last_Case_Email_Used__c
                    FROM Contact
                    WHERE Email = :email.fromAddress
                    OR ASU_Gmail__c = :email.fromAddress
                    OR EPO_Email__c = :email.fromAddress
                    OR ASU_Email__c = :email.fromAddress
                    OR Lead_Email__c = :email.fromAddress
                    OR Lead_Secondary_Email__c = :email.fromAddress
                    OR Personal_Email__c = :email.fromAddress
                    OR Preferred_Email__c = :email.fromAddress
                    OR Corporate_Relations_Email__c = :email.fromAddress
                ];

                if (contacts.size() > 1)
                {
                    Contact[] filteredContacts;

                    for (Contact c: contacts)
                    {
                        if ((c.FirstName != null && c.LastName != null) && c.FirstName.toLowerCase() == fname.toLowerCase() && c.LastName.toLowerCase() == lname.toLowerCase())
                        {
                            filteredContacts.add(c);
                        }
                    }

                    if (filteredContacts != null)
                    {
                        if (filteredContacts.size() > 0 && filteredContacts.size() < contacts.size())
                        {
                            contacts.clear();
                            contacts = filteredContacts.clone();
                        }
                    }
                }

                if (contacts.size() > 0)
                {
                    Contact theContact = contacts[0];
                    theCase.ContactId = theContact.Id;
                    theCase.AccountId = theContact.AccountId;
                    emailContact = contacts[0];

                    // How to handle multiple contacts? Addting a note to the Case description for now.
                    if (contacts.size() > 1)
                    {
                        theCase.Description = 'Note: there is more than one Contact with this email address. ' + theCase.Description;
                    }

                    // If the sender's email does not match the primary Email field for this Contact, update that field and note why
                    if (theContact.Email == null || theContact.Email != email.fromAddress)
                    {
                        theContact.Email = email.fromAddress;
                        theContact.Email_Change_Reason__c = 'Service request received';
                        theContact.Last_Case_Email_Used__c = email.fromAddress;
                        theContact.Email_Change_Date__c = Datetime.now();
                        update theContact;
                    }

                    if (theContact.Last_Case_Email_Used__c == null || theContact.Last_Case_Email_Used__c != email.fromAddress)
                    {
                        theContact.Last_Case_Email_Used__c = email.fromAddress;
                        update theContact;
                    }
                }
                else
                {
                    Id rtId;
                    List<RecordType> rtypes = [
                        SELECT Name, Id
                        FROM RecordType
                        WHERE sObjectType='Contact'
                        AND DeveloperName = 'SF_Mastered'
                        AND isActive=true
                    ];

                    if (rtypes.size() > 0)
                    {
                        rtId = rtypes[0].Id;
                    }

                    Contact c = new Contact(FirstName = fname, LastName = lname, Email = email.fromAddress, RecordTypeId=rtId);
                    insert c;

                    Contact insertedContact = [
                        SELECT Id, AccountId
                        FROM Contact
                        WHERE Id = :c.Id
                    ];
                    theCase.ContactId = insertedContact.Id;
                    theCase.AccountId = insertedContact.AccountId;
                    emailContact = insertedContact;
                }

                // Check to make sure we are not about to spawn an auto reply loop
                try
                {
                    recentCase = [
                        SELECT Id, Description, OwnerId
                        FROM Case
                        WHERE ContactId = :emailContact.Id
                        ORDER BY CreatedDate desc
                        LIMIT 1
                    ];

                    if(recentCase.Description == null)
                    {
                        recentCase.Description = '';
                    }

                    String currentCaseDescription = theCase.Description;
                    currentCaseDescription = currentCaseDescription.trim();

                    // If we catch an auto reply loop, do not create the case and discard this email
                    if (recentCase.Description.equals(currentCaseDescription) && recentCase.OwnerId == theCase.OwnerID)
                    {
                        return result;
                    }
                }
                catch (QueryException e)
                {
                }

                insert this.theCase;
            }
            else
            {
                // Grab the contact record from the existing case
                List<Contact> caseContact = [SELECT Id FROM Contact WHERE Id = :theCase.ContactId];

                if (caseContact.size() > 0)
                {
                    emailContact = caseContact[0];
                }
            }

            createEmailMessage(theCase,email);
            handleAttachments(theCase, emailContact, email);

            if (sendAutoReply && templateId != null)
            {
                sendAutoReply(theCase, emailContact, templateId);
            }
        }
        catch (Exception e)
        {
            // Catch any exceptions and create a lost email.
            String error = e.getMessage() + '\n' + e.getStackTraceString();
            generateLostEmail(email, error);
        }

        return result;
    }

    // Overload to support previous implementation
    private boolean handleAttachments(Case theCase, Contact theContact, Messaging.InboundEmail email)
    {
        boolean successfulAttachment = handleAttachments(theCase, email);

        if (!successfulAttachment)
        {
            String attachmentFailureTemplateId = getConfigurationSetting('Rejected Attachment Email Template ID');

            if (attachmentFailureTemplateId != null && attachmentFailureTemplateId != '')
            {
                sendAutoReply(theCase, theContact, attachmentFailureTemplateId);
            }
        }

        return successfulAttachment;
    }

    // Save attachments, if any
    private boolean handleAttachments(SObject parentObject, Messaging.InboundEmail email)
    {
        boolean successfulAttachment = true;
        Long attachmentSize = 0;
        Set<String> validFileExtensionSet = new Set<String>();
        String[] validFileExtensionList = getConfigurationSetting('Valid Attachment Types').split(',');

        if (validFileExtensionList.size() > 0)
        {
            for (String e: validFileExtensionList)
            {
                validFileExtensionSet.add(e);
            }
        }

        if (email.textAttachments!=null && email.textAttachments.size() >0)
        {
            for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments)
            {
                attachmentSize += tAttachment.body.length();

                if (validFileExtensionSet.isEmpty() || validFileExtensionSet.contains(tAttachment.fileName.substring(tAttachment.fileName.lastIndexOf('.')+1).toLowerCase()))
                {
                    if (tAttachment.body.length() > 5000000)
                    {
                        successfulAttachment = false;
                    }
                    else
                    {
                        Attachment attachment = new Attachment();
                        attachment.Name = tAttachment.fileName;
                        attachment.Body = Blob.valueOf(tAttachment.body);
                        attachment.ParentId = parentObject.Id;
                        insert attachment;
                    }
                }
                else if (!validFileExtensionSet.isEmpty())
                {
                    successfulAttachment = false;
                }
            }
        }

        if (email.binaryAttachments!=null && email.binaryAttachments.size() >0)
        {
            for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments)
            {
                attachmentSize += bAttachment.body.size();

                if (validFileExtensionSet.isEmpty() || validFileExtensionSet.contains(bAttachment.fileName.substring(bAttachment.fileName.lastIndexOf('.')+1).toLowerCase()))
                {
                    if (bAttachment.body.size() > 5000000)
                    {
                        successfulAttachment = false;
                    }
                    else
                    {
                        Attachment attachment = new Attachment();
                        attachment.Name = bAttachment.fileName;
                        attachment.Body = bAttachment.body;
                        attachment.ParentId = parentObject.Id;
                        insert(attachment);
                    }
                }
                else if (!validFileExtensionSet.isEmpty())
                {
                    successfulAttachment = false;
                }
            }
        }

        if (attachmentSize > 25000000)
        {
            successfulAttachment = false;
        }

        return successfulAttachment;
    }

    private String limitLength(String input, Integer maxLength)
    {
        String results;

        if (input != null && input.length() > maxLength)
        {
            results = input.substring(0,maxLength);
        }
        else
        {
            results = input;
        }

        return results;
    }

    private void createEmailMessage(Case theCase, Messaging.InboundEmail email)
    {
        String value;
        Integer maxlength;
        EmailMessage theEmail = new EmailMessage();
        theEmail.ParentId = theCase.Id;
        theEmail.Incoming = true;
        Schema.DescribeFieldResult F = EmailMessage.HtmlBody.getDescribe();
        maxlength = F.getLength();
        theEmail.Subject = limitLength(email.Subject, EmailMessage.Subject.getDescribe().getLength());
        theEmail.MessageDate = datetime.now();
        theEmail.HtmlBody = limitLength(email.htmlBody,EmailMessage.HtmlBody.getDescribe().getLength());
        theEmail.TextBody = limitLength(email.plainTextBody,EmailMessage.TextBody.getDescribe().getLength());

        /* **** To */
        if (email.toAddresses != null)
        {
            value = '';
            Boolean seenOne= false;

            for (String to : email.toAddresses)
            {
                if (seenOne)
                {
                    value += ';\n';
                }

                to  = extractAddress(to);
                value += to;
                seenOne = true;
            }
        }

        theEmail.ToAddress = limitLength(value,EmailMessage.ToAddress.getDescribe().getLength());

        /* **** From */
        theEmail.FromName = email.fromName;
        theEmail.FromAddress = email.fromAddress;

        /* **** CC */
        if (email.ccAddresses != null)
        {
            value = '';
            Boolean seenOne= false;

            for (String cc : email.ccAddresses)
            {
                if (seenOne)
                {
                    value += ';\n';
                }

                cc  = extractAddress(cc);
                value += cc;
                seenOne = true;
            }
        }

        theEmail.CcAddress = limitLength(value,EmailMessage.CcAddress.getDescribe().getLength());

        insert theEmail;
    }

    private String extractIdRefNew(String searchText)
    {
        if (searchtext==null)
        {
            return null;
        }

        String itemRef = null;
        String patternString;
        String caseId;

        if (searchText.indexOf(':ref') > searchText.indexOf('ref:'))
        {
            String caseReference = searchText.substring(searchText.indexOf('ref:') + 4, searchText.indexOf(':ref'));

            if (Test.isRunningTest())
            {
                caseId = caseReference;
            }
            else
            {
                try
                {
                    caseId = Cases.getCaseIdFromEmailThreadId(caseReference);
                }
                catch (Exception e)
                {
                    return null;
                }
            }

            return caseId;
        }
        else
        {
            return null;
        }
    }

    private String extractAddress(String inAddress)
    {
        String address;
        String patternString;
        Pattern thePattern;
        Matcher matcher;
        patternString = '.*<(.*)>.*';
        thePattern = Pattern.compile(patternString);
        matcher = thePattern.matcher(inAddress);

        if (matcher.matches())
        {
            address = matcher.group(1);
        }
        else
        {
            address = inAddress;
        }

        return address;
    }

    private Boolean filteredTermFound()
    {
        Email_To_Case_Filter__c[] filteredTerms = [
            SELECT Name, Rejection_Count__c
            FROM Email_To_Case_Filter__c
        ];

        for (Email_To_Case_Filter__c filter: filteredTerms)
        {
            String lcFilter = filter.Name.toLowerCase();

            if (filter.Rejection_Count__c == null)
            {
                filter.Rejection_Count__c = 0;
            }

            // If this filter is an email address, check the fromAddress only
            if (Pattern.matches('.+\\@.+\\..+', filter.Name))
            {
                if (inboundEmail.fromAddress.toLowerCase().contains(lcFilter))
                {
                    filter.Rejection_Count__c = filter.Rejection_Count__c + 1;
                    update filter;

                    return true;
                }
            }
            else if (inboundEmail.subject != null)
            {
                if (inboundEmail.subject.toLowerCase().contains(lcFilter))
                {
                    filter.Rejection_Count__c = filter.Rejection_Count__c + 1;
                    update filter;

                    return true;
                }
            }
        }
        return false;
    }

    private void loadConfigurationSettings()
    {
        Email_To_Case_Configuration__c[] configList = [SELECT Name, Value__c
        FROM Email_To_Case_Configuration__c];
        if (configList.size() > 0)
        {
            for (Email_To_Case_Configuration__c c: configList)
            {
                configMap.put(c.Name, c.Value__c);
            }
        }

        RecordType defaultCaseRecordType = [SELECT Id
        FROM RecordType
        WHERE SObjectType = 'Case'
        AND DeveloperName = 'ASU_Service'];

        if (defaultCaseRecordType != null)
        {
            defaultCaseRecordTypeId = defaultCaseRecordType.Id;
        }
    }

    private String getConfigurationSetting(String settingName)
    {
        if (configMap.containsKey(settingName))
        {
            return configMap.get(settingName);
        }

        return '';
    }

    private void setCaseAssignmentRule(String[] toEmailAddresses, String[] ccEmailAddresses)
    {
        Case_Assignment_Rule__c[] assignmentRuleList;

        if(toEmailAddresses.size() > 1)
        {
            assignmentRuleList = [SELECT Id, Name, Category__c, Sub_Category__c, Email_Address__c, Case_Feed_Email_Template_Id__c,Customer_Notice_Email_From_Name__c,Reply_To_Email_Address__c, Email_Template_ID__c, Functional_Group__c, Priority__c, Queue_ID__c, Case_Record_Type_ID__c, Fallback_Queue_ID__c, Type_of_Additional_Assignment_Needed__c, Associate_Case_To_Active_Opportunity__c, Origin__c, Campus__c
                                                            FROM Case_Assignment_Rule__c
                                                            WHERE Email_Address__c IN :toEmailAddresses
                                                            ORDER BY Priority__c];
        }
        else
        {
            //Try partial match
            String toEmailAddress = toEmailAddresses.get(0);
            String toEmailAddressPartial = toEmailAddress;
            if(toEmailAddressPartial.length() > 15)
            {
                toEmailAddressPartial = toEmailAddressPartial.substring(0, 15) + '%';
            }

            assignmentRuleList = [SELECT Id, Name, Category__c, Sub_Category__c, Email_Address__c, Case_Feed_Email_Template_Id__c,Customer_Notice_Email_From_Name__c,Reply_To_Email_Address__c, Email_Template_ID__c, Functional_Group__c, Priority__c, Queue_ID__c, Case_Record_Type_ID__c, Fallback_Queue_ID__c, Type_of_Additional_Assignment_Needed__c, Associate_Case_To_Active_Opportunity__c, Origin__c, Campus__c
                                                            FROM Case_Assignment_Rule__c
                                                            WHERE Email_Address__c LIKE :toEmailAddressPartial
                                                            ORDER BY Priority__c];
        }

        if (assignmentRuleList.size() > 0)
        {
            categoryName = assignmentRuleList[0].Category__c;
            subCategoryName = assignmentRuleList[0].Sub_Category__c;
            campus = assignmentRuleList[0].Campus__c;
            functionalGroup = assignmentRuleList[0].Functional_Group__c;
            origin = assignmentRuleList[0].Origin__c;
            queueId = ID.valueOf(assignmentRuleList[0].Queue_ID__c);

            if (assignmentRuleList[0].Email_Template_ID__c != null && assignmentRuleList[0].Email_Template_ID__c != '')
            {
                templateId = ID.valueOf(assignmentRuleList[0].Email_Template_ID__c);
            }

            if (assignmentRuleList[0].Case_Feed_Email_Template_Id__C != null && assignmentRuleList[0].Case_Feed_Email_Template_Id__C != '')
            {
                caseFeedTemplateId = ID.valueOf(assignmentRuleList[0].Case_Feed_Email_Template_Id__c);
            }

            if (assignmentRuleList[0].Reply_To_Email_Address__c != null && assignmentRuleList[0].Reply_To_Email_Address__c != '')
            {
                replyToAddress = assignmentRuleList[0].Reply_To_Email_Address__c;
            }
            else
            {
                replyToAddress = assignmentRuleList[0].Email_Address__c;
            }

            emailFromName = assignmentRuleList[0].Customer_Notice_Email_From_Name__c;

            if (assignmentRuleList[0].Case_Record_Type_ID__c != null)
            {
                caseRecordTypeId = ID.valueOf(assignmentRuleList[0].Case_Record_Type_ID__c);
            }

            if (assignmentRuleList[0].Fallback_Queue_ID__c != null)
            {
                fallbackQueueId = ID.valueOf(assignmentRuleList[0].Fallback_Queue_ID__c);
            }

            typeOfAdditionalAssignmentNeeded = assignmentRuleList[0].Type_of_Additional_Assignment_Needed__c;
            associateCaseToActiveOpportunity = assignmentRuleList[0].Associate_Case_to_Active_Opportunity__c;
        }
        else
        {
            assignmentRuleList = [SELECT Id, Name, Category__c, Sub_Category__c,
                Email_Address__c, Customer_Notice_Email_From_Name__c, Reply_To_Email_Address__c, Email_Template_ID__c, Case_Feed_Email_Template_Id__c,Functional_Group__c, Priority__c, Queue_ID__c, Case_Record_Type_ID__c, Fallback_Queue_ID__c, Type_of_Additional_Assignment_Needed__c, Associate_Case_To_Active_Opportunity__c, Origin__c, Campus__c
            FROM Case_Assignment_Rule__c
            WHERE Email_Address__c IN :ccEmailAddresses
            ORDER BY Priority__c];

            if (assignmentRuleList.size() > 0)
            {
                categoryName = assignmentRuleList[0].Category__c;
                subCategoryName = assignmentRuleList[0].Sub_Category__c;
                campus = assignmentRuleList[0].Campus__c;
                functionalGroup = assignmentRuleList[0].Functional_Group__c;
                origin = assignmentRuleList[0].Origin__c;
                queueId = ID.valueOf(assignmentRuleList[0].Queue_ID__c);

                if (assignmentRuleList[0].Email_Template_ID__c != null && assignmentRuleList[0].Email_Template_ID__c != '')
                {
                    templateId = ID.valueOf(assignmentRuleList[0].Email_Template_ID__c);
                }

                if (assignmentRuleList[0].Case_Feed_Email_Template_Id__C != null && assignmentRuleList[0].Case_Feed_Email_Template_Id__C != '')
                {
                    caseFeedTemplateId = ID.valueOf(assignmentRuleList[0].Case_Feed_Email_Template_Id__c);
                }

                if (assignmentRuleList[0].Reply_To_Email_Address__c != null && assignmentRuleList[0].Reply_To_Email_Address__c != '')
                {
                    replyToAddress = assignmentRuleList[0].Reply_To_Email_Address__c;
                }
                else
                {
                    replyToAddress = assignmentRuleList[0].Email_Address__c;
                }

                emailFromName = assignmentRuleList[0].Customer_Notice_Email_From_Name__c;

                if (assignmentRuleList[0].Case_Record_Type_ID__c != null){
                    caseRecordTypeId = ID.valueOf(assignmentRuleList[0].Case_Record_Type_ID__c);
                }

                if (assignmentRuleList[0].Fallback_Queue_ID__c != null){
                    fallbackQueueId = ID.valueOf(assignmentRuleList[0].Fallback_Queue_ID__c);
                }

                typeOfAdditionalAssignmentNeeded = assignmentRuleList[0].Type_of_Additional_Assignment_Needed__c;
                associateCaseToActiveOpportunity = assignmentRuleList[0].Associate_Case_to_Active_Opportunity__c;
            }
        }

        if (assignmentRuleList.size() == 0)
        {
            // Use the Default Email Address
            String defaultEmailAddress = getConfigurationSetting('Default Org Wide Email Address');
            Case_Assignment_Rule__c[] assignmentRuleListDefault;

            if (defaultEmailAddress != null && defaultEmailAddress != '')
            {
                assignmentRuleListDefault = [SELECT Id, Name, Category__c, Sub_Category__c,
                    Email_Address__c, Customer_Notice_Email_From_Name__c, Reply_To_Email_Address__c, Email_Template_ID__c, Case_Feed_Email_Template_Id__c,Functional_Group__c, Priority__c, Queue_ID__c, Case_Record_Type_ID__c, Fallback_Queue_ID__c, Type_of_Additional_Assignment_Needed__c, Associate_Case_To_Active_Opportunity__c, Origin__c, Campus__c
                FROM Case_Assignment_Rule__c
                WHERE Email_Address__c = :defaultEmailAddress];
            }

            if (assignmentRuleListDefault != null && assignmentRuleListDefault.size() > 0)
            {
                categoryName = assignmentRuleListDefault[0].Category__c;
                subCategoryName = assignmentRuleListDefault[0].Sub_Category__c;
                campus = assignmentRuleListDefault[0].Campus__c;
                functionalGroup = assignmentRuleListDefault[0].Functional_Group__c;
                origin = assignmentRuleListDefault[0].Origin__c;
                queueId = ID.valueOf(assignmentRuleListDefault[0].Queue_ID__c);

                if (assignmentRuleListDefault[0].Email_Template_ID__c != null && assignmentRuleListDefault[0].Email_Template_ID__c != '')
                {
                    templateId = ID.valueOf(assignmentRuleListDefault[0].Email_Template_ID__c);
                }

                if (assignmentRuleListDefault[0].Case_Feed_Email_Template_Id__C != null && assignmentRuleListDefault[0].Case_Feed_Email_Template_Id__C != '')
                {
                    caseFeedTemplateId = ID.valueOf(assignmentRuleListDefault[0].Case_Feed_Email_Template_Id__c);
                }

                if (assignmentRuleListDefault[0].Reply_To_Email_Address__c != null && assignmentRuleListDefault[0].Reply_To_Email_Address__c != '')
                {
                    replyToAddress = assignmentRuleListDefault[0].Reply_To_Email_Address__c;
                }
                else
                {
                    replyToAddress = assignmentRuleListDefault[0].Email_Address__c;
                }

                emailFromName = assignmentRuleListDefault[0].Customer_Notice_Email_From_Name__c;

                if (assignmentRuleListDefault[0].Case_Record_Type_ID__c != null)
                {
                    caseRecordTypeId = ID.valueOf(assignmentRuleListDefault[0].Case_Record_Type_ID__c);
                }

                if (assignmentRuleListDefault[0].Fallback_Queue_ID__c != null)
                {
                    fallbackQueueId = ID.valueOf(assignmentRuleListDefault[0].Fallback_Queue_ID__c);
                }

                typeOfAdditionalAssignmentNeeded = assignmentRuleListDefault[0].Type_of_Additional_Assignment_Needed__c;
                associateCaseToActiveOpportunity = assignmentRuleListDefault[0].Associate_Case_to_Active_Opportunity__c;
            }
        }
    }

    public LostEmail__c logDebugLostEmail(Id contactId, List<String> validFileExtensionList, Long attachmentSize, List<String> fileNames, List<Long> fileSizes, List<String> erroredFiles, List<String> erroredReasons)
    {
        LostEmail__c le = new LostEmail__c();
        le.Subject__c = 'Debug Log for Case Inbound Email Handler: ' + contactId + ' ' + DateTime.now();

        String body = 'Case ID: ' + contactId + '\n';
        body += 'Valid File Extensions: ' + validFileExtensionList + '\n';
        body += 'Attachment Size: ' + attachmentSize + '\n';
        body += 'File Names: ' + fileNames + '\n';
        body += 'File Sizes: ' + fileSizes + '\n';
        body += 'Errored Files: ' + erroredFiles + '\n';
        body += 'Errored Reasons: ' + erroredReasons + '\n';
        le.PlainTextBody__c = body;

        insert le;
        return le;
    }

    private void sendAutoReply(Case emailCase, Contact emailContact, String emailTemplateId)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(emailContact.Id);
        mail.setTemplateId(emailTemplateId);

        if (emailCase != null)
        {
            mail.setWhatId(emailCase.Id);
        }

        OrgWideEmailAddress oweaToUse = new OrgWideEmailAddress();
        OrgWideEmailAddress defaultOwea = getDefaultOrgWideEmailAddress();
        Boolean noOweaFound = false;

        // Find the appropriate OrgWideEmailAddress for this reply
        try
        {
            oweaToUse = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :replyToAddress];
            System.debug('!!!FINE: Using ' + oweaToUse + ' as OrgWideEmailAddress');
            mail.setOrgWideEmailAddressId(oweaToUse.Id);
        }
        catch (Exception e)
        {
            System.debug('!!!ERROR: Query for OrgWideEmailAddress failed when using ' + replyToAddress + '.\n' + e.getMessage());

            // Use context user's information if there is no default OrgWideEmailAddress configured
            if (defaultOwea == null)
            {
                mail.setSenderDisplayName(emailFromName);
                System.debug('!!!ERROR: No default OrgWideAddress configured. Using context user\'s email information instead.');
            }
            else
            {
                mail.setOrgWideEmailAddressId(defaultOwea.Id);
                System.debug('!!!WARN: Using default OrgWideEmailAddress ' + defaultOwea);
            }
        }

        //Send the email
        try
        {
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch (Exception e)
        {
            //Most likely SINGLE_EMAIL_LIMIT_EXCEEDED; catching so the transaction will continue
        }
    }

    private OrgWideEmailAddress getDefaultOrgWideEmailAddress()
    {
        OrgWideEmailAddress oweaLookup;
        String orgWideEmailAddress = getConfigurationSetting('Default Org Wide Email Address');

        if (orgWideEmailAddress != null && orgWideEmailAddress != '')
        {

            List<OrgWideEmailAddress> oweaList = [SELECT Id, DisplayName, Address
            FROM OrgWideEmailAddress
            WHERE Address = :orgWideEmailAddress];
            if (oweaList.size() > 0)
            {
                oweaLookup = oweaList[0];
            }
        }

        return oweaLookup;
    }

    private boolean isUserActive(String userId)
    {
        List<User> userList = [SELECT Id, IsActive
        FROM User
        WHERE Id = :userId];
        if (userList.size() > 0)
        {
            if (userList[0].IsActive)
            {
                return true;
            }
        }

        return false;
    }

    // Make this public for unit test access
    public LostEmail__C generateLostEmail(Messaging.InboundEmail email, String error)
    {
        loadConfigurationSettings();

        LostEmail__c lostEmail = new LostEmail__c();
        insert lostEmail;

        // Set the fields
        lostEmail.Sender__c = email.fromAddress;
        lostEmail.Subject__c = email.subject;
        lostEmail.PlainTextBody__c = email.plainTextBody;
        lostEmail.HtmlTextBody__c = email.htmlBody;
        lostEmail.Cause__c = error;

        // Convert the List into a concatenated string
        String recipientsString = '';
        if (email.toAddresses != null)
        {
            for (String s : email.toAddresses)
            {
                recipientsString += s + ', ';
            }

            recipientsString = recipientsString.substring(0, recipientsString.length()-2);
        }
        lostEmail.Recipient__c = recipientsString;

        String carbonCopiesString = '';
        if (email.ccAddresses != null)
        {
            for (String s : email.ccAddresses)
            {
                carbonCopiesString += s + ', ';
            }

            carbonCopiesString= carbonCopiesString.substring(0, carbonCopiesString.length()-2);
        }
        lostEmail.CarbonCopies__c = carbonCopiesString;

        Boolean attachSuccess = handleAttachments(lostEmail, email);

        lostEmail.RejectedAttachments__c = !attachSuccess;

        update lostEmail;

        return lostEmail;
    }
}