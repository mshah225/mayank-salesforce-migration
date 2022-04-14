public with sharing class FieldSetHelper {
    
    @AuraEnabled (cacheable=true)
    public static String getFieldsFromFieldSet(String fieldSetName){
        if(!String.isEmpty(fieldSetName)){   
            Map<String, String> returnMap = new Map<String, String>();

            //get fields from FieldSet
            SObject sObj = (SObject)(Type.forName('Schema.Case')?.newInstance());
            List<Schema.FieldSetMember> lstFSMember = 
                sObj?.getSObjectType()?.getDescribe()?.fieldSets.getMap().get(fieldSetName)?.getFields();
                
            returnMap.put('FIELD_LIST',JSON.serialize(lstFSMember));
            returnMap.put('OBJECT_LABEL', sObj?.getSObjectType()?.getDescribe()?.getLabel());

            return JSON.serialize(returnMap);
        }                                                                 
        return null;
    }
}