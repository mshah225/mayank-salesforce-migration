@isTest
public with sharing class OpportunityTriggerTest {
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

    static Id insertProgram(String programName, String programCode) {
        Program__c testProgram = new Program__c(Name = programName, Program_Code__c = programCode);

        insert testProgram;
        return testProgram.Id;
    }

    static Id insertPlan(String planName, String planCode, Id programId) {
        Plan__c testPlan = new Plan__c(
            Name = planName,
            Plan_Code__c = planCode,
            // Plan_Status__c = 'Active',
            Plan_Effective_Date__c = Date.today(),
            Program__c = programId
        );

        insert testPlan;
        return testPlan.Id;
    }

    //Convert Leads and create Opportunities
    static testMethod void testOpportunityHandler() {
        List<Contact> contacts = ContactService.createTestContacts(TRIGGERLOAD);
        insert contacts;

        List<Lead> leadList = LeadService.createTestLeadsToConvert(contacts);
        insert leadList;

        Set<Id> leadIds = new Set<Id>();

        // Perform Conversion
        for (Lead l : leadList) {
            l.Convert_Perform_Conversion__c = true;
            l.Convert_Create_Opportunity__c = true;
            leadIds.add(l.Id);
        }

        Test.startTest();
        update leadList;
        Test.stopTest();

        List<Lead> checkLeads = new List<Lead>([SELECT ConvertedContactID FROM Lead WHERE Id IN :leadIds]);

        Set<Id> contactIds = new Set<Id>();

        for (Lead l : checkLeads) {
            contactIds.add(l.ConvertedContactId);
        }

        // Confirm that Opps were created during lead conversion
        List<Opportunity> oppList = new List<Opportunity>(
            [SELECT Id, contact__c FROM Opportunity WHERE contact__c IN :contactIds]
        );

        System.assertEquals(opplist.size(), leadList.size());
    }

    // Validate that Contacts were updated on Opps (contact__c field)
    static testMethod void testCollegeFieldInsert() {
        List<Contact> contacts = ContactService.createTestContacts(TRIGGERLOAD);
        insert contacts;

        contacts = [SELECT AccountId, Name FROM Contact];

        List<Opportunity> opps = OpportunityService.createTestUndergraduateProspects(contacts);

        Id program1 = insertProgram('Test Program 1', '12345');
        Id program2 = insertProgram('Test Program 2', '23456');
        Id academicPlan1 = insertPlan('Academic Plan 1', '12345', program1);
        Id admittedPlan1 = insertPlan('Admitted Plan 1', '23456', program2);

        opps.get(0).Admitted_Plan__c = admittedPlan1;
        opps.get(1).Academic_Plan__c = academicPlan1;
        opps.get(2).Admitted_Plan__c = admittedPlan1;
        opps.get(2).Academic_Plan__c = academicPlan1;
        opps.get(3).Academic_Plan__c = academicPlan1;
        opps.get(3).College__c = program2;

        Test.startTest();
        insert opps;
        Test.stopTest();

        Opportunity o1 = opps[0];
        Opportunity o2 = opps[1];
        Opportunity o3 = opps[2];
        Opportunity o4 = opps[3];

        System.assert(opps.get(0).College__c == null);
        o1 = [SELECT College__c FROM Opportunity WHERE Id = :o1.Id];
        System.assert(o1.College__c == program2);

        System.assert(opps.get(1).College__c == null);
        o2 = [SELECT College__c FROM Opportunity WHERE Id = :o2.Id];
        System.assert(o2.College__c == program1);

        System.assert(opps.get(2).College__c == null);
        o3 = [SELECT College__c FROM Opportunity WHERE Id = :o3.Id];
        System.assert(o3.College__c == program2);

        System.assert(opps.get(3).College__c == program2);
        o4 = [SELECT College__c FROM Opportunity WHERE Id = :o4.Id];
        System.assert(o4.College__c == program1);

        o1.Name = 'Opportunity Update';
        update o1;
        o1 = [SELECT College__c FROM Opportunity WHERE Id = :o1.Id];
        System.assert(o1.College__c == program2);

        o2.Admitted_Plan__c = null;
        update o2;
        o2 = [SELECT College__c FROM Opportunity WHERE Id = :o2.Id];
        System.assert(o2.College__c == program1);
    }

    static testMethod void testCollegeFieldUpdate() {
        List<Contact> contacts = ContactService.createTestContacts(TRIGGERLOAD);
        insert contacts;

        contacts = [SELECT AccountId, Name FROM Contact];

        List<Opportunity> opps = OpportunityService.createTestUndergraduateProspects(contacts);
        insert opps;

        Opportunity o1 = opps[0];
        Opportunity o2 = opps[1];
        Opportunity o3 = opps[2];

        Id program1 = insertProgram('Test Program 1', '12345');
        Id program2 = insertProgram('Test Program 2', '23456');
        Id academicPlan1 = insertPlan('Academic Plan 1', '12345', program1);
        Id admittedPlan1 = insertPlan('Admitted Plan 1', '23456', program2);

        Test.startTest();
        o1.Academic_Plan__c = academicPlan1;
        System.assert(o1.College__c == null);
        update o1;
        Test.stopTest();

        o1 = [SELECT College__c FROM Opportunity WHERE Id = :o1.Id];
        System.assert(o1.College__c == program1);

        o2.Admitted_Plan__c = admittedPlan1;
        System.assert(o2.College__c == null);
        update o2;
        o2 = [SELECT College__c FROM Opportunity WHERE Id = :o2.Id];
        System.assert(o2.College__c == program2);

        o3.Admitted_Plan__c = admittedPlan1;
        System.assert(o3.College__c == null);
        update o3;
        o3 = [SELECT College__c FROM Opportunity WHERE Id = :o3.Id];
        System.assert(o3.College__c == program2);

        o1.Name = 'Opportunity Update';
        update o1;
        o1 = [SELECT College__c FROM Opportunity WHERE Id = :o1.Id];
        System.assert(o1.College__c == program1);

        o2.Admitted_Plan__c = null;
        update o2;
        o2 = [SELECT College__c FROM Opportunity WHERE Id = :o2.Id];
        System.assert(o2.College__c == program2);
    }
}
