public with sharing class SearchUsers {
    public List<User> uList { get; set; }
    public String searchString { get; set; }

    public SearchUsers() {
        uList = new List<User>();
    }

    //Take the user input and do a search
    public void search() {
        Boolean isValidSearchTerm = validateSearchString();
        if (isValidSearchTerm) {
            searchForUsers();
        }
    }

    public Boolean validateSearchString() {
        if (searchString.length() >= 2) {
            return true;
        } else {
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.ERROR, 'You must enter at least 2 search characters')
            );
            return false;
        }
    }

    public void searchForUsers() {
        List<List<SObject>> sobjectList = [
            FIND :'*' + searchString + '*'
            IN ALL FIELDS
            RETURNING
                User(
                    Id,
                    FirstName,
                    LastName,
                    Profile.Name,
                    Contact.Name,
                    Username,
                    ContactId,
                    Contact.ASURite_Id__c,
                    EmplId__c,
                    Contact.EMPLID__c,
                    Alias,
                    FederationIdentifier,
                    ASU_User_Type__c,
                    IsActive
                    LIMIT 50)
        ];

        if (sobjectList[0].size() > 0) {
            uList = sobjectList[0];
        } else {
            uList = new List<User>();
        }
    }
}
