public class CampusVisitBadgeController {
    public String studentName {get; set;}
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String campaignId {get; set;}
    public String imageUrl {get; set;}
    
    public CampusVisitBadgeController() {

        studentName = ApexPages.currentPage().getParameters().get('name');
        campaignId = ApexPages.currentPage().getParameters().get('campaign');
        firstName = '';
        lastName = '';

        if(studentName != null) {
            List<String> splitNames = studentName.split(' ');

            if (splitNames.size() > 0) {
                firstName = splitNames.remove(0);
                lastName = String.join(splitNames, ' ');
            }
        }
        
        List<ContentDocumentLink> contentDoc = [SELECT ContentDocumentId, ContentDocument.FileExtension FROM ContentDocumentLink WHERE LinkedEntityId =: campaignId and LinkedEntity.Type='Campaign'];
        
        if (contentDoc.size() > 0) {
            List<ContentVersion> versionId = [SELECT Id FROM ContentVersion WHERE ContentDocumentId =: contentDoc[0].ContentDocumentId LIMIT 1];
            
            if (versionId.size() > 0) {
                imageUrl = '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_' + contentDoc[0].ContentDocument.FileExtension + '&versionId=' + versionId[0].Id;
            }
        }
    }
}