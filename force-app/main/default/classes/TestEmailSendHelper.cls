public class TestEmailSendHelper {
    public TestEmailSendHelper() {
    }

    public String SendIt(string id) {
        string retVal = '';
        try {
            updateEmailStatus(id);
        } catch (Exception ex) {
            System.Debug('Error=' + ex);
        }
        return retVal;
    }

    private void updateEmailStatus(string id) {
        Test_Engagement_Contacts__c e = [SELECT Id, Test_Status__c FROM Test_Engagement_Contacts__c WHERE Id = :id];
        e.Test_Status__c = 'Sent';
        update e;
    }
}
