trigger addContactToCase on Case (before insert) 
{
    for(Case c : Trigger.new)
    {
        if(c.Status == 'Processing')
        {
            List<String> subjectSplit = c.Subject.split('%');
            if(subjectSplit.size() >= 2)
            {
                String emplid = '';
                for(Integer x = 0; x < subjectSplit.size(); x++)
                {
                    List<String> tokenSplit = subjectSplit[x].split(':');
                    if(tokenSplit.size() >= 2 && tokenSplit[0] == 'ASURITE' && tokenSplit[1] != '')
                    {
                        emplid = tokenSplit[1];
                        List<Contact> contactUsers = [SELECT Id FROM Contact WHERE EMPLID__c = :emplid LIMIT 1];
                        if(contactUsers != null && contactUsers.size() == 1)
                        {
                            c.ContactId = contactUsers[0].Id;
                        }
                        break;
                    }
                }
            }
        }
    }
}