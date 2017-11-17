public with sharing class EmailSendService {
	public static void setCampaignLookup(List<et4ae5__SendDefinition__c> emailSends) {
		for (et4ae5__SendDefinition__c send: emailSends) {
			if (!String.isBlank(send.et4ae5__Campaigns__c)) {
				String campaignId = send.et4ae5__Campaigns__c.subStringBetween('href="/', '"');
				if (!String.isBlank(campaignId)) {
					try {
						// Test validity of the Campaign ID
						Campaign idTestCampaign = new Campaign();
						idTestCampaign.Id = campaignId;
						// If we get here, ID is valid; Set the Campaign lookup
						send.et4ae5__Campaign__c = campaignId;
					}
					catch (Exception e) {
						// Do nothing; Campaigns were blank or ID was not valid
					}
				}
			}
		}
	}
}