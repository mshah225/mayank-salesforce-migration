@isTest
private class TestChangeStateOnDeeplinksUpdate
{
    private static Case createCase()
    {
        Case newCase = new Case(
            Subject = 'Test Subject%ASURITE:9999999999%Queue:00Gd00000027w7CEAQ',
            Description = 'Test Description',
            Status = 'Processing'
        );
        
        insert newCase;
        return newCase;
    }
    
    private static Contact createContact()
    {
        Contact newContact = new Contact(
            LastName = 'Contact',
            EMPLID__c = '9999999999'
        );
        
        insert newContact;
        return newContact;
    }
    
    static testmethod void TestChangeStateWithSufficientLinks()
    {
        Contact con = createContact();
        Case c = createCase();
        c.Deep_Links__c = 'field_1:<a href="http://www.google.com">Click Here</a><br />field_2:<a href="http://www.google.com">Click Here</a><br />field_3:<a href="http://www.google.com">Click Here</a><br />';
        c.Number_of_Files__c = '3';
        Test.startTest();
        update c;
        Test.stopTest();
        Case stat = [SELECT Status FROM Case WHERE Id = :c.Id LIMIT 1];
        System.assert(stat.Status == 'New');
    }
    
    static testmethod void TestChangeStateWithoutSufficientLinks()
    {
        Contact con = createContact();
        Case c = createCase();
        c.Deep_Links__c = 'field_1:<a href="http://www.google.com">Click Here</a><br />field_2:<a href="http://www.google.com">Click Here</a><br />field_3:<a href="http://www.google.com">Click Here</a><br />';
        c.Number_of_Files__c = '5';
        Test.startTest();
        update c;
        Test.stopTest();
        Case stat = [SELECT Status FROM Case WHERE Id = :c.Id LIMIT 1];
        System.assert(stat.Status != 'New');
    }
}