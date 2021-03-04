public class TestDataFactory {
    //ToDo: Create methods for generating test data (or filling sandboxes after refreshes)
    //ToDo: method for creating community users (students)

    /**
     * Create a user with community profile. Set last name to suffix for uniqueness
     *
     * @param String Unique value to append to lastname
     * @return User A community user - Must add a contact ID before insertion
     * to database
     */
    public static User createCommunityUser(String suffix) {
        return createCommunityUser(suffix, null);
    }

    /**
     * Create a user with provided contactId and associates community profile.
     * Set last name to suffix for uniqueness
     *
     * @param String Unique value to append to lastname
     * @param Id contactId for the user
     * @return User A community user ready for insertion to the database
     */
    public static User createCommunityUser(String suffix, Id contactId) {
        Id pId = [SELECT Id FROM Profile WHERE Name = 'ASU Community'].Id;
        return createUser(suffix, pId, contactId);
    }

    /**
     * Create a user with provided profile Id. Set last name to suffix for uniqueness.
     * No contact associated
     */
    public static User createUser(String suffix, Id profileId) {
        return createUser(suffix, profileId, null);
    }

    /**
     * Create a user with provided contactId and ProfileId. Set last
     * name to suffix for uniqueness
     *
     * @param String Unique value to set as last name (cannot contain spaces)
     * @param Id Id of desired profile for the user
     * @param Id contactId for the user if needed (can be null, used for community
     * users)
     * @return User a user ready for insertion to the database
     */
    public static User createUser(String suffix, Id profileId, Id contactId) {
        User result = new User();

        result.contactId = contactId;
        result.profileId = profileId;
        result.firstName = 'Mister';
        result.lastName = suffix;
        result.email = result.firstName + result.lastName + '@test.asu.edu';
        result.username = result.email;
        result.alias = result.firstName.left(1) + result.lastName.left(7);
        result.timeZoneSidKey = 'America/Phoenix';
        result.emailEncodingKey = 'ISO-8859-1';
        result.languageLocaleKey = 'en_US';
        result.localeSidKey = 'en_US';
        result.UserRoleId = null; //Required to allow mixed DML

        return result;
    }

    /**
     * Create a list of cases with the statuses set to new and the subjects set to
     * "Test Case: " + integer for uniqueness
     *
     * @param Integer Number of cases to create
     * @return List<Case> A list of cases ready for insertion to the database
     */
    public static List<Case> createCases(Integer numberOfCases) {
        List<Case> result = new List<Case>();

        for (Integer x = 0; x < numberOfCases; x++) {
            result.add(createCase('Test Case: ' + string.valueOf(x)));
        }

        return result;
    }

    /**
     * Create a case and set the status to new and the subject to the provided value
     * for uniqueness
     *
     * @param String The subject of the case
     * @return Case A case ready for insertion to the database
     */
    public static Case createCase(String suffix) {
        Case result = new Case();
        result.status = 'new';
        result.subject = suffix;

        return result;
    }

    /**
     * Create a list of accounts and set the account names. Append an integer to
     * account names for uniqueness
     *
     * @param Integer Number of accounts to create
     * @return Account A list of accounts ready for insertion to the database
     */
    public static List<Account> createAccounts(Integer numberOfAccounts) {
        List<Account> result = new List<Account>();

        for (Integer x = 0; x < numberOfAccounts; x++) {
            result.add(createAccount('Test Account ' + string.valueOf(x)));
        }

        return result;
    }

    /**
     * Create an account and set the account name to the provided suffix
     * for uniqueness
     *
     * @param String Value to add at end of account name for uniqueness
     * @return Account An account ready for insertion to the database
     */
    public static account createAccount(string suffix) {
        Account result = new Account();
        result.name = suffix;

        return result;
    }

    /**
     * Create a contact and set the last name to the provided unique value
     *
     * @param String value for Contact's last name
     * @return Contact A contact ready for insertion to the database
     */
    public static List<Contact> createContacts(Integer numberOfContacts) {
        List<Contact> result = new List<Contact>();

        for (Integer x = 0; x < numberOfContacts; x++) {
            result.add(createContact(string.valueOf(x)));
        }

        return result;
    }

    /**
     * Create a contact and set the last name to the provided unique value
     *
     * @param String value for Contact's last name
     * @return Contact A contact ready for insertion to the database
     */
    public static Contact createContact(string suffix) {
        Contact result = new contact();
        result.firstName = 'Mister';
        result.lastName = suffix;

        return result;
    }

    /**
     * Creats a list of leads and sets the last names to an integer value
     * for uniqueness
     *
     * @param Integer The number of leads to create
     * @return List<lead> A list of leads ready for insertion to the database
     */
    public static List<lead> createLeads(Integer numberOfLeads) {
        List<Lead> result = new List<Lead>();

        for (integer x = 0; x < numberOfLeads; x++) {
            result.add(createLead(string.valueOf(x)));
        }

        return result;
    }

    /**
     * Creats a lead and sets the last name to the provided unique value
     *
     * @param String Value for the leads last name
     * @return Lead A lead ready for insertion to the database
     */
    public static Lead createLead(string suffix) {
        Lead result = new Lead();
        result.firstName = 'Mister';
        result.lastName = suffix;
        result.company = result.firstName + ' ' + result.lastName;

        return result;
    }

    /**
     * Creates a list of attachments and appends an integer to the name and body
     * for uniqueness
     *
     * @param Integer The number of attachments to create
     * @return List<Attachments> list of attachment objects requiring parent IDs
     * before being ready to insert to the database
     */
    public static List<Attachment> createAttachments(Integer numberOfAttachments) {
        return createAttachments(numberOfAttachments, null);
    }

    /**
     * Creates a list of attachments and appends an integer to the name and body
     * for uniqueness
     *
     * @param Integer the number of attachments to create
     * @param Id the Id of the parent object for the attachments
     * @return List<Attachment> List of attachments ready to be inserted
     */
    public static List<Attachment> createAttachments(Integer numberOfAttachments, Id parentId) {
        List<Attachment> result = new List<Attachment>();

        for (Integer x = 0; x < numberOfAttachments; x++) {
            result.add(createAttachment(string.valueOf('Test Attachment ' + x), parentId));
        }

        return result;
    }

    /**
     * Creates an attachment and appends suffix to name and body for uniqueness
     *
     * @param String Value to add to end of attachment name and attachment body
     * for uniqueness
     * @return Attachment Attachment object requiring a parent ID to be set before
     * it is ready for insertion into the database
     */
    public static Attachment createAttachment(String suffix) {
        return createAttachment('Test Attachment ' + suffix, null);
    }

    /**
     * Creates an attachment and sets name to suffix. Appends suffix to body for uniqueness
     *
     * @param String Value to add to end of attachment name and attachment body
     * for uniqueness
     * @param Id The Id of the parent object that the attachment should be attached to
     * @return Attachment Attachment object ready for insertion to the database
     */
    public static Attachment createAttachment(String suffix, Id parentId) {
        Attachment result = new attachment();
        Blob resultBody = blob.valueOf('Test attachment ' + suffix);
        result.name = suffix;
        result.body = resultBody;
        result.parentId = parentId;

        return result;
    }

    /**
     * Creatsa  list of Email messages
     *
     * @param Integer The number of email messages to create
     * @param Id The ID of the case to associate the email with
     * @return List<EmailMessage> A list of email messages ready for insertion
     * to the database
     */
    public static List<EmailMessage> createEmailMessages(Integer numberOfEmailMessages, Id parentId) {
        List<EmailMessage> result = new List<EmailMessage>();

        for (Integer x = 0; x < numberOfEmailMessages; x++) {
            result.add(createEmailMessage('Test Message: ' + string.valueOf(x), parentId));
        }

        return result;
    }

    /**
     * Creates an email message object
     *
     * @param String Value for Email subject for uniqueness
     * @param Id The id of the case to associate the email with
     * @return EmailMessage email message object ready for insertion to the database
     */
    public static EmailMessage createEmailMessage(String suffix, Id parentId) {
        EmailMessage result = new EmailMessage();

        result.subject = suffix;
        result.parentId = parentId;

        return result;
    }

    /**
     * Create a list of campaign records
     *
     * @param Integer The number of records to create
     * @param Id The Id of the desired record type for the campaigns
     * @return List<Campaign> A list of campaign records ready for insertion to the database
     */
    public static List<Campaign> createCampaigns(Integer numberOfCampaigns, Id recordTypeId) {
        List<Campaign> result = new List<Campaign>();

        for (Integer x = 0; x < numberOfCampaigns; x++) {
            result.add(createCampaign(string.valueOf(x), recordTypeId));
        }

        return result;
    }

    /**
     * Create a campaign record
     *
     * @param String the value of the subject for the campaign. This value is also
     * appended to campaign description for uniqueness.
     * @return Campaign A campaign record ready for insertion to the database
     */
    public static Campaign createCampaign(String suffix, Id recordTypeId) {
        Campaign result = new Campaign();

        result.Name = suffix;
        result.description = 'Description for ' + suffix;
        result.type = 'Test Campaign';
        result.recordTypeId = recordTypeId;

        return result;
    }

    /**
     * Create a list of Campaign Member records
     *
     * @param Integer Number of records to create
     * @param Id The Id of the lead or contact that will be associated with the campaign member
     * @param Id The Id of the campaign the member will be associated with
     * @param Boolean Tru if the associated record is a contact, false if it is a lead
     * @return List<CampaignMember> List of records ready for insertion to the database
     */
    public static List<CampaignMember> createCampaignMembers(
        Integer numberOfCampaignMembers,
        Id associatedRecord,
        id campaignId,
        Boolean isContact
    ) {
        List<CampaignMember> result = new List<CampaignMember>();

        for (Integer x = 0; x < numberOfCampaignMembers; x++) {
            result.add(createCampaignMember(string.valueOf(x), associatedRecord, campaignId, isContact));
        }

        return result;
    }

    /**
     * Create a campaign member record
     *
     * @param String Unique value to set
     * @param Id The Id of the lead or contact that will be associated with the campaign member
     * @param Id The Id of the campaign the member will be associated with
     * @param Boolean Tru if the associated record is a contact, false if it is a lead
     * @return CampaignMember Record ready for insertion to the database
     */
    public static CampaignMember createCampaignMember(
        String suffix,
        Id associatedRecord,
        id campaignId,
        Boolean isContact
    ) {
        CampaignMember result = new CampaignMember();

        if (isContact) {
            result.contactId = associatedRecord;
        } else {
            result.leadId = associatedRecord;
        }

        result.campaignId = campaignId;
        result.status = 'New';

        return result;
    }

    /*
     * Create a list of pods for insertion into the database
     *
     * @param Integer The number of pods to be created
     * @param ID The record type Id for the new pods
     */
    public static List<Success_Pod__c> createAdvisorPods(Integer numberOfPods) {
        Id advisorPodRTID = IDHelper.getRTID('Success_Pod__c', 'Advisor');
        List<Success_Pod__c> result = new List<Success_Pod__c>();
        List<Group> groups = new List<Group>();
        List<QueueSobject> queues = new List<QueueSobject>();

        // Create list of groups
        for (Integer x = 0; x < numberOfPods; x++) {
            groups.add(new Group(Name = 'TestGroupName' + x, Type = 'Queue'));
        }

        insert groups;

        for (group g : groups) {
            queues.add(new QueueSobject(QueueId = g.Id, SobjectType = 'Success_Pod__c'));

            queues.add(new QueueSobject(QueueId = g.Id, SobjectType = 'Case'));
        }

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert queues;
        }
        Integer x = 0;

        for (group g : groups) {
            x++;
            result.add(
                new Success_Pod__c(
                    OwnerId = g.Id,
                    RecordTypeId = advisorPodRTID,
                    Primary_Email__c = g.name + '@test.asu.edu',
                    Name = 'Test Pod ' + x,
                    Committee__c = 'tp' + x
                )
            );
        }

        insert result;
        return result;
    }

    public static Success_Resource__c createMyAdvisorUserResource() {
        Id advisorResourceRTId = IDHelper.getRTID('Success_Resource__c', 'Advisor');

        Success_Resource__c result = new Success_Resource__c(
            IsActive__c = true,
            Role__c = 'User',
            Resource__c = UserInfo.getUserId(),
            RecordTypeId = advisorResourceRTId
        );
        insert result;
        return result;
    }

    public static List<Success_Resource_Pod_Association__c> createAdvisorSRPAS(
        Success_Resource__c advisorUserResource,
        List<Success_Pod__c> pods
    ) {
        List<Success_Resource_Pod_Association__c> result = new List<Success_Resource_Pod_Association__c>();

        for (Success_Pod__c sp : pods) {
            result.add(
                new Success_Resource_Pod_Association__c(
                    Success_Resource__c = advisorUserResource.Id,
                    Success_Pod__c = sp.Id
                )
            );
        }
        insert result;
        return result;
    }

    public static List<Success_Student__c> createAdvisorStudents(List<Success_Pod__c> pods, Integer numberOfStudents) {
        // Id advisorStudentRTID = IDHelper.getRTID('Success_Student__c', 'Advisor');
        List<Success_Student__c> result = new List<Success_Student__c>();
        Map<Id, List<Contact>> contacts = new Map<Id, List<Contact>>();

        // Create the specified number of students per pod
        for (Success_Pod__c sp : pods) {
            contacts.put(sp.Id, new List<Contact>());

            for (Integer x = 0; x < numberOfStudents; x++) {
                contacts.get(sp.Id).add(new contact(FirstName = 'TestContact' + x, LastName = sp.Name));
            }
        }

        // I tried coming up with about 6 different ways
        // I know that DML in loop is terrible, but this is the best way to set things up
        // We just can't pass a very high number of pods.
        for (id i : contacts.keySet()) {
            insert contacts.get(i);
        }

        // Now that we have contact id's, create junction objects
        for (Success_Pod__c sp : pods) {
            for (Contact c : contacts.get(sp.Id)) {
                result.add(
                    new Success_Student__c(
                        Is_Active__c = true,
                        Success_Pod__c = sp.Id,
                        Student__c = c.Id,
                        Coaching_Student__c = false
                    )
                );
            }
        }
        insert result;
        return result;
    }

    /*
     * Generates test data for the current user as if they were an advisor
     */
    public static void makeMeAnAdvisorUser(Integer numberOfPods, Integer numberOfCases, Integer numberOfStudents) {
        Id advisorOutReachId = IDHelper.getRTID('Case', 'ASU_Advisor_Outreach');
        Success_Resource__c myAdvisorUserResource = createMyAdvisorUserResource();
        List<Success_Pod__c> myAdvisorPods = createAdvisorPods(numberOfPods);
        List<Success_Student__c> myAdvisorStudents = createAdvisorStudents(myAdvisorPods, numberOfStudents);
        List<Success_Resource_Pod_Association__c> myAdvisorSRPAS = createAdvisorSRPAS(
            myAdvisorUserResource,
            myAdvisorPods
        );

        // Create watchlist and proactive cases for the pods/students
        List<Id> podIds = new List<Id>();

        for (Success_Pod__c sp : myAdvisorPods) {
            podIds.add(sp.id);
        }

        Map<Id, Success_Pod__c> podMap = new Map<Id, Success_Pod__c>(
            [SELECT Owner.Name FROM Success_Pod__c WHERE Id IN :podIds]
        );

        // Create cases
        // Note: This doesn't ensure that pods only contain cases for students in their pod
        // Pods may end up with cases for students not in their pod
        // This can and has happened in the real world so we are accounting for it here
        List<Case> cases = new List<Case>();
        createFunctionalGroup('ASU Advisor Outreach');
        createCategory('ASU Advisor Outreach', 'Outreach');
        createCategory('ASU Advisor Outreach', 'Watchlist');
        Id functionalGroup = [SELECT Id FROM case_classification__c WHERE name = 'ASU Advisor Outreach' LIMIT 1].Id;
        Id categoryOutreach = [SELECT Id FROM case_classification__c WHERE name = 'Outreach' LIMIT 1].Id;
        Id categoryWatchlist = [SELECT Id FROM case_classification__c WHERE name = 'Watchlist' LIMIT 1].Id;
        // Cases for pods
        for (Success_Pod__c sp : myAdvisorPods) {
            for (Integer x = 0; x < numberOfCases; x++) {
                // proactive case
                cases.add(
                    new Case(
                        OwnerId = sp.OwnerId,
                        RecordTypeId = advisorOutReachId,
                        Status = 'Outreach Required',
                        CC_Functional_Group__c = functionalGroup,
                        CC_Category__c = categoryOutreach,
                        Origin__c = 'Outreach',
                        Subject = 'Case Bloat ' + math.mod(x, 2),
                        Description = 'Case Bloat',
                        contactId = myAdvisorStudents[
                                (Integer) math.rint(math.random() * (myAdvisorStudents.size() - 1))
                            ]
                            .student__c
                    )
                );
                // Watchlist Cases
                cases.add(
                    new Case(
                        OwnerId = sp.OwnerId,
                        RecordTypeId = advisorOutReachId,
                        Status = 'New',
                        CC_Functional_Group__c = functionalGroup,
                        CC_Category__c = categoryWatchlist,
                        Origin__c = 'Outreach',
                        Subject = 'Case Bloat ' + math.mod(x, 2),
                        Description = 'Case Bloat',
                        contactId = myAdvisorStudents[
                                (Integer) math.rint(math.random() * (myAdvisorStudents.size() - 1))
                            ]
                            .student__c
                    )
                );
            }
        }
        // Cases for advisor
        for (Integer x = 0; x < numberOfCases; x++) {
            Success_Pod__c sp = myAdvisorPods[(Integer) math.rint(math.random() * (myAdvisorPods.size() - 1))];
            string mrq = podMap.get(sp.Id).Owner.Name;

            cases.add(
                new Case(
                    OwnerId = UserInfo.getUserId(),
                    RecordTypeId = advisorOutReachId,
                    Status = 'Outreach Required',
                    CC_Functional_Group__c = functionalGroup,
                    CC_Category__c = categoryWatchlist,
                    Origin__c = 'Outreach',
                    Subject = 'Case Bloat ' + math.mod(x, 2),
                    Description = 'Case Bloat',
                    contactId = myAdvisorStudents[(Integer) math.rint(math.random() * (myAdvisorStudents.size() - 1))]
                        .student__c,
                    Most_Recent_Queue__c = mrq
                )
            );
        }
        insert cases;
    }

    /**
     * Creates a functional group
     */
    public static Case_Classification__c createFunctionalGroup(string RT) {
        Case_Classification__c tmp = new Case_Classification__c();
        tmp.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Functional Group'].Id;
        tmp.Name = RT;
        tmp.Record_Types__c = 'ASU Service';
        tmp.Active__c = true;
        tmp.Visible__c = true;
        insert tmp;
        return tmp;
    }

    public static Case_Classification__c createCategory(string parent, string name) {
        Case_Classification__c tmp = new Case_Classification__c();
        tmp.Name = name;
        tmp.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Category'].Id;
        tmp.Parent__c = [SELECT Id FROM Case_Classification__c WHERE Name = :parent].Id;
        tmp.Active__c = true;
        tmp.Visible__c = true;
        insert tmp;
        return tmp;
    }

    public static Case_Classification__c createSubCategory(String parent, string name) {
        Case_Classification__c tmp = new Case_Classification__c();
        tmp.Name = name;
        tmp.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Sub Category'].Id;
        tmp.Parent__c = [SELECT Id FROM Case_Classification__c WHERE Name = :parent].Id;
        tmp.Active__c = true;
        tmp.Visible__c = true;
        insert tmp;
        return tmp;
    }

    public static void createFunctionalGroupWithCategory(
        string functionalGroupName,
        string categoryName,
        string subcategoryName
    ) {
        createFunctionalGroup(functionalGroupName);
        createCategory(functionalGroupName, categoryName);
        createSubCategory(categoryName, subcategoryName);
    }

    // Create Test Marketing Cloud Business Units (et4ae5__Business_Unit__c)
    public static List<et4ae5__Business_Unit__c> createBusinessUnits(Integer qty) {
        List<et4ae5__Business_Unit__c> buList = new List<et4ae5__Business_Unit__c>();
        for (Integer i = 0; i < qty; i++) {
            et4ae5__Business_Unit__c bu = new et4ae5__Business_Unit__c(
                et4ae5__Business_Unit_ID__c = 'T00000' + i,
                et4ae5__Enabled__c = true,
                Name = 'TestBU' + i
            );
            buList.add(bu);
        }
        return buList;
    }

    // Create Test Marketing Cloud Email Send Definitions (et4ae5__SendDefinition__c)
    public static List<et4ae5__SendDefinition__c> createEmailSends(Integer qty, String recTypeName) {
        List<et4ae5__SendDefinition__c> sdList = new List<et4ae5__SendDefinition__c>();
        Id recTypeId = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'et4ae5__SendDefinition__c' AND Name = :recTypeName
        ][0]
        .Id;
        for (Integer i = 0; i < qty; i++) {
            et4ae5__SendDefinition__c sd = new et4ae5__SendDefinition__c(RecordTypeId = recTypeid);
            sdList.add(sd);
        }
        return sdList;
    }

    // Create Test Subscriptions
    public static List<Subscription__c> createTestSubscriptions(Integer qty) {
        List<et4ae5__Business_Unit__c> buList = createBusinessUnits(1);
        insert buList;

        Subscription__c parentSubscription = new Subscription__c(
            Subscription_Type__c = 'Business Unit',
            Business_Unit__c = buList[0].Id,
            Name = 'ParentSub',
            Subscription_Description__c = 'Parent Sub Description',
            Available_for_Opt_In__c = true,
            Subscriber_Private_in_Salesforce__c = false
        );
        insert parentSubscription;

        List<Subscription__c> subscriptionList = new List<Subscription__c>();
        for (Integer i = 0; i < qty; i++) {
            Subscription__c subscription = new Subscription__c(
                Subscription_Type__c = 'List',
                Name = 'Sub' + i,
                Subscription_Description__c = 'Sub Description' + i,
                Subscriber_Private_in_Salesforce__c = false,
                Parent_Subscription__c = parentSubscription.Id
            );
            subscriptionList.add(subscription);
        }
        return subscriptionList;
    }

    // Create Test Group/Queue
    public static Group createTestGroupAndQueue(List<String> sObjectTypes) {
        List<QueueSObject> queueSObjects = new List<QueueSObject>();
        Group testGroup = new Group(Name = 'TestQueueIER', Type = 'Queue');
        insert testGroup;

        for (String s : sObjectTypes) {
            queueSObjects.add(new QueueSObject(QueueId = testGroup.Id, SobjectType = s));
        }

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert queueSObjects;
        }
        return testGroup;
    }

    /**
     * Create a test list of IERs for the provided Contact Ids and Send Definitions
     * @param A list of Contacts to create IERs for
     * @param A list of Email Send Definitions to create IERs for
     * @return A list of IERs for the provided Contact Id to insert
     */

    public static List<et4ae5__IndividualEmailResult__c> createTestIERs(
        List<Contact> contactList,
        List<et4ae5__SendDefinition__c> sdList
    ) {
        List<et4ae5__IndividualEmailResult__c> ierList = new List<et4ae5__IndividualEmailResult__c>();

        for (et4ae5__SendDefinition__c sd : sdList) {
            for (Contact c : contactList) {
                et4ae5__IndividualEmailResult__c ier = new et4ae5__IndividualEmailResult__c(
                    et4ae5__Contact__c = c.Id,
                    et4ae5__SendDefinition__c = sd.Id,
                    et4ae5__DateSent__c = Datetime.now().addMinutes(-1),
                    et4ae5__DateOpened__c = Datetime.now()
                );
                ierList.add(ier);
            }
        }
        return ierList;
    }

    /**
     * Create a test list of Subscribers for the provided Contact ID
     * @param A list of Contact IDs to create Subscribers for
     * @param A list of Subscriptions to add the Contact to
     * @return A list of Subscribers for the provided Contact IDs to insert
     */
    public static List<Subscriber__c> createTestSubscribers(
        List<Contact> contactList,
        List<Subscription__c> subscriptionList
    ) {
        List<Subscriber__c> subscribers = new List<Subscriber__c>();

        for (Subscription__c subscription : subscriptionList) {
            for (Contact contact : contactList) {
                Subscriber__c subscriber = new Subscriber__c(
                    Subscription__c = subscription.Id,
                    Contact__c = contact.Id,
                    Subscriber_Status__c = 'Subscribed'
                );
                subscribers.add(subscriber);
            }
        }
        return subscribers;
    }

    /**
     * Creates an exception object that can be used for testing exception handlers
     *
     * @return Exception A simple exception
     */
    public static Exception createException() {
        return (Exception) new TestException('Test Exception');
    }

    public class TestException extends Exception {
    }
}
