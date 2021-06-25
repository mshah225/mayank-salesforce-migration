@isTest
public with sharing class Test_LeadHandler {
    static Integer TRIGGERLOAD = 5;

    // Build Leads
    static List<Lead> createLeads(Integer quantity) {
        List<Lead> leadList = new List<Lead>();

        for (Integer i = 0; i < quantity; i++) {
            Lead l = new Lead(
                LastName = 'LName' + i,
                FirstName = 'FName' + i,
                Company = 'Company',
                Email = 'test' + i + '@test.test',
                LeadSource = 'Email'
            );
            leadList.add(l);
        }

        return leadList;
    }

    // Build Lead Interests
    static Id insertProgram(String programName, String programCode) {
        Program__c testProgram = new Program__c(Name = programName, Program_Code__c = programCode);
        insert testProgram;
        return testProgram.Id;
    }

    static Id insertPlan(String planName, String planCode, Id programId) {
        Plan__c testPlan = new Plan__c(
            Name = planName,
            Plan_Code__c = planCode,
            Plan_Effective_Date__c = Date.today(),
            Program__c = programId
        );
        insert testPlan;
        return testPlan.Id;
    }

    static List<Lead_Interest__c> createLeadInterests(List<Lead> associatedLeads) {
        List<Lead_Interest__c> liList = new List<Lead_Interest__c>();

        Id program1 = insertProgram('Program1', 'P1');
        Id plan1 = insertPlan('Plan1', 'PL1', program1);

        for (Lead l : associatedLeads) {
            Lead_Interest__c li = new Lead_Interest__c(College__c = program1, Plan__c = plan1, Leads__c = l.Id);
            liList.add(li);
        }

        return liList;
    }

    @isTest
    static void testManualLeadConversion() {
        Lead[] leadList = createLeads(TRIGGERLOAD);
        insert leadList;

        Lead_Interest__c[] liList = createLeadInterests(leadList);
        insert liList;

        Set<Id> leadIds = new Set<Id>();

        // Perform Conversion
        for (Lead l : leadList) {
            l.Convert_Perform_Conversion__c = true;
            leadIds.add(l.Id);
        }

        Test.startTest();
        update leadList;
        Test.stopTest();

        //Check conversion results
        List<Lead> convertedLeads = new List<Lead>([SELECT Id FROM Lead WHERE Id IN :leadIds AND IsConverted = TRUE]);

        System.assertEquals(TRIGGERLOAD, convertedLeads.size());
    }

    @isTest
    static void testConvertMultipleLeadsToOneAccount() {
        Integer DUPETHRESHOLD = 1;

        List<Account> institutionAccounts = new AccountFactory.Institution().create();
        insert institutionAccounts;

        List<Contact> testContacts = ContactService.createTestContacts(TRIGGERLOAD);
        insert testContacts;

        List<Lead> testLeads = LeadService.createTestLeadsToConvert(testContacts);
        insert testLeads;

        testContacts = [SELECT Name, FirstName, LastName, Email, AccountId FROM Contact];

        List<Opportunity> testOpptys = OpportunityService.createTestUndergraduateProspects(testContacts);
        insert testOpptys;

        Set<Id> leadIds = new Set<Id>();

        // Peform conversion
        for (Lead l : testLeads) {
            l.Convert_Perform_Conversion__c = true;
            l.Last_Institution_Attended__c = institutionAccounts[0].Id;
            leadIds.add(l.Id);
        }

        // Create duplicates
        for (Integer i = 1; i < DUPETHRESHOLD; i++) {
            testLeads.get(i).Convert_Contact__c = testContacts.get(0).Id;
        }

        Test.startTest();
        update testLeads;
        Test.stopTest();

        //Check conversion results
        List<Lead> convertedLeads = new List<Lead>([SELECT Id FROM Lead WHERE Id IN :leadIds AND IsConverted = TRUE]);

        System.assertEquals(TRIGGERLOAD, convertedLeads.size(), 'Leads were not converted correctly');
    }

    @isTest
    static void testLeadToOppFieldMapping() {
        Term__c testTerm = TermService.createTestTerm();
        insert testTerm;

        List<Contact> testContacts = ContactService.createTestContacts(10);
        insert testContacts;

        testContacts = [SELECT Name, FirstName, LastName, Email, AccountId FROM Contact];

        List<Opportunity> testOpptys = OpportunityService.createTestUndergraduateProspects(testContacts);
        insert testOpptys;

        List<Lead> testLeads = LeadService.createTestLeadsToConvert(testContacts);

        for (Lead l : testLeads) {
            l.Enrollment_Term__c = testTerm.Id;
        }

        insert testLeads;

        Set<Id> leadIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();

        // Perform conversion
        for (Lead l : testLeads) {
            l.Convert_Perform_Conversion__c = true;
            leadIds.add(l.Id);
            contactIds.add(l.Convert_Contact__c);
        }

        Test.startTest();
        update testLeads;
        Test.stopTest();

        List<Opportunity> oppsCreated = [
            SELECT
                Contact__c,
                Career__c,
                Term__c,
                Online_Degree__c,
                International_Student__c,
                First_Generation__c,
                Potential_National_Scholar__c,
                Potential_WUE__c,
                Search_Segment__c,
                Self_Reported_SES__c,
                Military_Status__c
            FROM Opportunity
            WHERE Contact__c IN :contactIds
        ];

        Lead expectedData = testLeads.get(0);
        Opportunity actualData = oppsCreated.get(0);

        System.assertEquals(
            expectedData.Convert_Contact__c,
            actualData.Contact__c,
            'Contact was not associated correctly'
        );
    }

    @isTest
    static void testCreationOfPERecordsOnConversion() {
        List<Account> institutionAccounts = new AccountFactory.Institution().create();
        insert institutionAccounts;

        List<Contact> testContacts = ContactService.createTestContacts(5);
        insert testContacts;

        testContacts = [SELECT Name, FirstName, LastName, Email, AccountId FROM Contact];

        List<Opportunity> testOpptys = OpportunityService.createTestUndergraduateProspects(testContacts);
        insert testOpptys;

        List<Lead> testLeads = LeadService.createTestLeadsToConvert(testContacts);
        insert testLeads;

        Set<Id> leadIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();

        // Perform conversion
        for (Lead l : testLeads) {
            l.Convert_Perform_Conversion__c = true;
            l.Last_Institution_Attended__c = institutionAccounts[0].Id;
            leadIds.add(l.Id);
            contactIds.add(l.Convert_Contact__c);
        }

        Test.startTest();
        update testLeads;
        Test.stopTest();

        List<Previous_Education__c> peRecordsCreated = [
            SELECT Account__c
            FROM Previous_Education__c
            WHERE Contact__c IN :contactIds
        ];

        for (Previous_Education__c pe : peRecordsCreated) {
            System.assertEquals(
                institutionAccounts[0].Id,
                pe.Account__c,
                'Previous Education was not created correctly'
            );
        }
    }
}
