@isTest
private class SandboxRefreshServiceTest {
    @isTest
    private static void setOrgDEV() {
        String url = 'www.test--DEV.my.salesforce.com';
        SandboxRefreshService.setOrgTypeFromUrl(url);
        System.assertEquals('.dev', SandboxRefreshService.orgType);
        url = 'www.test--QA.my.salesforce.com';
        SandboxRefreshService.setOrgTypeFromUrl(url);
        System.assertEquals('.dev', SandboxRefreshService.orgType);
    }

    @isTest
    private static void setOrgQA() {
        String url = 'www.test--QA.my.salesforce.com';
        SandboxRefreshService.setOrgTypeFromUrl(url);
        System.assertEquals('.qa', SandboxRefreshService.orgType);
    }

    @isTest
    private static void setOrgUAT() {
        String url = 'www.test--UAT.my.salesforce.com';
        SandboxRefreshService.setOrgTypeFromUrl(url);
        System.assertEquals('.uat', SandboxRefreshService.orgType);
    }

    @isTest
    private static void scrambleEmail() {
        String url = 'www.test--UAT.my.salesforce.com';
        SandboxRefreshService.setOrgTypeFromUrl(url);
        List<String> fieldList = new List<String>{ 'Email', 'Recruiting_Email__c', 'Secondary_Email__c' };

        LeadFactory.AllEmailAndBirthdayLead leadCreator = new LeadFactory.AllEmailAndBirthdayLead();
        List<Lead> createdTestLeads = leadCreator.create(1);
        Lead leadToScramble = createdTestLeads[0];
        List<String> originalEmails = new List<String>{
            leadToScramble.Email,
            leadToScramble.Recruiting_Email__c,
            leadToScramble.Secondary_Email__c
        };

        leadToScramble = (Lead) SandboxRefreshService.scrambleEmailField(leadToScramble, fieldList);

        System.assertEquals(originalEmails[0] + '.uat', leadToScramble.Email);
        System.assertEquals(originalEmails[1] + '.uat', leadToScramble.Recruiting_Email__c);
        System.assertEquals(originalEmails[2] + '.uat', leadToScramble.Secondary_Email__c);
    }

    @isTest
    private static void eightOneCharacterEmailLeadFailsInsert() {
        String eightyOneCharacterEmail = '123456789012345678901234567890123456789012345678901234567890123456789@example.com';

        LeadFactory.AllEmailAndBirthdayLead leadCreator = new LeadFactory.AllEmailAndBirthdayLead();
        List<Lead> createdTestLeads = leadCreator.create(1);
        Lead leadToFail = createdTestLeads[0];
        leadToFail.Email = eightyOneCharacterEmail;

        String errorMessage;
        try {
            Test.startTest();
            insert leadToFail;
        } catch (Exception e) {
            Test.stopTest();
            errorMessage = e.getMessage();
        }

        System.assert(errorMessage.contains('STRING_TOO_LONG'));
    }

    @isTest
    private static void truncateTooLongEmail() {
        String url = 'www.test--UAT.my.salesforce.com';
        SandboxRefreshService.setOrgTypeFromUrl(url);
        List<String> fieldList = new List<String>{ 'Email', 'Recruiting_Email__c', 'Secondary_Email__c' };
        String eightyCharacterEmail = '12345678901234567890123456789012345678901234567890123456789012345678@example.com';

        LeadFactory.AllEmailAndBirthdayLead leadCreator = new LeadFactory.AllEmailAndBirthdayLead();
        List<Lead> createdTestLeads = leadCreator.create(1);
        Lead leadToScramble = createdTestLeads[0];
        leadToScramble.Email = eightyCharacterEmail;
        List<String> originalEmails = new List<String>{
            leadToScramble.Email,
            leadToScramble.Recruiting_Email__c,
            leadToScramble.Secondary_Email__c
        };

        leadToScramble = (Lead) SandboxRefreshService.scrambleEmailField(leadToScramble, fieldList);

        System.assertNotEquals(originalEmails[0] + '.uat', leadToScramble.Email);
        System.assertEquals((eightyCharacterEmail + '.uat').right(80), leadToScramble.Email);

        System.assertEquals(originalEmails[1] + '.uat', leadToScramble.Recruiting_Email__c);
        System.assertEquals(originalEmails[2] + '.uat', leadToScramble.Secondary_Email__c);
    }

    @isTest
    private static void scrambleBirthay() {
        Date originalDate = System.today();
        Date scrambledDate = SandboxRefreshService.scrambleBirthday(originalDate);
        System.assert(verifyDateIsWithinThirtyDays(originalDate, scrambledDate));
    }

    @isTest
    private static void removeSilverPopId() {
        LeadFactory.AllEmailAndBirthdayLead leadCreator = new LeadFactory.AllEmailAndBirthdayLead();
        List<Lead> createdTestLeads = leadCreator.create(1);
        Lead leadToScramble = createdTestLeads[0];
        leadToScramble.silverpop__Silverpop_RecipientID__c = 'Test';
        System.assert(!String.isEmpty(leadToScramble.silverpop__Silverpop_RecipientID__c));
        SandboxRefreshService.removeSilverPopId(leadToScramble);
        System.assert(String.isEmpty(leadToScramble.silverpop__Silverpop_RecipientID__c));
    }

    private static boolean verifyDateIsWithinThirtyDays(Date oldDate, Date newDate) {
        Boolean withinThirtyDayRange = false;
        Date upperRange = oldDate.addDays(30);
        Date lowerRange = oldDate.addDays(-30);
        if (newDate < upperRange && newDate > lowerRange) {
            withinThirtyDayRange = true;
        }
        return withinThirtyDayRange;
    }
}
