@isTest
public class EmailMessageTriggerTest {
    @TestSetup
    private static void testSetup() {
        Contact testContact = new Contact(FirstName = 'Jesse', LastName = 'Faden', Email = 'jesse.faden@test.test');
        insert testContact;

        List<Case> testCases = new List<Case>();
        // Insert UGRD Advisor cases
        for (Integer i = 0; i < 5; i++) {
            testCases.add(
                new Case(
                    ContactId = testContact.Id,
                    Subject = 'Example Advisor Cae (UGRD)',
                    Status = 'New',
                    RecordTypeId = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach')
                )
            );
        }
        // Insert GRAD Advisor cases
        for (Integer i = 0; i < 5; i++) {
            testCases.add(
                new Case(
                    ContactId = testContact.Id,
                    Subject = 'Example Advisor Cae (GRD)',
                    Status = 'New',
                    RecordTypeId = RecordIdHelper.getRecordTypeId('Case', 'ASU_Graduate_Advisor_Portal')
                )
            );
        }

        insert testCases;
    }

    /**
     * Tests the happy path, case status is updated when EmailMessage is inserted
     * with correct status (and Case Record Type matches metadata)
     */
    @isTest
    private static void testUpdateCaseStatus() {
        // Add a metadata for converting advisor case status to "Email Sent" whenever EmailMessage is sent
        EmailMessageService.statusMetadataRecords = new List<Email_Message_Case_Status__mdt>{
            new Email_Message_Case_Status__mdt(
                Case_Record_Type__c = 'ASU_Advisor_Outreach',
                Email_Message_Status__c = 'Sent',
                Case_Status__c = 'Email Sent'
            )
        };
        // Enable feature
        FeatureFlagService.overrideTestDefault('Email Message Trigger', 'Update Case Status', true);

        Contact testContact = [SELECT Id, Email FROM Contact LIMIT 1];
        List<Case> testCases = [SELECT Id, Status FROM Case WHERE RecordType.DeveloperName = 'ASU_Advisor_Outreach'];
        Assert.areEqual(false, testCases.isEmpty(), 'Need at least one case for test to be meaningful');

        // Insert Email Message records
        List<EmailMessage> emailMessages = new List<EmailMessage>();
        for (Case testCase : testCases) {
            emailMessages.add(
                new EmailMessage(
                    FromAddress = 'salesforce.support@asu.edu',
                    ToAddress = testContact.email,
                    Subject = 'test email',
                    textBody = 'test email',
                    HTMLBody = 'test email',
                    ParentId = testCase.Id,
                    Status = EmailMessageService.emailMessageStatusMap.get('Sent')
                )
            );
        }
        insert emailMessages;

        // Get updated Cases
        Set<Id> testCaseIds = new Map<Id, Case>(testCases).keySet();
        testCases = [SELECT Id, Status FROM Case WHERE Id IN :testCaseIds];
        Assert.areEqual(false, testCases.isEmpty(), 'Need at least one case for test to be meaningful');

        // Check case statuses
        for (Case testCase : testCases) {
            Assert.areEqual('Email Sent', testCase.Status);
        }
    }

    /**
     * Tests the happy path, case status is updated when EmailMessage is updated
     * with correct status (and Case Record Type matches metadata)
     * (this simulates how EmailMessages work in Lightning, as they are usually saved as a Draft before layer being updated to Sent)
     */
    @isTest
    private static void testUpdateCaseStatusOnEmailMessageUpdate() {
        // Add a metadata for converting advisor case status to "Email Sent" whenever EmailMessage is sent
        EmailMessageService.statusMetadataRecords = new List<Email_Message_Case_Status__mdt>{
            new Email_Message_Case_Status__mdt(
                Case_Record_Type__c = 'ASU_Advisor_Outreach',
                Email_Message_Status__c = 'Sent',
                Case_Status__c = 'Email Sent'
            )
        };
        // Enable feature
        FeatureFlagService.overrideTestDefault('Email Message Trigger', 'Update Case Status', true);

        Contact testContact = [SELECT Id, Email FROM Contact LIMIT 1];
        List<Case> testCases = [SELECT Id, Status FROM Case WHERE RecordType.DeveloperName = 'ASU_Advisor_Outreach'];
        Assert.areEqual(false, testCases.isEmpty(), 'Need at least one case for test to be meaningful');

        // Insert Email Message records
        List<EmailMessage> emailMessages = new List<EmailMessage>();
        for (Case testCase : testCases) {
            emailMessages.add(
                new EmailMessage(
                    FromAddress = 'salesforce.support@asu.edu',
                    ToAddress = testContact.email,
                    Subject = 'test email',
                    textBody = 'test email',
                    HTMLBody = 'test email',
                    ParentId = testCase.Id,
                    Status = EmailMessageService.emailMessageStatusMap.get('Draft')
                )
            );
        }
        insert emailMessages;

        // Get (not yet) updated Cases
        Set<Id> testCaseIds = new Map<Id, Case>(testCases).keySet();
        testCases = [SELECT Id, Status FROM Case WHERE Id IN :testCaseIds];
        Assert.areEqual(false, testCases.isEmpty(), 'Need at least one case for test to be meaningful');

        // Check case statuses (not updated yet)
        for (Case testCase : testCases) {
            Assert.areEqual('New', testCase.Status);
        }

        // Send the drafts!
        for (EmailMessage emailMessage : emailMessages) {
            emailMessage.Status = EmailMessageService.emailMessageStatusMap.get('Sent');
        }
        update emailMessages;

        // Get updated Cases
        testCases = [SELECT Id, Status FROM Case WHERE Id IN :testCaseIds];
        Assert.areEqual(false, testCases.isEmpty(), 'Need at least one case for test to be meaningful');

        // Check case statuses
        for (Case testCase : testCases) {
            Assert.areEqual('Email Sent', testCase.Status);
        }
    }

    /**
     * Tests that case status is NOT updated on cases if the Case's record type does not
     * match custom metadata
     */
    @isTest
    private static void testDontUpdateCaseStatus_WrongRecordType() {
        // Add a metadata for converting advisor case status to "Email Sent" whenever EmailMessage is sent
        EmailMessageService.statusMetadataRecords = new List<Email_Message_Case_Status__mdt>{
            new Email_Message_Case_Status__mdt(
                Case_Record_Type__c = 'ASU_Advisor_Outreach',
                Email_Message_Status__c = 'Sent',
                Case_Status__c = 'Email Sent'
            )
        };
        // Enable feature
        FeatureFlagService.overrideTestDefault('Email Message Trigger', 'Update Case Status', true);

        Contact testContact = [SELECT Id, Email FROM Contact LIMIT 1];
        List<Case> testCases = [SELECT Id, Status FROM Case WHERE RecordType.DeveloperName != 'ASU_Advisor_Outreach'];
        Assert.areEqual(false, testCases.isEmpty(), 'Need at least one case for test to be meaningful');

        // Insert Email Message records
        List<EmailMessage> emailMessages = new List<EmailMessage>();
        for (Case testCase : testCases) {
            emailMessages.add(
                new EmailMessage(
                    FromAddress = 'salesforce.support@asu.edu',
                    ToAddress = testContact.email,
                    Subject = 'test email',
                    textBody = 'test email',
                    HTMLBody = 'test email',
                    ParentId = testCase.Id,
                    Status = EmailMessageService.emailMessageStatusMap.get('Sent')
                )
            );
        }
        insert emailMessages;

        // Get updated Cases
        Set<Id> testCaseIds = new Map<Id, Case>(testCases).keySet();
        testCases = [SELECT Id, Status FROM Case WHERE Id IN :testCaseIds];
        Assert.areEqual(false, testCases.isEmpty(), 'Need at least one case for test to be meaningful');

        // Check case statuses
        for (Case testCase : testCases) {
            Assert.areEqual('New', testCase.Status);
        }
    }

    /**
     * Tests that case status is NOT updated on cases if the EmailMessage's status does not match
     * custom metadata
     */
    @isTest
    private static void testDontUpdateCaseStatus_WrongStatus() {
        // Add a metadata for converting advisor case status to "Email Sent" whenever EmailMessage is sent
        EmailMessageService.statusMetadataRecords = new List<Email_Message_Case_Status__mdt>{
            new Email_Message_Case_Status__mdt(
                Case_Record_Type__c = 'ASU_Advisor_Outreach',
                Email_Message_Status__c = 'Sent',
                Case_Status__c = 'Email Sent'
            )
        };
        // Enable feature
        FeatureFlagService.overrideTestDefault('Email Message Trigger', 'Update Case Status', true);

        Contact testContact = [SELECT Id, Email FROM Contact LIMIT 1];
        List<Case> testCases = [SELECT Id, Status FROM Case WHERE RecordType.DeveloperName = 'ASU_Advisor_Outreach'];
        Assert.areEqual(false, testCases.isEmpty(), 'Need at least one case for test to be meaningful');

        // Insert Email Message records
        List<EmailMessage> emailMessages = new List<EmailMessage>();
        for (Case testCase : testCases) {
            emailMessages.add(
                new EmailMessage(
                    FromAddress = 'salesforce.support@asu.edu',
                    ToAddress = testContact.email,
                    Subject = 'test email',
                    textBody = 'test email',
                    HTMLBody = 'test email',
                    ParentId = testCase.Id,
                    Status = EmailMessageService.emailMessageStatusMap.get('Draft')
                )
            );
        }
        insert emailMessages;

        // Get updated Cases
        Set<Id> testCaseIds = new Map<Id, Case>(testCases).keySet();
        testCases = [SELECT Id, Status FROM Case WHERE Id IN :testCaseIds];
        Assert.areEqual(false, testCases.isEmpty(), 'Need at least one case for test to be meaningful');

        // Check case statuses
        for (Case testCase : testCases) {
            Assert.areEqual('New', testCase.Status);
        }
    }

    /**
     * Tests that if there are multiple rules for the same status (but differing record types),
     * the cases status is updated properly
     */
    @isTest
    private static void testUpdateCaseStatusMultipleRulesForSameStatus() {
        // Add a metadata for converting advisor case status to "Email Sent" whenever EmailMessage is sent
        EmailMessageService.statusMetadataRecords = new List<Email_Message_Case_Status__mdt>{
            new Email_Message_Case_Status__mdt(
                Case_Record_Type__c = 'ASU_Advisor_Outreach',
                Email_Message_Status__c = 'Sent',
                Case_Status__c = 'Email Sent'
            ),
            new Email_Message_Case_Status__mdt(
                Case_Record_Type__c = 'ASU_Graduate_Advisor_Portal',
                Email_Message_Status__c = 'Sent',
                Case_Status__c = 'Closed: SPAM'
            )
        };
        // Enable feature
        FeatureFlagService.overrideTestDefault('Email Message Trigger', 'Update Case Status', true);

        Contact testContact = [SELECT Id, Email FROM Contact LIMIT 1];
        List<Case> testCases = [
            SELECT Id, Status
            FROM Case
            WHERE RecordType.DeveloperName IN ('ASU_Advisor_Outreach', 'ASU_Graduate_Advisor_Portal')
        ];
        Assert.areEqual(false, testCases.isEmpty(), 'Need at least one case for test to be meaningful');

        // Insert Email Message records
        List<EmailMessage> emailMessages = new List<EmailMessage>();
        for (Case testCase : testCases) {
            emailMessages.add(
                new EmailMessage(
                    FromAddress = 'salesforce.support@asu.edu',
                    ToAddress = testContact.email,
                    Subject = 'test email',
                    textBody = 'test email',
                    HTMLBody = 'test email',
                    ParentId = testCase.Id,
                    Status = EmailMessageService.emailMessageStatusMap.get('Sent')
                )
            );
        }
        insert emailMessages;

        // Get updated Cases
        Set<Id> testCaseIds = new Map<Id, Case>(testCases).keySet();
        testCases = [SELECT Id, RecordType.DeveloperName, Status FROM Case WHERE Id IN :testCaseIds];
        Assert.areEqual(false, testCases.isEmpty(), 'Need at least one case for test to be meaningful');

        // Check case statuses
        for (Case testCase : testCases) {
            if (testCase.RecordType.DeveloperName == 'ASU_Advisor_Outreach')
                Assert.areEqual('Email Sent', testCase.Status);
            else if (testCase.RecordType.DeveloperName == 'ASU_Graduate_Advisor_Portal')
                Assert.areEqual('Closed: SPAM', testCase.Status);
        }
    }

    /**
     * Tests that if there are multiple rules for the same record type (but differing status),
     * the cases status is updated properly
     */
    @isTest
    private static void testUpdateCaseStatusMultipleRulesForSameRecordType() {
        // Add a metadata for converting advisor case status to "Email Sent" whenever EmailMessage is sent
        EmailMessageService.statusMetadataRecords = new List<Email_Message_Case_Status__mdt>{
            new Email_Message_Case_Status__mdt(
                Case_Record_Type__c = 'ASU_Advisor_Outreach',
                Email_Message_Status__c = 'Sent',
                Case_Status__c = 'Email Sent'
            ),
            new Email_Message_Case_Status__mdt(
                Case_Record_Type__c = 'ASU_Advisor_Outreach',
                Email_Message_Status__c = 'Draft',
                Case_Status__c = 'Closed: SPAM'
            )
        };
        // Enable feature
        FeatureFlagService.overrideTestDefault('Email Message Trigger', 'Update Case Status', true);

        Contact testContact = [SELECT Id, Email FROM Contact LIMIT 1];
        List<Case> testCases = [SELECT Id, Status FROM Case WHERE RecordType.DeveloperName = 'ASU_Advisor_Outreach'];
        Assert.areEqual(false, testCases.isEmpty(), 'Need at least one case for test to be meaningful');

        // Split cases into two groups
        List<Case> casesSent = new List<Case>();
        List<Case> casesDraft = new List<Case>();
        for (Integer i = 0; i < testCases.size(); i++) {
            Case testCase = testCases[i];

            if (math.mod(i, 2) == 0)
                casesSent.add(testCase);
            else
                casesDraft.add(testCase);
        }
        Assert.areEqual(false, casesSent.isEmpty(), 'Need at least one case for test to be meaningful');
        Assert.areEqual(false, casesDraft.isEmpty(), 'Need at least one case for test to be meaningful');

        List<EmailMessage> emailMessages = new List<EmailMessage>();

        // Insert Email Message records
        for (Case testCase : casesSent) {
            emailMessages.add(
                new EmailMessage(
                    FromAddress = 'salesforce.support@asu.edu',
                    ToAddress = testContact.email,
                    Subject = 'test email',
                    textBody = 'test email',
                    HTMLBody = 'test email',
                    ParentId = testCase.Id,
                    Status = EmailMessageService.emailMessageStatusMap.get('Sent')
                )
            );
        }
        for (Case testCase : casesDraft) {
            emailMessages.add(
                new EmailMessage(
                    FromAddress = 'salesforce.support@asu.edu',
                    ToAddress = testContact.email,
                    Subject = 'test email',
                    textBody = 'test email',
                    HTMLBody = 'test email',
                    ParentId = testCase.Id,
                    Status = EmailMessageService.emailMessageStatusMap.get('Draft')
                )
            );
        }
        insert emailMessages;

        // Get updated Cases
        Set<Id> casesSentIds = new Map<Id, Case>(casesSent).keySet();
        casesSent = [SELECT Id, Status FROM Case WHERE Id IN :casesSentIds];
        Assert.areEqual(false, casesSent.isEmpty(), 'Need at least one case for test to be meaningful');
        Set<Id> casesDraftIds = new Map<Id, Case>(casesDraft).keySet();
        casesDraft = [SELECT Id, Status FROM Case WHERE Id IN :casesDraftIds];
        Assert.areEqual(false, casesDraft.isEmpty(), 'Need at least one case for test to be meaningful');

        // Check case statuses
        for (Case testCase : casesSent) {
            Assert.areEqual('Email Sent', testCase.Status);
        }
        for (Case testCase : casesDraft) {
            Assert.areEqual('Closed: SPAM', testCase.Status);
        }
    }
}
