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

//    @isTest static void testLeadHandler()
//    {
//        Integer numberOfLeads = 200;
//        Lead[] leadList = createLeads(numberOfLeads);
//        insert leadList;
//
//        Lead_Interest__c[] liList = createLeadInterests(leadList);
//        insert liList;
//
//        Set<Id> leadIds = new Set<Id>();
//
//        // Perform Conversion
//        for (Lead l: leadList)
//        {
//            l.Convert_Perform_Conversion__c = true;
//            leadIds.add(l.Id);
//        }
//
//        update leadList;
//
//        //Check conversion results
//        List<Lead> convertedLeads = new List<Lead>([SELECT Id FROM Lead WHERE Id IN :leadIds AND IsConverted = true]);
//
//        System.assertEquals(numberOfLeads, convertedLeads.size());
//    }

    @isTest static void testLeadToOppFieldMapping()
    {
        List<Lead> testLeads = LeadService.createTestLeads(10);
        insert testLeads;

        Set<Id> leadIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();

        // Perform conversion
        for (Lead l : testLeads)
        {
            l.Convert_Perform_Conversion__c = true;
            l.Convert_Create_Opportunity__c = true;
            leadIds.add(l.Id);
        }

        Test.startTest();
        update testLeads;
        Test.stopTest();

        List<Lead> convertedContacts = [
                SELECT ConvertedContactId
                FROM Lead
        ];

        System.debug('Lead data ' + convertedContacts);

        for (Lead l : convertedContacts)
        {
            contactIds.add(l.ConvertedContactId);
        }

        System.debug('Converted Contacts: ' + contactIds);

        List<Opportunity> oppsCreated = [
                SELECT Career__c, Term__c, Online_Degree__c, International_Student__c, First_Generation__c, Potential_National_Scholar__c, Potential_WUE__c, Search_Segment__c, Self_Reported_SES__c, Military_Status__c
                FROM Opportunity
                WHERE Contact__c IN :contactIds
        ];


        Lead expectedData = testLeads.get(0);
        Opportunity actualData = oppsCreated.get(0);

        System.assertEquals(expectedData.Career__c, actualData.Career__c, 'Career was not converted correctly');
    }
}