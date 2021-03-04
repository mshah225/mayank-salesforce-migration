public without sharing class ContactUploadAddFileExtension {
    private final Contact_Upload__c myContactUpload;
    private final Integer UPLOAD_BATCH_SIZE = 200;
    private final Integer MATCHER_BATCH_SIZE = 500;
    public List<Attachment> attachmentList { get; set; }
    public Boolean modeSelected {
        get {
            if (modeSelected == null) {
                modeSelected = false;
            }
            return modeSelected;
        }
        set;
    }
    public Boolean contactIdMatch {
        get {
            if (contactIdMatch == null) {
                contactIdMatch = false;
            }
            return contactIdMatch;
        }
        set;
    }

    public String contactModeSelected {
        get {
            if (contactModeSelected == null) {
                contactModeSelected = 'Subscriber Upload';
            }
            return contactModeSelected;
        }
        set;
    }

    public Attachment newAttachment {
        get {
            if (newAttachment == null) {
                newAttachment = new Attachment();
            }
            return newAttachment;
        }
        set;
    }

    /**
     * The extension constructor initializes the private member
     * variable mysObject by using the getRecord method from the standard
     * controller.
     */
    public ContactUploadAddFileExtension(ApexPages.StandardController stdController) {
        this.myContactUpload = (Contact_Upload__c) stdController.getRecord();
        queryAttachments();
    }

    private void queryAttachments() {
        attachmentList = new List<Attachment>(
            [
                SELECT Id, Name, Description, CreatedDate, CreatedById, CreatedBy.Name
                FROM Attachment
                WHERE ParentId = :myContactUpload.Id
            ]
        );
    }

    public PageReference upload() {
        newAttachment.OwnerId = UserInfo.getUserId();
        newAttachment.ParentId = myContactUpload.Id;
        newAttachment.IsPrivate = true;

        try {
            insert newAttachment;
            queryAttachments();
            if (contactIdMatch) {
                ContactMatcherBatch batch = new ContactMatcherBatch(newAttachment.Id, subscriptionId);
                Database.executeBatch(batch, MATCHER_BATCH_SIZE);
            } else {
                ContactUploadBatch batch = new ContactUploadBatch(
                    newAttachment.Id,
                    subscriptionId,
                    subscriptionStatusValue
                );
                Database.executeBatch(batch, UPLOAD_BATCH_SIZE);
            }
        } catch (DMLException e) {
            ApexPages.addMessage(
                new ApexPages.message(ApexPages.severity.ERROR, 'Error uploading attachment: ' + e.getMessage())
            );
        } finally {
            newAttachment = new Attachment();
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
                    WHERE Group.Type = 'Queue' AND UserOrGroupId IN :groupIdsUserIsIn
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
