@isTest
private class TestChangeStateOnDeeplinksUpdate
{
    private static Case createCase(Id queue_id)
    {
        Case newCase = new Case(
            Subject = 'Test Subject%ASURITE:9999999999%Queue:' + queue_id,
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
    
    static testmethod void TestFAChangeStateWithSufficientLinks()
    {
        Id fa_id = [SELECT Id FROM Group WHERE Name = 'Financial Aid (Case)' LIMIT 1].Id;

        Contact con = createContact();
        Case c = createCase(fa_id);
        c.Deep_Links__c = 'field_1:<a href="http://www.google.com">Click Here</a><br />field_2:<a href="http://www.google.com">Click Here</a><br />field_3:<a href="http://www.google.com">Click Here</a><br />';
        c.Number_of_Files__c = '3';
        Test.startTest();
        update c;
        Test.stopTest();
        Case stat = [SELECT Status FROM Case WHERE Id = :c.Id LIMIT 1];
        System.assert(stat.Status == 'Closed: Resolved');
    }

    static testmethod void TestRegChangeStateWithSufficientLinks()
    {
        Id reg_id = [SELECT Id FROM Group WHERE Name = 'University Registrar Services (Case)' LIMIT 1].Id;

        Contact con = createContact();
        Case c = createCase(reg_id);
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
        Id reg_id = [SELECT Id FROM Group WHERE Name = 'University Registrar Services (Case)' LIMIT 1].Id;

        Contact con = createContact();
        Case c = createCase(reg_id);
        c.Deep_Links__c = 'field_1:<a href="http://www.google.com">Click Here</a><br />field_2:<a href="http://www.google.com">Click Here</a><br />field_3:<a href="http://www.google.com">Click Here</a><br />';
        c.Number_of_Files__c = '5';
        Test.startTest();
        update c;
        Test.stopTest();
        Case stat = [SELECT Status FROM Case WHERE Id = :c.Id LIMIT 1];
        System.assert(stat.Status == 'Processing');
    }
}
