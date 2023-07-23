public class TaggingComponentController {
    
    
    /*This method fetches all the tags which are a part of contacts in a Map on page load by taking the recordId as parameter*/
    @AuraEnabled
    public static Map<String,Object_Tag__c> contactTags(Id recordId) {
        
        Map<String,Object_Tag__c> objTagMap = new Map<String,Object_Tag__c>();
     
       
        List<Object_Tag__c> objectTagList = [
            SELECT Contact__r.Name, Tag__r.Name, Tag__r.Color__c, isActive__c,isVerified__c, Tag__r.Tag_Api_Name__c,Tag__r.Tag_Label_Color__c, Tag__r.Priority__c, Tag__r.Tag_Description__c, Tag__r.Removeable__c,Tag__r.Tag_Icon_URL__c, CP_Stage__c,Verified_Image__c,Verification__c 
            FROM Object_Tag__c 
            WHERE Related_Object_Id__c =: recordId 
            AND isActive__c=true ORDER 
            BY Tag__r.Priority__c ASC ,Tag__r.Name ASC
        ];
        
        for (Object_Tag__c obListItem : objectTagList) {
            objTagMap.put(obListItem.Tag__r.Name, obListItem);
        }
        
        return objTagMap;
    }
    
    /*This method fetches all the tags which can be serached on the UI and takes the tagSearch String as the parameter*/
     @AuraEnabled
    public static List<String> fetchTags(String tagSearch) {
        String tagSearchKey = '%' + tagSearch + '%';
        
        List<String> tagListToReturn = new  List<String>();
        
        
        
        for(Tag__c conTag :[
            SELECT Name,Searchable__c FROM Tag__c WHERE Name Like :tagSearchKey AND Searchable__c= true  
        ]){
            
            tagListToReturn.add(conTag.Name);
        }
        return tagListToReturn;
    }
    
    /*Method is used to uncheck the checkbox on ContactTag__c Object when a tag is removed on the UI or create a new tag if not available on the UI .It takes 2 parameters tag label and recordId.*/
   @AuraEnabled
   public static String updateTag(String tag,Id recordId){
        
        String returnResult; 
        Id tagId;
        
        for(Tag__c t:[SELECT Id,Name,Searchable__c FROM Tag__c WHERE Name Like:tag]){
            tagId =t.Id;
        }
        List<Object_Tag__c> contactTaggedList = [
            SELECT Contact__r.Name,Tag__r.Name,isActive__c FROM Object_Tag__c WHERE Contact__r.Id =:recordId AND Tag__r.Name =:tag
        ];
        
        system.debug('contactTaggedList'+contactTaggedList);
        list<Object_Tag__c> updateTag = new List<Object_Tag__c>();
        
        if(!contactTaggedList.isEmpty()){
            
            for(Object_Tag__c cc: contactTaggedList){
                if(cc.isActive__c == false){
                    cc.isActive__c = true;
                    cc.Effective_Date__c = datetime.now();
                    cc.InEffective_Date__c = null;
                    cc.Tag_Removal_Reason__c = null;
                }
                updateTag.add(cc);
            }
        }
        else{
            
            Object_Tag__c addtag = new Object_Tag__c();
            addtag.Related_Object_Id__c = recordId;
            addtag.Tag__c = tagId;
            addtag.isActive__c = true;
            addtag.Effective_Date__c = datetime.now();
            updateTag.add(addtag);
            
        }
        
        if(!updateTag.isEmpty()){
            upsert updateTag;
            returnResult ='Success';
        }
        else{
            returnResult = 'Error';
        }
        
        return returnResult;
    }
    
    
    /*Method is used to uncheck the checkbox on ContactTag__c Object when a tag is removed on the UI. It takes 3 parameters tag label,recordId and tagRemovalReason*/
    @AuraEnabled
    public static String removeTag(String tag,Id recordId ,String tagRemovalReason){
        
        String returnResult; 
        
        list<Object_Tag__c> removeTag = new List<Object_Tag__c>();
        for(Object_Tag__c cc: [
            SELECT Contact__r.Name,Tag__r.Name,isActive__c FROM Object_Tag__c WHERE Contact__r.Id =:recordId AND Tag__r.Name =:tag AND Tag__r.Removeable__c = true
        ]){
            cc.isActive__c = false;
            cc.Tag_Removal_Reason__c = tagRemovalReason;
            cc.InEffective_Date__c = datetime.now();
            removeTag.add(cc);
        }
        
        if(!removeTag.isEmpty()){
            system.debug('removeTag'+removeTag);
            update removeTag;
            returnResult ='Success';
        }
        else{
            returnResult = 'Error';
        }
        
        return returnResult;
    } 
    
    /*This method is used to get all the tagRemovalReason onto the picklist filed on the frontEnds*/
    @AuraEnabled
    public static String tagRemovalReason(){
        Map<String,String> pickListValues = new Map<String,String>();
        
        Schema.DescribeFieldResult fieldResult = Object_Tag__c.Tag_Removal_Reason__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValues.put(pickListVal.getLabel(),pickListVal.getValue());
        }     
        return SYSTEM.JSON.serialize(pickListValues);
    } 
    
}