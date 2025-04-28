/**
 * This is a batch job to convert existing default filters on Success_Resource__c records
 * to a corresponding custom filter set for that user.
 *
 * This should need to be run once, after deploying custom filter sets to an environment,
 * and then never again.
 */

public without sharing class FilterSetConversionBatch implements Database.Batchable<SObject> {
    public FilterSetConversionBatch() {
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        try {
            List<Success_Resource__c> allSuccessResources = [
                SELECT Id, Resource__c, Default_Filter__c
                FROM Success_Resource__c
                WHERE IsActive__c = TRUE
            ];

            Set<Id> hasDefaultFilterIds = new Set<Id>();
            Set<Id> seenUserIds = new Set<Id>();

            // For each success resource with a default filter, and where we haven't already done it for that user
            for (Success_Resource__c sr : allSuccessResources) {
                if (String.isNotBlank(sr.Default_Filter__c) && !seenUserIds.contains(sr.Resource__c)) {
                    seenUserIds.add(sr.Resource__c);
                    hasDefaultFilterIds.add(sr.Id);
                }
            }

            String query = 'SELECT Id, Resource__c, Default_Filter__c FROM Success_Resource__c WHERE Id IN :hasDefaultFilterIds';
            return Database.getQueryLocator(query);
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            ErrorLogger.log(ex, vars, false);
            return null;
        }
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        try {
            List<Filter_Set__c> filterSets = new List<Filter_Set__c>();

            for (SObject sObj : scope) {
                Success_Resource__c sr = (Success_Resource__c) sObj;

                AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(sr.Default_Filter__c);

                // Upgrade filter to most recent version
                if (!sr.Default_Filter__c.contains('"filter"'))
                    filter.version = 'v1';
                filter.upgradeToMostRecentVersion();
                // Set owner as the user from the success resource
                filter.ownerIds = sr.Resource__c;

                filterSets.add(
                    new Filter_Set__c(
                        Name = 'Saved default filter',
                        Value__c = filter.toString(),
                        OwnerId = sr.Resource__c
                    )
                );
            }

            insert filterSets;
        } catch (Exception ex) {
            List<Id> recordIds = new List<Id>();
            for (SObject sObj : scope)
                recordIds.add(sObj.Id);

            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertListToJSON('recordIds', recordIds));
            ErrorLogger.log(ex, vars, false);
        }
    }

    public void finish(Database.BatchableContext BC) {
    }
}