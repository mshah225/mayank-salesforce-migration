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
            SenderIdUnit__c = 'Global Freshman Academy',
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
        for (Integer i = 0; i < 6; i++) {
            // Convert to json and back so we can set a CreatedDate (a normally unwritable field)
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
        allSMS[0].smagicinteract__Status__c = 'QUEUED';
        Test.setCreatedDate(allSMS[0].Id, System.now().addHours(-3));

        allSMS[1].smagicinteract__Conversation__c = edPlusConvo.Id;
        allSMS[1].smagicinteract__Status__c = 'QUEUED';

        allSMS[2].smagicinteract__Conversation__c = edPlusConvo.Id;
        allSMS[2].smagicinteract__Status__c = 'QUEUED';
        Test.setCreatedDate(allSMS[2].Id, System.now().addDays(-8));

        allSMS[3].smagicinteract__Conversation__c = fysConvo.Id;
        allSMS[3].smagicinteract__Status__c = 'QUEUED';
        Test.setCreatedDate(allSMS[3].Id, System.now().addDays(-6));

        allSMS[4].smagicinteract__Conversation__c = fysConvo.Id;
        allSMS[4].smagicinteract__Status__c = 'SUBMITTED';
        Test.setCreatedDate(allSMS[4].Id, System.now().addDays(-6));

        allSMS[5].smagicinteract__Conversation__c = globalFreshmanConvo.Id;
        allSMS[5].smagicinteract__Status__c = 'ERROR';
        Test.setCreatedDate(allSMS[5].Id, System.now().addDays(-12));

        update allSMS;
    }

    @isTest
    private static void testEmailSends() {
        ScheduledStalledSMSDetector smsDetector = new ScheduledStalledSMSDetector();

        Test.startTest();

        smsDetector.primaryMethod();

        // Two test meatadata can have emails - but only one gets sent since only one matches test data
        System.assertEquals(1, Limits.getEmailInvocations());

        Test.stopTest();
    }

    @isTest
    private static void SMSDetectionRuleSetFiltering() {
        SMS_Stall_Detection_Rule__mdt metadata1 = new SMS_Stall_Detection_Rule__mdt(
            Email_Addresses__c = 'test1@test.com',
            Report_Fields__c = 'Id,smagicinteract__SMSText__c',
            Sender_Id_Units__c = 'EdPlus'
        );
        SMS_Stall_Detection_Rule__mdt metadata2 = new SMS_Stall_Detection_Rule__mdt(
            Email_Addresses__c = 'test2@test.com',
            Report_Fields__c = 'Id,smagicinteract__SMSText__c',
            Statuses__c = 'QUEUED'
        );
        SMS_Stall_Detection_Rule__mdt metadata3 = new SMS_Stall_Detection_Rule__mdt(
            Email_Addresses__c = 'test3@test.com',
            Report_Fields__c = 'Id,smagicinteract__SMSText__c',
            At_Least_N_Hours_Old__c = 1
        );
        SMS_Stall_Detection_Rule__mdt metadata4 = new SMS_Stall_Detection_Rule__mdt(
            Email_Addresses__c = 'test4@test.com',
            Report_Fields__c = 'Id,smagicinteract__SMSText__c',
            Number_Of_Days__c = 7
        );

        ScheduledStalledSMSDetector.SMSDetectionRuleSet ruleSet1 = new ScheduledStalledSMSDetector.SMSDetectionRuleSet(
            metadata1
        );
        ScheduledStalledSMSDetector.SMSDetectionRuleSet ruleSet2 = new ScheduledStalledSMSDetector.SMSDetectionRuleSet(
            metadata2
        );
        ScheduledStalledSMSDetector.SMSDetectionRuleSet ruleSet3 = new ScheduledStalledSMSDetector.SMSDetectionRuleSet(
            metadata3
        );
        ScheduledStalledSMSDetector.SMSDetectionRuleSet ruleSet4 = new ScheduledStalledSMSDetector.SMSDetectionRuleSet(
            metadata4
        );

        ScheduledStalledSMSDetector.SMSDetectionRuleSet ruleSuperSet = new ScheduledStalledSMSDetector.SMSDetectionRuleSet(
            new List<ScheduledStalledSMSDetector.SMSDetectionRuleSet>{ ruleSet1, ruleSet2, ruleSet3, ruleSet4 }
        );

        List<smagicinteract__smsMagic__c> resultsSuperSet = Database.query(ruleSuperSet.getQuery());
        List<smagicinteract__smsMagic__c> results1 = ruleSet1.filter(resultsSuperSet);
        List<smagicinteract__smsMagic__c> results2 = ruleSet2.filter(resultsSuperSet);
        List<smagicinteract__smsMagic__c> results3 = ruleSet3.filter(resultsSuperSet);
        List<smagicinteract__smsMagic__c> results4 = ruleSet4.filter(resultsSuperSet);

        // Proper sizes
        System.assertEquals(6, resultsSuperSet.size());
        System.assertEquals(3, results1.size());
        System.assertEquals(4, results2.size());
        System.assertEquals(5, results3.size());
        System.assertEquals(4, results4.size());

        // Proper SMS
        for (smagicinteract__smsMagic__c sms : results1) {
            System.assertEquals('EdPlus', sms.SenderIdUnit__c);
            System.assert(
                sms.smagicinteract__SMSText__c == 'Test0' ||
                sms.smagicinteract__SMSText__c == 'Test1' ||
                sms.smagicinteract__SMSText__c == 'Test2'
            );
        }
        for (smagicinteract__smsMagic__c sms : results2) {
            System.assertEquals('QUEUED', sms.smagicinteract__Status__c);
            System.assert(
                sms.smagicinteract__SMSText__c == 'Test0' ||
                sms.smagicinteract__SMSText__c == 'Test1' ||
                sms.smagicinteract__SMSText__c == 'Test2' ||
                sms.smagicinteract__SMSText__c == 'Test3'
            );
        }
        for (smagicinteract__smsMagic__c sms : results3) {
            System.assert(sms.CreatedDate < System.now().addHours(-1));
            System.assert(
                sms.smagicinteract__SMSText__c == 'Test0' ||
                sms.smagicinteract__SMSText__c == 'Test2' ||
                sms.smagicinteract__SMSText__c == 'Test3' ||
                sms.smagicinteract__SMSText__c == 'Test4' ||
                sms.smagicinteract__SMSText__c == 'Test5'
            );
        }
        for (smagicinteract__smsMagic__c sms : results4) {
            System.assert(sms.CreatedDate > System.now().addDays(-7));
            System.assert(
                sms.smagicinteract__SMSText__c == 'Test0' ||
                sms.smagicinteract__SMSText__c == 'Test1' ||
                sms.smagicinteract__SMSText__c == 'Test3' ||
                sms.smagicinteract__SMSText__c == 'Test4'
            );
        }
    }

    @isTest
    private static void SMSDetectionRuleSetCreation() {
        SMS_Stall_Detection_Rule__mdt metadata1 = new SMS_Stall_Detection_Rule__mdt(
            At_Least_N_Hours_Old__c = 1,
            Number_Of_Days__c = 7,
            Email_Addresses__c = 'test1@test.com, test2@test.com',
            Report_Fields__c = 'Id,SenderIdUnit__c,Name',
            Sender_Id_Units__c = 'EdPlus',
            Statuses__c = 'SUBMITTED,ERROR'
        );
        SMS_Stall_Detection_Rule__mdt metadata2 = new SMS_Stall_Detection_Rule__mdt(
            Email_Addresses__c = 'test1@test.com, test3@test.com',
            Report_Fields__c = 'smagicinteract__PhoneNumber__c'
        );
        SMS_Stall_Detection_Rule__mdt metadata3 = new SMS_Stall_Detection_Rule__mdt(
            Email_Addresses__c = 'test2@test.com, test4@test.com',
            Report_Fields__c = 'SenderIdUnit__c',
            At_Least_N_Hours_Old__c = 0,
            Number_Of_Days__c = 12,
            Sender_Id_Units__c = 'FYS,EdPlus',
            Statuses__c = 'QUEUED,ERROR'
        );

        ScheduledStalledSMSDetector.SMSDetectionRuleSet ruleSet1 = new ScheduledStalledSMSDetector.SMSDetectionRuleSet(
            metadata1
        );
        ScheduledStalledSMSDetector.SMSDetectionRuleSet ruleSet2 = new ScheduledStalledSMSDetector.SMSDetectionRuleSet(
            metadata2
        );
        ScheduledStalledSMSDetector.SMSDetectionRuleSet ruleSet3 = new ScheduledStalledSMSDetector.SMSDetectionRuleSet(
            metadata3
        );

        ScheduledStalledSMSDetector.SMSDetectionRuleSet ruleSuperSet = new ScheduledStalledSMSDetector.SMSDetectionRuleSet(
            new List<ScheduledStalledSMSDetector.SMSDetectionRuleSet>{ ruleSet1, ruleSet2 }
        );
        ScheduledStalledSMSDetector.SMSDetectionRuleSet ruleSuperSet2 = new ScheduledStalledSMSDetector.SMSDetectionRuleSet(
            new List<ScheduledStalledSMSDetector.SMSDetectionRuleSet>{ ruleSet1, ruleSet3 }
        );

        // RuleSet 1
        System.assertEquals(1, ruleSet1.minHoursOld, 'Should have minimum hours old equal to 1');
        System.assertEquals(7, ruleSet1.maxDaysOld, 'Should have maximum days old equal to 7');
        System.assertEquals(2, ruleSet1.emailsSet.size(), 'Should have 2 emails set');
        System.assert(ruleSet1.emailsSet.contains('test1@test.com'), 'Should contain \'test1@test.com\' email');
        System.assert(ruleSet1.emailsSet.contains('test2@test.com'), 'Should contain \'test2@test.com\' email');
        System.assertEquals(3, ruleSet1.queryFields.size(), 'Should have 3 fields obtained');
        System.assert(ruleSet1.queryFields.contains('Id'), 'Should contain \'Id\' field');
        System.assert(ruleSet1.queryFields.contains('SenderIdUnit__c'), 'Should contain \'SenderIdUnit__c\' field');
        System.assert(ruleSet1.queryFields.contains('Name'), 'Should contain \'Name\' field');
        System.assertEquals(1, ruleSet1.constraintSenderIdUnits.size(), 'Should have 1 Sender_Id_Unit contraint');
        System.assert(ruleSet1.constraintSenderIdUnits.contains('EdPlus'), 'Should contain \'EdPlus\' constraint');
        System.assertEquals(2, ruleSet1.constraintStatuses.size(), 'Should have 2 Status constraints');
        System.assert(ruleSet1.constraintStatuses.contains('SUBMITTED'), 'Should contain \'SUBMITTED\' constraint');
        System.assert(ruleSet1.constraintStatuses.contains('ERROR'), 'Should contain \'ERROR\' constraint');

        // RuleSet 2
        System.assertEquals(null, ruleSet2.minHoursOld, 'Should not have minimum hours old set');
        System.assertEquals(null, ruleSet2.maxDaysOld, 'Should not have maximum days old equal set');
        System.assertEquals(2, ruleSet2.emailsSet.size(), 'Should have 1 emails set');
        System.assert(ruleSet2.emailsSet.contains('test1@test.com'), 'Should contain \'test1@test.com\' email');
        System.assert(ruleSet2.emailsSet.contains('test3@test.com'), 'Should contain \'test3@test.com\' email');
        System.assertEquals(1, ruleSet2.queryFields.size(), 'Should have 1 fields obtained');
        System.assert(
            ruleSet2.queryFields.contains('smagicinteract__PhoneNumber__c'),
            'Should contain \'smagicinteract__PhoneNumber__c\' field'
        );
        System.assertEquals(0, ruleSet2.constraintSenderIdUnits.size(), 'Should not have Sender_Id_Unit contraint');
        System.assertEquals(0, ruleSet2.constraintStatuses.size(), 'Should not have Status constraints');

        // RuleSet 3
        System.assertEquals(0, ruleSet3.minHoursOld, 'Should have minimum hours old equal to 0');
        System.assertEquals(12, ruleSet3.maxDaysOld, 'Should have maximum days old equal to 12');
        System.assertEquals(2, ruleSet3.emailsSet.size(), 'Should have 2 emails set');
        System.assert(ruleSet3.emailsSet.contains('test2@test.com'), 'Should contain \'test2@test.com\' email');
        System.assert(ruleSet3.emailsSet.contains('test4@test.com'), 'Should contain \'test4@test.com\' email');
        System.assertEquals(1, ruleSet3.queryFields.size(), 'Should have 1 fields obtained');
        System.assert(ruleSet3.queryFields.contains('SenderIdUnit__c'), 'Should contain \'SenderIdUnit__c\' field');
        System.assertEquals(2, ruleSet3.constraintSenderIdUnits.size(), 'Should have 2 Sender_Id_Unit contraint');
        System.assert(ruleSet3.constraintSenderIdUnits.contains('EdPlus'), 'Should contain \'EdPlus\' constraint');
        System.assert(ruleSet3.constraintSenderIdUnits.contains('FYS'), 'Should contain \'FYS\' constraint');
        System.assertEquals(2, ruleSet3.constraintStatuses.size(), 'Should have 2 Status constraints');
        System.assert(ruleSet3.constraintStatuses.contains('QUEUED'), 'Should contain \'QUEUED\' constraint');
        System.assert(ruleSet3.constraintStatuses.contains('ERROR'), 'Should contain \'ERROR\' constraint');

        // SuperRuleSet
        System.assertEquals(null, ruleSuperSet.minHoursOld, 'Should not have minimum hours old set');
        System.assertEquals(null, ruleSuperSet.maxDaysOld, 'Should not have maximum days old equal set');
        System.assertEquals(3, ruleSuperSet.emailsSet.size(), 'Should have 2 emails set');
        System.assert(ruleSuperSet.emailsSet.contains('test1@test.com'), 'Should contain \'test1@test.com\' email');
        System.assert(ruleSuperSet.emailsSet.contains('test2@test.com'), 'Should contain \'test2@test.com\' email');
        System.assert(ruleSuperSet.emailsSet.contains('test3@test.com'), 'Should contain \'test3@test.com\' email');
        System.assertEquals(4, ruleSuperSet.queryFields.size(), 'Should have 4 fields obtained');
        System.assert(ruleSuperSet.queryFields.contains('Id'), 'Should contain \'Id\' field');
        System.assert(ruleSuperSet.queryFields.contains('SenderIdUnit__c'), 'Should contain \'SenderIdUnit__c\' field');
        System.assert(ruleSuperSet.queryFields.contains('Name'), 'Should contain \'Name\' field');
        System.assert(
            ruleSuperSet.queryFields.contains('smagicinteract__PhoneNumber__c'),
            'Should contain \'smagicinteract__PhoneNumber__c\' field'
        );
        System.assertEquals(0, ruleSuperSet.constraintSenderIdUnits.size(), 'Should have no Sender_Id_Unit contraint');
        System.assertEquals(0, ruleSuperSet.constraintStatuses.size(), 'Should have no Status constraints');

        // SuperRuleSet2
        System.assertEquals(0, ruleSuperSet2.minHoursOld, 'Should have minimum hours old equal to 0');
        System.assertEquals(12, ruleSuperSet2.maxDaysOld, 'Should have maximum days old equal to 12');
        System.assertEquals(3, ruleSuperSet2.emailsSet.size(), 'Should have 3 emails set');
        System.assert(ruleSuperSet2.emailsSet.contains('test1@test.com'), 'Should contain \'test1@test.com\' email');
        System.assert(ruleSuperSet2.emailsSet.contains('test2@test.com'), 'Should contain \'test2@test.com\' email');
        System.assert(ruleSuperSet2.emailsSet.contains('test4@test.com'), 'Should contain \'test4@test.com\' email');
        System.assertEquals(3, ruleSuperSet2.queryFields.size(), 'Should have 3 fields obtained');
        System.assert(ruleSuperSet2.queryFields.contains('Id'), 'Should contain \'Id\' field');
        System.assert(
            ruleSuperSet2.queryFields.contains('SenderIdUnit__c'),
            'Should contain \'SenderIdUnit__c\' field'
        );
        System.assert(ruleSuperSet2.queryFields.contains('Name'), 'Should contain \'Name\' field');
        System.assertEquals(2, ruleSuperSet2.constraintSenderIdUnits.size(), 'Should have 2 Sender_Id_Unit contraint');
        System.assert(ruleSuperSet2.constraintSenderIdUnits.contains('EdPlus'), 'Should contain \'EdPlus\' constraint');
        System.assert(ruleSuperSet2.constraintSenderIdUnits.contains('FYS'), 'Should contain \'FYS\' constraint');
        System.assertEquals(3, ruleSuperSet2.constraintStatuses.size(), 'Should have 3 Status constraints');
        System.assert(
            ruleSuperSet2.constraintStatuses.contains('SUBMITTED'),
            'Should contain \'SUBMITTED\' constraint'
        );
        System.assert(ruleSuperSet2.constraintStatuses.contains('QUEUED'), 'Should contain \'QUEUED\' constraint');
        System.assert(ruleSuperSet2.constraintStatuses.contains('ERROR'), 'Should contain \'ERROR\' constraint');
    }

    @isTest
    private static void SMSDetectionRuleSetQueryConstruction() {
        SMS_Stall_Detection_Rule__mdt metadata1 = new SMS_Stall_Detection_Rule__mdt(
            At_Least_N_Hours_Old__c = 1,
            Number_Of_Days__c = 7,
            Email_Addresses__c = 'test1@test.com, test2@test.com',
            Report_Fields__c = 'Id,SenderIdUnit__c,Name',
            Sender_Id_Units__c = 'EdPlus',
            Statuses__c = 'SUBMITTED,ERROR'
        );
        SMS_Stall_Detection_Rule__mdt metadata2 = new SMS_Stall_Detection_Rule__mdt(
            Email_Addresses__c = 'test1@test.com, test3@test.com',
            Report_Fields__c = 'smagicinteract__PhoneNumber__c',
            Statuses__c = 'QUEUED'
        );

        ScheduledStalledSMSDetector.SMSDetectionRuleSet ruleSet1 = new ScheduledStalledSMSDetector.SMSDetectionRuleSet(
            metadata1
        );
        ScheduledStalledSMSDetector.SMSDetectionRuleSet ruleSet2 = new ScheduledStalledSMSDetector.SMSDetectionRuleSet(
            metadata2
        );

        ScheduledStalledSMSDetector.SMSDetectionRuleSet ruleSuperSet = new ScheduledStalledSMSDetector.SMSDetectionRuleSet(
            new List<ScheduledStalledSMSDetector.SMSDetectionRuleSet>{ ruleSet1, ruleSet2 }
        );

        String query1 = ruleSet1.getQuery();
        String query2 = ruleSet2.getQuery();
        String superQuery = ruleSuperSet.getQuery();

        // Query 1
        System.assert(
            query1.substring(0, query1.indexOf('WHERE')).contains('Id,SenderIdUnit__c,Name'),
            'Querying incorrect fields'
        );
        System.assert(
            query1.substring(query1.indexOf('WHERE')).contains('( SenderIdUnit__c=\'EdPlus\' )'),
            'Incorrect constraints'
        );
        System.assert(
            query1.substring(query1.indexOf('WHERE'))
                .contains('( smagicinteract__Status__c=\'SUBMITTED\' OR smagicinteract__Status__c=\'ERROR\' )'),
            'Incorrect constraints'
        );
        System.assert(query1.substring(query1.indexOf('WHERE')).contains('CreatedDate > '), 'Incorrect constraints');
        System.assert(query1.substring(query1.indexOf('WHERE')).contains('CreatedDate < '), 'Incorrect constraints');

        // Query 2
        System.assert(
            query2.substring(0, query2.indexOf('WHERE')).contains('smagicinteract__PhoneNumber__c'),
            'Querying incorrect fields'
        );
        System.assert(!query2.substring(query2.indexOf('WHERE')).contains('SenderIdUnit__c'), 'Incorrect constraints');
        System.assert(
            query2.substring(query2.indexOf('WHERE')).contains('( smagicinteract__Status__c=\'QUEUED\' )'),
            'Incorrect constraints'
        );
        System.assert(!query2.substring(query2.indexOf('WHERE')).contains('CreatedDate > '), 'Incorrect constraints');
        System.assert(!query2.substring(query2.indexOf('WHERE')).contains('CreatedDate < '), 'Incorrect constraints');

        // Super Query
        System.assert(
            superQuery.substring(0, superQuery.indexOf('WHERE'))
                .contains('Id,SenderIdUnit__c,Name,smagicinteract__PhoneNumber__c'),
            'Querying incorrect fields'
        );
        System.assert(
            !superQuery.substring(superQuery.indexOf('WHERE')).contains('SenderIdUnit__c'),
            'Incorrect constraints'
        );
        System.assert(
            superQuery.substring(superQuery.indexOf('WHERE'))
                .contains(
                    '( smagicinteract__Status__c=\'SUBMITTED\' OR smagicinteract__Status__c=\'ERROR\' OR smagicinteract__Status__c=\'QUEUED\' )'
                ),
            'Incorrect constraints'
        );
        System.assert(
            !superQuery.substring(superQuery.indexOf('WHERE')).contains('CreatedDate > '),
            'Incorrect constraints'
        );
        System.assert(
            !superQuery.substring(superQuery.indexOf('WHERE')).contains('CreatedDate < '),
            'Incorrect constraints'
        );
    }

    @isTest
    private static void SMSDetectionRuleSetDescribeSMS() {
        ScheduledStalledSMSDetector.SMSDetectionRuleSet ruleSet1 = new ScheduledStalledSMSDetector.SMSDetectionRuleSet(
            new SMS_Stall_Detection_Rule__mdt(
                Email_Addresses__c = 'test1@test.com, test2@test.com',
                Report_Fields__c = 'smagicinteract__SMSText__c,smagicinteract__Direction__c,smagicinteract__Status__c'
            )
        );

        smagicinteract__smsMagic__c sms = new smagicinteract__smsMagic__c(
            smagicinteract__Direction__c = 'OUT',
            smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey(),
            smagicinteract__SenderId__c = 'Test',
            smagicinteract__SMSText__c = 'Test123',
            smagicinteract__Source__c = '9000',
            smagicinteract__PhoneNumber__c = '9192939495',
            smagicinteract__Unformatted_Phone_Number__c = '19192939495',
            smagicinteract__Status__c = 'QUEUED'
        );

        String header = ruleSet1.describeSMSHeader();
        String description = ruleSet1.describeSMS(sms);

        List<String> headerSplit = header.split(',');
        List<String> descriptionSplit = description.split(',');

        System.assertEquals(descriptionSplit.indexOf('Test123'), headerSplit.indexOf('smagicinteract__SMSText__c'));
        System.assertEquals(descriptionSplit.indexOf('OUT'), headerSplit.indexOf('smagicinteract__Direction__c'));
        System.assertEquals(descriptionSplit.indexOf('QUEUED'), headerSplit.indexOf('smagicinteract__Status__c'));
    }
}
