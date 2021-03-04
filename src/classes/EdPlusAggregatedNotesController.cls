/**
 * File Name: EdPlusAggregatedNotesController
 * Description: Tasks from EdPlus
 * Author: Carl Hussey
 * Created: 04/22/2020
 */
public with sharing class EdPlusAggregatedNotesController {
    private Contact theContact { get; set; }
    public String parentId { get; set; }
    public String trackedAction { get; set; }
    public String relatedRecordId { get; set; }
    public List<Wrapper> filteredDataWrapper { get; private set; }
    public List<Wrapper> dataWrapper { get; private set; }
    public List<SelectOption> options { get; set; }

    public String filterType { get; set; }
    public Date startDate { get; set; }
    public Date endDate { get; set; }

    public EdPlusAggregatedNotesController(ApexPages.StandardController stdController) {
        this.theContact = (Contact) stdController.getRecord();
        this.parentId = theContact.Id;
        List<Id> Contacts = EdPlusUtilities.getExternalContacts(this.parentId);

        List<EdPlusTask__x> tasks = Query.records(
            [
                SELECT
                    Owner_Id_edpl__r.Name_edpl__c,
                    Owner_Id_edpl__r.Id,
                    Description_edpl__c,
                    Created_Date_edpl__c,
                    Id,
                    ExternalId,
                    Created_By_Id_edpl__r.Id,
                    Created_By_Id_edpl__r.ExternalId,
                    Created_By_Id_edpl__r.Name_edpl__c,
                    Subject_edpl__c
                FROM EdPlusTask__x
                WHERE Who_Id_edpl__c IN :Contacts
                ORDER BY Activity_Date_edpl__c DESC
                ALL ROWS
            ]
        );

        dataWrapper = new List<Wrapper>();

        for (EdPlusTask__x ta : tasks) {
            dataWrapper.add(new Wrapper(ta));
        }

        dataWrapper.sort();
        filteredDataWrapper = dataWrapper;
    }

    /**
     * Filter options for table
     */
    public List<SelectOption> getFilterOptions() {
        options = new List<SelectOption>();
        options.add(new SelectOption('Created', 'Created Date'));

        return options;
    }

    /**
     * Clear the search filters
     */
    public void clearFilter() {
        this.startDate = null;
        this.endDate = null;
        filterType = 'Created';
        filteredDataWrapper = dataWrapper;
    }

    /**
     * Filter the results based on the type and dates selected
     */
    public void getFilterResults() {
        filteredDataWrapper = new List<Wrapper>();

        if (filterType == 'Created') {
            for (Wrapper thisData : dataWrapper) {
                if (startDate != null && endDate != null && thisData.createdDate != null) {
                    if (
                        Date.valueOf(thisData.createdDate) >= startDate &&
                        Date.valueOf(thisData.createdDate) <= endDate.AddDays(1)
                    ) {
                        filteredDataWrapper.add(thisData);
                    }
                }
            }
        } else {
            System.debug('The filter type does not correspond to any expected values, or is null.');
        }
    }

    /**
     * Track Usage on Controller load
     */
    public void trackUsage() {
        EdPlusUtilities.trackUsage(userInfo.getUserId(), this.trackedAction, this.relatedRecordId);
    }

    /**
     * Wrapper for the combined Task and Event data
     */
    public class Wrapper implements Comparable {
        public EdPlusTask__x tsk { get; set; }

        public String ownerId { get; set; }
        public String ownerName { get; set; }

        public Datetime createdDate { get; set; }
        public String createdByName { get; set; }
        public String createdById { get; set; }

        public String id { get; set; }
        public String type { get; set; }
        public String notes { get; set; }
        public String subject { get; set; }

        public Wrapper(EdPlusTask__x t) {
            tsk = t;
            ownerId = tsk.Owner_Id_edpl__r.Id;
            ownerName = tsk.Owner_Id_edpl__r.Name_edpl__c;
            createdDate = tsk.Created_Date_edpl__c;
            createdByName = tsk.Created_By_Id_edpl__r.Name_edpl__c;
            createdById = tsk.Created_By_Id_edpl__r.Id;
            id = tsk.Id;
            type = 'Task';
            notes = (tsk.Description_edpl__c != '' ? tsk.Description_edpl__c : 'N/A');
            subject = tsk.Subject_edpl__c;
        }

        public Integer compareTo(Object instance) {
            Wrapper that = (Wrapper) instance;
            if (this.createdDate > that.createdDate) {
                return -1;
            }
            if (this.createdDate < that.createdDate) {
                return 1;
            }

            return 0;
        }
    }
}
