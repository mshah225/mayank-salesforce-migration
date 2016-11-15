@isTest
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
     * Create a list oc cases with the statuses set to new and the subjects set to
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
    public static List<CampaignMember> createCampaignMembers(Integer numberOfCampaignMembers, 
        Id associatedRecord, id campaignId, Boolean isContact) {
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
    public static CampaignMember createCampaignMember(String suffix, Id associatedRecord, id campaignId, Boolean isContact) {
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
    
    /**
     * Creates an exception object that can be used for testing exception handlers
     *
     * @return Exception A simple exception
     */
    public static Exception createException() {
        return (Exception) new testException('Test Exception');
    }
    
    public class testException extends Exception { }
}