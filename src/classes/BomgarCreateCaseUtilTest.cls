@isTest
private class BomgarCreateCaseUtilTest
{
    @testSetup static void setup()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'ASU Community'];
        Profile h = [SELECT Id FROM Profile WHERE Name = 'ASU Service - Help Desk'];

        Contact testContact = ContactService.createTestContact();
        testContact.EMPLID__c = '1231231231';
        insert testContact;

        List<User> userList = UserService.createMultipleTestUsers(2);

        User testUser = userList[0];
        testUser.ProfileId = p.Id;
        testUser.ContactId = testContact.Id;
        insert testUser;

        User testBomgarUser = userList[1];
        testBomgarUser.ProfileId = h.Id;
        insert testBomgarUser;
    }

    @isTest static void testCreateCaseFA()
    {
        Test.startTest();
        String value = null;
        bomgar__BomgarWebEvent__c webEvent = new bomgar__BomgarWebEvent__c();
        webEvent.bomgar__Username__c = 'joetest123123';
        webEvent.bomgar__ExternalKey__c = 'SFDC:{"employeeNumber":"1231231231", "description":"Bacon ipsum dolor amet bresaola drumstick leberkas, meatloaf picanha turducken tenderloin alcatra biltong cow pastrami tongue swine. Ham meatloaf fatback biltong bresaola. Kevin pork shank, meatball t-bone ball tip hamburger short loin tenderloin prosciutto salami turducken fatback tongue porchetta. Brisket fatback corned beef bacon shankle filet mignon doner kevin short loin meatloaf salami. Pork turducken tenderloin brisket corned beef turkey. Pork chop boudin corned beef", "asuriteId":"testc", "externalKey":"Finances"}';
        value = BomgarCreateCaseUtil.createCase(webEvent);
        System.assertNotEquals(null, value);
        Test.stopTest();
    }

    @isTest static void testCreateCaseOther()
    {
        Test.startTest();
        String value = null;
        bomgar__BomgarWebEvent__c webEvent = new bomgar__BomgarWebEvent__c();
        webEvent.bomgar__Username__c = 'joetest123123';
        webEvent.bomgar__ExternalKey__c = 'SFDC:{"employeeNumber":"1231231231", "description":"Bacon ipsum dolor amet bresaola drumstick leberkas", "asuriteId":"testc", "externalKey":"Other"}';
        value = BomgarCreateCaseUtil.createCase(webEvent);
        System.assertNotEquals(null, value);
        Test.stopTest();
    }

    @isTest static void testCreateCaseNoEmplId()
    {
        Test.startTest();
        String value = null;
        bomgar__BomgarWebEvent__c webEvent = new bomgar__BomgarWebEvent__c();
        webEvent.bomgar__Username__c = 'joetest123123';
        webEvent.bomgar__ExternalKey__c = 'SFDC:{"employeeNumber":"", "description":"Bacon ipsum dolor amet bresaola drumstick leberkas", "asuriteId":"testc", "externalKey":"Other"}';
        value = BomgarCreateCaseUtil.createCase(webEvent);
        System.assertNotEquals(null, value);
        Test.stopTest();
    }

    @isTest static void testAssignCase()
    {
        Test.startTest();
        String value = null;
        try
        {
            BomgarCreateCaseUtil.assignCase('lsid', 'caseId');
        }
        catch (Exception e)
        {
            value = e.getMessage();
        }
        Test.stopTest();
    }

    @isTest static void testLookupUserByAlias()
    {
        Test.startTest();
        String value = null;
        try
        {
            BomgarCreateCaseUtil.lookupUserByAlias('testc');
        }
        catch (Exception e)
        {
            value = e.getMessage();
        }
        Test.stopTest();
    }

    @isTest static void testLookupUserByAliasBomgar()
    {
        Test.startTest();
        String value = null;
        try
        {
            BomgarCreateCaseUtil.lookupUserByAlias('abcd');
        }
        catch (Exception e)
        {
            value = e.getMessage();
        }
        Test.stopTest();
    }

    @isTest static void testlookupUserByBomgarUsername()
    {
        Test.startTest();
        String value = null;
        try
        {
            BomgarCreateCaseUtil.lookupUserByBomgarUsername('abcd');
        }
        catch (Exception e)
        {
            value = e.getMessage();
        }
        try
        {
            BomgarCreateCaseUtil.lookupUserByBomgarUsername('nobody');
        }
        catch (Exception e)
        {
            value = e.getMessage();
        }
        Test.stopTest();
    }

    @isTest static void testGetOwnerIdBySessionId()
    {
        Bomgar__BomgarSession__c bs = new Bomgar__BomgarSession__c(
            bomgar__Duration__c = '00:00:30');
        insert bs;

        Bomgar__Participant__c bp = new Bomgar__Participant__c(
            bomgar__Username__c = 'BomgarParticipant',
            bomgar__IsPrimary__c = true,
            bomgar__ParticipantType__c = 'Representative',
            bomgar__BomgarSession__c = bs.Id);
        insert bp;

        Test.startTest();
        String value = null;
        try
        {
            BomgarCreateCaseUtil.getOwnerIdBySessionId(bs.Id);
        }
        catch (Exception e)
        {
            value = e.getMessage();
        }
        Test.stopTest();
    }

    @isTest static void testlookupContactByEmployeeId()
    {
        Test.startTest();
        String value = null;
        try
        {
            BomgarCreateCaseUtil.lookupContactByEmployeeId('1231231231');
        }
        catch (Exception e)
        {
            value = e.getMessage();
        }
        try
        {
            BomgarCreateCaseUtil.lookupContactByEmployeeId('3432423432');
        }
        catch (Exception e)
        {
            value = e.getMessage();
        }
        Test.stopTest();
    }

    @isTest static void testlookupUserByASURITE()
    {
        Test.startTest();
        String value = null;
        try
        {
            BomgarCreateCaseUtil.lookupContactByASURITE('testc');
        }
        catch (Exception e)
        {
            value = e.getMessage();
        }
        try
        {
            BomgarCreateCaseUtil.lookupContactByASURITE('nobody');
        }
        catch (Exception e)
        {
            value = e.getMessage();
        }
        Test.stopTest();
    }
}
