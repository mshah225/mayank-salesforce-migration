public without sharing class SubscriptionCenterController
{
	private static final String UNSUB = 'Unsubscribed';
    private static final String SUB = 'Subscribed';
    private static final String NA = 'No Preference';

	private String actionParm;
	private String subscriberIdParm;
	private String campaignIdParm;
	private String subscriptionIdParm;
	public String subscriberKeyParm { get; set; }
	public String searchTerms { get; set; }
	public String subscriberEmail { get; set; }
	public Boolean hasOptedOutOfEmail { get; set; }
	public Boolean noSubscriber { get; set; }
	public Boolean noSubscriberRecords { get; set; }
	public Boolean directUnsubscribe { get; set; }
	public Boolean directUnsubscribeSuccess { get; set; }
	public Boolean updateSuccess { get; set; }
	private String directUnsubscribeSubscriberId;
	public String directUnsubscribeName { get; set; }
	public String unsubscribeMessage { get; set; }
	private List<Subscription__c> subscriptionList;
//	private List<SubscriberWrapper> subscriberList { get; set; }
	private Set<String> parentSubIds;
	private Set<String> availableParentSubIds;
	private Boolean isContact;

	public Map<String, List<SubscriberWrapper>> subsByParentSubIdMap { get; set; }
	public Map<String, List<SubscriberWrapper>> availableSubsByParentSubIdMap { get; set; }

	public Map<String, SubscriberWrapper> subbedBuSubIdToWrapperMap { get; set; }
	public Map<String, SubscriberWrapper> notSubbedBuSubIdToWrapperMap { get; set; }

	public List<String>  mySubsBUMapKeys { get; set; }
	public List<String>  availableSubsBUMapKeys { get; set; }

//	private Map<Integer, String> switchToStatusMap;


	public SubscriptionCenterController() {

        subscriberKeyParm = ApexPages.currentPage().getParameters().get('subscriberKey'); // Id of a Contact or Lead record
		subscriptionIdParm = ApexPages.currentPage().getParameters().get('subscriptionId'); // Id of a Subscription__c record
		actionParm = ApexPages.currentPage().getParameters().get('action'); // String describing what action to take
		campaignIdParm = ApexPages.currentPage().getParameters().get('campaignId'); // Id of a Campaign record
		subscriberIdParm = ApexPages.currentPage().getParameters().get('subscriberId'); // Id of a Subscriber__c record

        if(subscriberKeyParm != null) {
            subscriberKeyParm = EncodingUtil.urlEncode(subscriberKeyParm, 'UTF-8');
            List<Contact> tmpList = new List<Contact>();
            tmpList = [SELECT Id FROM Contact WHERE HashContactId__c =: subscriberKeyParm];
            if(tmpList.size() > 0) {
                System.debug(tmpList);
                subscriberKeyParm = tmpList[0].Id;
            } else {
                List<Lead> tmpLeadList = new List<Lead>();
                tmpLeadList = [Select Id FROM Lead WHERE HashLeadId__c =: subscriberKeyParm];
                if(tmpLeadList.size() > 0) {
                    subscriberKeyParm = tmpLeadList[0].Id;
                }
            }
        }
        
        if(subscriptionIdParm != null) {
            subscriptionIdParm = EncodingUtil.urlEncode(subscriptionIdParm, 'UTF-8');
            List<Subscription__c> tmpList = new List<Subscription__c>();
            tmpList = [SELECT Id FROM Subscription__c WHERE HashSubscriptionId__c =: subscriptionIdParm];
            if(tmpList.size() > 0) {
                subscriptionIdParm = tmpList[0].Id;
            }
        }
        
        if(campaignIdParm != null) {
            campaignIdParm = EncodingUtil.urlEncode(campaignIdParm, 'UTF-8');
            List<Campaign> tmpList = new List<Campaign>();
            tmpList = [SELECT Id FROM Campaign WHERE HashCampaignId__c =: campaignIdParm];
            if(tmpList.size() > 0) {
                campaignIdParm = tmpList[0].Id;
            }
        }
        
        if(subscriberIdParm != null) {
            subscriberIdParm = EncodingUtil.urlEncode(subscriberIdParm, 'UTF-8');
            List<Subscriber__c> tmpList = new List<Subscriber__c>();
            tmpList = [SELECT Id FROM Subscriber__c WHERE HashSubscriberId__c =: subscriberIdParm];
            if(tmpList.size() > 0) {
                subscriberIdParm = tmpList[0].Id;
            }
        }
        
//		switchToStatusMap = new Map<Integer, String>{0 => NA, 1 => SUB, 2 => UNSUB};
		noSubscriber = false;

		if (actionParm == 'unsubscribe')
		{
			if (subscriberIdParm != null)
			{
				List<Subscriber__c> subList = new List<Subscriber__c>([SELECT Id, Contact__c, Lead__c, Contact__r.Email, Lead__r.Email, Subscription__r.Name, Subscriber_Status__c
																	   FROM   Subscriber__c
																	   WHERE  Id = :subscriberIdParm]);
				if (subList.size() > 0)
				{
					if (subList[0].Contact__c != null)
					{
						subscriberKeyParm = subList[0].Contact__c;
						subscriberEmail = subList[0].Contact__r.Email;
					}
					else if (subList[0].Lead__c != null)
					{
						subscriberKeyParm = subList[0].Lead__c;
						subscriberEmail = subList[0].Lead__r.Email;
					}
					directUnsubscribeName = subList[0].Subscription__r.Name;
					directUnsubscribeSubscriberId = subscriberIdParm;
					directUnsubscribe = true;
					if (subList[0].Subscriber_Status__c == 'Unsubscribed')
					{
						unsubscribeMessage = ' is already Unsubscribed from ' + directUnsubscribeName;
						directUnsubscribeSuccess = true;
					}
				}
				else
				{
					noSubscriber = true;
				}
			}
			else if (campaignIdParm != null && subscriberKeyParm != null)
			{
				List<Campaign> campList = new List<Campaign>([SELECT Id, Subscription__c FROM Campaign WHERE Id = :campaignIdParm AND Subscription__c != null]);
				if (campList.size() > 0)
				{
					List<Subscriber__c> subList = new List<Subscriber__c>([SELECT Id, Contact__c, Contact__r.Email, Lead__r.Email, Lead__c, Subscription__r.Name, Subscriber_Status__c
																		   FROM   Subscriber__c
																		   WHERE  (Contact__c = :subscriberKeyParm OR Lead__c = :subscriberKeyParm)
																		     AND  Subscription__c = :campList[0].Subscription__c]);
					if (subList.size() > 0)
					{
						if (subList[0].Contact__c != null)
						{
							subscriberKeyParm = subList[0].Contact__c;
							subscriberEmail = subList[0].Contact__r.Email;
						}
						else if (subList[0].Lead__c != null)
						{
							subscriberKeyParm = subList[0].Lead__c;
							subscriberEmail = subList[0].Lead__r.Email;
						}
						directUnsubscribeName = subList[0].Subscription__r.Name;
						directUnsubscribeSubscriberId = subList[0].Id;
						directUnsubscribe = true;
						if (subList[0].Subscriber_Status__c == 'Unsubscribed')
						{
							unsubscribeMessage = ' is already Unsubscribed from ' + directUnsubscribeName;
							directUnsubscribeSuccess = true;
						}
					}
					else
					{
						noSubscriber = true;
					}
				}
				else
				{
					noSubscriber = true;
				}

			}
			else if (subscriptionIdParm != null && subscriberKeyParm != null)
			{
				List<Subscriber__c> subList = new List<Subscriber__c>([SELECT Id, Contact__c, Lead__c, Subscription__r.Name
																	   FROM   Subscriber__c
																	   WHERE  (Contact__c = :subscriberKeyParm OR Lead__c = :subscriberKeyParm)
																	     AND  Subscription__c = :subscriptionIdParm]);
				if (subList.size() > 0)
				{
					if (subList[0].Contact__c != null)
						subscriberKeyParm = subList[0].Contact__c;
					else if (subList[0].Lead__c != null)
						subscriberKeyParm = subList[0].Lead__c;
					directUnsubscribeName = subList[0].Subscription__r.Name;
					directUnsubscribeSubscriberId = subList[0].Id;
					directUnsubscribe = true;
				}
				else
				{
					noSubscriber = true;
				}
			}
			else
			{
				// Nothing to do!
				noSubscriber = true;
			}
		}

		if (subscriberKeyParm != null && subscriberKeyParm.left(3) == '003')
		{
			isContact = true;
			List<Contact> contactList = new List<Contact>([SELECT Id, Email, HasOptedOutOfEmail FROM Contact WHERE Id = :subscriberKeyParm]);
			if (!contactList.isEmpty())
			{
				subscriberEmail = contactList[0].Email;
				hasOptedOutOfEmail = contactList[0].HasOptedOutOfEmail;
				subscriberIdParm = contactList[0].Id;
			}
		}
		else if (subscriberKeyParm != null && subscriberKeyParm.left(3) == '00Q')
		{
			isContact = false;
			List<Lead> leadList = new List<Lead>([SELECT Id, Email, HasOptedOutOfEmail FROM Lead WHERE Id = :subscriberKeyParm]);
			if (!leadList.isEmpty())
			{
				subscriberEmail = leadList[0].Email;
				hasOptedOutOfEmail = leadList[0].HasOptedOutOfEmail;
				subscriberIdParm = leadList[0].Id;
			}
		}
		if (!String.isBlank(subscriberIdParm))
			getAllSubscriptions();
		else
			noSubscriber = true;

	}

	private void getAllSubscriptions()
	{
		subsByParentSubIdMap = new Map<String, List<SubscriberWrapper>>();
		availableSubsByParentSubIdMap = new  Map<String, List<SubscriberWrapper>>();

		mySubsBUMapKeys = new List<String>();
		availableSubsBUMapKeys = new List<String>();

		subbedBuSubIdToWrapperMap = new Map<String, SubscriberWrapper>();
		notSubbedBuSubIdToWrapperMap = new Map<String, SubscriberWrapper>();

		parentSubIds = new Set<String>();
		availableParentSubIds = new Set<String>();
		noSubscriberRecords = false;

		subscriptionList = new List<Subscription__c>([SELECT Id, Name, Available_for_Opt_In__c, Subscription_Center_Description__c, Subscription_Type__c,
															   Always_Show_In_My_Subscriptions__c, Parent_Subscription__c, Parent_Subscription__r.Name,
															   (SELECT Id, Email__c, Subscriber_Status__c, Subscription__c, Subscription__r.Name,
															   		   Subscription__r.Subscription_Center_Description__c
															    FROM Subscribers__r WHERE (Contact__c = :subscriberKeyParm OR Lead__c = :subscriberKeyParm)),
																(SELECT Id FROM Subscriptions__r LIMIT 1)
														FROM   Subscription__c
														ORDER BY Subscription_Type__c, Parent_Subscription__r.Name, Name]);
		// Loop through once to set up the Parent Subscription names in order
		for (Subscription__c subscription: subscriptionList)
		{
			if (subscription.Parent_Subscription__c != null)
			{
				if (subscription.Subscribers__r.size() > 0 || subscription.Always_Show_In_My_Subscriptions__c)
					parentSubIds.add(subscription.Parent_Subscription__c);
				else
				{
					if (subscription.Available_for_Opt_In__c && !parentSubIds.contains(subscription.Parent_Subscription__c))
						availableParentSubIds.add(subscription.Parent_Subscription__c);
				}
			}
			else
			{
				if (subscription.Subscribers__r.size() > 0 || subscription.Always_Show_In_My_Subscriptions__c)
					parentSubIds.add(subscription.Id);
			}

		}
		/*
		{
			if (subscription.Parent_Subscription__c == null)
				continue;

			if (subscription.Subscribers__r.size() > 0 || subscription.Always_Show_In_My_Subscriptions__c)
				parentSubIds.add(subscription.Parent_Subscription__c);
			else
			{
				if (subscription.Available_for_Opt_In__c && !parentSubIds.contains(subscription.Parent_Subscription__c))
					availableParentSubIds.add(subscription.Parent_Subscription__c);
			}
		}
		*/
		// If a Parent Sub ended up in both lists, remove it from the non-subscribed (aka "lower") list
		for (String subId: availableParentSubIds)
		{
			if (parentSubIds.contains(subId))
				availableParentSubIds.remove(subId);
		}
		system.debug('subscriptionList: ' + subscriptionList);
		system.debug('parentSubIds: ' + parentSubIds);
		system.debug('availableParentSubIds: ' + availableParentSubIds);
/*
		List<String> sortList = new List<String>(parentSubIds);
		sortList.sort();
		parentSubIds = new Set<String>(sortList);

		sortList = new List<String>(availableParentSubIds);
		sortList.sort();
		availableParentSubIds = new Set<String>(sortList);
*/
		for (String s: parentSubIds)
		{
			subsByParentSubIdMap.put(s, new List<SubscriberWrapper>());
		}
		for (String s: availableParentSubIds)
		{
			availableSubsByParentSubIdMap.put(s, new List<SubscriberWrapper>());
		}

		for (Subscription__c subscription: subscriptionList)
		{

			if (subscription.Subscription_Type__c == 'Business Unit')
			{
				if (subsByParentSubIdMap.containsKey(subscription.Id))
				{
					subbedBuSubIdToWrapperMap.put(subscription.Id, new SubscriberWrapper(subscription, (subscription.Subscribers__r.size()>0?subscription.Subscribers__r[0]:null)));
					mySubsBUMapKeys.add(subscription.Id);
				}
				else if (subscription.Available_for_Opt_In__c)
				{
					notSubbedBuSubIdToWrapperMap.put(subscription.Id, new SubscriberWrapper(subscription, null));
					availableSubsBUMapKeys.add(subscription.Id);
				}
			}
			else
			{
				if (subsByParentSubIdMap.containsKey(subscription.Parent_Subscription__c))
				{
					if (subscription.Subscribers__r.size() > 0)
					{
						for (Subscriber__c subscriber: subscription.Subscribers__r)
						{
							subsByParentSubIdMap.get(subscription.Parent_Subscription__c).add(new SubscriberWrapper(subscription, subscriber));
						}
					}
					else if (subscription.Available_for_Opt_In__c) // Only show child subs with this flag set to true if they have a sibling sub w/a subscriber record
					{
						subsByParentSubIdMap.get(subscription.Parent_Subscription__c).add(new SubscriberWrapper(subscription, null));
					}
				}
				else
				{
                    if (subscription.Available_for_Opt_In__c && subscription.Parent_Subscription__c != null && availableSubsByParentSubIdMap.containsKey(subscription.Parent_Subscription__c))
					{
						availableSubsByParentSubIdMap.get(subscription.Parent_Subscription__c).add(new SubscriberWrapper(subscription, null));
					}
				}
			}

/*

			if (subscription.Subscribers__r.size() > 0)
			{
				if (subscription.Subscription_Type__c == 'Business Unit')
				{
					subbedBuSubIdToWrapperMap.put(subscription.Id, new SubscriberWrapper(subscription, subscription.Subscribers__r[0]));
				}
				else
				{
					for (Subscriber__c subscriber: subscription.Subscribers__r)
					{
						subsByParentSubIdMap.get(subscription.Parent_Subscription__c).add(new SubscriberWrapper(subscription, subscriber));
					}
				}
			}
			else
			{
				if (subscription.Subscription_Type__c == 'Business Unit')
				{
					if (subscription.Subscriptions__r.size() > 0)
						notSubbedBuSubIdToWrapperMap.put(subscription.Id, new SubscriberWrapper(subscription, null));
				}
				else
				{
					if (subscription.Available_for_Opt_In__c)
						if (subsByParentSubIdMap.containsKey(subscription.Parent_Subscription__c))
							subsByParentSubIdMap.get(subscription.Parent_Subscription__c).add(new SubscriberWrapper(subscription, null));
						else
							availableSubsByParentSubIdMap.get(subscription.Parent_Subscription__c).add(new SubscriberWrapper(subscription, null));
				}
			}

*/
		}
		/*
		system.debug('subsByParentSubIdMap: ' + subsByParentSubIdMap);
		system.debug('availableSubsByParentSubIdMap: ' + availableSubsByParentSubIdMap);
		system.debug('subbedBuSubIdToWrapperMap: ' + subbedBuSubIdToWrapperMap);
		system.debug('notSubbedBuSubIdToWrapperMap: ' + notSubbedBuSubIdToWrapperMap);
		*/

		if (subbedBuSubIdToWrapperMap.size() == 0)
			noSubscriberRecords = true;


	}

	public void doUnsubscribe()
	{
		List<Subscriber__c> unsubList = new List<Subscriber__c>([SELECT Id, Subscriber_Status__c FROM Subscriber__c
																 WHERE Id = :directUnsubscribeSubscriberId
																   AND Subscriber_Status__c != 'Unsubscribed']);
		if (unsubList.size() > 0)
		{
			unsubList[0].Subscriber_Status__c = 'Unsubscribed';
			try
			{
				update unsubList;
			}
			catch (Exception e)
			{
				// TO DO: Add logger code
			}
			directUnsubscribeSuccess = true;
			unsubscribeMessage = ' has been Unsubscribed';
		}
	}

	public void filterAvailableSubscriptions()
	{
		updateSuccess = false;
		notSubbedBuSubIdToWrapperMap.clear();
		availableSubsByParentSubIdMap.clear();
		availableSubsBUMapKeys.clear();
		Set<Id> subsMatchingFilter = new Set<Id>();

		for (String s: availableParentSubIds)
		{
			availableSubsByParentSubIdMap.put(s, new List<SubscriberWrapper>());
		}
		for (Subscription__c subscription: subscriptionList)
		{
			if (subscription.Name.containsIgnoreCase(searchTerms) || (!String.isBlank(subscription.Subscription_Center_Description__c) && subscription.Subscription_Center_Description__c.containsIgnoreCase(searchTerms)))
				subsMatchingFilter.add(subscription.Id);

			if (subscription.Subscription_Type__c == 'Business Unit')
			{
				if (subsByParentSubIdMap.containsKey(subscription.Id))
				{
					continue;
				}
				else
				{
					notSubbedBuSubIdToWrapperMap.put(subscription.Id, new SubscriberWrapper(subscription, null));
					availableSubsBUMapKeys.add(subscription.Id);
				}
			}
			else
			{
				if (subsByParentSubIdMap.containsKey(subscription.Parent_Subscription__c))
				{
					continue;
				}
				else
				{
					if (subscription.Available_for_Opt_In__c && (subscription.Name.containsIgnoreCase(searchTerms) ||
																 subscription.Parent_Subscription__r.Name.containsIgnoreCase(searchTerms) ||
																 (!String.isBlank(subscription.Subscription_Center_Description__c) &&
																 subscription.Subscription_Center_Description__c.containsIgnoreCase(searchTerms))))
					{
						availableSubsByParentSubIdMap.get(subscription.Parent_Subscription__c).add(new SubscriberWrapper(subscription, null));
						availableSubsBUMapKeys.add(subscription.Parent_Subscription__c);
					}
				}
			}
		}
		/*
		for (String subId: notSubbedBuSubIdToWrapperMap.keySet())
		{
			if (availableSubsByParentSubIdMap.get(subId).size() == 0 && !subsMatchingFilter.contains(subId))
				notSubbedBuSubIdToWrapperMap.remove(subId);
		}
		for (String s: availableParentSubIds)
		{
			if (!s.containsIgnoreCase(searchTerms) && availableSubsByParentSubIdMap.get(s).size() == 0)
				availableSubsByParentSubIdMap.remove(s);
		}
		*/
	}

	public void filterAvailableSubscriptions2()
	{
		updateSuccess = false;
		notSubbedBuSubIdToWrapperMap.clear();
		availableSubsByParentSubIdMap.clear();
		availableSubsBUMapKeys.clear();
		Set<Id> subsMatchingFilter = new Set<Id>();

		for (String s: availableParentSubIds)
		{
			availableSubsByParentSubIdMap.put(s, new List<SubscriberWrapper>());
		}
		for (Subscription__c subscription: subscriptionList)
		{
			if (subscription.Name.containsIgnoreCase(searchTerms) || (!String.isBlank(subscription.Subscription_Center_Description__c) && subscription.Subscription_Center_Description__c.containsIgnoreCase(searchTerms)))
				subsMatchingFilter.add(subscription.Id);

			if (subscription.Subscription_Type__c == 'Business Unit')
			{
				if (subsByParentSubIdMap.containsKey(subscription.Id))
				{
					continue;
				}
				else if (!subscription.Always_Show_In_My_Subscriptions__c)
				{
					notSubbedBuSubIdToWrapperMap.put(subscription.Id, new SubscriberWrapper(subscription, null));
					//availableSubsBUMapKeys.add(subscription.Id);
				}
			}
			else
			{
				if (subsByParentSubIdMap.containsKey(subscription.Parent_Subscription__c))
				{
					continue;
				}
				else
				{
					if (subscription.Available_for_Opt_In__c &&
						!subscription.Always_Show_In_My_Subscriptions__c && (subscription.Name.containsIgnoreCase(searchTerms) ||
																 			 subscription.Parent_Subscription__r.Name.containsIgnoreCase(searchTerms) ||
																 		 	(!String.isBlank(subscription.Subscription_Center_Description__c) &&
																 			 subscription.Subscription_Center_Description__c.containsIgnoreCase(searchTerms))))
					{
						availableSubsByParentSubIdMap.get(subscription.Parent_Subscription__c).add(new SubscriberWrapper(subscription, null));
						//availableSubsBUMapKeys.add(subscription.Parent_Subscription__c);
					}
				}
			}
		}
		for (String subId: notSubbedBuSubIdToWrapperMap.keySet())
		{
			if (!availableSubsByParentSubIdMap.containsKey(subId))
				continue;
			if (availableSubsByParentSubIdMap.get(subId).size() == 0 && !subsMatchingFilter.contains(subId))
				notSubbedBuSubIdToWrapperMap.remove(subId);
			else
				availableSubsBUMapKeys.add(subId);
		}
		for (String s: availableParentSubIds)
		{
			if (!s.containsIgnoreCase(searchTerms) && availableSubsByParentSubIdMap.get(s).size() == 0)
				availableSubsByParentSubIdMap.remove(s);
		}
	}

	public void updateSubscriptions()
	{
		updateSuccess = false;
		List<Subscriber__c> subsToUpdate = new List<Subscriber__c>();
		List<Subscriber__c> subsToInsert = new List<Subscriber__c>();

		for (Id parentSubId: subsByParentSubIdMap.keySet())
		{
			Boolean parentSubUnsubscribed = false;
			SubscriberWrapper parentSubWrapper = subbedBuSubIdToWrapperMap.get(parentSubId);
			system.debug('BLAH: ' + parentSubWrapper);
			if (parentSubWrapper.subscriberStatus != parentSubWrapper.dbSubscriberStatus)
			{
				parentSubUnsubscribed = (parentSubWrapper.subscriberStatus == UNSUB && parentSubWrapper.dbSubscriberStatus != UNSUB ? true : false);
				if (parentSubWrapper.subscriber == null)
				{
					parentSubWrapper.subscriber = new Subscriber__c(Subscription__c = parentSubWrapper.subscription.Id,
													  Subscriber_Status__c = parentSubWrapper.subscriberStatus);
					if (isContact)
						parentSubWrapper.subscriber.Contact__c = subscriberKeyParm;
					else
						parentSubWrapper.subscriber.Lead__c = subscriberKeyParm;
					subsToInsert.add(parentSubWrapper.subscriber);
				}
				else
				{
					parentSubWrapper.subscriber.Subscriber_Status__c = parentSubWrapper.subscriberStatus;
					subsToUpdate.add(parentSubWrapper.subscriber);
				}
			}

			for (SubscriberWrapper sw: subsByParentSubIdMap.get(parentSubId))
			{
				system.debug('sw.subscriberStatus: ' + sw.subscriberStatus);
				system.debug('sw.dbSubscriberStatus: ' + sw.dbSubscriberStatus);
				system.debug('sw: ' + sw);
				if (parentSubUnsubscribed && sw.subscriber != null)
				{
					sw.subscriber.Subscriber_Status__c = UNSUB;
					subsToUpdate.add(sw.subscriber);
					continue;
				}
				if (sw.subscriberStatus != NA && sw.subscriberStatus != sw.dbSubscriberStatus)
				{
					if (sw.subscriber == null)
					{
						sw.subscriber = new Subscriber__c(Subscription__c = sw.subscription.Id,
														  Subscriber_Status__c = SUB);
						if (isContact)
							sw.subscriber.Contact__c = subscriberKeyParm;
						else
							sw.subscriber.Lead__c = subscriberKeyParm;
						subsToInsert.add(sw.subscriber);
					}
					else
					{
						sw.subscriber.Subscriber_Status__c = sw.subscriberStatus;
						subsToUpdate.add(sw.subscriber);
					}
				}
			}
		}
		for (Id parentSubId: availableSubsByParentSubIdMap.keySet())
		{
			Boolean parentSubUnsubscribed = false;
			SubscriberWrapper parentSubWrapper = notSubbedBuSubIdToWrapperMap.get(parentSubId);
			if (parentSubWrapper.subscriberStatus != NA)
			{
				parentSubUnsubscribed = (parentSubWrapper.subscriberStatus == UNSUB && parentSubWrapper.dbSubscriberStatus != UNSUB ? true : false);
				parentSubWrapper.subscriber = new Subscriber__c(Subscription__c = parentSubWrapper.subscription.Id,
												  Subscriber_Status__c = parentSubWrapper.subscriberStatus);
				if (isContact)
					parentSubWrapper.subscriber.Contact__c = subscriberKeyParm;
				else
					parentSubWrapper.subscriber.Lead__c = subscriberKeyParm;
				subsToInsert.add(parentSubWrapper.subscriber);
			}
			if (parentSubUnsubscribed)
				continue;
			for (SubscriberWrapper sw: availableSubsByParentSubIdMap.get(parentSubId))
			{
				if (sw.subscriberStatus == SUB)
				{
					sw.subscriber = new Subscriber__c(Subscription__c = sw.subscription.Id,
													  Subscriber_Status__c = SUB);
					if (isContact)
						sw.subscriber.Contact__c = subscriberKeyParm;
					else
						sw.subscriber.Lead__c = subscriberKeyParm;

					subsToInsert.add(sw.subscriber);
				}
			}
		}
		if (!subsToUpdate.isEmpty())
		{
			update subsToUpdate;
			updateSuccess = true;
		}

		if (!subsToInsert.isEmpty())
		{
			insert subsToInsert;
			updateSuccess = true;
		}

		getAllSubscriptions();
	}

	public void updateSubscribersToNoPreference()
	{
		updateSuccess = false;
		List<Subscriber__c> subsToUpdate = new List<Subscriber__c>();
		for (Id parentSubId: subsByParentSubIdMap.keySet())
		{
			for (SubscriberWrapper sw: subsByParentSubIdMap.get(parentSubId))
			{
				if (sw.subscriberStatus == 'Subscribed')
				{
					sw.subscriberStatus = 'No Preference';
					sw.subscriber.Subscriber_Status__c = 'No Preference';
					subsToUpdate.add(sw.subscriber);
				}
			}
		}
		for (String subId: subbedBuSubIdToWrapperMap.keySet())
		{
			SubscriberWrapper sw = subbedBuSubIdToWrapperMap.get(subId);
			if (sw.subscriber.Subscriber_Status__c == 'Subscribed')
			{
				sw.subscriberStatus = 'No Preference';
				sw.subscriber.Subscriber_Status__c = 'No Preference';
				subsToUpdate.add(sw.subscriber);
			}
		}
		if (subsToUpdate.size() > 0)
			update subsToUpdate;
	}

	public PageReference toggleOptOut()
	{
		updateSuccess = false;
		if (isContact)
		{
			Contact c = new Contact(Id = subscriberIdParm,
									HasOptedOutOfEmail = !hasOptedOutOfEmail);
			try
			{
				update c;
			}
			catch (Exception e)
			{

			}
			HasOptedOutOfEmail = !hasOptedOutOfEmail;
		}
		else
		{
			Lead l = new Lead(Id = subscriberIdParm,
							  HasOptedOutOfEmail = !hasOptedOutOfEmail);
			try
  			{
  				update l;
  			}
			catch (Exception e)
			{

			}
  			HasOptedOutOfEmail = !hasOptedOutOfEmail;
		}
		if (hasOptedOutOfEmail)
			updateSubscribersToNoPreference();

        getAllSubscriptions();
        return null;
	}

	public Class SubscriberWrapper
    {
        public Subscriber__c subscriber { get; set; }
        public String subscriberStatus { get; set; }
		public String dbSubscriberStatus { get; set; }
        public Boolean required { get; set; }
        public Integer multiCheckVal { get; set; } // 1 is subbed, 2 is unsubbed, 0 is no preference
        public String name { get; set; }
        public Subscription__c subscription { get; set; }
        public String desc1 { get; set; }
        //public Boolean checked { get; set; }

		public void setSubscriberStatus(String val)
		{
			subscriberStatus = val;

		}

        public SubscriberWrapper(Subscriber__c aSubscriber)
        {
            subscriber = aSubscriber;
            subscriberStatus = aSubscriber.Subscriber_Status__c;
			dbSubscriberStatus = aSubscriber.Subscriber_Status__c;
            name = aSubscriber.Subscription__r.Name;
            desc1 = aSubscriber.Subscription__r.Subscription_Center_Description__c;

            subscription = aSubscriber.Subscription__r;
            //checked=false;

            if (aSubscriber.Subscriber_Status__c == SUB) {
                multiCheckVal = 1;
                //checked=true;
            }
            else if (aSubscriber.Subscriber_Status__c == NA) {
                multiCheckVal = 0;
            }
            else if (aSubscriber.Subscriber_Status__c == UNSUB) {
                multiCheckVal = 2;
            }
        }

        public SubscriberWrapper(Subscription__c aSubscription, Subscriber__c aSubscriber)
        {
            subscription = aSubscription;
            if (aSubscriber != null)
            {
                subscriber = aSubscriber;
                subscriberStatus = aSubscriber.Subscriber_Status__c;
				dbSubscriberStatus = aSubscriber.Subscriber_Status__c;
                name = aSubscription.Name;
                desc1 = aSubscription.Subscription_Center_Description__c;

                if (aSubscriber.Subscriber_Status__c == SUB) {
                    multiCheckVal = 1;
                }
                else if (aSubscriber.Subscriber_Status__c == NA) {
                    multiCheckVal = 0;
                }
                else if (aSubscriber.Subscriber_Status__c == UNSUB) {
                    multiCheckVal = 2;
            	}
            }
            else  // if aSubscriber = null
            {
                subscription = aSubscription;
                required=false;
                name = aSubscription.Name;
                desc1 = aSubscription.Subscription_Center_Description__c;

                multiCheckVal = 0;
                subscriberStatus = NA;
				dbSubscriberStatus = null;

                //checked = false;
			}
		}

    }

}