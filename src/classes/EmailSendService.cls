public with sharing class EmailSendService {
    public static void setCampaignLookup(et4ae5__SendDefinition__c send) {
        String campaignId = send.et4ae5__Campaigns__c.subStringBetween('href="/', '"');
        if (!String.isBlank(campaignId)) {
            try {
                // Test validity of the Campaign ID
                Id idUnderTest = Id.valueOf(campaignId);
                if (Schema.Campaign.SobjectType == idUnderTest.getSObjectType()) {
                    send.et4ae5__Campaign__c = campaignId; // If we get here, ID is valid; Set the Campaign lookup
                }
            } catch (Exception e) {
                // Do nothing; Campaigns were blank or ID was not valid
            }
        }
    }
}
