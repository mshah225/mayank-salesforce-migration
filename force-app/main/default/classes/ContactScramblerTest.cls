@isTest
private class ContactScramblerTest {
    @TestSetup
    private static void setup() {
        Contact c = new Contact(
            FirstName = 'TestContact',
            LastName = 'TestContact',
            Email = 'test.contact@test.test',
            Corporate_Relations_Email__c = 'test.contact@test.test',
            EPO_Email__c = 'test.contact@test.test',
            ASU_Email__c = 'test.contact@test.test',
            Last_Case_Email_Used__c = 'test.contact@test.test',
            Lead_Email__c = 'test.contact@test.test',
            Lead_Secondary_Email__c = 'test.contact@test.test',
            me3hs_User_ID__c = 'test.contact@test.test',
            Parent_Email__c = 'test.contact@test.test',
            Personal_Email__c = 'test.contact@test.test',
            Birthdate = System.today()
        );

        insert c;
    }

    @IsTest
    private static void testScramble() {
        Contact contactToScramble = [
            SELECT
                Id,
                Email,
                Corporate_Relations_Email__c,
                EPO_Email__c,
                ASU_Email__c,
                Last_Case_Email_Used__c,
                Lead_Email__c,
                Lead_Secondary_Email__c,
                me3hs_User_ID__c,
                Parent_Email__c,
                Personal_Email__c,
                Birthdate,
                silverpop__Silverpop_RecipientID__c
            FROM Contact
            LIMIT 1
        ];

        ContactScrambler scramble = new ContactScrambler(contactToScramble);
        Test.startTest();
        Contact scrambledContact = (Contact) scramble.scrambleFields();
        Test.stopTest();

        System.assert(scrambledContact.email.contains('.' + UserInfo.getUserName().substringAfterLast('.')));
        System.assert(
            scrambledContact.Corporate_Relations_Email__c.contains('.' + UserInfo.getUserName().substringAfterLast('.'))
        );
        System.assert(scrambledContact.EPO_Email__c.contains('.' + UserInfo.getUserName().substringAfterLast('.')));
        System.assert(scrambledContact.ASU_Email__c.contains('.' + UserInfo.getUserName().substringAfterLast('.')));
        System.assert(
            scrambledContact.Last_Case_Email_Used__c.contains('.' + UserInfo.getUserName().substringAfterLast('.'))
        );
        System.assert(scrambledContact.Lead_Email__c.contains('.' + UserInfo.getUserName().substringAfterLast('.')));
        System.assert(
            scrambledContact.Lead_Secondary_Email__c.contains('.' + UserInfo.getUserName().substringAfterLast('.'))
        );
        System.assert(scrambledContact.me3hs_User_ID__c.contains('.' + UserInfo.getUserName().substringAfterLast('.')));
        System.assert(scrambledContact.Parent_Email__c.contains('.' + UserInfo.getUserName().substringAfterLast('.')));
        System.assert(
            scrambledContact.Personal_Email__c.contains('.' + UserInfo.getUserName().substringAfterLast('.'))
        );
        System.assertNotEquals(Date.today(), scrambledContact.Birthdate);
        System.assertEquals(null, scrambledContact.silverpop__Silverpop_RecipientID__c);
    }

    @isTest
    private static void testToCsvString() {
        Contact contactToScramble = [
            SELECT
                Id,
                Email,
                Corporate_Relations_Email__c,
                EPO_Email__c,
                ASU_Email__c,
                Last_Case_Email_Used__c,
                Lead_Email__c,
                Lead_Secondary_Email__c,
                me3hs_User_ID__c,
                Parent_Email__c,
                Personal_Email__c,
                Birthdate,
                silverpop__Silverpop_RecipientID__c
            FROM Contact
            LIMIT 1
        ];

        String expectedString =
            contactToScramble.Id +
            ',' +
            contactToScramble.Birthdate +
            ',' +
            contactToScramble.Email +
            ',' +
            contactToScramble.Corporate_Relations_Email__c +
            ',' +
            contactToScramble.EPO_Email__c +
            ',' +
            contactToScramble.ASU_Email__c +
            ',' +
            contactToScramble.Last_Case_Email_Used__c +
            ',' +
            contactToScramble.Lead_Email__c +
            ',' +
            contactToScramble.Lead_Secondary_Email__c +
            ',' +
            contactToScramble.me3hs_User_ID__c +
            ',' +
            contactToScramble.Parent_Email__c +
            ',' +
            contactToScramble.Personal_Email__c +
            ',#N/A\n';

        ContactScrambler scrambler = new ContactScrambler(contactToScramble);

        String csvString = scrambler.toCsvString();

        System.assertEquals(expectedString, csvString);
    }
}
