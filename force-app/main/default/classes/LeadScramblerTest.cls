@isTest
private class LeadScramblerTest {
    @TestSetup
    private static void setup() {
        Lead testLead = new Lead(
            FirstName = 'Mister',
            LastName = 'Test',
            Company = 'Test Pvt Ltd ',
            Email = 'test@test.com',
            Recruiting_Email__c = 'test@test.com',
            Secondary_Email__c = 'test@test.com',
            Date_of_Birth__c = System.today(),
            silverpop__Silverpop_RecipientID__c = '1234'
        );

        insert testLead;
    }

    @IsTest
    private static void testScramble() {
        Lead leadToScramble = [
            SELECT
                Id,
                Date_of_Birth__c,
                Email,
                Recruiting_Email__c,
                Secondary_Email__c,
                silverpop__Silverpop_RecipientID__c
            FROM Lead
            LIMIT 1
        ];
        LeadScrambler scrambler = new LeadScrambler(leadToScramble);
        Test.startTest();
        Lead scrabledLead = (Lead) scrambler.scrambleFields();
        Test.stopTest();

        System.assert(scrabledLead.email.contains('.' + UserInfo.getUserName().substringAfterLast('.')));
        System.assert(scrabledLead.Recruiting_Email__c.contains('.' + UserInfo.getUserName().substringAfterLast('.')));
        System.assert(scrabledLead.Secondary_Email__c.contains('.' + UserInfo.getUserName().substringAfterLast('.')));
        System.assertNotEquals(Date.today(), scrabledLead.Date_of_Birth__c);
        System.assertEquals(null, scrabledLead.silverpop__Silverpop_RecipientID__c);
    }

    @IsTest
    private static void testToCsvString() {
        Lead leadToScramble = [
            SELECT
                Id,
                Date_of_Birth__c,
                Email,
                Recruiting_Email__c,
                Secondary_Email__c,
                silverpop__Silverpop_RecipientID__c
            FROM Lead
            LIMIT 1
        ];

        String expectedString =
            leadToScramble.Id +
            ',' +
            leadToScramble.Date_of_Birth__c +
            ',' +
            leadToScramble.Email +
            ',' +
            leadToScramble.Recruiting_Email__c +
            ',' +
            leadToScramble.Secondary_Email__c +
            ',#N/A\n';

        LeadScrambler scrambler = new LeadScrambler(leadToScramble);

        String csvString = scrambler.toCsvString();

        System.assertEquals(expectedString, csvString);
    }
}
