@isTest
public with sharing class Test_LeadHandler
{
    // Build Leads
    static List<Lead> createLeads (Integer quantity)
    {
        List<Lead> leadList = new List<Lead>();

        for (Integer i=0;i<quantity;i++)
        {
            Lead l = new Lead(LastName='LName'+i,
                              FirstName='FName'+i,
                              Company='Company',
                              Email='test'+i+'@test.test',
                              LeadSource='Email');
            leadList.add(l);
        }

        return leadList;
    }

    // Build Lead Interests
    static Id insertProgram(String programName, String programCode)
    {
        Program__c testProgram = new Program__c(Name=programName, Program_Code__c = programCode);
        insert testProgram;
        return testProgram.Id;
    }

    static Id insertPlan(String planName, String planCode, Id programId)
    {
        Plan__c testPlan = new Plan__c(Name = planName, Plan_Code__c = planCode,Plan_Effective_Date__c = Date.today(), Program__c = programId);
        insert testPlan;
        return testPlan.Id;
    }

    static List<Lead_Interest__c> createLeadInterests(List<Lead> associatedLeads)
    {
        List<Lead_Interest__c> liList = new List<Lead_Interest__c>();

        Id program1 = insertProgram('Program1', 'P1');
        Id plan1 = insertPlan('Plan1', 'PL1', program1);

        for (Lead l: associatedLeads)
        {
            Lead_Interest__c li = new Lead_Interest__c(College__c=program1, Plan__c=plan1, Leads__c=l.Id);
            liList.add(li);
        }

        System.debug('Lead Interests: ' + liList);

        return liList;
    }

    // @isTest static void testLeadHandler()
    // {
    //     Integer numberOfLeads = 200;
    //     Lead[] leadList = createLeads(numberOfLeads);
    //     insert leadList;
    //
    //     Lead_Interest__c[] liList = createLeadInterests(leadList);
    //     insert liList;
    //
    //     Set<Id> leadIds = new Set<Id>();
    //
    //     // Perform Conversion
    //     for (Lead l: leadList)
    //     {
    //        l.Convert_Perform_Conversion__c = true;
    //        leadIds.add(l.Id);
    //     }
    //
    //     update leadList;
    //
    //     //Check conversion results
    //     List<Lead> convertedLeads = new List<Lead>([SELECT Id FROM Lead WHERE Id IN :leadIds AND IsConverted = true]);
    //
    //     System.assertEquals(numberOfLeads, convertedLeads.size());
    // }

    @isTest static void testLeadToOppFieldMapping()
    {
        Term__c testTerm = TermService.createTestTerm();
        insert testTerm;

        List<Contact> testContacts = ContactService.createTestContacts(10);
        insert testContacts;

        testContacts = [
                SELECT Name, FirstName, LastName, Email, AccountId
                FROM Contact
        ];

        List<Opportunity> testOpptys = OpportunityService.createTestUndergraduateProspects(testContacts);
        insert testOpptys;

        System.debug('Opportunities: ' + testOpptys);

        List<Lead> testLeads = LeadService.createTestLeadsToConvert(testContacts);

        for (Lead l : testLeads)
        {
            l.Enrollment_Term__c = testTerm.Id;
        }

        insert testLeads;

        Set<Id> leadIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();

        // Perform conversion
        for (Lead l : testLeads)
        {
            l.Convert_Perform_Conversion__c = true;
            leadIds.add(l.Id);
            contactIds.add(l.Convert_Contact__c);
        }

        System.debug('!!! Contact Ids ' + contactIds);

        Test.startTest();
        update testLeads;
        Test.stopTest();

        List<Opportunity> oppsCreated = [
                SELECT Contact__c, Career__c, Term__c, Online_Degree__c, International_Student__c, First_Generation__c, Potential_National_Scholar__c, Potential_WUE__c, Search_Segment__c, Self_Reported_SES__c, Military_Status__c
                FROM Opportunity
                WHERE Contact__c IN :contactIds
        ];

        System.debug('Opportunities: ' + oppsCreated);

        Lead expectedData = testLeads.get(0);
        Opportunity actualData = oppsCreated.get(0);

        System.assertEquals(expectedData.Convert_Contact__c, actualData.Contact__c, 'Contact was not associated correctly');
        System.assertEquals(expectedData.Career__c, actualData.Career__c, 'Career was not converted correctly');
        System.assertEquals(expectedData.Enrollment_Term__c, actualData.Term__c, 'Term was not converted correctly');
        System.assertEquals(expectedData.First_Generation__c, actualData.First_Generation__c, 'First Generation was not converted correctly');
        System.assertEquals(expectedData.Online__c, actualData.Online_Degree__c, 'Online degree was not converted correctly');
        System.assertEquals(expectedData.International_Student__c, actualData.International_Student__c, 'International Student status was not converted correctly');
        System.assertEquals(expectedData.Potential_National_Scholar__c, actualData.Potential_National_Scholar__c, 'Potential National Scholar status was not converted correctly');
        System.assertEquals(expectedData.Potential_WUE__c, actualData.Potential_WUE__c, 'Potential WUE status was not converted correctly');
        System.assertEquals(expectedData.Search_Segment__c, actualData.Search_Segment__c, 'Search segment was not converted correctly');
        System.assertEquals(expectedData.Self_Reported_SES__c, actualData.Self_Reported_SES__c, 'Self Reported SES was not converted correctly');
        System.assertEquals(expectedData.Veteran_Status__c, actualData.Military_Status__c, 'Military status was not converted correctly');
    }

}