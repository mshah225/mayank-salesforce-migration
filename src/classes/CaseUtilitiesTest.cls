@isTest
private class CaseUtilitiesTest {
    @isTest
    private static void forwardToUnitReturnsServiceNow() {
        String unitApiName = 'ServiceNow';
        String unitLabel = '';

        for (Schema.PicklistEntry entry : Case.Forward_To_Unit__c.getDescribe().getPicklistValues()) {
            if (entry.getValue() == unitApiName) {
                unitLabel = entry.getLabel();
            }
        }
        System.assertEquals(unitLabel, CaseUtilities.getForwardToUnit(unitApiName));
    }

    @isTest
    private static void forwardToUnitNoOption() {
        System.assertEquals('', CaseUtilities.getForwardToUnit('Not Valid Api Name'));
    }
}
