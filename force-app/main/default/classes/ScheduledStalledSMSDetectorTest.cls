@isTest
public with sharing class ScheduledStalledSMSDetectorTest {
    @TestSetup
    private static void setup() {
        // Insert neccessary senders
        smagicinteract__SMS_SenderId__c edPlusSender = new smagicinteract__SMS_SenderId__c(
            SenderIdUnit__c = 'EdPlus',
            smagicinteract__senderId__c = 'ID-EP-1'
        );
        smagicinteract__SMS_SenderId__c globalFreshmanSender = new smagicinteract__SMS_SenderId__c(
            SenderIdUnit__c = 'Universal Learner Courses',
            smagicinteract__senderId__c = 'ID-GFM-1'
        );
        smagicinteract__SMS_SenderId__c fysSender = new smagicinteract__SMS_SenderId__c(
            SenderIdUnit__c = 'FYS',
            smagicinteract__senderId__c = 'ID-FYS-1'
        );
        insert new List<smagicinteract__SMS_SenderId__c>{ edPlusSender, globalFreshmanSender, fysSender };

        // Insert necessary conversations
        smagicinteract__Conversation__c edPlusConvo = new smagicinteract__Conversation__c(
            smagicinteract__Sender__c = edPlusSender.Id
        );
        smagicinteract__Conversation__c globalFreshmanConvo = new smagicinteract__Conversation__c(
            smagicinteract__Sender__c = globalFreshmanSender.Id
        );
        smagicinteract__Conversation__c fysConvo = new smagicinteract__Conversation__c(
            smagicinteract__Sender__c = fysSender.Id
        );
        insert new List<smagicinteract__Conversation__c>{ edPlusConvo, globalFreshmanConvo, fysConvo };

        // Insert SMS
        List<smagicinteract__smsMagic__c> allSMS = new List<smagicinteract__smsMagic__c>();
        for (Integer i = 0; i < 8; i++) {
            allSMS.add(
                new smagicinteract__smsMagic__c(
                    smagicinteract__Direction__c = 'OUT',
                    smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey(),
                    smagicinteract__SenderId__c = 'Test',
                    smagicinteract__SMSText__c = 'Test' + i,
                    smagicinteract__Source__c = '9000',
                    smagicinteract__PhoneNumber__c = '9192939495',
                    smagicinteract__Unformatted_Phone_Number__c = '19192939495'
                )
            );
        }
        insert allSMS;

        // Some of this must be set after insert to avoid onInsert alterations
        allSMS[0].smagicinteract__Conversation__c = edPlusConvo.Id;
        allSMS[0].smagicinteract__Status__c = 'SUBMITTED';
        Test.setCreatedDate(allSMS[0].Id, System.now().addHours(-3));

        allSMS[1].smagicinteract__Conversation__c = edPlusConvo.Id;
        allSMS[1].smagicinteract__Status__c = 'SUBMITTED';
        Test.setCreatedDate(allSMS[1].Id, System.now().addHours(-9));

        allSMS[2].smagicinteract__Conversation__c = edPlusConvo.Id;
        allSMS[2].smagicinteract__Status__c = 'SUBMITTED';
        Test.setCreatedDate(allSMS[2].Id, System.now().addDays(-8));

        allSMS[3].smagicinteract__Conversation__c = fysConvo.Id;
        allSMS[3].smagicinteract__Status__c = 'SUBMITTED';
        Test.setCreatedDate(allSMS[3].Id, System.now().addDays(-6));

        allSMS[4].smagicinteract__Conversation__c = fysConvo.Id;
        allSMS[4].smagicinteract__Status__c = 'SUBMITTED';
        Test.setCreatedDate(allSMS[4].Id, System.now().addDays(-6));

        allSMS[5].smagicinteract__Conversation__c = globalFreshmanConvo.Id;
        allSMS[5].smagicinteract__Status__c = 'ERROR';
        Test.setCreatedDate(allSMS[5].Id, System.now().addDays(-12));

        allSMS[6].smagicinteract__Conversation__c = globalFreshmanConvo.Id;
        allSMS[6].smagicinteract__Status__c = 'ERROR';
        Test.setCreatedDate(allSMS[6].Id, System.now().addDays(-12));

        allSMS[7].smagicinteract__Conversation__c = globalFreshmanConvo.Id;
        allSMS[7].smagicinteract__Status__c = 'ERROR';
        Test.setCreatedDate(allSMS[7].Id, System.now().addDays(-12));

        update allSMS;
    }

    @isTest
    private static void testQueuesJobs() {
        // Setup test metadata
        ScheduledStalledSMSDetector.TEST_METADATA = new List<SMS_Stall_Detection_Rule__mdt>{
            new SMS_Stall_Detection_Rule__mdt(
                MasterLabel = 'TEST_1',
                At_Least_N_Hours_Old__c = 0,
                Number_Of_Days__c = 31,
                Email_Addresses__c = 'test2@test.test',
                Report_Fields__c = 'Id, smagicinteract__PhoneNumber__c, smagicinteract__SMSText__c',
                Sender_Id_Units__c = 'Universal Learner Courses',
                Statuses__c = 'ERROR'
            ),
            new SMS_Stall_Detection_Rule__mdt(
                MasterLabel = 'TEST_2',
                At_Least_N_Hours_Old__c = 4,
                Number_Of_Days__c = 7,
                Email_Addresses__c = 'test1@test.test',
                Report_Fields__c = 'Id, SenderIdUnit__c, smagicinteract__SenderId__c, Name',
                Sender_Id_Units__c = 'EdPlus',
                Statuses__c = 'SUBMITTED'
            )
        };
        ScheduledStalledSMSDetector smsDetector = new ScheduledStalledSMSDetector();

        // Run job
        Test.startTest();
        String jobId = System.schedule('Stalled SMS Detection Test', '0 0 0 1 4 ? *', smsDetector);
        Test.stopTest();

        // Queues a batch job for each rule
        List<AsyncApexJob> apexJobs = [
            SELECT Id, JobType, MethodName, ParentJobId, Status, ApexClassId, ApexClass.Name
            FROM AsyncApexJob
            WHERE ApexClass.Name = 'ScheduledStalledSMSDetectorBatch'
        ];

        Assert.areEqual(2, apexJobs.size());
    }

    @isTest
    private static void testEmailsSent() {
        // Setup test metadata
        ScheduledStalledSMSDetector.TEST_METADATA = new List<SMS_Stall_Detection_Rule__mdt>{
            new SMS_Stall_Detection_Rule__mdt(
                MasterLabel = 'TEST_1',
                At_Least_N_Hours_Old__c = 0,
                Number_Of_Days__c = 31,
                Email_Addresses__c = 'test2@test.test',
                Report_Fields__c = 'Id, smagicinteract__PhoneNumber__c, smagicinteract__SMSText__c',
                Sender_Id_Units__c = 'Universal Learner Courses',
                Statuses__c = 'ERROR'
            ),
            new SMS_Stall_Detection_Rule__mdt(
                MasterLabel = 'TEST_2',
                At_Least_N_Hours_Old__c = 4,
                Number_Of_Days__c = 7,
                Email_Addresses__c = 'test1@test.test',
                Report_Fields__c = 'Id, SenderIdUnit__c, smagicinteract__SenderId__c, Name',
                Sender_Id_Units__c = 'EdPlus',
                Statuses__c = 'SUBMITTED'
            )
        };
        ScheduledStalledSMSDetector smsDetector = new ScheduledStalledSMSDetector();

        Datetime now = System.now();

        // Expected results for each rule
        List<smagicinteract__smsMagic__c> ulcSmsLs = [
            SELECT Id, smagicinteract__PhoneNumber__c, smagicinteract__SMSText__c
            FROM smagicinteract__smsMagic__c
            WHERE
                smagicinteract__Direction__c = 'OUT'
                AND CreatedDate > :now.addDays(-31)
                    .addHours(-1 * now.hour())
                    .addMinutes(-1 * now.minute())
                    .addSeconds(-1 * now.second())
                AND SenderIdUnit__c IN ('Universal Learner Courses')
                AND smagicinteract__Status__c IN ('ERROR')
        ];
        List<smagicinteract__smsMagic__c> edplusSmsLs = [
            SELECT Id, SenderIdUnit__c, smagicinteract__SenderId__c, Name, CreatedDate
            FROM smagicinteract__smsMagic__c
            WHERE
                smagicinteract__Direction__c = 'OUT'
                AND CreatedDate > :now.addDays(-7)
                    .addHours(-1 * now.hour())
                    .addMinutes(-1 * now.minute())
                    .addSeconds(-1 * now.second())
                AND CreatedDate < :now.addHours(-4)
                AND SenderIdUnit__c IN ('EdPlus')
                AND smagicinteract__Status__c IN ('SUBMITTED')
        ];

        Assert.isFalse(ulcSmsLs.isEmpty(), 'Must have results for test to be meaningful');
        Assert.isFalse(edplusSmsLs.isEmpty(), 'Must have results for test to be meaningful');

        // Run job
        Test.startTest();
        smsDetector.execute(null); // cannot use System.schedule since we want to make sure enqueued batch jobs are done at Test.stopTest()
        Test.stopTest();

        // Find created emails and attachments
        Map<Id, EmailMessage> sentEmailsMp = new Map<Id, EmailMessage>(
            [SELECT Id, Subject, TextBody FROM EmailMessage]
        );

        Map<Id, Id> emailIdToContentDocumentIdMp = new Map<Id, Id>();
        for (ContentDocumentLink cdl : [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :sentEmailsMp.keySet()
        ]) {
            emailIdToContentDocumentIdMp.put(cdl.LinkedEntityId, cdl.ContentDocumentId);
        }

        Map<Id, ContentVersion> contentDocumentIdToContentVersion = new Map<Id, ContentVersion>();
        for (ContentVersion att : [
            SELECT ContentDocumentId, Id, VersionData
            FROM ContentVersion
            WHERE ContentDocumentId IN :emailIdToContentDocumentIdMp.values()
        ]) {
            contentDocumentIdToContentVersion.put(att.ContentDocumentId, att);
        }

        Map<Id, ContentVersion> emailIdToAttachmentMp = new Map<Id, ContentVersion>();
        for (Id emailId : emailIdToContentDocumentIdMp.keySet()) {
            if (contentDocumentIdToContentVersion.containsKey(emailIdToContentDocumentIdMp.get(emailId)))
                emailIdToAttachmentMp.put(
                    emailId,
                    contentDocumentIdToContentVersion.get(emailIdToContentDocumentIdMp.get(emailId))
                );
        }

        EmailMessage ulcEmail = null, edplusEmail = null;

        for (EmailMessage em : sentEmailsMp.values()) {
            if (em.Subject.contains('TEST_1'))
                ulcEmail = em;
            else if (em.Subject.contains('TEST_2'))
                edplusEmail = em;
            else
                Assert.isTrue(
                    false,
                    'Created an email whose subject indicates it is for neither custom metadata rule. Subject was "' +
                        em.Subject +
                        '"'
                );
        }

        Assert.areNotEqual(null, ulcEmail);
        Assert.isTrue(emailIdToAttachmentMp.containsKey(ulcEmail.Id));

        Assert.areNotEqual(null, edplusEmail);
        Assert.isTrue(emailIdToAttachmentMp.containsKey(edplusEmail.Id));

        Assert.isTrue(
            ulcEmail.TextBody.contains('There are ' + ulcSmsLs.size() + ' SMS stalled'),
            'Expected email body to contain "There are ' +
                ulcSmsLs.size() +
                ' SMS stalled" but it instead said "' +
                ulcEmail.TextBody +
                '"'
        );
        Assert.isTrue(
            edplusEmail.TextBody.contains('There are ' + edplusSmsLs.size() + ' SMS stalled'),
            'Expected email body to contain "There are ' +
                edplusSmsLs.size() +
                ' SMS stalled" but it instead said "' +
                edplusEmail.TextBody +
                '"'
        );

        // Check file contents for ULC attachment
        ContentVersion ulcAttachment = emailIdToAttachmentMp.get(ulcEmail.Id);
        List<String> ulcRows = ulcAttachment.VersionData.toString().split('\n');

        Assert.areEqual(ulcSmsLs.size() + 1, ulcRows.size());

        // Correct header row
        List<String> ulcHeaderRow = ulcRows[0].split(',');
        Assert.areEqual('Id', ulcHeaderRow[0]);
        Assert.areEqual('smagicinteract__PhoneNumber__c', ulcHeaderRow[1]);
        Assert.areEqual('smagicinteract__SMSText__c', ulcHeaderRow[2]);
        // Contains a row for each expected SMS
        for (smagicinteract__smsMagic__c expectedSms : ulcSmsLs) {
            List<String> matchedRow = null;
            for (Integer i = 1; i < ulcRows.size(); i++) {
                List<String> eachRow = ulcRows[i].split(',');
                if (eachRow[0] == expectedSms.Id) {
                    matchedRow = eachRow;
                    break;
                }
            }

            Assert.areNotEqual(null, matchedRow);
            Assert.areEqual(expectedSms.Id, matchedRow[0]);
            Assert.areEqual(expectedSms.smagicinteract__PhoneNumber__c, matchedRow[1]);
            Assert.areEqual(expectedSms.smagicinteract__SMSText__c, matchedRow[2]);
        }

        // Check file contents for EdPlus attachment
        ContentVersion edplusAttachment = emailIdToAttachmentMp.get(edplusEmail.Id);
        List<String> edplusRows = edplusAttachment.VersionData.toString().split('\n');

        Assert.areEqual(edplusSmsLs.size() + 1, edplusRows.size());

        // Correct header row
        List<String> edplusHeaderRow = edplusRows[0].split(',');
        Assert.areEqual('Id', edplusHeaderRow[0]);
        Assert.areEqual('SenderIdUnit__c', edplusHeaderRow[1]);
        Assert.areEqual('smagicinteract__SenderId__c', edplusHeaderRow[2]);
        Assert.areEqual('Name', edplusHeaderRow[3]);
        // Contains a row for each expected SMS
        for (smagicinteract__smsMagic__c expectedSms : edplusSmsLs) {
            List<String> matchedRow = null;
            for (Integer i = 1; i < edplusRows.size(); i++) {
                List<String> eachRow = edplusRows[i].split(',');
                if (eachRow[0] == expectedSms.Id) {
                    matchedRow = eachRow;
                    break;
                }
            }

            Assert.areNotEqual(null, matchedRow);
            Assert.areEqual(expectedSms.Id, matchedRow[0]);
            Assert.areEqual(expectedSms.SenderIdUnit__c, matchedRow[1]);
            Assert.areEqual(expectedSms.smagicinteract__SenderId__c, matchedRow[2]);
            Assert.areEqual(expectedSms.Name, matchedRow[3]);
        }
    }

    @isTest
    private static void testHighHeapUsage() {
        // Setup test metadata
        ScheduledStalledSMSDetector.TEST_METADATA = new List<SMS_Stall_Detection_Rule__mdt>{
            new SMS_Stall_Detection_Rule__mdt(
                MasterLabel = 'TEST_1',
                Email_Addresses__c = 'test2@test.test',
                Report_Fields__c = 'Id, smagicinteract__PhoneNumber__c, smagicinteract__SMSText__c',
                Sender_Id_Units__c = 'Universal Learner Courses',
                Statuses__c = 'ERROR'
            )
        };
        ScheduledStalledSMSDetector smsDetector = new ScheduledStalledSMSDetector();
        ScheduledStalledSMSDetectorBatch.FORCE_WASTE_HEAP_SPACE = true;

        Datetime now = System.now();

        // Expected results for each rule
        List<smagicinteract__smsMagic__c> expectedSmsLs = [
            SELECT Id, smagicinteract__PhoneNumber__c, smagicinteract__Status__c, smagicinteract__statusMessage__c
            FROM smagicinteract__smsMagic__c
            WHERE
                smagicinteract__Direction__c = 'OUT'
                AND SenderIdUnit__c IN ('Universal Learner Courses')
                AND smagicinteract__Status__c IN ('ERROR')
        ];

        Assert.isFalse(expectedSmsLs.isEmpty(), 'Must have results for test to be meaningful');

        // Run job
        Test.startTest();
        smsDetector.execute(null); // cannot use System.schedule since we want to make sure enqueued batch jobs are done at Test.stopTest()
        Test.stopTest();

        // Created emails and attachments
        List<EmailMessage> emailsLs = [SELECT Id, Subject, TextBody FROM EmailMessage LIMIT 1];
        List<ContentVersion> attachmentLs = [
            SELECT ContentDocumentId, Id, VersionData
            FROM ContentVersion
            LIMIT 1
        ];

        Assert.isFalse(emailsLs.isEmpty());
        Assert.isFalse(attachmentLs.isEmpty());

        EmailMessage em = emailsLs[0];
        ContentVersion att = attachmentLs[0];

        Assert.isTrue(
            em.TextBody.contains('There are ' + expectedSmsLs.size() + ' SMS stalled'),
            'Expected email body to contain "There are ' +
                expectedSmsLs.size() +
                ' SMS stalled" but it instead said "' +
                em.TextBody +
                '"'
        );

        // Check file contents for ULC attachment
        List<String> rows = att.VersionData.toString().split('\n');

        Assert.areEqual(expectedSmsLs.size() + 1, rows.size());

        // Correct header row
        List<String> headerRow = rows[0].split(',');
        Assert.areEqual('Id', headerRow[0]);
        Assert.areEqual('smagicinteract__PhoneNumber__c', headerRow[1]);
        Assert.areEqual('smagicinteract__Status__c', headerRow[2]);
        Assert.areEqual('smagicinteract__statusMessage__c', headerRow[3]);
        // Contains a row for each expected SMS
        for (smagicinteract__smsMagic__c expectedSms : expectedSmsLs) {
            List<String> matchedRow = null;
            for (Integer i = 1; i < rows.size(); i++) {
                List<String> eachRow = rows[i].split(',');
                if (eachRow[0] == expectedSms.Id) {
                    matchedRow = eachRow;
                    break;
                }
            }

            Assert.areNotEqual(null, matchedRow);
            Assert.areEqual(expectedSms.Id, matchedRow[0]);
            Assert.areEqual(expectedSms.smagicinteract__PhoneNumber__c, matchedRow[1]);
            Assert.areEqual(expectedSms.smagicinteract__Status__c, matchedRow[2]);
            Assert.areEqual(expectedSms.smagicinteract__statusMessage__c, matchedRow[3]);
        }
    }
}
