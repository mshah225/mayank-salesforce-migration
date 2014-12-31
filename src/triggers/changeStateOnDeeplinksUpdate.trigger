trigger changeStateOnDeeplinksUpdate on Case (before update) 
{
    for(Case c : Trigger.new)
    {
        if(c.Status == 'Processing' && c.Deep_Links__c != NULL)
        {
            List<String> links = c.Deep_Links__c.split('Click Here');
            if(links.size() == (Integer.valueof(c.Number_of_Files__c) + 1))
            {
                c.Status = 'New';
                
                List<String> subjectSplit = c.Subject.split('%');
                if(subjectSplit.size() >= 2)
                {
                    String queueId = '';
                    for(Integer x = 0; x < subjectSplit.size(); x++)
                    {
                        List<String> tokenSplit = subjectSplit[x].split(':');
                        if(tokenSplit.size() >= 2 && tokenSplit[0] == 'Queue' && tokenSplit[1] != '')
                        {
                            queueId = tokenSplit[1];
                            c.OwnerId = queueId;
                            System.debug(c.OwnerId);
                        }

                    }
                    c.Subject = subjectSplit[0];
                }
            }
        }
    }
}