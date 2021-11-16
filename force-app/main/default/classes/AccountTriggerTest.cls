@isTest
private class AccountTriggerTest {
    @isTest
    private static void testCreateAndUpdateAccount() {
        Account acc = new Account();
        acc.Name = 'Testaccount';
        insert acc;

        acc.Name = 'Testaccount2';
        update acc;

        System.assertEquals(acc.Name, 'Testaccount2');
    }
}
