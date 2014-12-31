@istest
private class BomgarCreateCaseTriggerTest {

    static testMethod void createCaseTriggerTest() {
        test.starttest();
        bomgar__BomgarWebEvent__c webEvent = new bomgar__BomgarWebEvent__c();
         webEvent.bomgar__ExternalKey__c = 'SFDC:{"employeeNumber":"123123123", "description":"test"}';
         webEvent.bomgar__BomgarSessionID__c ='lsid';
         webEvent.bomgar__EventType__c ='support_conference_member_added';
         webEvent.bomgar__ConferenceMemberType__c ='representative';
         webEvent.bomgar__UserID__c ='12345';
         webEvent.bomgar__Username__c ='joe12345';
         insert webEvent;
         
         test.stoptest();
    }
}