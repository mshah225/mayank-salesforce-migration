public without sharing class SubscriptionCenterController {
    private Boolean debug = false;
    private Boolean isContact;
    private Id subscriptionCenterRecordTypeId;
    public String subscriberId {get; set;}
    public Boolean failState {get; set;}
    public SubscriptionTree subTree {get; set;}
    public List<Subscription> searchResults {get; set;}
    public Boolean showSearchResults {get; set;}
    public String searchInput {get; set;}
    public Boolean urlParamsExistAndAreValid = true;
    public string emailAddress {get; set;}
    
    /**
     * Constructor called by VF page
     * <p>
     * Note: Error logger cannot create cases during controller constructor. 
     * As such, the only actions that should be performed are getting/validating
     * url parameters. All other actions that need to occur on page load should be
     * placed into the init method to be called using the 'action' attribute of the
     * <apex:page> tag.
     * <p>
     * Note: Null checks on url params are handled by the validator. There is no need
     * to manually check for null values.
     */
    public SubscriptionCenterController() {
        subscriberId = ApexPages.currentPage().getParameters().get('subId');
        
        if (Validator.validateId(subscriberId, contact.class)) {
            isContact = true;
        } else if (Validator.validateId(subscriberId, lead.class)) {
            isContact = false;
        } else {
            urlParamsExistAndAreValid = false;
        }
    }
    
    /**
     * initialize the page. This method is to be called in the 'action' attribute of the
     * <apex:page> tag.
     * <p>
     * Note: In order to expose local variables to the logger, the must be defined outside
     * of the try/catch block.
     * </p>
     * <p>
     * Note: First line of the try catch is verifying that URL parameters are valid. An
     * exception will be thrown to the error logger if the parameters are not set.
     * </p>
     * <p>
     * Note: Variables are not initialized until after URL parameters are checked to avoid
     * attempting to process data in the event of an exception.
     * </p>
     * 
     * @return pageReference Action methods are required to return a pageReference value.
     * Returns null under all conditions to prevent the page from redirecting. May consider
     * returning the generic error page in the event of an error (need to discuss with team)
     */
    public pageReference init() {
        Id subscriptionCenterCampaignMemberRecordTypeId;
        Map<Id,List<Campaign>> buCatCampaigns;
        BusinessUnit tempBu;
        Boolean hasCampaignMember;
        
        try {
            if (urlParamsExistAndAreValid) {
                failState = false;
                subscriptionCenterRecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Subscription Center'].Id;
                subscriptionCenterCampaignMemberRecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Subscription Center Campaign Member'].Id;
                subTree = new SubscriptionTree();
                showSearchResults = false;
                
                if (isContact) {
                    emailAddress = [SELECT Email FROM Contact WHERE Id = :subscriberId].email;
                } else {
                    emailAddress = [SELECT Email FROM Lead WHERE Id = :subscriberId].email;
                }
                
                //Get all Bu campaigns, their campaign members and their category campaigns
                for (Campaign bu : [SELECT Id, Name,
                    (SELECT Id, Name, Subscription_Center_Description__c
                        FROM ChildCampaigns
                        WHERE RecordTypeId = :subscriptionCenterRecordTypeId
                        AND Visible_on_Subscription_Center__c = true
	                    AND isActive = true),
                    (SELECT Id, isSubscribed__c
                        FROM CampaignMembers 
                        WHERE (contactId = :subscriberId OR leadId = :subscriberId)) 
                    FROM Campaign 
                    WHERE RecordTypeId = :subscriptionCenterRecordTypeId
                    AND Visible_on_Subscription_Center__c = true
                    AND parentId = null
                    AND isActive = true]) {
                    hasCampaignMember = false;
                    // ToDo: only add BU if the Campaign has a valid subscription
                    tempBu = new BusinessUnit(new Subscription(bu));
                    
                    for (CampaignMember cm : bu.campaignMembers) {
                        tempBu.sub.addSubscriber(cm);
                        hasCampaignMember = true;
                    }
                    
                    // If the BU is missing a campaign member, add it and set IsSubscribed = false (defualt value)
                    if (!hasCampaignMember) {
                        if (isContact) {
                            tempBu.sub.addSubscriber(new CampaignMember(CampaignId = bu.Id, contactId = subscriberId));
                        } else {
                            tempBu.sub.addSubscriber(new CampaignMember(CampaignId = bu.Id, leadId = subscriberId));
                        }
                    }
	                
                    for (Campaign cat : bu.childCampaigns) {
                        tempBu.catSubs.put(cat.Id, new Subscription(cat));
                    }
	                
                    subTree.buSubs.put(bu.Id, tempBu);
                }
                
                for (Campaign cat : [SELECT Id, parentId,
                    (SELECT Id, isSubscribed__c 
                        FROM CampaignMembers
                        WHERE (contactId = :subscriberId OR leadId = :subscriberId))
                    FROM Campaign
                    WHERE Id IN :subTree.aggregateCatIds()
                    AND isActive = true
                    AND Visible_on_Subscription_Center__c = true
                    AND RecordTypeId = :subscriptionCenterRecordTypeId]) {
                    hasCampaignMember = false;
                    if (subTree.buSubs.get(cat.parentId) != null) {
                        if (subTree.buSubs.get(cat.parentId).catSubs.get(cat.Id) != null) {
                            // Add all campaign members to the proper cat
                            for (CampaignMember cm : cat.campaignMembers) {
                                subTree.buSubs.get(cat.parentId).catSubs.get(cat.Id).addSubscriber(cm);
                                hasCampaignMember = true;
                            }
                            
                            if (!hasCampaignMember) {
                                if (isContact) {
                                    subTree.buSubs.get(cat.parentId).catSubs.get(cat.Id).addSubscriber(
                                        new CampaignMember(campaignId = cat.Id, contactId = subscriberId));
                                } else {
                                    subTree.buSubs.get(cat.parentId).catSubs.get(cat.Id).addSubscriber(
                                        new CampaignMember(campaignId = cat.Id, leadId = subscriberId));
                                }
                            }
                        } else {
                            // WHAT?!
                        }
                    } else {
                        // WHAT?!
                    }
                }
                
                return null;
            } else {
                throw new subscribtionCenterException('URL Parameters are missing or invalid');
            }
            
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            failState = true;
            
            vars.add(ErrorLogger.convertBooleanToJSON('failState', failState));
            vars.add(ErrorLogger.convertBooleanToJSON('urlParamsExistAndAreValid', urlParamsExistAndAreValid));
            vars.add(ErrorLogger.convertStringToJSON('subscriberId', subscriberId));
            vars.add(ErrorLogger.convertBooleanToJSON('isContact', isContact));
            vars.add(ErrorLogger.convertIdToJSON('subscriptionCenterRecordTypeId', subscriptionCenterRecordTypeId));
            vars.add(ErrorLogger.convertIdToJSON('subscriptionCenterCampaignMemberRecordTypeId', subscriptionCenterCampaignMemberRecordTypeId));
            vars.add(ErrorLogger.convertBooleanToJSON('showSearchResults', showSearchResults));
            vars.add(ErrorLogger.convertStringToJSON('emailAddress', emailAddress));
            vars.add(ErrorLogger.convertBooleanToJSON('hasCampaignMember', hasCampaignMember));
            vars.add(string.valueOf(tempBu)); //Custom class used only in this controller
            vars.add(string.valueOf(subTree)); //Custome class used only in this controller
            
            ErrorLogger.log(ex, vars, debug);
            return null;
        }
    }
    
    /**
     * Perform a search for campaigns based on provided keywords.
     *
     * @return pageReference Action methods are required to return a pageReference value.
     * Returns null under all conditions to prevent the page from redirecting. May consider
     * returning the generic error page in the event of an error (need to discuss with team)
     */
    public pageReference doSearch() {
        Boolean hasCampaignMember; // Determines if a campaign member already exists
        Subscription tempSubscription; // Used to create new subscriptions
        Campaign tempCampaign; // Used to create new campaigns?
        Map<Id, SObject> queryResults; // Used to store sosl/soql query results
        string searchString; // User input converted into SOSL Search string
                
        try {
	        if (searchInput != null && searchInput != '') {
	            searchResults = new List<Subscription>();
	            searchString = '';
	            showSearchResults = true;
	            
	            if (subscriptionCenterRecordTypeId == null) {
	                subscriptionCenterRecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Subscription Center'].Id;
	            }
	            
	            for (String s : searchInput.split(' ')) {
	                searchString = '*' + searchString + s + '* or ';
	            }
	            
	            searchString = searchString.left(searchString.length() - 4);
	            
	            queryResults = new Map<Id, SObject>([FIND :searchString 
	                RETURNING Campaign (Id
	                    WHERE Visible_on_Subscription_Center__c = true 
	                    AND IsActive = true
	                    AND RecordTypeId = :subscriptionCenterRecordTypeId)][0]);
	                    
                system.debug('SOSl' + queryResults);
                
	            queryResults = new Map<Id, SObject>([SELECT Name, Subscription_Center_Description__c,
                    parentId,
	                (SELECT Id, isSubscribed__c 
	                    FROM CampaignMembers 
	                    WHERE contactId = :subscriberId or leadId = :subscriberId) 
	                FROM Campaign 
	                WHERE Id IN :queryResults.keyset()]);
                
                system.debug('SOQl' + queryResults);
	                
	            for (SObject so : queryResults.values()) {
	                tempCampaign = (Campaign) so;
	                tempSubscription = new Subscription(tempCampaign);
	                hasCampaignMember = false;
	                
	                for (CampaignMember cm : tempCampaign.campaignMembers) {
	                    tempSubscription.addSubscriber(cm);
	                    hasCampaignMember = true;
	                }
	                
	                if (!hasCampaignMember) {
	                    if (isContact) {
	                        tempSubscription.addSubscriber(new CampaignMember(CampaignId = tempCampaign.Id, contactId = subscriberId));
	                    } else {
	                        tempSubscription.addSubscriber(new CampaignMember(CampaignId = tempCampaign.Id, leadId = subscriberId));
	                    }
	                }
	                
	                searchResults.add(tempSubscription);
	            }
	            
	        } else {
	            showSearchResults = false;
	        }
	        
	        return null;
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertStringToJSON('searchInput', searchInput));
            vars.add(ErrorLogger.convertBooleanToJSON('showSearchResults', showSearchResults));
            vars.add(ErrorLogger.convertIdToJSON('subscriptionCenterRecordTypeId', subscriptionCenterRecordTypeId));
            vars.add(ErrorLogger.convertStringToJSON('searchString', searchString));
            vars.add(ErrorLogger.convertMapToJSON('queryResults', queryResults));
            vars.add(ErrorLogger.convertSObjectToJSON('tempCampaign', tempCampaign));
            vars.add(string.valueOf(tempSubscription)); //Custom class used only in this controller
            vars.add(ErrorLogger.convertBooleanToJSON('hasCampaignMember', hasCampaignMember));
            vars.add(string.valueOf(searchResults)); //Custom class used only in this controller
            
            ErrorLogger.log(ex, vars, debug);
            
            pageReference redirect = Page.error;
            redirect.setRedirect(true);
            
            return redirect;
        }
    }
    
    /**
     * Updates the new subscription values into the database.
     * <p>
     * Note: Consider moving this under the subtree class
     * </p>
     * <p>
     * Note: Due to a bug in salesforce, we cannot use upsert on campaign member
     * </p>
     *
     * @return pageReference Action methods are required to return a pageReference value.
     * Returns null under all conditions to prevent the page from redirecting. May consider
     * returning the generic error page in the event of an error (need to discuss with team)
     */
    public pageReference upsertSubTree() {
        List<CampaignMember> recordsToUpdate;
        List<CampaignMember> recordsToinsert;
        
        try {
            // Note: Due to bug in software we cannot actually use upsert on campaign members
            // We need to create 2 seperate lists, 1 for update, 1 for insert
            recordsToUpdate = new List<CampaignMember>();
            recordsToInsert = new List<CampaignMember>();
            
            for (CampaignMember cm : subTree.getRecordsToUpsert()) {
                if (cm.Id != null) {
                    recordsToUpdate.add(cm);
                } else {
                    recordsToInsert.add(cm);
                }
            }
            
            if (recordsToUpdate.size() > 0) {
                update recordsToUpdate;
            }
            
            if (recordsToInsert.size() > 0) {
                insert recordsToInsert;
            }
            
            init();
            
            return null;
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertListToJSON('recordsToUpdate', recordsToUpdate));
            vars.add(ErrorLogger.convertListToJSON('recordsToInsert', recordsToInsert));
            
            ErrorLogger.log(ex, vars, debug);
            
            pageReference redirect = Page.error;
            redirect.setRedirect(true);
            
            return redirect;
        }
    }
    
    /**
     * Commits subscription modifications made to the search results
     * <p>
     * Note: Due to a bug in salesforce, we cannot use upsert on campaign member
     * </p>
     */
    public pageReference upsertSearchResults() {
        list<SObject> recordsToUpdate;
        List<SObject> recordsToInsert;
        List<Id> parentIdsToUpdate;
        List<CampaignMember> subscriptionsToUpdate;
        boolean hasCampaignMember;
        
        //ToDo: check the subscriptions for parents and update them as well
        
        try {
            recordsToUpdate = new List<SObject>();
            recordsToInsert = new List<SObject>();
            parentIdsToUpdate = new List<Id>();
            
            
            // Try to find out if there is a parent campaign
            for (Subscription s : searchResults) {
                if (s.info.parentId != null && s.subscriber.IsSubscribed__c) {
                	parentIdsToUpdate.add(s.info.parentId);
                }
                
                if (s.subscriber.Id != null) {
                    recordsToUpdate.add(s.subscriber);
                } else {
                    recordsToInsert.add(s.subscriber);
                }
            }
            
            if (recordsToUpdate.size() > 0) {
                update recordsToUpdate;
            }
            
            if (recordsToInsert.size() > 0) {
                insert recordsToInsert;
            }
            
            system.debug(parentIdsToUpdate);
            if (parentIdsToUpdate.size() > 0) {
                subscriptionsToUpdate = new List<CampaignMember>();
                
                for (Campaign c : [SELECT Id,
                    (SELECT Id, IsSubscribed__c
                        FROM CampaignMembers
                        WHERE contactId = :subscriberId OR LeadId = :subscriberId)
                    FROM Campaign
                    WHERE Id IN :parentIdsToUpdate]) {
                    hasCampaignMember = false;
                        
                    for (CampaignMember cm : c.campaignMembers) {
                        cm.isSubscribed__c = true;
                        subscriptionsToUpdate.add(cm);
                        hasCampaignMember = true;
                    }
                    
                    system.debug(hasCampaignMember);
                    
                    if (!hasCampaignMember) {
                        if (isContact) {
                            subscriptionsToUpdate.add(
                                new CampaignMember(
                                    CampaignId = c.Id,
                                    ContactId = subscriberId,
                                    isSubscribed__c = true
                                )
                            );
                        } else {
                            subscriptionsToUpdate.add(
                                new CampaignMember(
                                    CampaignId = c.Id,
                                    LeadId = subscriberId,
                                    isSubscribed__c = true
                                )
                            );
                        }
                    }
                }
                
                if (subscriptionsToUpdate.size() > 0) {
                    system.debug(subscriptionsToUpdate);
                    update subscriptionsToUpdate;
                }
            }
            
            init();
            
            return null;
        } catch (Exception ex) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertListToJSON('recordsToUpdate', recordsToUpdate));
            vars.add(ErrorLogger.convertListToJSON('recordsToInsert', recordsToInsert));
            
            
            ErrorLogger.log(ex, vars, debug);
            
            pageReference redirect = Page.error;
            redirect.setRedirect(true);
            
            return redirect;  
        }
    }
    
    /**
     * Custom exception to be thrown as needed
     */
    private class subscribtionCenterException extends Exception {}
    
    /**
     * Custom class to organize campaigns according to the specified heirarchy.
     * <p>
     * Campaigns are organized into 3 tiers: Business Unit, Category, Send. The Business Unit
     * tier represents a department within ASU such as enrollment or Athletics. Category campaigns
     * represent groups within a department such as basketball or football. Send campaigns represent
     * email marketting campaigns that marketting cloud will send to. Send campaigns can be children of
     * business unit and category campaigns; send campaigns should not appear in the subscription center.
     * </p>
     * <p>
     * Campaign Members exist at both the BU and Cat levels to facilitate granular subscribing.
     * </p>
     * <p>
     * There is talk about organizing Business Units by "topic". To Add Topic Level fitlering, convert
     * the map to Map<String, Map<id, BusinessUnit>> and Add another apex:repeat tag to page to loop 
     * through the topics
     * </p>
     */
    public class SubscriptionTree {
        public Map<Id, BusinessUnit> buSubs {get; set;}
        public Boolean show {
            get {
                //Make sure there is a least 1 campaign member
                //in the tree that is subscribed
                for (BusinessUnit bu : buSubs.values()) {
                    if (bu.sub.subscriber.IsSubscribed__c) {
                        return true;
                    } else {
                        for (Subscription s : bu.catsubs.values()) {
                            if (s.subscriber.IsSubscribed__c) {
                                return true;
                            }
                        }
                    }
                }
                
                return false;
            }
            set;
        }
        
        /**
         * Constructor - initializes BuSubs
         */
        public SubscriptionTree() {
            buSubs = new Map<Id, BusinessUnit>();
        }
        
        /**
         * Aggregates all of the category Ids into a single list
         *
         * @return List<Id> List of aggregate Ids
         */
        public List<Id> aggregateCatIds () {
            List<Id> result = new List<Id>();
            
            for (BusinessUnit bu : buSubs.values()) {
                for (Id catId : bu.catSubs.keySet()) {
                    result.add(catId);
                }
            }
            
            return result;
        }
        
        /**
         * Aggregates a list of campaign members that will be updated
         *
         * @return List<CampaignMembers> Aggregate list of members to be udpated
         */
        public List<CampaignMember> getRecordsToUpsert() {
            List<CampaignMember> recordsToUpsert = new List<CampaignMember>();
            
            for (BusinessUnit bu : busubs.values()) {
                recordsToUpsert.add(bu.sub.subscriber);
            
                for (Subscription cat : bu.catSubs.values()) {
                    recordsToUpsert.add(cat.subscriber);
                }
            }
            
            return recordsToUpsert;
        }
    }
    
    /**
     * Represents a business unit campaign. Contains a business unit subscriptions and
     * a list of child-category subscriptions.
     */
    public class BusinessUnit {
        public Subscription sub {get; set;} // Business Unit Subscription
        public Map<Id, Subscription> catSubs {get; set;} // List of Category Subscriptions
        // Determins if the businessUnit should be visible on the visual force page
        public Boolean Show {
            get {
                Boolean result = false;
	            
	            // loop through all cats/subscribers to see if this should be shown
	            for (Subscription s : catSubs.values()) {
	                if (s.subscriber != null) {
	                    if (s.subscriber.IsSubscribed__c) {
	                        result = true;
	                        break;
	                    }
	                }
	            }
	            
	            if (result) {
	                return true;
	            } else {
	                return sub.subscriber.IsSubscribed__c;
	            }
            }
        }
        
        /**
         * Constructor - initializes business unit subscription and category list
         *
         * @param Subscription The business unit level subscription
         */
        public businessUnit(Subscription businessUnitSubscription) {
            sub = businessUnitSubscription;
            catSubs = new Map<Id, Subscription>();
        }
    }
    
    /**
     * Represents a subscription to a campaign. Maps out a campaign to a campaign member.
     */
    public class Subscription {
        public Campaign Info {get; set;} // Campaign the subscriber is subscribed to
        public Id subscriberId {get; set;} // Id of the campaign member that is subscribing
        public CampaignMember subscriber {get; set;} // The campaign member related to the subscriber
        // determine if this subscription should be visible to the subscription center
        public Boolean show {
            get {
                return subscriber.IsSubscribed__c;    
            }
            
            set;
        }
        
        /**
         * Constructor. Initializes campaign
         * @param Campaign The campaign the subscription is related to
         */
        public subscription(Campaign c) {
            info = c;
        }
        
        /**
         * Relates a subscriber to this subscriptions campaign.
         *
         * @param CampaignMember The subscriber to relate to thsi campaign
         */
        public void addSubscriber(CampaignMember subscriberToAdd) {
            subscriberId = subscriberToAdd.Id;
            subscriber = subscriberToAdd;
        }
    }
}