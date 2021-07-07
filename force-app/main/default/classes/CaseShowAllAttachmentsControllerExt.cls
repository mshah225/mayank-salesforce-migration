public with sharing class CaseShowAllAttachmentsControllerExt {
    public String caseId { get; private set; }
    public String caseParentId { get; private set; }

    public String attachmentIdOnCase { get; set; }
    private final String STANDARD_PREFIX = '--c';
    private final String DOWNLOAD_AS_ZIP_PREFIX = '--attachmentzip';

    public List<Attachment> allAttachmentsOnCaseOrEmailMessageOrCaseParent;
    public String baseUrlForAttachmentIntegration { get; private set; }

    public CaseShowAllAttachmentsControllerExt(ApexPages.StandardController stdController) {
        List<Case> currentCaseOnPage = [SELECT Id, ParentId FROM Case WHERE Id = :stdController.getRecord().Id];

        if (!currentCaseOnPage.isEmpty()) {
            caseId = currentCaseOnPage[0].Id;
            caseParentId = currentCaseOnPage[0].ParentId;
        }
        baseUrlForAttachmentIntegration = getDownloadAllAsZipUrl();
    }

    private Set<Id> retrieveEmailMessageIdsOnCaseAndCaseParent() {
        Set<Id> emailMessageIdsOnCaseAndCaseParent = new Set<Id>();

        for (EmailMessage eachEmailMessage : [
            SELECT Id
            FROM EmailMessage
            WHERE ParentId = :caseId OR ParentId = :caseParentId
        ]) {
            emailMessageIdsOnCaseAndCaseParent.add(eachEmailMessage.Id);
        }
        return emailMessageIdsOnCaseAndCaseParent;
    }

    public List<Attachment> getAllAttachmentsOnCaseAndCaseParent() {
        Set<Id> emaiLMessageIdsOnCaseAndCaseParent = retrieveEmailMessageIdsOnCaseAndCaseParent();

        return allAttachmentsOnCaseOrEmailMessageOrCaseParent = [
            SELECT Id, Name, LastModifiedDate, CreatedBy.Name, BodyLength
            FROM Attachment
            WHERE ParentId = :caseId OR ParentId IN :emailMessageIdsOnCaseAndCaseParent OR ParentId = :caseParentId
            ORDER BY LastModifiedDate
        ];
    }

    private String getDownloadAllAsZipUrl() {
        String baseUrl = Url.getSalesforceBaseUrl().toExternalForm();
        return baseUrl.replace(STANDARD_PREFIX, DOWNLOAD_AS_ZIP_PREFIX);
    }

    public PageReference deleteSelectedAttachmentOnCase() {
        Attachment attachmentOnCase = new Attachment(Id = attachmentIdOnCase);

        try {
            delete attachmentOnCase;
        } catch (Exception e) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'There was a problem deleting the attachment. Please try again or contact the administrator.'
                )
            );
        }
        return null;
    }
}
