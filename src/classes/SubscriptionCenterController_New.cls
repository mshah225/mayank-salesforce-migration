global with sharing class SubscriptionCenterController_New
{

    public static SubscriptionCenterController_New controller;
    private static final String UNSUB = 'Unsubscribed';
    private static final String SUB = 'Subscribed';
    private static final String NA = 'No Preference';
    private Id passedSubscriptionId;
    private String passedContactId;
    private String passedLeadId;
    public String passedSubscriberKey {get; set; }
    public Set<String> subscriptionNames {get; set; }
    private List<SubscriberWrapper> allSubscriberWrappers = new List<SubscriberWrapper>();

    public String subscriberStatus { get; set; }
    public Integer tabIndex {get; set;}

    private map <String, Subscriber__c> allSubscribers = new map <String, Subscriber__c>();

    public Boolean successPage { get; set; }

    public Contact theContact { get; set; }
    public Lead theLead { get; set; }
    public Subscription__c theSubscription { get; set; }

    public Map<String,SubscriberWrapper> allBusinessUnits { get; set; }

    public Map<String,Set<String>> allCommunicationCategoriesMap {get; set;}
    public Map<String,List<SubscriberWrapper>> allCategoriesWrappersMap {get; set;}

    public String successString { get; set; }

    public List <Subscriber__c> subscribedForContact { get; set; }

    public SubscriptionCenterController_New()
    {
        successPage = false;

        allBusinessUnits = new Map<String,SubscriberWrapper>();

        allCommunicationCategoriesMap = new Map<String,Set<String>>();
        passedSubscriptionId = ApexPages.currentPage().getParameters().get('subscriptionId');
       // passedContactId = ApexPages.currentPage().getParameters().get('contactId');
       // passedLeadId = ApexPages.currentPage().getParameters().get('leadId');
        passedSubscriberKey = ApexPages.currentPage().getParameters().get('subscriberKey');

        if (String.isNotBlank(passedSubscriberKey) && passedSubscriberKey.length() > 2)
        {
            if (passedSubscriberKey.substring(0,3) == '003')
                passedContactId = passedSubscriberKey;
            else
                passedLeadId = passedSubscriberKey;
        }

        subscribedForContact = [
        select Name
        from Subscriber__c
        where ((Contact__c = :passedContactId and Contact__c != null)
            or (Lead__c = :passedLeadId and Lead__c != null))
            and Subscriber_Status__c =: SUB];

            allCategoriesWrappersMap = new Map<String,List<SubscriberWrapper>>();

        if (String.isNotBlank(passedContactId))
        {
            try
            {
                theContact = [
                    SELECT Name, FirstName, LastName, Email
                    FROM Contact
                    WHERE Id = :passedContactId
                ];

            }
            catch (QueryException e)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,
                    'Error: Could not find associated Contact ' + e.getMessage()));
                return;
            }
        }

        if (String.isNotBlank(passedLeadId))
        {
            try
            {
                theLead = [
                    SELECT Name, FirstName, LastName, Email
                    FROM Lead
                    WHERE Id = :passedLeadId
                ];

            }
            catch (QueryException e)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,
                    'Error: Could not find associated Lead ' + e.getMessage()));
                return;
            }
        }
        if (passedSubscriptionId != null)
        {
            try
            {
                theSubscription = [
                    SELECT Id, Name,
                        Business_Unit__c,
                        Subscription_Center_Description__c,
                        Always_Show_In_My_Subscriptions__c,
                        Available_for_Opt_In__c,
                        Subscription_Type__c,
                        Business_Unit__r.Name
                    FROM Subscription__c
                    WHERE Id = :passedSubscriptionId
                ];
            }
            catch (QueryException e)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,
                    'Error: Could not find associated Subscription ' + e.getMessage()));
                return;
            }

        }


        if (theContact == null && theSubscription == null && theLead == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,
                'Error: No Contact, Lead or Subscription found.'));
            return;
        }


        if ((String.isNotBlank(passedContactId) || String.isNotBlank(passedLeadId) != null) && passedSubscriptionId == null)
        {

              for (Subscriber__c subscriber : [
                SELECT Id, Name, Contact__c, Lead__c, Last_Subscribed_Date__c, Subscription__r.Name,
                    Last_Unsubscribed_Date__c, Subscription__c, Subscriber_Status__c, Subscription__r.Id,
                    Subscription__r.Business_Unit__r.Name, Subscription__r.Subscription_Type__c,
                    Subscription__r.Available_for_Opt_In__c, Subscription__r.Always_Show_In_My_Subscriptions__c,
                    Subscription__r.Subscription_Center_Description__c
                FROM Subscriber__c
                WHERE ((Contact__c = :passedContactId and Contact__c != null) or
                    (Lead__c = :passedLeadId and Lead__c != null))
                    AND Subscription__r.Available_for_Opt_In__c = true
                ORDER BY Subscription__r.Business_Unit__r.Name
            ])
            {

                allSubscribers.put( passedContactId+passedLeadId+subscriber.Subscription__r.Id  ,subscriber);


            }

            populateSubscriptionTabMap();


            //allBusinessUnits = allCategoriesWrappersMap.keySet();
            subscriptionNames = allCategoriesWrappersMap.keySet();
        }
        SubscriptionCenterController_new.controller = this;
    }

    public void populateSubscriptionTabMap()
    {


              for (Subscription__c subscription : [
                SELECT Id, Name, Business_Unit__c, Subscription_Center_Description__c,
                    Available_for_Opt_In__c, Always_Show_In_My_Subscriptions__c,
                    Business_Unit__r.Name, Subscription_Type__c
                FROM Subscription__c
                WHERE Available_for_Opt_In__c = true
                ORDER BY Business_Unit__r.Name, Name
            ])
            {

                SubscriberWrapper aWrapper = new SubscriberWrapper(subscription,allSubscribers.get(passedContactId+passedLeadId+subscription.Id));
                allSubscriberWrappers.add(aWrapper);

                if (subscription.Subscription_Type__c == 'Business Unit')
                {
                        allBusinessUnits.put(subscription.Subscription_Center_Description__c,aWrapper);
                }
                else
                {
                        if (!allCategoriesWrappersMap.containsKey(subscription.Subscription_Center_Description__c))
                                allCategoriesWrappersMap.put(subscription.Subscription_Center_Description__c,new List<SubscriberWrapper>());
                        allCategoriesWrappersMap.get(subscription.Subscription_Center_Description__c).add(aWrapper);
                }
            }

    }

public void unsubFromSingleSubscription()
    {

        if (String.isNotBlank(passedSubscriptionId))
        {
                Subscriber__c subscriberToUnsub;
                try
                {
                subscriberToUnsub = [
                    SELECT Name, Subscriber_Status__c
                    FROM Subscriber__c
                    WHERE (Contact__c = :passedContactId or Lead__c = :passedLeadId)
                    AND Subscription__c = :passedSubscriptionId limit 1
                ];
                }
                catch (Exception ex)
                {
                        System.debug('One Click exception ' + ex);
                }

        // If Subscriber exists, unsub. If not, create a new one with status unsub
        if (subscriberToUnsub != null)
        {
                subscriberToUnsub.Subscriber_Status__c = UNSUB;

        }
        else
        {
            subscriberToUnsub = new Subscriber__c(
                Contact__c = passedContactId,
                Lead__c = passedLeadId,
                Subscription__c = passedSubscriptionId,
                Subscriber_Status__c = UNSUB
            );


        }


            try
            {
                upsert subscriberToUnsub;
                successString = 'You have been successfully unsubscribed from ' + theSubscription.Name + '.';
            }
            catch (DmlException e)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,
                    'Error: Could not update subscription ' + e.getMessage()));
                return;
            }
    }
    }


    // Update all of the subscptionc based on the wrappers
        public PageReference updateSubscriptions()
    {
        List<Subscriber__c> subscribersToUpdate = new List<Subscriber__c>();
        Map<String,Subscriber__c> subscribersToUpdateMap = new Map<String,Subscriber__c>();

            for (SubscriberWrapper sw: allSubscriberWrappers)
            {
                Subscriber__c aSubscriber;
                if (sw.subscriberStatus != NA)
                {
                        if (sw.subscriber == null)
                        {
                                aSubscriber = new Subscriber__c();
                                aSubscriber.Contact__c = passedContactID;
                                aSubscriber.Lead__c = passedLeadID;
                                aSubscriber.Subscription__c = sw.subscription.Id;
                                sw.subscriber = aSubscriber;
                        }
                        else
                        {
                                subscribersToUpdateMap.put(sw.subscriber.Id,sw.subscriber);
                        }

                    aSubscriber = sw.subscriber;

                    aSubscriber.Subscriber_Status__c = sw.subscriberStatus;

                    subscribersToUpdate.add(aSubscriber);
                }
            }



        try
        {
            upsert subscribersToUpdate;
            successPage = true;
            successString = 'Your preferences have been updated.';
        }
        catch (DmlException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,
                'Error: Could not update subscriptions ' + e.getMessage()));
            return null;
        }
        //PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
        //pageref.getParameters().put('contactid',passedContactId);
        //System.debug('Page Ref ' + pageref.getParameters());
        //pageref.setRedirect(true);
        //return pageRef;
        return null;
    }


    public void unsubFromAllComms()
    {
        List<Subscriber__c> subscribersToUnsub = new List<Subscriber__c>();
        if (theContact != null)
            theContact.HasOptedOutOfEmail = true;
        if (theLead != null)
            theLead.HasOptedOutOfEmail = true;

              for (Subscriber__c subscriber : [
                SELECT Id, Subscriber_Status__c, Subscription__r.Subscription_Type__c
                FROM Subscriber__c
                WHERE ((Contact__c != null and Contact__c = :passedContactId) or
                (Lead__c != null and Lead__c = :passedLeadId))
                    //AND Subscription__r.Show_on_Subscription_Center__c = true
                    AND Subscriber_Status__c = :SUB
                ORDER BY Subscription__r.Business_Unit__r.Name
            ])
            {


                if (subscriber.Subscription__r.Subscription_Type__c == 'Business Unit')
                {
                    subscriber.Subscriber_Status__c=UNSUB;
                    subscribersToUnsub.add(subscriber);
                }


            }

        try
        {
            if (theContact != null)
                update theContact;
            if (theLead != null)
                update theLead;
            update subscribersToUnsub;
            successPage = true;
            successString = 'You have been successfully unsubscribed from all University of Pittsburgh communications.';
        }
        catch (DmlException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,
                'Error: Could not update subscriptions ' + e.getMessage()));
            return;
        }
    }

    public Class SubscriberWrapper
    {
        public Subscriber__c subscriber { get; set; }
        public String subscriberStatus { get; set; }
        public Boolean required {get; set;}
        public Integer multiCheckVal { get; set; } // 1 is subbed, 2 is unsubbed, 0 is no preference
        public String description { get; set; }
        public Subscription__c subscription {get; set;}
        public String details {get; set;}
        public Boolean checked {get; set;}


        public SubscriberWrapper(Subscriber__c aSubscriber)
        {

            subscriber = aSubscriber;
            subscriberStatus = aSubscriber.Subscriber_Status__c;
            description = aSubscriber.Subscription__r.Name;
            details = aSubscriber.Subscription__r.Subscription_Center_Description__c;

            subscription = aSubscriber.Subscription__r;
            checked=false;

            if (aSubscriber.Subscriber_Status__c == SUB) {
                multiCheckVal = 1;
                checked=true;
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
                    description = aSubscriber.Subscription__r.Name;
                    details = aSubscription.Subscription_Center_Description__c;



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
                    description = aSubscription.Name;
                    details = aSubscription.Subscription_Center_Description__c;

                    multiCheckVal = 0;
                    subscriberStatus = NA;

                    checked = false;

        }

    }
    }
}