public with sharing class MarketingCloudViewEmailController {
    public final et4ae5__IndividualEmailResult__c individualEmailResult;
    public final static String CUSTOM_SETTING_BY_NAME = 'dataext';
    private final static String LINK_UNAVAILABLE_ERROR = 'View As web page link unavailable for this record.';

    public MarketingCloudViewEmailController(ApexPages.StandardController stdController) {
        this.individualEmailResult = [
            SELECT et4ae5__SendDefinition__r.et4ae5__JobId__c, View_Email_URL__c, et4ae5__Lead__c, et4ae5__Contact__c
            FROM et4ae5__IndividualEmailResult__c
            WHERE Id = :stdController.getRecord().Id
        ];
    }

    public PageReference viewEmailAndStoreLink() {
        if (urlIsNotCached()) {
            try {
                individualEmailResult.View_Email_URL__c = getEmailLinkFromMarketingCloud();
                storeEmailLinkUrl();
            } catch (Exception e) {
                return redirectToStaticEmailImage();
            }
        }
        return new PageReference(individualEmailResult.View_Email_URL__c).setRedirect(true);
    }

    private Boolean urlIsNotCached() {
        return !String.isNotBlank(individualEmailResult.View_Email_URL__c);
    }

    private String getEmailLinkFromMarketingCloud() {
        String contactOrLeadId = String.isEmpty(individualEmailResult.et4ae5__Contact__c)
            ? individualEmailResult.et4ae5__Lead__c
            : individualEmailResult.et4ae5__Contact__c;
        String jobId = individualEmailResult.et4ae5__SendDefinition__r.et4ae5__JobId__c;

        MarketingCloudEmailLinkWebService calloutToMarkingCloudForEmailLink = new MarketingCloudEmailLinkWebService(
            CUSTOM_SETTING_BY_NAME
        );
        String url = calloutToMarkingCloudForEmailLink.retrieveViewEmailUrl(jobId, contactOrLeadId);

        return modifyUrlForHttps(url);
    }

    private String modifyUrlForHttps(String url) {
        if (String.isBlank(url)) {
            throw new MarketingCloudEmailLinkWebService.MarketingCloudCalloutException(LINK_UNAVAILABLE_ERROR);
        }
        return url.replace('http:', 'https:');
    }

    private void storeEmailLinkUrl() {
        update individualEmailResult;
    }

    private PageReference redirectToStaticEmailImage() {
        return Page.et4ae5__ierImage;
    }
}
