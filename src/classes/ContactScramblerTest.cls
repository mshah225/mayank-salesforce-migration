@isTest
private class ContactScramblerTest {
    private static Contact createAndInsertContact() {
        ContactFactory.AllEmailsFilled contactMaker = new ContactFactory.AllEmailsFilled();
        Contact contactToInsert = (Contact) contactMaker.create(1)[0];
        contactToInsert.Birthdate = Date.today();
        insert contactToInsert;

        return contactToInsert;
    }

    @IsTest
    private static void testScramble() {
        Contact contactToScramble = createAndInsertContact();
        ContactScrambler scramble = new ContactScrambler(contactToScramble);
        test.startTest();
        scramble.scrambleFields();
        test.stopTest();

        System.assert(contactToScramble.email.contains('.' + UserInfo.getUserName().substringAfterLast('.')));
        System.assert(
            contactToScramble.Corporate_Relations_Email__c.contains(
                '.' + UserInfo.getUserName().substringAfterLast('.')
            )
        );
        System.assert(contactToScramble.EPO_Email__c.contains('.' + UserInfo.getUserName().substringAfterLast('.')));
        System.assert(contactToScramble.ASU_Email__c.contains('.' + UserInfo.getUserName().substringAfterLast('.')));
        System.assert(
            contactToScramble.Last_Case_Email_Used__c.contains('.' + UserInfo.getUserName().substringAfterLast('.'))
        );
        System.assert(contactToScramble.Lead_Email__c.contains('.' + UserInfo.getUserName().substringAfterLast('.')));
        System.assert(
            contactToScramble.Lead_Secondary_Email__c.contains('.' + UserInfo.getUserName().substringAfterLast('.'))
        );
        System.assert(
            contactToScramble.me3hs_User_ID__c.contains('.' + UserInfo.getUserName().substringAfterLast('.'))
        );
        System.assert(contactToScramble.Parent_Email__c.contains('.' + UserInfo.getUserName().substringAfterLast('.')));
        System.assert(
            contactToScramble.Personal_Email__c.contains('.' + UserInfo.getUserName().substringAfterLast('.'))
        );
        System.assertNotEquals(Date.today(), contactToScramble.Birthdate);
        System.assertEquals(null, contactToScramble.silverpop__Silverpop_RecipientID__c);
    }
}
