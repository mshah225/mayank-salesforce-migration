@isTest
private class UpdateTermTest {
    @isTest
    private static void currentTermEndsInOne() {
        insert new StudentTerm__c();
        Term__c termInDB = new Term__c(
            PeopleSoft_Code__c = '2001',
            Year__c = '2001',
            Session_A_C_Close_Date__c = Date.Today(),
            Term_Begin_Date__c= Date.Today()            
        );
        insert termInDB;

        UpdateTerm classToUpdateCurrentTerm = new UpdateTerm();
        classToUpdateCurrentTerm.execute(null);

        StudentTerm__c currentTermData = StudentTerm__c.getOrgDefaults();

        System.assertEquals('2001', currentTermData.CurrTerm__c, 'Current Term Does Not Match');
        System.assertEquals('1997', currentTermData.PrevTerm__c, 'Previous Term Does Not Match');
        System.assertEquals('2004', currentTermData.NextTerm__c, 'Next Term Does Not Match');
        System.assertEquals('2007', currentTermData.FutureTerm__c, 'Future Term Does Not Match');
    }

    @isTest
    private static void currentTermEndsInFour() {
        insert new StudentTerm__c();
        Term__c termInDB = new Term__c(
            PeopleSoft_Code__c = '2004',
            Year__c = '2004',
            Session_A_C_Close_Date__c = Date.Today(),
            Term_Begin_Date__c= Date.Today()     
        );
        insert termInDB;

        UpdateTerm classToUpdateCurrentTerm = new UpdateTerm();
        classToUpdateCurrentTerm.execute(null);

        StudentTerm__c currentTermData = StudentTerm__c.getOrgDefaults();

        System.assertEquals('2004', currentTermData.CurrTerm__c, 'Current Term Does Not Match');
        System.assertEquals('2001', currentTermData.PrevTerm__c, 'Previous Term Does Not Match');
        System.assertEquals('2007', currentTermData.NextTerm__c, 'Next Term Does Not Match');
        System.assertEquals('2011', currentTermData.FutureTerm__c, 'Future Term Does Not Match');
    }

    @isTest
    private static void currentTermEndsInSeven() {
        insert new StudentTerm__c();
        Term__c termInDB = new Term__c(
            PeopleSoft_Code__c = '2007',
            Year__c = '2007',
            Session_A_C_Close_Date__c = Date.Today(),
            Term_Begin_Date__c= Date.Today()    
        );
        insert termInDB;

        UpdateTerm classToUpdateCurrentTerm = new UpdateTerm();
        classToUpdateCurrentTerm.execute(null);

        StudentTerm__c currentTermData = StudentTerm__c.getOrgDefaults();

        System.assertEquals('2007', currentTermData.CurrTerm__c, 'Current Term Does Not Match');
        System.assertEquals('2004', currentTermData.PrevTerm__c, 'Previous Term Does Not Match');
        System.assertEquals('2011', currentTermData.NextTerm__c, 'Next Term Does Not Match');
        System.assertEquals('2014', currentTermData.FutureTerm__c, 'Future Term Does Not Match');
    }
}
