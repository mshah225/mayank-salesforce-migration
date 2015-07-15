global class CaseInboundEmailHandler implements Messaging.InboundEmailHandler 
{
    private Static Boolean TRACE = true;

    private Map<String, String> configMap = new Map<String, String>();
    private Id queueId;
    private Id templateId;
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
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        result.success = true;
        this.inboundEmail = email;
        Boolean sendAutoReply = false;
        Contact emailContact = new Contact();

        // Load the configuration info from Custom Settings
        loadConfigurationSettings();

        // Retrieves the sender's first and last names
        String fName = '';
        String lName = '';
        System.debug('GRF fromname: ' + email.fromname);
        System.debug('GRF fromaddress: ' + email.fromaddress);

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

        System.debug('GRF plainTextBody: ' + email.plaintextBody);
        System.debug('GRF htmlBody: ' + email.htmlBody);
        System.debug('GRF subject: ' + email.subject);

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

            Case[] caseSearch = [SELECT Id, ContactId, Subject, Description, Status, ClosedDate
                                FROM Case
                                WHERE Id = :caseId];

            if (caseSearch.size() > 0) 
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

                Boolean caseCanBeReopened = iReopenClosedCaseThreshold != 0 && caseSearch[0].Status.startsWith('Closed') && caseSearch[0].ClosedDate != null && caseSearch[0].ClosedDate > DateTime.Now().addDays(iReopenClosedCaseThreshold);
                Boolean caseStatusIsNotNull = caseSearch[0].Status != null;
                Boolean caseStatusIsNotClosed = !caseSearch[0].Status.startsWith('Closed');

                // If the case was closed within the last n days set in custom settings, re-open it.  Otherwise, create a new case below
                if (caseStatusIsNotNull && (caseStatusIsNotClosed || caseCanBeReopened))
                {
                    this.theCase = caseSearch[0];

                    if (this.theCase.Status.startsWith('Closed'))
                    {
                        this.theCase.Status = 'Re-Opened';
                        updateSObject(this.theCase);
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

            System.debug('GRF theCase.OwnerId: ' + theCase.OwnerId);
            
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
            String toAddressConcat = '';
            String ccAddressConcat = '';

            if (email.ToAddresses != null && email.ToAddresses.size() > 0)
            {
                for (String a: email.ToAddresses)
                {
                    System.debug('GRF toaddresses size: ' + email.ToAddresses.size());
                    System.debug('GRF address: ' + a);
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

            System.debug('GRF replyTo: ' + email.replyTo);

            Contact[] contacts = [SELECT Id, FirstName, LastName, Name, AccountId, Email, Last_Case_Email_Used__c
                                    FROM Contact
                                    WHERE Email = :email.fromAddress
                                    OR ASU_Gmail__c = :email.fromAddress
                                    OR EPO_Email__c = :email.fromAddress
                                    OR ASU_Email__c = :email.fromAddress
                                    OR Lead_Email__c = :email.fromAddress
                                    OR Lead_Secondary_Email__c = :email.fromAddress
                                    OR Personal_Email__c = :email.fromAddress
                                    OR Preferred_Email__c = :email.fromAddress
                                    OR Corporate_Relations_Email__c = :email.fromAddress];

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
                    updateSObject(theContact);
                }

                if (theContact.Last_Case_Email_Used__c == null || theContact.Last_Case_Email_Used__c != email.fromAddress) 
                {
                    System.debug('GRF Last Case Email: ' + theContact.Last_Case_Email_Used__c + ':' + email.fromAddress);
                    theContact.Last_Case_Email_Used__c = email.fromAddress;
                    updateSObject(theContact);
                }
            }
            else 
            {
                Id rtId;
                List<RecordType> rtypes = [SELECT Name, Id
                                            FROM RecordType
                                            WHERE sObjectType='Contact'
                                            AND DeveloperName = 'SF_Mastered'
                                            AND isActive=true];
                
                if (rtypes.size() > 0)
                {
                    rtId = rtypes[0].Id;
                }

                Contact c = new Contact(FirstName = fname, LastName = lname, Email = email.fromAddress, RecordTypeId=rtId);
                insertSObject(c);

                Contact insertedContact = [SELECT Id, AccountId
                                            FROM Contact
                                            WHERE Id = :c.Id];
                theCase.ContactId = insertedContact.Id;
                theCase.AccountId = insertedContact.AccountId;
                emailContact = insertedContact;
            }

            // Check to make sure we are not about to spawn an auto reply loop
            try
            {
                recentCase = [SELECT Id, Description, OwnerId
                                FROM Case
                                WHERE ContactId = :emailContact.Id
                                ORDER BY CreatedDate desc
                                LIMIT 1];

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
                System.debug('This is the contact\'s initial case.');
            } 
            catch (Exception e)
            {
                System.debug('An error has occurred while trying to prevent an auto-reply loop from forming:\n ' + e.getStackTraceString());
            }

            insertSObject(this.theCase);    
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
        System.debug('GRF template: ' + templateId);
        
        if (sendAutoReply && templateId != null) 
        {
            sendAutoReply(theCase, emailContact, templateId);
        }
        
        return result;
    }

    // Save attachments, if any
    private void handleAttachments(Case theCase, Contact theContact, Messaging.InboundEmail email) 
    {
        Boolean bAttachmentError = false;
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
                        bAttachmentError = true;
                    }
                    else 
                    {
                        Attachment attachment = new Attachment();
                        attachment.Name = tAttachment.fileName;
                        attachment.Body = Blob.valueOf(tAttachment.body);
                        attachment.ParentId = theCase.Id;
                        insertSObject(attachment);
                    }
                }
                else if (!validFileExtensionSet.isEmpty()) 
                {
                    bAttachmentError = true;
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
                    System.debug('GRF attachment size: ' + bAttachment.body.size());
                    
                    if (bAttachment.body.size() > 5000000) 
                    {
                        bAttachmentError = true;
                        System.debug('GRF Attachment too big: ' + battachment.body.size());
                    }
                    else 
                    {
                        Attachment attachment = new Attachment();
                        attachment.Name = bAttachment.fileName;
                        attachment.Body = bAttachment.body;
                        attachment.ParentId = theCase.Id;
                        insertSObject(attachment);
                    }
            }
            else if (!validFileExtensionSet.isEmpty()) 
            {
                bAttachmentError = true;
            }
            }
        }

        if (attachmentSize > 25000000)
    { 
            bAttachmentError = true;
        }

        if (bAttachmentError) 
    {
            String attachmentFailureTemplateId = getConfigurationSetting('Rejected Attachment Email Template ID');

            if (attachmentFailureTemplateId != null && attachmentFailureTemplateId != '')
        {
                sendAutoReply(theCase, theContact, attachmentFailureTemplateId);
            }
        }
    }

    private void insertSObject(sObject obj) 
    {
        try 
        {
            insert obj;
        } 
        catch (System.DmlException e) 
        {
            handleError(e, 'Could not insert record '+ obj);
        }
    }

    private void updateSObject(sObject obj) 
    {
        try 
        {
            update obj;
        }
        catch (System.DmlException e) 
        {
            handleError(e, 'Could not update record '+ obj);
        }
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
                System.debug('ToAddress: ' + to);
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
                System.debug('CcAddress: ' + cc);
                value += cc;
                seenOne = true;
            }
        }

        theEmail.CcAddress = limitLength(value,EmailMessage.CcAddress.getDescribe().getLength());

        insertSObject(theEmail);
    }

    private void handleError(System.DmlException e,  String message)
    {
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
        String caseURL;
        String msg = message + '\n';

        if (TRACE)
        {
            System.debug(baseURL);
        }

        if (this.theCase != null) 
        {
            caseURL = baseURL + theCase.Id;
            msg += '\n';
            msg += 'Originating Case Number: ' + theCase.CaseNumber + '  '+ caseURL+'\n';
        }

        if (this.inboundEmail != null) 
        {
            String toAddressConcat = '';
            String ccAddressConcat = '';
            
            if (this.inboundEmail.ToAddresses != null && this.inboundEmail.ToAddresses.size() > 0) 
            {
                for (string a: this.inboundEmail.ToAddresses) 
                {
                    toAddressConcat += (a + ',');
                }

                toAddressConcat = toAddressConcat.subString(0,toAddressConcat.length()-1);
            }

            if (this.inboundEmail.CCAddresses != null && this.inboundEmail.CCAddresses.size() > 0) 
            {
                for (string a: this.inboundEmail.CCAddresses) 
                {
                    ccAddressConcat += (a + ',');
                }

                ccAddressConcat = ccAddressConcat.subString(0,ccAddressConcat.length()-1);
            }

            msg += '\nEmail:';
            msg += '  Subject: ' + inboundEmail.Subject + '\n';
            msg += '  To: ' + toAddressConcat + '\n';
            msg += '  Cc: ' + ccAddressConcat + '\n';
            msg += '  From: ' + inboundEmail.FromName + '\n';
            msg += '  Address: ' + inboundEmail.FromAddress + '\n';
        }

        // compose the DmlException message on one line to minimize the number of untested lines.  AFAIK easy to instantiate a DmlException in a unit test.
        if (e != null) 
        { 
            msg += '\n';
            msg += 'EXCEPTION:\n  Error: ' + e.getMessage() + '\n  Type: ' +
            e.getTypeName() + '\n  Line Number: ' + e.getLineNumber() + '\n  Trace:\n' +
            e.getStackTraceString() + '\n(end stack trace)\n';
        }

        Case errCase = new Case();
        errCase.OwnerId = UserInfo.getUserId();
        errCase.Status = 'New';
        errCase.Priority = 'Normal';
        errCase.Origin = 'Email';
        errCase.Subject = 'Error processing incoming email';
        errCase.Description = limitLength(msg,Case.Description.getDescribe().getLength());
        insert errCase;
        
        errCase = [SELECT Id, CaseNumber
                    FROM Case
                    WHERE Id = :errCase.Id
                    LIMIT 1];

        caseURL = baseURL + errCase.Id;
        msg += '\n\n';
        msg += 'Created new Case number ' + errCase.CaseNumber + ' for this error.  See: ' + caseURL +'\n';
    }

    private String extractIdRefNew(String searchText)
    {
        if (searchtext==null)
        {
            return null;
        }

        String itemRef = null;
        String patternString;

        if (searchText.indexOf(':ref') > searchText.indexOf('ref:')) 
        {
            String caseReference = searchText.substring(searchText.indexOf('ref:') + 4, searchText.indexOf(':ref'));
            String caseId = Cases.getCaseIdFromEmailThreadId(caseReference);
            System.debug('GRF caseId extracted: ' + caseId);

            return caseId;
        }
        else 
        {
            System.debug('GRF no caseId extracted from ' + searchText);

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
            System.debug('Extracted address ' + address);
        }
        else
        {
            address = inAddress;
            System.debug('Did not match angle-address ' + address);
        }

        return address;
    }

    private Boolean filteredTermFound() 
    {
        Email_To_Case_Filter__c[] filteredTerms = [SELECT Name, Rejection_Count__c 
                                                    FROM Email_To_Case_Filter__c];

        for (Email_To_Case_Filter__c filter: filteredTerms) 
        {
            String lcFilter = filter.Name.toLowerCase();

            if (filter.Rejection_Count__c == null)
            {
                filter.Rejection_Count__c = 0;
            }

            System.debug('grf1 email address filter: ' + lcFilter);
            System.debug('grf2: fromAddress: ' + inboundEmail.fromAddress);
            System.debug('grf2.5: subject: ' + inboundEmail.subject);

            // If this filter is an email address, check the fromAddress only
            if (Pattern.matches('.+\\@.+\\..+', filter.Name))
            {
                System.debug('grf: email regex matched');

                if (inboundEmail.fromAddress.toLowerCase().contains(lcFilter)) 
                {
                    System.debug('grf3 email address filter: ' + lcFilter);
                    System.debug('grf4: fromAddress: ' + inboundEmail.fromAddress);
                    filter.Rejection_Count__c = filter.Rejection_Count__c + 1;
                    update filter;

                    return true;
                }
            }
            else if (inboundEmail.subject.toLowerCase().contains(lcFilter))
            {
                System.debug('grf5 non-email filter: ' + lcFilter);
                System.debug('grf4: subject: ' + inboundEmail.subject);
                filter.Rejection_Count__c = filter.Rejection_Count__c + 1;
                update filter;

                return true;
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
        Case_Assignment_Rule__c[] assignmentRuleList = [SELECT Id, Name, Category__c, Sub_Category__c, Email_Address__c, Customer_Notice_Email_From_Name__c,Reply_To_Email_Address__c, Email_Template_ID__c, Functional_Group__c, Priority__c, Queue_ID__c, Case_Record_Type_ID__c, Fallback_Queue_ID__c, Type_of_Additional_Assignment_Needed__c, Associate_Case_To_Active_Opportunity__c, Origin__c, Campus__c
                                                        FROM Case_Assignment_Rule__c
                                                        WHERE Email_Address__c IN :toEmailAddresses
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

            System.debug('GRF queueID: ' + queueId);
            System.debug('GRF CAR__c: ' + assignmentRuleList[0]);
        }
        else 
        {
            assignmentRuleList = [SELECT Id, Name, Category__c, Sub_Category__c,
            Email_Address__c, Customer_Notice_Email_From_Name__c, Reply_To_Email_Address__c, Email_Template_ID__c, Functional_Group__c, Priority__c, Queue_ID__c, Case_Record_Type_ID__c, Fallback_Queue_ID__c, Type_of_Additional_Assignment_Needed__c, Associate_Case_To_Active_Opportunity__c, Origin__c, Campus__c
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

                System.debug('GRF queueID: ' + queueId);
                System.debug('GRF CAR__c: ' + assignmentRuleList[0]);
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
                Email_Address__c, Customer_Notice_Email_From_Name__c, Reply_To_Email_Address__c, Email_Template_ID__c, Functional_Group__c, Priority__c, Queue_ID__c, Case_Record_Type_ID__c, Fallback_Queue_ID__c, Type_of_Additional_Assignment_Needed__c, Associate_Case_To_Active_Opportunity__c, Origin__c, Campus__c
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

                System.debug('GRF queueID: ' + queueId);
                System.debug('GRF CAR__c: ' + assignmentRuleListDefault[0]);
            }
        }

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
        System.debug('GRF owea:' + orgWideEmailAddress);

        if (orgWideEmailAddress != null && orgWideEmailAddress != '') 
        {

            List<OrgWideEmailAddress> oweaList = [SELECT Id, DisplayName, Address 
                                                    FROM OrgWideEmailAddress 
                                                    WHERE Address = :orgWideEmailAddress];
            System.debug('GRF owea list:' + oweaList);

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
}