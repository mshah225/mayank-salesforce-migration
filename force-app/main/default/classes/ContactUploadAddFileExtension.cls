public without sharing class ContactUploadAddFileExtension {
    private final Contact_Upload__c myContactUpload;
    private final Integer UPLOAD_BATCH_SIZE = 200;
    private final Integer MATCHER_BATCH_SIZE = 500;
    
    private List<ContentVersion> fileListCache;
    private Boolean modeSelectedCache;
    private Boolean contactIdMatchCache;
    private String contactModeSelectedCache;
    
    public List<ContentVersion> fileList {
        get {
            if (fileListCache == null) {
                queryFiles();
            }
            return fileListCache;
        }
        set {
            fileListCache = value;
        }
    }
    public Boolean modeSelected {
        get {
            if (modeSelectedCache == null) {
                modeSelectedCache = false;
            }
            return modeSelectedCache;
        }
        set {
            modeSelectedCache = value;
        }
    }
    public Boolean contactIdMatch {
        get {
            if (contactIdMatchCache == null) {
                contactIdMatchCache = false;
            }
            return contactIdMatchCache;
        }
        set {
            contactIdMatchCache = value;
        }
    }
    public String contactModeSelected {
        get {
            if (contactModeSelectedCache == null) {
                contactModeSelectedCache = 'Subscriber Upload';
            }
            return contactModeSelectedCache;
        }
        set {
            contactModeSelectedCache = value;
        }
    }
    public ContentVersion newFile {
        get {
            if (newFile == null) {
                newFile = new ContentVersion();
            }
            return newFile;
        }
        set;
    }
    
    /**
* The extension constructor initializes the private member
* variable myContactUpload by using the getRecord method from the standard
* controller.
*/
    public ContactUploadAddFileExtension(ApexPages.StandardController stdController) {
        this.myContactUpload = (Contact_Upload__c) stdController.getRecord();
        queryFiles();
    }
    private void queryFiles() {
        List<ContentDocumentLink> docLinks = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :myContactUpload.Id
        ];
        
        Set<Id> docIds = new Set<Id>();
        for (ContentDocumentLink link : docLinks) {
            docIds.add(link.ContentDocumentId);
        }
        if (!docIds.isEmpty()) {
            fileListCache = [
                SELECT Id, Title, Description, CreatedDate, CreatedById, CreatedBy.Name,ContentDocumentId
                FROM ContentVersion
                WHERE ContentDocumentId IN :docIds
                AND IsLatest = true
            ];
        } else {
            fileListCache = new List<ContentVersion>();
        }
    }
    public PageReference upload() {
        try {
            newFile.OwnerId = UserInfo.getUserId();
            newFile.PathOnClient = newFile.Title;
            
            insert newFile;
            ContentVersion insertedVersion = [
                SELECT Id, ContentDocumentId, Title
                FROM ContentVersion
                WHERE Id = :newFile.Id
                LIMIT 1
            ];
            
            insert new ContentDocumentLink(
                ContentDocumentId = insertedVersion.ContentDocumentId,
                LinkedEntityId = myContactUpload.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            );
            queryFiles();
            if (contactIdMatch) {
                ContactMatcherBatch batch = new ContactMatcherBatch(insertedVersion.Id, subscriptionId,myContactUpload.Id);
                Database.executeBatch(batch, MATCHER_BATCH_SIZE);
            } else {
                ContactUploadBatch batch = new ContactUploadBatch(
                    insertedVersion.Id,
                    subscriptionId,
                    subscriptionStatusValue
                );
                Database.executeBatch(batch, UPLOAD_BATCH_SIZE);
            }
        } catch (DMLException e) {
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.ERROR, 'Error uploading file: ' + e.getMessage())
            );
        } finally {
            newFile = new ContentVersion();
        }
        return null;
    }
    public void contactUploadButton() {
        contactIdMatch = false;
        contactModeSelected = 'Upload Subscribers';
        modeSelected = true;
    }
    public void contactMatcherButton() {
        contactIdMatch = true;
        contactModeSelected = 'Match Contacts';
        modeSelected = true;
    }
    public String subscriptionValue { get; set; }
    
    public Id subscriptionId {
        get {
            if (subscriptionValue == '--' || subscriptionValue == null) {
                return null;
            } else {
                return Id.valueOf(subscriptionValue);
            }
        }
    }
    public List<SelectOption> subscriptionOptions {
        get {
            if (subscriptionOptions == null) {
                subscriptionOptions = new List<SelectOption>();
                
                Id userId = UserInfo.getUserId();
                List<GroupMember> groupsOfUser = [
                    SELECT UserOrGroupId, Group.Id
                    FROM GroupMember
                    WHERE UserOrGroupId = :userId
                ];
                List<Id> groupIdsUserIsIn = new List<Id>();
                groupIdsUserIsIn.add(userId);
                for (GroupMember groups : groupsOfUser) {
                    groupIdsUserIsIn.add(groups.GroupId);
                }
                List<GroupMember> queueUserIsIn = [
                    SELECT UserOrGroupId, Group.Name, Group.Id
                    FROM GroupMember
                    WHERE 
                    Group.Type = 'Queue' AND 
                    UserOrGroupId IN :groupIdsUserIsIn
                ];
                List<Id> queueIdList = new List<Id>();
                for (GroupMember queues : queueUserIsIn) {
                    queueIdList.add(queues.GroupId);
                }
                List<Subscription__c> allSubs = [
                    SELECT Id, Name
                    FROM Subscription__c
                    WHERE Owner.Id IN :queueIdList
                    ORDER BY Name ASC
                ];
                for (Subscription__c sub : allSubs) {
                    subscriptionOptions.add(new SelectOption(sub.Id, sub.Name));
                }
                if (contactIdMatch) {
                    subscriptionOptions.add(new SelectOption('--', 'All Contacts'));
                }
            }
            return subscriptionOptions;
        }
        set;
    }
    public String subscriptionStatusValue { get; set; }
    public List<SelectOption> subscriptionStatusOptions {
        get {
            if (subscriptionStatusOptions == null) {
                subscriptionStatusOptions = new List<SelectOption>();
                
                subscriptionStatusOptions.add(new SelectOption('Subscribed', 'Subscribed'));
                subscriptionStatusOptions.add(new SelectOption('Unsubscribed', 'Unsubscribed'));
            }
            return subscriptionStatusOptions;
        }
        set;
    }
}