/*
* Test class : ContentDocumentLinkTriggerTest
*/

trigger ContentDocumentTrigger on ContentDocument (before delete,after delete) {
    Set<Id> deletedDocIds = new Set<Id>();
    List<ContentDocumentLink> deletedLinks = new List<ContentDocumentLink>();
    for (ContentDocument doc : Trigger.old) {
        system.debug('doc :: '+ doc.parentId);
        deletedDocIds.add(doc.Id);
    }
    
    if (Trigger.isbefore) {
        if (Trigger.isDelete) {
            system.debug('Trigger.isbefore :: '+ Trigger.isbefore);
            system.debug('Trigger.isDelete :: '+ Trigger.isDelete);
            deletedLinks = [
                SELECT Id, LinkedEntityId
                FROM ContentDocumentLink
                WHERE ContentDocumentId IN :deletedDocIds
            ];
            for(ContentDocumentLink cdl : deletedLinks){
                FileService.cdlink.add(cdl);
            }
        }
    }
    if (Trigger.isAfter) {
        if (Trigger.isDelete) {
            FileService.updateCasesFromFiles(deletedLinks);
        }
    }
}