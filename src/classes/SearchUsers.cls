public with sharing class SearchUsers
{
    public Boolean hideCommunity { get; set; }
    public List<User> uList { get; set; }
    public String searchString { get; set; }

    public SearchUsers()
    {
        hideCommunity = false;
        populateUList();
    }

    public void populateUList()
    {
        uList = [
            SELECT Id, Name, Profile.Name, Contact.Name, ContactId,
                Contact.ASURite_Id__c, Alias, FederationIdentifier,
                ASU_User_Type__c, IsActive
            FROM User
            ORDER BY Name ASC
            LIMIT 50
        ];

        if (uList.size() == 0)
        {
            ulist = new List<User>();
        }
    }

    //Take the user input and do a search
    public void search()
    {
        if (searchString.length() > 2)
        {
            String searchQuery = '' +
                'FIND \'*' + String.escapeSingleQuotes(searchString) + '*\' ' +
                'IN ALL FIELDS ' +
                'RETURNING User(' +
                    'Id, Name, Profile.Name, Contact.Name, ContactId, Contact.ASURite_Id__c, ' +
                    'EmplId__c, contact.EMPLID__c, Alias, FederationIdentifier, ASU_User_Type__c, ' +
                    'IsActive ';

            if (hideCommunity)
            {
                searchQuery += 'WHERE Profile.Name != \'ASU Community\' ' +
                    'AND Profile.Name != \'ASU Community CAP\' ';
            }

            searchQuery += 'ORDER BY Name ASC LIMIT 50)';

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

    //Remove user input from variable
    public void clear()
    {
        uList.clear();
        populateUList();
    }

    //Do we have results? returns true/false
    public Boolean getNoResults()
    {
        if (uList.isEmpty())
        {
            return true;
        }
        else
        {
            return false;
        }
    }
}