@isTest
private class LeadScramblerTest {
    private static Lead createLead() {
        LeadFactory.AllEmailAndBirthdayLead leadMaker = new LeadFactory.AllEmailAndBirthdayLead();
        Lead leadToInsert = (Lead) leadMaker.create(1)[0];
        leadToInsert.silverpop__Silverpop_RecipientID__c = '1234';
        insert leadToInsert;

        return leadToInsert;
    }

    @IsTest
    private static void scrambleLead() {
        Lead leadToScramble = createLead();
        LeadScrambler scramble = new LeadScrambler(leadToScramble);
        test.startTest();
        scramble.scrambleFields();
        test.stopTest();

        System.assert(leadToScramble.email.contains('.' + UserInfo.getUserName().substringAfterLast('.')));
        System.assert(
            leadToScramble.Recruiting_Email__c.contains('.' + UserInfo.getUserName().substringAfterLast('.'))
        );
        System.assert(leadToScramble.Secondary_Email__c.contains('.' + UserInfo.getUserName().substringAfterLast('.')));
        System.assertNotEquals(Date.today(), leadToScramble.Date_of_Birth__c);
        System.assertEquals(null, leadToScramble.silverpop__Silverpop_RecipientID__c);
    }
}
