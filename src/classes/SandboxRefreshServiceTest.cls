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
        List<String> fieldList = new List<String> {
            'Email', 'Recruiting_Email__c', 'Secondary_Email__c'
        };
        
        LeadFactory.SandBoxRefreshLead leadCreator = new LeadFactory.SandBoxRefreshLead();
        List<Lead> createdTestLeads = leadCreator.create(1);
        Lead leadToScramble = createdTestLeads[0];
        List<String> originalEmails = new List<String>{leadToScramble.Email, leadToScramble.Recruiting_Email__c, leadToScramble.Secondary_Email__c};
        
        leadToScramble = (Lead)SandboxRefreshService.scrambleEmailField(leadToScramble, fieldList);
        
        System.assertEquals(originalEmails[0] + '.uat', leadToScramble.Email);
        System.assertEquals(originalEmails[1] + '.uat', leadToScramble.Recruiting_Email__c);
        System.assertEquals(originalEmails[2] + '.uat', leadToScramble.Secondary_Email__c);
    }
    
    @isTest
    private static void scrambleBirthay () {
        Date originalDate = System.today();
        Date scrambledDate = SandboxRefreshService.scrambleBirthday(originalDate);
      	System.assert(verifyDateIsWithinThirtyDays(originalDate, scrambledDate));
    }
    
    @isTest 
    private static void removeSilverPopId() {
    	LeadFactory.SandBoxRefreshLead leadCreator = new LeadFactory.SandBoxRefreshLead();
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