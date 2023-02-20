public with sharing class CaseClassificationLWCService {

    @AuraEnabled(cacheable=true)
    public static List<Case_Classification__c> getClassifications(){
        return [SELECT Id,Name, Parent__c
                FROM Case_Classification__c
                WHERE Active__c = true];
    }
}