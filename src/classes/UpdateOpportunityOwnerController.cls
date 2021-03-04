/*
 * @author aesanch2
 */
public with sharing class UpdateOpportunityOwnerController {
    private final ApexPages.StandardSetController controller;
    private final PageReference listView;
    private final List<SObject> opportunities;
    private Map<String, Schema.SObjectField> opportunityFields;
    private Schema.SObjectField ownerField;
    private transient ApexPages.Message apexMessage;
    private Integer page;
    private String newOwner;

    public UpdateOpportunityOwnerController(ApexPages.StandardSetController stdController) {
        page = 1;
        stdController.setPageSize(1000);
        controller = (ApexPages.StandardSetController) stdController;
        listView = controller.cancel();
        if (this.opportunities == null) {
            this.opportunities = (List<SObject>) controller.getSelected();
        }

        if (getNumberOfOpportunities() < 1) {
            String msg =
                'No opportunities selected in the list view. Please click back on your browser or any button below and select the opportunities ' +
                'you would like to change the owner on.';
            apexMessage = new ApexPages.Message(ApexPages.severity.ERROR, msg);
            ApexPages.addMessage(apexMessage);
        } else if (getNumberOfOpportunities() > 10000) {
            String msg =
                'Warning: you will not be able to update more than 10000 opportunities at a time. Please click back on your browser or any ' +
                'button below to decrease the number of opportunites you would like to update.';
            apexMessage = new ApexPages.Message(ApexPages.severity.ERROR, msg);
            ApexPages.addMessage(apexMessage);
        }
    }

    public Integer getNumberOfOpportunities() {
        if (opportunities != null) {
            return opportunities.size();
        } else {
            return 0;
        }
    }

    public PageReference confirmOwner() {
        if (getNumberOfOpportunities() < 1 || getNumberOfOpportunities() > 10000) {
            return listView;
        }
        page = 2;
        return ApexPages.currentPage();
    }

    public void selectOwner() {
        Opportunity opp = (Opportunity) controller.getRecord();
        newOwner = [SELECT Id FROM User WHERE Id = :opp.OwnerId].Id;
    }

    public Integer getPage() {
        return page;
    }

    public void setNewOwner(String newOwner) {
        this.newOwner = newOwner;
    }

    public PageReference cancel() {
        return listView;
    }

    public PageReference page1() {
        page = 1;
        return ApexPages.currentPage();
    }

    public PageReference submitUpdate() {
        page = 3;
        ApexPages.addMessage(updateOwner());
        return ApexPages.currentPage();
    }

    private ApexPages.Message updateOwner() {
        Schema.DescribeSObjectResult sObj = discoverSobjectType(opportunities.get(0));

        opportunityFields = sObj.fields.getMap();
        ownerField = opportunityFields.get('OwnerId');

        try {
            for (SObject opp : opportunities) {
                opp.put(ownerField, newOwner);
            }
        } catch (System.SObjectException e) {
            System.debug('Type exception: ' + e.getMessage());
            return new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage() + ' No opportunities updated.');
        }

        try {
            update opportunities;
            return new ApexPages.Message(
                ApexPages.severity.INFO,
                'Updated ' +
                opportunities.size() +
                ' opportunities with new owner.'
            );
        } catch (System.DmlException e) {
            return new ApexPages.Message(ApexPages.severity.ERROR, e.getDmlMessage(0) + ' No opportunities updated.');
        }
    }

    private DescribeSObjectResult discoverSobjectType(SObject s) {
        Map<String, Schema.SObjectType> des = Schema.getGlobalDescribe();

        for (Schema.SObjectType o : des.values()) {
            if (s.getSObjectType() == o) {
                return o.getDescribe();
            }
        }
        return null;
    }
}
