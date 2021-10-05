@isTest
private class ObjectScrambleServiceTest {
    @isTest
    private static void testContactQuery() {
        ObjectScrambleService scrambleService = new ObjectScrambleService(ObjectScrambleService.ObjectTypes.CONTACT);

        System.assertEquals(
            'SELECT Email, Corporate_Relations_Email__c, EPO_Email__c, ASU_Email__c, ' +
            'Last_Case_Email_Used__c, Lead_Email__c, Lead_Secondary_Email__c, me3hs_User_ID__c, ' +
            'Parent_Email__c, Personal_Email__c, Birthdate FROM Contact WHERE (' +
            ObjectScrambleService.generateNotLikeSandboxDomainStatement('Email') +
            ' AND ' +
            ObjectScrambleService.generateNotLikeSandboxDomainStatement('Corporate_Relations_Email__c') +
            ' AND ' +
            ObjectScrambleService.generateNotLikeSandboxDomainStatement('EPO_Email__c') +
            ' AND ' +
            ObjectScrambleService.generateNotLikeSandboxDomainStatement('ASU_Email__c') +
            ' AND ' +
            ObjectScrambleService.generateNotLikeSandboxDomainStatement('Last_Case_Email_Used__c') +
            ' AND ' +
            ObjectScrambleService.generateNotLikeSandboxDomainStatement('Lead_Email__c') +
            ' AND ' +
            ObjectScrambleService.generateNotLikeSandboxDomainStatement('Lead_Secondary_Email__c') +
            ' AND ' +
            ObjectScrambleService.generateNotLikeSandboxDomainStatement('me3hs_User_ID__c') +
            ' AND ' +
            ObjectScrambleService.generateNotLikeSandboxDomainStatement('Parent_Email__c') +
            ' AND ' +
            ObjectScrambleService.generateNotLikeSandboxDomainStatement('Personal_Email__c') +
            ')',
            scrambleService.getQueryFromObject()
        );
    }

    @isTest
    private static void testContactHeader() {
        ObjectScrambleService scrambleService = new ObjectScrambleService(ObjectScrambleService.ObjectTypes.CONTACT);

        System.assertEquals(
            'Id,Birthdate,Email,Corporate_Relations_Email__c,EPO_Email__c,ASU_Email__c,Last_Case_Email_Used__c,Lead_Email__c,' +
            'Lead_Secondary_Email__c,me3hs_User_ID__c,Parent_Email__c,Personal_Email__c,silverpop__Silverpop_RecipientID__c\n',
            scrambleService.getObjectHeader()
        );
    }

    @isTest
    private static void testContactScramblerType() {
        ObjectScrambleService scrambleService = new ObjectScrambleService(ObjectScrambleService.ObjectTypes.CONTACT);
        Contact contactToScramble = new Contact();
        System.assert(
            scrambleService.getScrambleClassForObject(contactToScramble) instanceof ContactScrambler,
            'Scramble class was not of type Contact Scrambler'
        );
    }

    @isTest
    private static void testLeadQuery() {
        ObjectScrambleService scrambleService = new ObjectScrambleService(ObjectScrambleService.ObjectTypes.LEAD);

        System.assertEquals(
            'SELECT Id, Date_of_Birth__c, Email, Recruiting_Email__c, Secondary_Email__c FROM LEAD WHERE (' +
            ObjectScrambleService.generateNotLikeSandboxDomainStatement('Email') +
            ' AND ' +
            ObjectScrambleService.generateNotLikeSandboxDomainStatement('Recruiting_Email__c') +
            ' AND ' +
            ObjectScrambleService.generateNotLikeSandboxDomainStatement('Secondary_Email__c') +
            ')',
            scrambleService.getQueryFromObject()
        );
    }

    @isTest
    private static void testLeadHeader() {
        ObjectScrambleService scrambleService = new ObjectScrambleService(ObjectScrambleService.ObjectTypes.LEAD);

        System.assertEquals(
            'Id,Date_of_Birth__c,Email,Recruiting_Email__c,Secondary_Email__c,silverpop__Silverpop_RecipientID__c\n',
            scrambleService.getObjectHeader()
        );
    }

    @isTest
    private static void testLeadScramblerType() {
        ObjectScrambleService scrambleService = new ObjectScrambleService(ObjectScrambleService.ObjectTypes.LEAD);
        Lead leadToScramble = new Lead();
        System.assert(
            scrambleService.getScrambleClassForObject(leadToScramble) instanceof LeadScrambler,
            'Scramble class was not of type Lead Scrambler'
        );
    }

    @isTest
    private static void testUserQuery() {
        ObjectScrambleService scrambleService = new ObjectScrambleService(ObjectScrambleService.ObjectTypes.USER);
        Id sysAdminId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        String expectedQuery =
            'SELECT Id FROM User WHERE IsActive = true AND Sandbox_DEV__c = false AND (NOT Username LIKE \'%@00dn000000091oqeay.com\') AND ProfileId <> \'' +
            sysAdminId +
            '\'';
        System.assertEquals(expectedQuery, scrambleService.getQueryFromObject());
    }

    @isTest
    private static void testUserHeader() {
        ObjectScrambleService scrambleService = new ObjectScrambleService(ObjectScrambleService.ObjectTypes.USER);

        System.assertEquals('Id,IsActive\n', scrambleService.getObjectHeader());
    }

    @isTest
    private static void testUserScramblerType() {
        ObjectScrambleService scrambleService = new ObjectScrambleService(ObjectScrambleService.ObjectTypes.USER);
        User userToScramble = new User();
        System.assert(
            scrambleService.getScrambleClassForObject(userToScramble) instanceof UserScrambler,
            'Scramble class was not of type User Scrambler'
        );
    }

    @isTest
    private static void testObjectDoesNotExist() {
        ObjectScrambleService scrambleService = new ObjectScrambleService(null);
        System.assertEquals(null, scrambleService.getObjectHeader());
        System.assertEquals(null, scrambleService.getQueryFromObject());
    }
}
