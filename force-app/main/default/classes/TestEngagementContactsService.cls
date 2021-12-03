public class TestEngagementContactsService {
    private final static boolean debug = false;

    public static void updateEmailStatuses(List<Test_Engagement_Contacts__c> TECList) {
        List<Id> TECIdList = new List<Id>();
        for (Test_Engagement_Contacts__c TEC : TECList) {
            TECIdList.add(TEC.Id);
        }

        // Query required to get non-read-only copy, as param might be read-only
        TECList = [SELECT Id, Test_Status__c FROM Test_Engagement_Contacts__c WHERE Id IN :TECIdList];
        for (Test_Engagement_Contacts__c TEC : TECList) {
            TEC.Test_Status__c = 'Sent';
        }
        try {
            update TECList;
        } catch (Exception ex) {
            System.Debug('Error=' + ex);

            List<String> variables = new List<String>();
            for (Integer i = 0; i < TECIdList.size(); i++) {
                variables.add(ErrorLogger.convertIdToJSON('TECIdList[' + i + ']', TECIdList[i]));
            }
            ErrorLogger.log(ex, variables, debug);
        }
    }

    public static void triggerER4AE5Utility() {
        try {
            et4ae5.triggerUtility.automate('Test_Engagement_Contacts__c');
        } catch (Exception shouldOnlyBeInTests) {
            if (
                !Test.isRunningTest() &&
                shouldOnlyBeInTests.getTypeName() == 'et4ae5.MCBaseException.InvalidParameterException'
            ) {
                List<String> variables = new List<String>();
                ErrorLogger.log(shouldOnlyBeInTests, variables, debug);
            }
        }
    }
}