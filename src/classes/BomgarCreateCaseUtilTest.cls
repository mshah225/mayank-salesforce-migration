@isTest
private class BomgarCreateCaseUtilTest {
    @isTest static void testCreateCase(){
        Test.startTest();
        String value = null;
        
            bomgar__BomgarWebEvent__c webEvent = new bomgar__BomgarWebEvent__c();
            webEvent.bomgar__Username__c = 'joetest123123';
            webEvent.bomgar__ExternalKey__c = 'SFDC:{"employeeNumber":"123123123", "description":"test"}';
            value = BomgarCreateCaseUtil.createCase(webEvent);
        
        System.assertNotEquals(null, value);
        Test.stopTest();
    }
    
    @isTest static void testAssignCase(){
        Test.startTest();
        String value = null;
        try{
            BomgarCreateCaseUtil.assignCase('lsid', 'caseId');
        }
        catch(Exception e){
            value = e.getMessage();
        }
        Test.stopTest();
    }
    
    @isTest static void testLookupUserByAlias(){
        Test.startTest();
        String value = null;
        try{
            BomgarCreateCaseUtil.lookupUserByAlias('abcd');
        }
        catch(Exception e){
            value = e.getMessage();
        }
        Test.stopTest();
    }
    
    @isTest static void testlookupUserByBomgarUsername(){
        Test.startTest();
        String value = null;
        try{
            BomgarCreateCaseUtil.lookupUserByBomgarUsername('abcd');
        }
        catch(Exception e){
            value = e.getMessage();
        }
        Test.stopTest();
    }
    
    @isTest static void testGetOwnerIdBySessionId(){
        Test.startTest();
        String value = null;
        try{
            BomgarCreateCaseUtil.getOwnerIdBySessionId('abcd');
        }
        catch(Exception e){
            value = e.getMessage();
        }
        Test.stopTest();
    } 
    
    @isTest static void testlookupContactByEmployeeId(){
        Test.startTest();
        String value = null;
        try{
            BomgarCreateCaseUtil.lookupContactByEmployeeId('1231231231');
        }
        catch(Exception e){
            value = e.getMessage();
        }
        Test.stopTest();
    } 
    
    @isTest static void testlookupUserByASURITE(){
        Test.startTest();
        String value = null;
        try{
            BomgarCreateCaseUtil.lookupContactByASURITE('abcd');
        }
        catch(Exception e){
            value = e.getMessage();
        }
        Test.stopTest();
    } 
}