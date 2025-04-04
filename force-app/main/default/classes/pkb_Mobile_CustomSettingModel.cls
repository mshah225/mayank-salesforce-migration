/**
 * Custom Settings Model Class for managing knowledge articles settings and layouts.
 */
public with sharing class pkb_Mobile_CustomSettingModel {
    private static final String CRITICAL_ERROR = System.Label.PKB2M_config_critical_error;

    /**
     * Retrieves custom settings for knowledge articles.
     *
     * @param customSettingId The ID of the custom setting to retrieve.
     * @return A map containing the status, data, and size of the custom setting values.
     */
    public static Object getKnowledgeArticlesCustomSetting(String customSettingId) {
        Map<String, Object> ret = new Map<String, Object>();

        List<pkb_Ka__c> values = [SELECT Id, apiName__c, layout__c FROM pkb_Ka__c WHERE pkb__c = :customSettingId];

        ret.put('Status', 'Success');
        ret.put('data', values);
        ret.put('size', values.size());

        // Check access permissions
        pkb_SecurityHandler.canAccess((Schema.SObjectType.pkb_Ka__c.fields.getMap()).values());

        return ret;
    }

    /**
     * Retrieves knowledge types and their fields based on the provided language options.
     *
     * @param d A comma-separated string of language options.
     * @return A map containing the record type names and their respective fields.
     */
    public static Object getKnowledgeTypesAndFields(String d) {
        pkb_SecurityHandler.canAccess(new List<Schema.SObjectType>{ FAQ__kav.sObjectType });

        Map<String, Object> ret = new Map<String, Object>();

        List<String> options = d.split(',');
        Integer maxRows = Limits.getLimitDmlRows() - Limits.getDmlRows();

        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();

        for (AggregateResult elm : [
            SELECT RecordType.Name
            FROM FAQ__kav
            WHERE Language IN :options AND PublishStatus = 'Online'
            GROUP BY RecordType.Name
            LIMIT :maxRows
        ]) {
            Schema.DescribeSObjectResult descRes;
            Map<String, Schema.SObjectField> fieldMap;
            if (schemaMap.get(String.valueOf(elm.get('RecordType.Name'))) != null) {
                descRes = schemaMap.get(String.valueOf(elm.get('RecordType.Name'))).getDescribe();
                fieldMap = descRes.fields.getMap();
                ret.put(String.valueOf(elm.get('RecordType.Name')), fieldMap.keySet());
            }
        }
        return ret;
    }

    /**
     * Retrieves the layout of a specific article type from the custom settings.
     *
     * @param customSettingId The ID of the custom setting.
     * @param articleType The API name of the article type.
     * @return The layout of the specified article type.
     */
    public static String getArticleTypeLayout(String customSettingId, String articleType) {
        String result = '';

        List<pkb_Ka__c> kaFields = [
            SELECT layout__c
            FROM pkb_Ka__c
            WHERE pkb__c = :customSettingId AND apiName__c = :articleType
        ];
        if (!kaFields.isEmpty()) {
            result = kaFields.get(0).layout__c;
        }

        return result;
    }
}