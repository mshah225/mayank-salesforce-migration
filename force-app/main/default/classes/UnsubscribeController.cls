public without sharing class UnsubscribeController {
    private boolean debug = false; // Determine error logging capabilities
    private List<CampaignMember> campaignMembersToUnsubscribe; // List of campaign members to mark as unsubscribed
    private List<id> campaignsToUnsubscribeFrom; // List of campaigns to unsubscribe the subscriber from
    private Campaign sendCampaign; // The campaign that the email was sent on (child of Business Unit or Category campaign)
    private String campaignId; // The Id for the campaign provided by marketing cloud
    private Boolean isContact; // Is the Id for a lead or contact?
    public String subscriberId { get; set; } // Lead or Contact Id provided by marketing cloud
    private Id subscriptionCenterRecordTypeId; // Id of the subscription center record type
    public Campaign displayCampaign { get; set; } // The campaign that will be displayed to the visual force page (Business unit or category)
    public String emailAddress { get; set; } // Email address of subscriber who is unsubscribing
    public Boolean failState { get; set; } // did the page fail to work?
    public Boolean urlParamsExistAndAreValid = true; // Are the url parameters present and valid?

    /**
     * Constructor for the controller. Get records from database for the page
     * to display and for the unsubscribe method to work with.
     */
    public unsubscribeController() {
        subscriberId = ApexPages.currentPage().getParameters().get('subId');
        campaignId = ApexPages.currentPage().getParameters().get('campaignId');

        if (Validator.validateId(campaignId, campaign.class)) {
            if (Validator.validateId(subscriberId, contact.class)) {
                isContact = true;
            } else if (Validator.validateId(subscriberId, lead.class)) {
                isContact = false;
            } else {
                urlParamsExistAndAreValid = false;
            }
        } else {
            urlParamsExistAndAreValid = false;
        }
    }

    /**
     * Method to run on page load to automatically opt out from the specified campagin
     *
     * @return null The subscriber should not be redirected to a new page once the method
     * is finished
     */
    public PageReference optOutOfEmails() {
        boolean hasCampaignMember; // Determiens if a campaign member esits
        CampaignMember tempCM; // Used to create a new campaign member if needed
        List<CampaignMember> CMsToInsert; // Stores all new campaign members for insertion

        try {
            if (urlParamsExistAndAreValid) {
                hasCampaignMember = false;
                CMsToInsert = new List<CampaignMember>();
                campaignMembersToUnsubscribe = new List<CampaignMember>();
                subscriptionCenterRecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Subscription Center' LIMIT 1]
                .Id;

                if (isContact) {
                    emaiLAddress = [SELECT Email FROM Contact WHERE Id = :subscriberId].email;
                } else {
                    emaiLAddress = [SELECT Email FROM Lead WHERE Id = :subscriberId].email;
                }

                sendCampaign = [SELECT parentId FROM Campaign WHERE Id = :campaignId];

                // Note: if it's not a Business unit campaign, the child campaigns will be send campaigns
                // and should be ignored
                displayCampaign = [
                    SELECT
                        Name,
                        Subscription_Center_Description__c,
                        parentId,
                        (
                            SELECT Id, IsSubscribed__c
                            FROM CampaignMembers
                            WHERE contactId = :subscriberId OR leadId = :subscriberId
                        ),
                        (SELECT Id FROM ChildCampaigns WHERE Visible_on_Subscription_Center__c = TRUE)
                    FROM Campaign
                    WHERE Id = :sendCampaign.parentId
                ];

                // If this is not a BU level campaign, these are the only members to unsub
                // if this is a BU level campaign, we will unsub any members here and on all
                // child category campaigns
                for (CampaignMember cm : displayCampaign.campaignMembers) {
                    hasCampaignMember = true;
                    cm.isSubscribed__c = false;
                    campaignMembersToUnsubscribe.add(cm);
                }

                // Add a campaign member to the send campaign's parent if it does not exist
                if (!hasCampaignMember) {
                    tempCM = new CampaignMember(isSubscribed__c = false, campaignId = displayCampaign.Id);

                    if (isContact) {
                        tempCM.ContactId = subscriberId;
                    } else {
                        tempCM.LeadId = subscriberId;
                    }

                    CMsToInsert.add(tempCM);
                }

                // Handle Business Unit Level Campaign
                if (displayCampaign.parentId == null) {
                    campaignsToUnsubscribeFrom = new List<Id>();

                    for (Campaign c : displayCampaign.childCampaigns) {
                        campaignsToUnsubscribeFrom.add(c.Id);
                    }

                    for (Campaign c : [
                        SELECT
                            Id,
                            (
                                SELECT Id, IsSubscribed__c
                                FROM CampaignMembers
                                WHERE contactId = :subscriberId OR leadId = :subscriberId
                            )
                        FROM Campaign
                        WHERE Id IN :campaignsToUnsubscribeFrom
                    ]) {
                        hasCampaignMember = false;

                        for (CampaignMember cm : c.campaignMembers) {
                            hasCampaignMember = true;
                            cm.IsSubscribed__c = false;
                            campaignMembersToUnsubscribe.add(cm);
                        }

                        if (!hasCampaignMember) {
                            tempCM = new CampaignMember(isSubscribed__c = true, campaignId = c.Id);

                            if (isContact) {
                                tempCM.ContactId = subscriberId;
                            } else {
                                tempCM.LeadId = subscriberId;
                            }

                            CMsToInsert.add(tempCM);
                        }
                    }
                }

                if (campaignMembersToUnsubscribe.size() > 0) {
                    update campaignMembersToUnsubscribe;
                }

                if (CMsToInsert.size() > 0) {
                    insert CMsToInsert;
                }
            } else {
                throw new unsubscribeException('URL Parameters are missing or invalid');
            }

            return null;
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            failState = true;
            vars.add(ErrorLogger.convertBooleanToJSON('urlParamsExistAndAreValid', urlParamsExistAndAreValid));
            vars.add(ErrorLogger.convertBooleanToJSON('failState', failState));
            vars.add(ErrorLogger.convertStringToJSON('subscriberId', subscriberId));
            vars.add(ErrorLogger.convertStringToJSON('campaignId', campaignId));
            vars.add(ErrorLogger.convertBooleanToJSON('isContact', isContact));
            vars.add(ErrorLogger.convertStringToJSON('emailAddress', emailAddress));
            vars.add(ErrorLogger.convertSObjectToJSON('sendCampaign', sendCampaign));
            vars.add(ErrorLogger.convertSObjectToJSON('displayCampaign', displayCampaign));
            vars.add(ErrorLogger.convertListToJSON('campaignsToUnsubscribeFrom', campaignsToUnsubscribeFrom));
            vars.add(ErrorLogger.convertListToJSON('campaignMembersToUnsubscribe', campaignMembersToUnsubscribe));

            ErrorLogger.log(ex, vars, debug);
            return null;
        }
    }

    private class unsubscribeException extends Exception {
    }
}
