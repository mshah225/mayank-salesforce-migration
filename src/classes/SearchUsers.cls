public with sharing class SearchUsers
{
    public Boolean hideCommunity { get; set; }
    public List<User> uList { get; set; }
    public String searchString { get; set; }

    public SearchUsers()
    {
        hideCommunity = false;
        uList = new List<User>();
    }

    //Take the user input and do a search
    public void search()
    {
        if (searchString.length() >= 2)
        {
            String searchQuery = '' +
                'FIND \'*' + String.escapeSingleQuotes(searchString) + '*\' ' +
                'IN ALL FIELDS ' +
                'RETURNING User(' +
                'Id, FirstName, LastName, Profile.Name, Contact.Name, ContactId, ' +
                'Contact.ASURite_Id__c, EmplId__c, contact.EMPLID__c, Alias, ' +
                'FederationIdentifier, ASU_User_Type__c, IsActive ';

            if (hideCommunity)
            {
                searchQuery += 'WHERE Profile.Name != \'ASU Community\' ' +
                    'AND Profile.Name != \'ASU Community CAP\' ';
            }

            searchQuery += 'LIMIT 50)';

            List<List<SObject>> sobjectList = Search.query(searchQuery);

            if (sobjectList[0].size() > 0)
            {
                uList = sobjectList[0];
            }
            else
            {
                uList = new List<User>();
            }
        }
        else
        {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'You must enter at least 2 search characters'
                )
            );
        }
    }
}