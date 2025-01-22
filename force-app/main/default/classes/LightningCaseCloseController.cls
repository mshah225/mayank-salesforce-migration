public with sharing class LightningCaseCloseController {
    @AuraEnabled
    public static void closeCasesList(List<Case> cases) {
        try {
            update cases;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
