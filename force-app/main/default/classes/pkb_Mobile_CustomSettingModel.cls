/**
 * @author Altimetrik
 * @description
 *		started at 2/12/2013
 *		Custom Settings Model Class
 **/
public with sharing class pkb_Mobile_CustomSettingModel {
    private static final String CRITICAL_ERROR = System.Label.PKB2M_config_critical_error;

    public static Object getKnowledgeArticlesCustomSetting(String customSettingId) {
        map<String, Object> ret = new Map<String, Object>();

        list<pkb_Ka__c> values = [SELECT Id, apiName__c, layout__c FROM pkb_Ka__c WHERE pkb__c = :customSettingId];

        ret.put('Status', 'Success');
        ret.put('data', values);
        ret.put('size', values.size());

        //checking can access
        pkb_SecurityHandler.canAccess((Schema.SObjectType.pkb_ka__c.fields.getMap()).values());

        return ret;
    }

    public static Object getKnowledgeTypesAndFields(String d) {
        pkb_SecurityHandler.canAccess(new List<Schema.SObjectType>{ KnowledgeArticleVersion.sObjectType });
        //pkb_SecurityHandler.canAccess( (Schema.SObjectType.KnowledgeArticleVersion.fields.getMap()).values() );

        map<String, Object> ret = new Map<String, Object>();

        list<String> options = d.split(',');
        Integer maxRows = Limits.getLimitDmlRows() - Limits.getDmlRows();

        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();

        for (AggregateResult elm : [
            SELECT ArticleType
            FROM KnowledgeArticleVersion
            WHERE Language IN :options AND PublishStatus = 'Online'
            GROUP BY ArticleType
            LIMIT :maxRows
        ]) {
            Schema.DescribeSObjectResult descRes;
            Map<String, Schema.SObjectField> fieldMap;
            if (schemaMap.get(String.valueOf(elm.get('ArticleType'))) != null) {
                descRes = schemaMap.get(String.valueOf(elm.get('ArticleType'))).getDescribe();
                fieldMap = descRes.fields.getMap();
                ret.put(String.valueOf(elm.get('ArticleType')), fieldMap.keySet());
            }
        }
        return ret;
    }

    public static String getArticleTypeLayout(String customSettingId, String articleType) {
        String result = '';

        list<pkb_Ka__c> kaFields = [
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
