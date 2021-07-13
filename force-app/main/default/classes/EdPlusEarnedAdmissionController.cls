public with sharing class EdPlusEarnedAdmissionController {
    private Contact theContact { get; set; }
    public String parentId { get; set; }
    public String trackedAction { get; set; }
    public String relatedRecordId { get; set; }
    public List<EA_Learner_Application__x> applications { get; set; }

    public EdPlusEarnedAdmissionController(ApexPages.StandardController stdController) {
        this.theContact = (Contact) stdController.getRecord();
        this.parentId = theContact.Id;

        // Access the MDM crosswalk for the matching contacts
        List<Id> Contacts = EdPlusUtilities.getExternalContacts(this.parentId);

        // Learner applications
        applications = query.records(
            [
                SELECT
                    Id,
                    ExternalId,
                    Completed__c,
                    Number_of_Credits_Completed__c,
                    Number_of_Credits_Needed__c,
                    Name__c,
                    Eligibility_Start_Date__c,
                    Eligibility_End_Date__c
                FROM EA_Learner_Application__x
                WHERE Contact__c IN :Contacts
            ]
        );
    }

    public void trackUsage() {
        EdPlusUtilities.trackUsage(userInfo.getUserId(), this.trackedAction, this.relatedRecordId);
    }
}
