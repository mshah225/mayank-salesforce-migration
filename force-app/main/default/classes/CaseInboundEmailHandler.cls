global class CaseInboundEmailHandler implements Messaging.InboundEmailHandler {
    private Map<String, String> configMap = new Map<String, String>();
    private Email_Logging__c loggingSettings = Email_Logging__c.getValues('Current_Settings');
    protected Case theCase = null;
    protected Messaging.InboundEmail inboundEmail;
    
    public CaseInboundEmailHandler() {
        // Load the configuration info from Custom Settings
        loadConfigurationSettings();
    }
    
    global Messaging.InboundEmailResult handleInboundEmail(
        Messaging.InboundEmail email,
        Messaging.InboundEnvelope env
    ) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        result.success = true;
        this.inboundEmail = email;
        Boolean sendAutoReply = false;
        Contact emailContact = new Contact();
        CaseAssignmentResult caseAssignmentInfo;
        
        try {
            // Retrieves the sender's first and last names
            String fName = '';
            String lName = '';
            
            if (email.fromname != null && email.fromname != '') {
                if (email.fromname.indexof(' ') == -1) {
                    fName = '';
                    lName = email.fromname;
                } else {
                    fName = email.fromname.substring(0, email.fromname.indexOf(' '));
                    lName = email.fromname.substring(email.fromname.indexOf(' '));
                }
            } else {
                fname = email.fromAddress;
                lname = email.fromAddress;
            }
            
            // If the parsed first name ends with a comma, assume it's actually the last name and swap them, sans comma
            if (fname.endsWith(',')) {
                String newLname = fname.substring(0, fname.length() - 1);
                fName = lName;
                lName = newLname;
            }
            
            // Trim spaces from name
            fName = fName.trim();
            lName = lName.trim();
            
            // Check the inbound email for filtered terms; if found, no do nothing
            String filteredTerm = filteredTermFound();
            if (filteredTerm != null) {
                if (loggingSettings.Spam_Logging__c) {
                    generateLostEmail(email, null, 'Filtered Term: ' + filteredTerm);
                }
                return result;
            }
            
            String caseId = extractIdRefNew(email.plainTextBody);
            
            if (caseId == null) {
                caseId = extractIdRefNew(email.htmlBody);
            }
            
            if (caseId == null) {
                caseId = extractIdRefNew(email.subject);
            }
            
            if (caseId == null && email.Headers != null) {
                caseId = Cases.getCaseIdFromEmailHeaders(email.Headers);
            }
            
            if (caseId != null) {
                Case caseSearch = (Case) ObjectService.queryAllFields('Case', caseId);
                
                if (caseSearch != null) {
                    Integer iReopenClosedCaseThreshold;
                    String reopenClosedCaseThreshold = getConfigurationSetting('Reopen Closed Case Threshold');
                    
                    if (reopenClosedCaseThreshold != null && Integer.valueOf(reopenClosedCaseThreshold) > 0) {
                        iReopenClosedCaseThreshold = Integer.valueOf(reopenClosedCaseThreshold) * -1;
                    } else {
                        iReopenClosedCaseThreshold = 0;
                    }
                    
                    Boolean caseCanBeReopened =
                        iReopenClosedCaseThreshold != 0 &&
                        caseSearch.Status.startsWith('Closed') &&
                        caseSearch.ClosedDate != null &&
                        caseSearch.ClosedDate > DateTime.Now().addDays(iReopenClosedCaseThreshold);
                    Boolean caseStatusIsNotNull = caseSearch.Status != null;
                    Boolean caseStatusIsNotClosed = !caseSearch.Status.startsWith('Closed');
                    
                    // If the case was closed within the last n days set in custom settings, re-open it.  Otherwise, create a new case below
                    if (caseStatusIsNotNull && (caseStatusIsNotClosed || caseCanBeReopened)) {
                        this.theCase = caseSearch;
                        
                        Id serviceRecordType = RecordIDHelper.getRecordTypeId('Case', 'ASU_Service');
                        
                        // Assign service cases back to the most recently associated Queue
                        if (this.theCase.RecordTypeId == serviceRecordType) {
                            String groupName = this.theCase.Most_Recent_Queue__c;
                            Group groupToReopen;
                            
                            // Case will reopen to the currently associated user if no group can be found
                            try {
                                this.theCase.OwnerId = GroupService.getGroupDetails(groupName).Id;
                            } catch (Exception e) {
                                List<String> vars = new List<String>();
                                vars.add(ErrorLogger.convertSObjectToJSON('case', theCase));
                                
                                if (groupName != null) {
                                    vars.add(
                                        ErrorLogger.convertStringToJSON(
                                            'error',
                                            'Could not assign group as case owner: ' + groupName
                                        )
                                    );
                                } else {
                                    vars.add(
                                        ErrorLogger.convertStringToJSON(
                                            'error',
                                            'Could not assign null group as case owner'
                                        )
                                    );
                                }
                                ErrorLogger.log(e, vars, false);
                            }
                            
                            if (this.theCase.CC_Most_Recent_Functional_Group__c == null) {
                                // Handle NPE on Most_Recent_Functional_Group__c
                                this.theCase.CC_Most_Recent_Functional_Group__c = this.theCase.CC_Functional_Group__c;
                            } else if (
                                this.theCase.CC_Functional_Group__c ==
                                [
                                    SELECT Id
                                    FROM Case_Classification__c
                                    WHERE
                                    RecordType.Name = 'Functional Group'
                                    AND Active__c = TRUE
                                    AND Name = 'External Unit'
                                    LIMIT 1
                                ]
                                .Id
                            ) {
                                this.theCase.CC_Functional_Group__c = this.theCase.CC_Most_Recent_Functional_Group__c;
                            }
                        }
                        
                        // Get a list of closed cases that we want to re-open
                        List<Case> closedCases = [SELECT Id, IsClosed FROM Case WHERE Id = :theCase.Id];
                        
                        if (closedCases[0].IsClosed) {
                            this.theCase.Status = 'Re-Opened';
                            update this.theCase;
                        }
                    }
                }
            }
            
            List<String> toAddressList = new List<String>();
            List<String> ccAddressList = new List<String>();
            
            if (email.ToAddresses != null) {
                toAddressList = email.ToAddresses;
            }
            
            if (email.CCAddresses != null) {
                ccAddressList = email.CcAddresses;
            }
            
            caseAssignmentInfo = getCaseAssignmentRule(toAddressList, ccAddressList);
            
            // If this email was sent to multiple addresses, check to be sure we aren't about to create
            // a duplicate case
            if (email.ToAddresses != null && email.ToAddresses.size() > 1) {
                DateTime dtOneMinuteAgo = DateTime.now().addMinutes(-1);
                String suppliedEmail = email.fromAddress;
                Case[] dupeCases = [
                    SELECT Id
                    FROM Case
                    WHERE Subject = :email.Subject AND SuppliedEMail = :suppliedEmail AND CreatedDate >= :dtOneMinuteAgo
                ];
                
                if (dupeCases.size() > 0) {
                    // Found one; let's stop here
                    return result;
                }
            }
            
            Case recentCase = new Case();
            
            //Create a brand new case
            if (this.theCase == null) {
                if (caseAssignmentInfo.fallbackQueueId != null) {
                    if (isUserActive(caseAssignmentInfo.queueId) == false) {
                        caseAssignmentInfo.queueId = caseAssignmentInfo.fallbackQueueId;
                    }
                }
                
                sendAutoReply = true;
                this.theCase = new Case();
                
                if (caseAssignmentInfo.caseRecordTypeId != null) {
                    theCase.RecordTypeId = caseAssignmentInfo.caseRecordTypeId;
                }
                
                theCase.CC_Functional_Group__c = caseAssignmentInfo.functionalGroupCC;
                theCase.CC_Category__c = caseAssignmentInfo.categoryNameCC;
                theCase.CC_Sub_Category__c = caseAssignmentInfo.subCategoryNameCC;
                
                theCase.Campus__c = caseAssignmentInfo.campus;
                theCase.SuppliedEmail = email.fromAddress;
                theCase.SuppliedName = fname + ' ' + lname;
                if (theCase.SuppliedName.length() > 80) {
                    theCase.SuppliedName = theCase.SuppliedName.subString(0, 80);
                }
                
                theCase.Status = 'New';
                theCase.Priority = 'Normal';
                theCase.Case_Feed_Email__c = caseAssignmentInfo.replyToAddress;
                theCase.Case_Feed_Email_Template_Id__c = caseAssignmentInfo.caseFeedTemplateId;
                
                if (email.headers != null) {
                    extractSourceFromHeaders(email);
                }
                
                // The Queue ID should be set as long as a Cse Assignment Rule was found; just in case, adding
                // and else clause to be sure the Owner is not set to null, which would prevent the insert
                if (caseAssignmentInfo.queueId != null) {
                    theCase.OwnerId = caseAssignmentInfo.queueId;
                } else {
                    theCase.OwnerId = UserInfo.getUserId();
                }
                
                if (caseAssignmentInfo.origin != null) {
                    theCase.Origin__c = caseAssignmentInfo.origin;
                } else {
                    theCase.Origin__c = 'Email';
                }
                
                theCase.Subject = limitLength(email.Subject, 255);
                theCase.Description = '';
                theCase.Inbound_Email_Checksum__c = generateChecksum(
                    (String.isNotBlank(email.plainTextBody)
                     ? email.plainTextBody
                     : String.isNotBlank(email.htmlBody) ? email.htmlBody : '') + theCase.Subject
                );
                
                if (email.plainTextBody != null) {
                    theCase.Description = limitLength(email.plainTextBody, 31500);
                } else if (email.htmlBody != null) {
                    theCase.Description =
                        'Note: This description was reformatted from the original email body. Please view the case feed to see the original email body.\n\n' +
                        limitLength(email.htmlBody.replaceAll('<[^>]+>', ''), 31500);
                }
                
                String toAddressConcat = '';
                String ccAddressConcat = '';
                
                if (email.ToAddresses != null && email.ToAddresses.size() > 0) {
                    toAddressConcat = String.join(email.ToAddresses, ',');
                }
                
                if (email.CCAddresses != null && email.CCAddresses.size() > 0) {
                    ccAddressConcat = String.join(email.CCAddresses, ',');
                }
                
                if (ccAddressConcat != '') {
                    toAddressConcat += ', ' + ccAddressConcat;
                }
                
                theCase.Initial_Request_Sent_To_Addresses__c = toAddressConcat;
                theCase.Type_of_Additional_Assignment_Needed__c = caseAssignmentInfo.typeOfAdditionalAssignmentNeeded;
                
                if (caseAssignmentInfo.associateCaseToActiveOpportunity == null) {
                    theCase.Associate_Case_to_Active_Opportunity__c = false;
                } else {
                    theCase.Associate_Case_to_Active_Opportunity__c = caseAssignmentInfo.associateCaseToActiveOpportunity;
                }
                
                EmailTransformer transformer = new EmailTransformer();
                String cleanFromAddress = transformer.cleanEmailAddress(email.fromAddress);
                Contact[] contacts = [
                    SELECT
                    Id,
                    FirstName,
                    LastName,
                    Name,
                    AccountId,
                    Email,
                    Last_Case_Email_Used__c,
                    Preferred_First_Name__c,
                    Preferred_Full_Name__c
                    FROM Contact
                    WHERE
                    Email = :cleanFromAddress
                    OR ASU_Gmail__c = :cleanFromAddress
                    OR EPO_Email__c = :cleanFromAddress
                    OR ASU_Email__c = :cleanFromAddress
                    OR Lead_Email__c = :cleanFromAddress
                    OR Lead_Secondary_Email__c = :cleanFromAddress
                    OR Personal_Email__c = :cleanFromAddress
                    OR Corporate_Relations_Email__c = :cleanFromAddress
                    ORDER BY RecordType.Name
                ];
                
                // Multiple matches - require further filtering using name
                if (contacts.size() > 1) {
                    theCase.Description =
                        'Note: there is more than one Contact with this email address. ' + theCase.Description;
                    
                    List<Contact> filteredContacts = new List<Contact>();
                    
                    // If there are no contacts that also match on first name and last name
                    // then we will need to make a new Contact
                    for (Contact c : contacts) {
                        /**
* If both:
*  1. First name of contact and fname from email are either:
*     a. both are null/empty string (String.isEmpty)
*     b. both the same (case insenstive)
*  2. Lase name of contact and lname from email are either:
*     a. both are null/empty string (String.isEmpty)
*     b. both the same (case insenstive)
*/
                        
                        Boolean matchFirstName = false;
                        Boolean matchLastName = false;
                        
                        if (String.isEmpty(c.FirstName)) {
                            // First name is null/empty string
                            // so fname should be too
                            matchFirstName = String.isEmpty(fname);
                        } else {
                            // First name is set - so fname should match
                            matchFirstName = c.FirstName.equalsIgnoreCase(fname);
                        }
                        
                        if (String.isEmpty(c.LastName)) {
                            // Last name is null/empty string
                            // so lname should be too
                            matchLastName = String.isEmpty(lname);
                        } else {
                            // Last name is set - so lname should match
                            matchLastName = c.LastName.equalsIgnoreCase(lname);
                        }
                        
                        if (matchFirstName && matchLastName)
                            // Then this contact ahould be used
                            filteredContacts.add(c);
                    }
                    
                    contacts.clear();
                    contacts.addAll(filteredContacts);
                }
                
                if (contacts.size() > 0) {
                    Contact theContact = contacts[0];
                    theCase.ContactId = theContact.Id;
                    theCase.AccountId = theContact.AccountId;
                    emailContact = contacts[0];
                    
                    // If the sender's email does not match the primary Email field for this Contact, update that field and note why
                    if (theContact.Email == null || theContact.Email != cleanFromAddress) {
                        theContact.Email = cleanFromAddress;
                        theContact.Email_Change_Reason__c = 'Service request received';
                        theContact.Last_Case_Email_Used__c = cleanFromAddress;
                        theContact.Email_Change_Date__c = Datetime.now();
                        update theContact;
                    }
                    if (
                        theContact.Last_Case_Email_Used__c == null ||
                        theContact.Last_Case_Email_Used__c != cleanFromAddress
                    ) {
                        theContact.Last_Case_Email_Used__c = cleanFromAddress;
                        update theContact;
                    }
                } else {
                    Id rtId = RecordIDHelper.getRecordTypeId('Contact', 'SF_Mastered');
                    
                    if (fname.length() > 40) {
                        fname = fname.subString(0, 40);
                    }
                    
                    if (lname.length() > 80) {
                        lname = lname.subString(0, 80);
                    }
                    
                    Contact c = new Contact(
                        FirstName = fname,
                        LastName = lname,
                        Email = cleanFromAddress,
                        RecordTypeId = rtId
                    );
                    insert c;
                    
                    Contact insertedContact = [
                        SELECT
                        Id,
                        AccountId,
                        FirstName,
                        LastName,
                        Email,
                        RecordTypeId,
                        Last_Case_Email_Used__c,
                        Preferred_First_Name__c,
                        Preferred_Full_Name__c
                        FROM Contact
                        WHERE Id = :c.Id
                    ];
                    theCase.ContactId = insertedContact.Id;
                    theCase.AccountId = insertedContact.AccountId;
                    emailContact = insertedContact;
                }
                
                // Set the case subject before trying to find a recent case in case there is an exception
                if (this.theCase.Subject == null || this.theCase.Subject.deleteWhitespace() == '') {
                    this.theCase.Subject = 'Email Received From: ' + email.fromAddress.trim();
                }
                
                for (Case recentCaseFromEmail : [
                    SELECT Id, Description, Subject, OwnerId, Inbound_Email_Checksum__c
                    FROM Case
                    WHERE ContactId = :emailContact.Id
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ]) {
                    recentCase = recentCaseFromEmail;
                    if (recentCase.Description == null) {
                        recentCase.Description = '';
                    }
                    
                    Boolean hasAttachments =
                        (email.textAttachments != null && email.textAttachments.size() > 0) ||
                        (email.binaryAttachments != null &&
                         email.binaryAttachments.size() > 0);
                    
                    // If we catch an auto reply loop, do not create the case and discard this email
                    if (
                        recentCase.Description.equals(theCase.Description.trim()) &&
                        recentCase.OwnerId == theCase.OwnerID &&
                        !hasAttachments
                    ) {
                        Integer currentCasePos = theCase.Subject.indexOf('Case Number');
                        Integer prevCasePos = recentCase.Subject.indexOf('Case Number');
                        if (currentCasePos >= 0 && prevCasePos >= 0) {
                            if (
                                theCase.Subject.substring(0, currentCasePos)
                                .equals(recentCase.Subject.substring(0, prevCasePos))
                            ) {
                                return result;
                            }
                        } else {
                            if (recentCase.Inbound_Email_Checksum__c == theCase.Inbound_Email_Checksum__c) {
                                return result;
                            }
                        }
                    }
                }
                insert this.theCase;
            } else {
                // Grab the contact record from the existing case
                List<Contact> caseContact = [
                    SELECT
                    Id,
                    FirstName,
                    LastName,
                    Name,
                    AccountId,
                    Email,
                    Last_Case_Email_Used__c,
                    Preferred_First_Name__c,
                    Preferred_Full_Name__c
                    FROM Contact
                    WHERE Id = :theCase.ContactId
                ];
                if (caseContact.size() > 0) {
                    emailContact = caseContact[0];
                }
            }
            
            Boolean successfulAttachments = true;
            Boolean hasAttachments =
                (email.textAttachments != null && email.textAttachments.size() > 0) ||
                (email.binaryAttachments != null &&
                 email.binaryAttachments.size() > 0);
            // Check attachment sizes and notify
            AttachmentResult attachmentResponse;
            if (hasAttachments) {
                checkAttachmentSize(email);
                attachmentResponse = handleAttachments(theCase, emailContact, email, caseAssignmentInfo); // must run before createEmailMessage to cleanup cid images
            }
            
            createEmailMessage(theCase, email);
            
            if (
                (attachmentResponse == null || attachmentResponse.success) &&
                htmlBodyIsEmpty(email.HtmlBody) &&
                String.isBlank(removeAllWhitespaces(email.plainTextBody))
            ) {
                if (this.theCase.Description == null) {
                    this.theCase.Description = '';
                }
                
                if (hasAttachments && !attachmentResponse.neutralEmail) {
                    this.theCase.Description += ' Attachment received at ' + Datetime.now().formatLong();
                } else {
                    this.theCase.Description +=
                        ' Email received at ' +
                        Datetime.now().formatLong() +
                        ' without email body or attachment.';
                }
                
                update this.theCase;
            }
            
            if (sendAutoReply && caseAssignmentInfo.templateId != null) {
                sendAutoReply(theCase, emailContact, caseAssignmentInfo.templateId, caseAssignmentInfo);
            }
        } catch (Exception e) {
            String error = e.getMessage() + '\n' + e.getStackTraceString();
            List<String> vars = new List<String>();
            if (email != null) {
                vars.add(ErrorLogger.convertInboundEmailToJSON('email', email));
            }
            vars.add(ErrorLogger.convertSObjectToJSON('case', theCase));
            vars.add(ErrorLogger.convertStringToJSON('error', error));
            ErrorLogger.log(e, vars, false);
            generateLostEmail(email, theCase, error);
        }
        return result;
    }
    
    private void checkAttachmentSize(Messaging.InboundEmail email) {
        Long attachmentCombinedSize = 0;
        Long attachmentThreshold = 25000000; // 25MB;
        Boolean exceededSingleLimit = false;
        Boolean exceededCombinedLimit = false;
        
        // Binary attachments
        if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
            for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                Long attSize = bAttachment.body.size();
                attachmentCombinedSize += attSize;
                
                // If this file exceeded our threshold for a single file, flag it
                if (attSize > attachmentThreshold) {
                    exceededSingleLimit = true;
                }
            }
        }
        // Text attachments
        if (email.textAttachments != null && email.textAttachments.size() > 0) {
            for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                Long attSize = tAttachment.body.length();
                attachmentCombinedSize += attSize;
                
                // If this file exceeded our threshold for a single file, flag it
                if (attSize > attachmentThreshold) {
                    exceededSingleLimit = true;
                }
            }
        }
        
        // Check if the combined attachment limit has been exceeded
        if (attachmentCombinedSize > attachmentThreshold) {
            exceededCombinedLimit = true;
        }
        
        // Create a lost email to track
        if (exceededCombinedLimit || exceededCombinedLimit) {
            generateLostEmail(email, theCase, 'File(s) size greater than 25MB');
        }
    }
    
    // Overload to support previous implementation
    private AttachmentResult handleAttachments(
        Case theCase,
        Contact theContact,
        Messaging.InboundEmail email,
        CaseAssignmentResult caseAssignmentInfo
    ) {
        AttachmentResult attachmentResponse = handleAttachments(theCase, email);
        
        if (!attachmentResponse.success) {
            String attachmentFailureTemplateId;
            
            if (attachmentResponse.attachmentSizeLimitReached) {
                attachmentFailureTemplateId = getConfigurationSetting('Attachment Limit Email Template ID');
            } else {
                attachmentFailureTemplateId = getConfigurationSetting('Rejected Attachment Email Template ID');
            }
            
            if (attachmentFailureTemplateId != null && attachmentFailureTemplateId != '') {
                sendAutoReplyAttachment(
                    theCase,
                    theContact,
                    attachmentFailureTemplateId,
                    caseAssignmentInfo,
                    attachmentResponse
                );
            }
            if (loggingSettings.Attachment_Logging__c) {
                generateLostEmail(email, theCase, 'Attachment is invalid');
            }
        }
        
        return attachmentResponse;
    }
    //SFE-61359 Start
    /*
// Save attachments, if any
private AttachmentResult handleAttachments(SObject parentObject, Messaging.InboundEmail email) {
Map<String, Attachment> cidToAttachmentMap = new Map<String, Attachment>();
List<Attachment> allEmailAttachments = new List<Attachment>();
AttachmentResult response = new AttachmentResult();
response.success = true;
List<String> validFileExtensionList = getConfigurationSetting('Valid Attachment Types').split(',');
Integer attachmentLimit = Integer.valueOf(getConfigurationSetting('Attachment Limit'));
Set<String> validFileExtensionSet = new Set<String>(validFileExtensionList);

Integer attachmentsOnCase = [SELECT COUNT() FROM Attachment WHERE ParentId = :parentObject.Id];

if (loggingSettings.Attachment_Limit_Logging__c && attachmentsOnCase >= attachmentLimit) {
response.success = false;
response.attachmentSizeLimitReached = true;
generateLostEmail(email, theCase, 'This case currently has too many attachments.');
return response;
}

if (email.textAttachments != null && email.textAttachments.size() > 0) {
for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
String fileName = tAttachment.fileName.trim(); //trim whitespace
if (
validFileExtensionSet.isEmpty() ||
validFileExtensionSet.contains(fileName.substringAfterLast('.').toLowerCase())
) {
Attachment attachment = new Attachment();
attachment.Name = fileName;
attachment.Body = Blob.valueOf(tAttachment.body);
attachment.ParentId = parentObject.Id;
if (!fileName.toLowerCase().contains('.p7s')) {
response.neutralEmail = false;
allEmailAttachments.add(attachment);
}
} else {
response.success = false;
response.badTextAttachments.add(tAttachment);
}
}
}

if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
String fileName = bAttachment.fileName.trim(); //trim whitespace
if (
validFileExtensionSet.isEmpty() ||
validFileExtensionSet.contains(fileName.substringAfterLast('.').toLowerCase())
) {
Attachment attachment = new Attachment();
attachment.Name = fileName;
attachment.Body = bAttachment.body;
attachment.ContentType = bAttachment.mimeTypeSubType;
attachment.ParentId = parentObject.Id;
if (!fileName.toLowerCase().contains('.p7s')) {
response.neutralEmail = false;
allEmailAttachments.add(attachment);
}

if (bAttachment.headers != null && email.htmlBody != null) {
for (Integer i = 0; i < bAttachment.headers.size(); i++) {
String headerValue = bAttachment.headers[i].value;
String headerName = bAttachment.headers[i].name;
if (
headerValue.startsWith('ii') ||
headerValue.startsWith('< image') ||
headerName.equals('Content-ID')
) {
headerValue = headerValue.replaceAll('<', '').replaceAll('>', '');
cidToAttachmentMap.put(headerValue, attachment);
}
}
}
} else {
response.success = false;
response.badBinaryAttachments.add(bAttachment);
}
}
}

insert allEmailAttachments;

// change any cid links to new url
for (String headerValue : cidToAttachmentMap.keySet()) {
String refLink = '/servlet/../servlet/servlet.FileDownload?file=' + cidToAttachmentMap.get(headerValue).Id;
email.htmlBody = email.htmlBody.replaceAll('cid:' + headerValue, refLink);
}

return response;
}
*/
    private AttachmentResult handleAttachments(SObject parentObject, Messaging.InboundEmail email) {
        Map<String, ContentVersion> cidToAttachmentMap = new Map<String, ContentVersion>();
        List<ContentVersion> allEmailAttachments = new List<ContentVersion>();
        AttachmentResult response = new AttachmentResult();
        response.success = true;
        List<String> validFileExtensionList = getConfigurationSetting('Valid Attachment Types').split(',');
        Integer attachmentLimit = Integer.valueOf(getConfigurationSetting('Attachment Limit'));
        Set<String> validFileExtensionSet = new Set<String>(validFileExtensionList);
        
        Integer attachmentsOnCase = [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :parentObject.Id];
        
        if (loggingSettings.Attachment_Limit_Logging__c && attachmentsOnCase >= attachmentLimit) {
            response.success = false;
            response.attachmentSizeLimitReached = true;
            generateLostEmail(email, theCase, 'This record currently has too many attachments.');
            return response;
        }
        
        if (email.textAttachments != null && email.textAttachments.size() > 0) {
            for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                String fileName = tAttachment.fileName.trim(); // Trim whitespace
                if (validFileExtensionSet.isEmpty() || validFileExtensionSet.contains(fileName.substringAfterLast('.').toLowerCase())) {
                    ContentVersion contentVersion = new ContentVersion();
                    contentVersion.Title = fileName;
                    contentVersion.PathOnClient = fileName;
                    contentVersion.VersionData = Blob.valueOf(tAttachment.body);
                    contentVersion.IsMajorVersion = true;
                    if (!fileName.toLowerCase().contains('.p7s')) {
                        response.neutralEmail = false;
                        allEmailAttachments.add(contentVersion);
                    }
                } else {
                    response.success = false;
                    response.badTextAttachments.add(tAttachment);
                }
            }
        }
        
        if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
            for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                String fileName = bAttachment.fileName.trim(); // Trim whitespace
                if (validFileExtensionSet.isEmpty() || validFileExtensionSet.contains(fileName.substringAfterLast('.').toLowerCase())) {
                    ContentVersion contentVersion = new ContentVersion();
                    contentVersion.Title = fileName;
                    contentVersion.PathOnClient = fileName;
                    contentVersion.VersionData = bAttachment.body;
                    contentVersion.IsMajorVersion = true;
                    if (!fileName.toLowerCase().contains('.p7s')) {
                        response.neutralEmail = false;
                        allEmailAttachments.add(contentVersion);
                    }
                } else {
                    response.success = false;
                    response.badBinaryAttachments.add(bAttachment);
                }
            }
        }
        
        insert allEmailAttachments;
        
        List<ContentDocumentLink> contentLinks = new List<ContentDocumentLink>();
        for (ContentVersion cv : allEmailAttachments) {
            ContentDocumentLink link = new ContentDocumentLink();
            link.LinkedEntityId = parentObject.Id;
            link.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;
            link.ShareType = 'V'; // Viewer permission
            link.Visibility = 'AllUsers';
            contentLinks.add(link);
        }
        insert contentLinks;
        
        return response;
    }
    //SFE-61359 End
    @TestVisible
    private void createEmailMessage(Case theCase, Messaging.InboundEmail email) {
        String value;
        Integer maxlength;
        EmailMessage theEmail = new EmailMessage();
        theEmail.ParentId = theCase.Id;
        theEmail.Incoming = true;
        Schema.DescribeFieldResult F = EmailMessage.HtmlBody.getDescribe();
        maxlength = F.getLength();
        theEmail.Subject = limitLength(email.Subject, EmailMessage.Subject.getDescribe().getLength());
        theEmail.MessageDate = datetime.now();
        theEmail.HtmlBody = limitLength(email.htmlBody, EmailMessage.HtmlBody.getDescribe().getLength());
        theEmail.TextBody = limitLength(email.plainTextBody, EmailMessage.TextBody.getDescribe().getLength());
        
        List<String> toAddresses = new List<String>();
        
        /* **** To */
        if (email.toAddresses != null) {
            value = '';
            Boolean seenOne = false;
            
            for (String to : email.toAddresses) {
                toAddresses.add(extractAddress(to));
            }
            value = String.join(toAddresses, ';\n');
        }
        
        theEmail.ToAddress = limitLength(value, EmailMessage.ToAddress.getDescribe().getLength());
        
        /* **** From */
        theEmail.FromName = email.fromName;
        // Clean from address (Remove @reply.asu.edu)
        EmailTransformer cleanFromTransformer = new EmailTransformer();
        theEmail.FromAddress = cleanFromTransformer.cleanEmailAddress(email.fromAddress);
        
        value = '';
        /* **** CC */
        if (email.ccAddresses != null) {
            Boolean seenOne = false;
            
            List<String> ccAddresses = new List<String>();
            for (String cc : email.ccAddresses) {
                if (!toAddresses.contains(cc)) {
                    ccAddresses.add(extractAddress(cc));
                }
            }
            value = String.join(ccAddresses, ';\n');
        }
        theEmail.CcAddress = limitLength(value, EmailMessage.CcAddress.getDescribe().getLength());
        
        if (loggingSettings.Header_Logging__c) {
            if (email.headers != null) {
                theEmail.Headers = parseHeaders(email);
            }
        }
        
        insert theEmail;
    }
    
    private void sendAutoReply(
        Case emailCase,
        Contact emailContact,
        String emailTemplateId,
        CaseAssignmentResult caseAssignmentInfo
    ) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(emailContact.Id);
        mail.setTemplateId(emailTemplateId);
        
        if (emailCase != null) {
            mail.setWhatId(emailCase.Id);
        }
        
        OrgWideEmailAddress oweaToUse = new OrgWideEmailAddress();
        OrgWideEmailAddress defaultOwea = getDefaultOrgWideEmailAddress();
        Boolean noOweaFound = false;
        
        // Find the appropriate OrgWideEmailAddress for this reply
        try {
            oweaToUse = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :caseAssignmentInfo.replyToAddress];
            mail.setOrgWideEmailAddressId(oweaToUse.Id);
        } catch (Exception e) {
            if (defaultOwea != null) {
                mail.setOrgWideEmailAddressId(defaultOwea.Id);
            }
            
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertSingleEmailMessageToJSON('email', mail));
            vars.add(ErrorLogger.convertSObjectToJSON('case', emailCase));
            vars.add(ErrorLogger.convertSObjectToJSON('contact', emailContact));
            vars.add(ErrorLogger.convertStringToJSON('emailTemplate', emailTemplateId));
            ErrorLogger.log(e, vars, false);
        }
        
        // Send the email
        try {
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
        } catch (Exception e) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertSingleEmailMessageToJSON('email', mail));
            vars.add(ErrorLogger.convertSObjectToJSON('case', emailCase));
            vars.add(ErrorLogger.convertSObjectToJSON('contact', emailContact));
            vars.add(ErrorLogger.convertStringToJSON('emailTemplate', emailTemplateId));
            vars.add(
                ErrorLogger.convertStringToJSON(
                    'note',
                    'Potentially due to SINGLE_EMAIL_LIMIT_EXCEEDED; may need investigation'
                )
            );
            ErrorLogger.log(e, vars, false);
        }
    }
    
    private void sendAutoReplyAttachment(
        Case emailCase,
        Contact emailContact,
        String emailTemplateId,
        CaseAssignmentResult caseAssignmentInfo,
        AttachmentResult attachmentDetails
    ) {
        emailCase = [SELECT CaseNumber, Id, Thread_Id__c FROM Case WHERE Id = :emailCase.Id];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        EmailTemplate et = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE id = :emailTemplateId LIMIT 1];
        String failedAttachments = '';
        for (Messaging.Inboundemail.BinaryAttachment bAttachment : attachmentDetails.badBinaryAttachments) {
            failedAttachments += 'File Name: ' + bAttachment.fileName + '\n';
        }
        for (Messaging.Inboundemail.TextAttachment tAttachment : attachmentDetails.badTextAttachments) {
            failedAttachments += 'File Name: ' + tAttachment.fileName + '\n';
        }
        String htmlAttachments = failedAttachments.replace('\n', '<br />');
        String subject = et.Subject;
        subject = subject.substring(0, subject.indexOf('{'));
        subject += emailCase.CaseNumber;
        
        String htmlBody = et.HtmlValue;
        htmlBody = htmlBody.replace('{!Contact.Preferred_First_Name__c}', emailContact.Preferred_First_Name__c);
        htmlBody = htmlBody.replace('{!Contact.LastName}', emailContact.LastName);
        htmlBody = htmlBody.replace('{!Case.Thread_Id}', emailCase.Thread_Id__c);
        htmlBody = htmlBody.replace('{!failedAttachmentsList}', htmlAttachments);
        
        String plainBody = et.Body;
        plainBody = plainBody.replace('{!Contact.Preferred_First_Name__c}', emailContact.Preferred_First_Name__c);
        plainBody = plainBody.replace('{!Contact.LastName}', emailContact.LastName);
        plainBody = plainBody.replace('{!Case.Thread_Id}', emailCase.Thread_Id__c);
        plainBody = plainBody.replace('{!failedAttachmentsList}', failedAttachments);
        
        mail.setTargetObjectId(emailContact.Id);
        mail.setSubject(subject);
        mail.setHtmlBody(htmlBody);
        mail.setPlainTextBody(plainBody);
        
        if (emailCase != null) {
            mail.setWhatId(emailCase.Id);
        }
        
        OrgWideEmailAddress oweaToUse = new OrgWideEmailAddress();
        OrgWideEmailAddress defaultOwea = getDefaultOrgWideEmailAddress();
        Boolean noOweaFound = false;
        
        // Find the appropriate OrgWideEmailAddress for this reply
        try {
            oweaToUse = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :caseAssignmentInfo.replyToAddress];
            mail.setOrgWideEmailAddressId(oweaToUse.Id);
        } catch (Exception e) {
            if (defaultOwea != null) {
                mail.setOrgWideEmailAddressId(defaultOwea.Id);
            }
            
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertSingleEmailMessageToJSON('email', mail));
            vars.add(ErrorLogger.convertSObjectToJSON('case', emailCase));
            vars.add(ErrorLogger.convertSObjectToJSON('contact', emailContact));
            vars.add(ErrorLogger.convertStringToJSON('emailTemplate', emailTemplateId));
            ErrorLogger.log(e, vars, false);
        }
        
        //Send the email
        try {
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
        } catch (Exception e) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertSingleEmailMessageToJSON('email', mail));
            vars.add(ErrorLogger.convertSObjectToJSON('case', emailCase));
            vars.add(ErrorLogger.convertSObjectToJSON('contact', emailContact));
            vars.add(ErrorLogger.convertStringToJSON('emailTemplate', emailTemplateId));
            vars.add(
                ErrorLogger.convertStringToJSON(
                    'note',
                    'Potentially due to SINGLE_EMAIL_LIMIT_EXCEEDED; may need investigation'
                )
            );
            ErrorLogger.log(e, vars, false);
        }
    }
    
    @TestVisible
    private LostEmail__c generateLostEmail(Messaging.InboundEmail email, Case theCase, String error) {
        LostEmail__c lostEmail = new LostEmail__c();
        try {
            insert lostEmail; // need to insert early since needs to be assigned an id for handleAttachments function
            lostEmail.Sender__c = limitLength(email.fromAddress, 255);
            lostEmail.Subject__c = limitLength(email.subject, 255);
            lostEmail.PlainTextBody__c = limitLength(email.plainTextBody, 31500);
            lostEmail.HtmlTextBody__c = limitLength(email.htmlBody, 31500);
            lostEmail.Cause__c = limitLength(error, 255);
            
            // Convert the List into a concatenated string
            String recipientsString = '';
            if (email.toAddresses != null) {
                recipientsString = String.join(email.toAddresses, ', ');
            }
            lostEmail.Recipient__c = recipientsString;
            
            String carbonCopiesString = '';
            if (email.ccAddresses != null) {
                carbonCopiesString = String.join(email.CCAddresses, ', ');
            }
            lostEmail.CarbonCopies__c = carbonCopiesString;
            
            Boolean attachSuccess = handleAttachments(lostEmail, email).success;
            lostEmail.RejectedAttachments__c = !attachSuccess;
            if (!attachSuccess) {
                String attachmentInfo =
                    '\n**********\nCase ID: ' +
                    (theCase != null ? String.valueOf(theCase.Id) : 'SPAM: Not Created') +
                    '\n\n*****List of Attachments*****\n';
                if (email.binaryAttachments != null) {
                    for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                        attachmentInfo +=
                            'FileName: ' +
                            bAttachment.fileName +
                            ' File Size: ' +
                            bAttachment.body.size() / 1000.00 +
                            ' kB\n';
                    }
                }
                if (email.textAttachments != null) {
                    for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                        attachmentInfo +=
                            'FileName: ' +
                            tAttachment.fileName +
                            ' File Size: ' +
                            tAttachment.body.length() / 1000.00 +
                            ' kB\n';
                    }
                }
                lostEmail.PlainTextBody__c += attachmentInfo;
            }
            
            if (loggingSettings.Header_Logging__c) {
                if (email.headers != null) {
                    lostEmail.Headers__c = parseHeaders(email);
                }
            }
            
            update lostEmail;
        } catch (Exception e) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertInboundEmailToJSON('email', email));
            vars.add(ErrorLogger.convertSObjectToJSON('case', theCase));
            vars.add(ErrorLogger.convertStringToJSON('error', error));
            vars.add(ErrorLogger.convertSObjectToJSON('lostEmail', lostEmail));
            ErrorLogger.log(e, vars, false);
        }
        return lostEmail;
    }
    
    private String extractIdRefNew(String searchText) {
        if (searchtext == null) {
            return null;
        }
        
        String itemRef = null;
        String patternString;
        String caseId;
        
        if (searchText.indexOf(':ref') > searchText.indexOf('ref:')) {
            String caseReference = searchText.substring(searchText.indexOf('ref:') + 4, searchText.indexOf(':ref'));
            try {
                caseId = Cases.getCaseIdFromEmailThreadId(caseReference);
            } catch (Exception e) {
                List<String> vars = new List<String>();
                vars.add(ErrorLogger.convertStringToJSON('caseReference', caseReference));
                vars.add(ErrorLogger.convertStringToJSON('searchText', searchText));
                ErrorLogger.log(e, vars, false);
                return null;
            }
            return caseId;
        } else {
            return null;
        }
    }
    
    private String extractAddress(String inAddress) {
        String address;
        String patternString;
        Pattern thePattern;
        Matcher matcher;
        patternString = '.*<(.*)>.*';
        thePattern = Pattern.compile(patternString);
        matcher = thePattern.matcher(inAddress);
        
        if (matcher.matches()) {
            address = matcher.group(1);
        } else {
            address = inAddress;
        }
        
        return address;
    }
    
    private String filteredTermFound() {
        Email_Case_Filter__c[] filteredTerms = [
            SELECT Name, Rejection_Count__c, Filter_Email_Body__c
            FROM Email_Case_Filter__c
            ORDER BY Filter_Email_Body__c ASC
        ];
        
        List<Email_Case_Filter__c> filtersToUpdate = new List<Email_Case_Filter__c>();
        for (Email_Case_Filter__c filter : filteredTerms) {
            if (filter.Rejection_Count__c == null) {
                filter.Rejection_Count__c = 0;
            }
            
            // If this filter is an email address, check the fromAddress only
            if (Pattern.matches('\\S*\\@\\S+\\.\\S+', filter.Name)) {
                if (inboundEmail.fromAddress.containsIgnoreCase(filter.Name)) {
                    filter.Rejection_Count__c += 1;
                    filtersToUpdate.add(filter);
                    break;
                }
            } else if (inboundEmail.subject != null) {
                if (inboundEmail.subject.containsIgnoreCase(filter.Name)) {
                    filter.Rejection_Count__c += 1;
                    filtersToUpdate.add(filter);
                    break;
                }
            }
            
            if (filter.Filter_Email_Body__c && inboundEmail.htmlBody != null) {
                if (inboundEmail.htmlBody.containsIgnoreCase(filter.Name)) {
                    filter.Rejection_Count__c += 1;
                    filtersToUpdate.add(filter);
                    break;
                }
            }
        }
        if (!filtersToUpdate.isEmpty()) {
            if (
                configMap.get('Filter Rejection Count On') != null &&
                configMap.get('Filter Rejection Count On') == 'true'
            ) {
                update filtersToUpdate;
            }
            
            return filtersToUpdate.get(0).Name;
        }
        return null;
    }
    
    private CaseAssignmentResult getCaseAssignmentRule(String[] toEmailAddresses, String[] ccEmailAddresses) {
        CaseAssignmentResult response = new CaseAssignmentResult();
        List<Case_Assignment_Rule__c> assignmentRuleList = new List<Case_Assignment_Rule__c>();
        
        if (toEmailAddresses.size() > 1) {
            assignmentRuleList = [
                SELECT
                Id,
                Name,
                CC_Category__c,
                CC_Sub_Category__c,
                Email_Address__c,
                Case_Feed_Email_Template_Id__c,
                Reply_To_Email_Address__c,
                Email_Template_ID__c,
                CC_Functional_Group__c,
                Priority__c,
                Queue_ID__c,
                Case_Record_Type_ID__c,
                Fallback_Queue_ID__c,
                Type_of_Additional_Assignment_Needed__c,
                Associate_Case_To_Active_Opportunity__c,
                Origin__c,
                Campus__c
                FROM Case_Assignment_Rule__c
                WHERE Email_Address__c IN :toEmailAddresses
                ORDER BY Priority__c
            ];
        } else if (toEmailAddresses.size() > 0) {
            String toEmailAddress = toEmailAddresses.get(0);
            
            //See if this is an RMM email
            String rmmSevenChar = '';
            List<String> splitAt = toEmailAddress.split('@');
            if (splitAt.size() == 2 && (splitAt[1] == 'e.asu.edu' || splitAt[1] == 'reply.asu.edu')) {
                List<String> splitDash = new List<String>();
                splitDash = splitAt[0].split('-');
                if (splitDash.size() > 1) {
                    rmmSevenChar = splitDash.get(splitDash.size() - 2);
                }
            }
            
            if (rmmSevenChar.length() == 7) {
                String toEmailAddressPartial = '%-' + rmmSevenChar + '-_@%';
                assignmentRuleList = [
                    SELECT
                    Id,
                    Name,
                    CC_Category__c,
                    CC_Sub_Category__c,
                    Email_Address__c,
                    Case_Feed_Email_Template_Id__c,
                    Reply_To_Email_Address__c,
                    Email_Template_ID__c,
                    CC_Functional_Group__c,
                    Priority__c,
                    Queue_ID__c,
                    Case_Record_Type_ID__c,
                    Fallback_Queue_ID__c,
                    Type_of_Additional_Assignment_Needed__c,
                    Associate_Case_To_Active_Opportunity__c,
                    Origin__c,
                    Campus__c
                    FROM Case_Assignment_Rule__c
                    WHERE Email_Address__c LIKE :toEmailAddressPartial
                    ORDER BY Priority__c
                ];
            } else {
                assignmentRuleList = [
                    SELECT
                    Id,
                    Name,
                    CC_Category__c,
                    CC_Sub_Category__c,
                    Email_Address__c,
                    Case_Feed_Email_Template_Id__c,
                    Reply_To_Email_Address__c,
                    Email_Template_ID__c,
                    CC_Functional_Group__c,
                    Priority__c,
                    Queue_ID__c,
                    Case_Record_Type_ID__c,
                    Fallback_Queue_ID__c,
                    Type_of_Additional_Assignment_Needed__c,
                    Associate_Case_To_Active_Opportunity__c,
                    Origin__c,
                    Campus__c
                    FROM Case_Assignment_Rule__c
                    WHERE Email_Address__c = :toEmailAddress
                    ORDER BY Priority__c
                ];
            }
            
            String toEmailAddressPartial = toEmailAddress;
            if (toEmailAddressPartial.length() > 15) {
                toEmailAddressPartial = toEmailAddressPartial.substring(0, 15) + '%';
            }
        }
        
        if (assignmentRuleList.isEmpty()) {
            assignmentRuleList = [
                SELECT
                Id,
                Name,
                CC_Category__c,
                CC_Sub_Category__c,
                Email_Address__c,
                Reply_To_Email_Address__c,
                Email_Template_ID__c,
                Case_Feed_Email_Template_Id__c,
                CC_Functional_Group__c,
                Priority__c,
                Queue_ID__c,
                Case_Record_Type_ID__c,
                Fallback_Queue_ID__c,
                Type_of_Additional_Assignment_Needed__c,
                Associate_Case_To_Active_Opportunity__c,
                Origin__c,
                Campus__c
                FROM Case_Assignment_Rule__c
                WHERE Email_Address__c IN :ccEmailAddresses
                ORDER BY Priority__c
            ];
        }
        if (assignmentRuleList.isEmpty()) {
            String defaultEmailAddress = getConfigurationSetting('Default Org Wide Email Address');
            
            assignmentRuleList = [
                SELECT
                Id,
                Name,
                CC_Category__c,
                CC_Sub_Category__c,
                Email_Address__c,
                Reply_To_Email_Address__c,
                Email_Template_ID__c,
                Case_Feed_Email_Template_Id__c,
                CC_Functional_Group__c,
                Priority__c,
                Queue_ID__c,
                Case_Record_Type_ID__c,
                Fallback_Queue_ID__c,
                Type_of_Additional_Assignment_Needed__c,
                Associate_Case_To_Active_Opportunity__c,
                Origin__c,
                Campus__c
                FROM Case_Assignment_Rule__c
                WHERE Email_Address__c = :defaultEmailAddress
            ];
        }
        
        if (!assignmentRuleList.isEmpty()) {
            response.categoryNameCC = assignmentRuleList[0].CC_Category__c;
            response.subCategoryNameCC = assignmentRuleList[0].CC_Sub_Category__c;
            response.campus = assignmentRuleList[0].Campus__c;
            response.functionalGroupCC = assignmentRuleList[0].CC_Functional_Group__c;
            response.origin = assignmentRuleList[0].Origin__c;
            response.queueId = ID.valueOf(assignmentRuleList[0].Queue_ID__c);
            
            if (
                assignmentRuleList[0].Email_Template_ID__c != null &&
                assignmentRuleList[0].Email_Template_ID__c != ''
            ) {
                response.templateId = ID.valueOf(assignmentRuleList[0].Email_Template_ID__c);
            }
            
            if (
                assignmentRuleList[0].Case_Feed_Email_Template_Id__C != null &&
                assignmentRuleList[0].Case_Feed_Email_Template_Id__C != ''
            ) {
                response.caseFeedTemplateId = ID.valueOf(assignmentRuleList[0].Case_Feed_Email_Template_Id__c);
            }
            
            if (
                assignmentRuleList[0].Reply_To_Email_Address__c != null &&
                assignmentRuleList[0].Reply_To_Email_Address__c != ''
            ) {
                response.replyToAddress = assignmentRuleList[0].Reply_To_Email_Address__c;
            } else {
                response.replyToAddress = assignmentRuleList[0].Email_Address__c;
            }
            
            if (assignmentRuleList[0].Case_Record_Type_ID__c != null) {
                response.caseRecordTypeId = ID.valueOf(assignmentRuleList[0].Case_Record_Type_ID__c);
            }
            
            if (assignmentRuleList[0].Fallback_Queue_ID__c != null) {
                response.fallbackQueueId = ID.valueOf(assignmentRuleList[0].Fallback_Queue_ID__c);
            }
            
            response.typeOfAdditionalAssignmentNeeded = assignmentRuleList[0].Type_of_Additional_Assignment_Needed__c;
            response.associateCaseToActiveOpportunity = assignmentRuleList[0].Associate_Case_to_Active_Opportunity__c;
        }
        
        return response;
    }
    
    private OrgWideEmailAddress getDefaultOrgWideEmailAddress() {
        OrgWideEmailAddress oweaLookup;
        String orgWideEmailAddress = getConfigurationSetting('Default Org Wide Email Address');
        
        if (orgWideEmailAddress != null && orgWideEmailAddress != '') {
            List<OrgWideEmailAddress> oweaList = [
                SELECT Id, DisplayName, Address
                FROM OrgWideEmailAddress
                WHERE Address = :orgWideEmailAddress
            ];
            if (oweaList.size() > 0) {
                oweaLookup = oweaList[0];
            }
        }
        
        return oweaLookup;
    }
    
    private boolean isUserActive(String userId) {
        List<User> userList = [SELECT Id, IsActive FROM User WHERE Id = :userId];
        if (userList.size() > 0) {
            if (userList[0].IsActive) {
                return true;
            }
        }
        
        return false;
    }
    
    private void extractSourceFromHeaders(Messaging.InboundEmail email) {
        for (Integer x = 0; x < email.headers.size(); x++) {
            if (email.headers[x].name == 'Received' && email.headers[x].value.contains('')) {
                List<String> emailValue1 = email.headers[x].value.split('for \\<');
                if (emailValue1.size() > 1) {
                    List<String> emailValue2 = emailValue1[1].split('\\>');
                    if (emailValue2.size() > 0) {
                        this.theCase.Intended_Recipient__c = emailValue2[0];
                        break;
                    }
                }
            }
        }
    }
    
    private String parseHeaders(Messaging.InboundEmail email) {
        String header = '';
        for (Messaging.InboundEmail.Header h : email.headers) {
            header += h.name + ' : ' + h.value + '\n';
        }
        return header;
    }
    
    private void loadConfigurationSettings() {
        Email_To_Case_Configuration__c[] configList = [SELECT Name, Value__c FROM Email_To_Case_Configuration__c];
        if (configList.size() > 0) {
            for (Email_To_Case_Configuration__c c : configList) {
                configMap.put(c.Name, c.Value__c);
            }
        }
    }
    
    private String getConfigurationSetting(String settingName) {
        if (configMap.containsKey(settingName)) {
            return configMap.get(settingName);
        }
        
        return '';
    }
    
    private String limitLength(String input, Integer maxLength) {
        String results;
        
        if (input != null && input.length() > maxLength) {
            results = input.substring(0, maxLength);
        } else {
            results = input;
        }
        
        return results;
    }
    
    private String removeAllWhitespaces(String removeFrom) {
        // \s handles most whitespace characters.  Misses non-breaking space types and a couple others
        // Using https://en.wikipedia.org/wiki/Whitespace_character as defining list of whitespace
        
        if (removeFrom == null) {
            removeFrom = '';
        }
        return removeFrom.replaceAll(
            '[\\s|\\u00A0|\\u0085|\\u2007|\\u202F|\\u180E|\\u200B|\\u200C|\\u200D|\\u2060|\\uFEFF]',
            ''
        )
            .replaceAll('&nbsp;', '');
    }
    
    private Boolean htmlBodyIsEmpty(String htmlBody) {
        if (htmlBody == null) {
            htmlBody = '';
        }
        
        htmlBody = htmlBody.replaceAll('<head>[\\s\\S]*</head>', '');
        htmlBody = htmlBody.replaceAll('<[^>]+>', '');
        htmlBody = removeAllWhitespaces(htmlBody);
        
        return String.isBlank(htmlBody);
    }
    
    @TestVisible
    public String generateChecksum(String input) {
        Blob inputBlob = Blob.valueOf(input);
        Blob sha256Hash = Crypto.generateDigest('SHA-256', inputBlob);
        return EncodingUtil.convertToHex(sha256Hash);
    }
    
    private class AttachmentResult {
        public Boolean success = false;
        public Boolean neutralEmail = true;
        public Boolean attachmentSizeLimitReached = false;
        public List<Messaging.Inboundemail.BinaryAttachment> badBinaryAttachments = new List<Messaging.Inboundemail.BinaryAttachment>();
        public List<Messaging.Inboundemail.TextAttachment> badTextAttachments = new List<Messaging.Inboundemail.TextAttachment>();
    }
    
    private class CaseAssignmentResult {
        public Id queueId;
        public Id templateId;
        public Id caseFeedTemplateId;
        public Id functionalGroupCC;
        public Id categoryNameCC;
        public Id subCategoryNameCC;
        public String origin;
        public String campus;
        public String replyToAddress;
        public String emailFromName;
        public Id caseRecordTypeId;
        public Id fallbackQueueId;
        public String typeOfAdditionalAssignmentNeeded;
        public boolean associateCaseToActiveOpportunity;
    }
}