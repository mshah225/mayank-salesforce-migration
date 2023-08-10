public with sharing class StudentSearchController {
    public String contactId { get; set; }
    public boolean urlParamsExistAndAreValid { get; set; }

    public StudentSearchController() {
        if (ApexPages.currentPage().getParameters().get('contactId') != null) {
            contactId = ApexPages.currentPage().getParameters().get('contactId');
            urlParamsExistAndAreValid = true;
        } else {
            urlParamsExistAndAreValid = false;
        }
    }

    public void init() {
    }
}