public with sharing class SuncardPhotoController {
    public Contact theContact;

    public SuncardPhotoController(ApexPages.StandardController stdController) {
        this.theContact = (Contact) stdController.getRecord();

        theContact = ContactService.getContactInformation(theContact.Id);
    }

    public String getSuncardPhotoURL() {
        String suncardPhotoURL = SuncardPhotoService.getSunCardPhotoURL(theContact.ASURite_ID__c, theContact.EMPLID__c);

        return suncardPhotoURL;
    }
}
