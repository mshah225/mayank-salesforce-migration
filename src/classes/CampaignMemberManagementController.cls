public class CampaignMemberManagementController 
{
    // Main page variables
    public CampaignMember camMemInterest;
    public CampaignMember camMemEvent;
    public Id elId { get; set; }
    public Id intId { get; set; }
    public Id contId { get; set; }
    public List<CampaignMember> eventList;
    public List<CampaignMember> interestList;
    public List<CampaignMember> scholarList;
    public List<CampaignMember> cohortList;
    public List<CampaignMember> oSourceList;
    public List<CampaignMember> markCommList;
    public List<CampaignMember> partCourseList;
    public List<Campaign> eventSearchResults;
    public List<Campaign> interestSearchResults;
    public String eSearchString { get;set; }
    public String iSearchString { get;set; }

    // CR specific variables
    public Contact campaignContact;
    public CampaignMember newParentCamMem { get; set; }
    public CampaignMember newChildCamMem { get; set; }
    public CampaignMember inActivateCamMem { get; set; }
    public CampaignMember activateParentCamMem { get; set; }
    public CampaignMember activateChildCamMem { get; set; }
    public Boolean shouldRedirect { get; set; }
    public Id crRecordTypeId;
    public Id selectedParentCampaign { get; set; }
    public Id selectedChildCampaign { get; set; }
    public String inActivateCMId { get; set; }
    public List<CampaignMember> currentCampaigns { get; set; }
    public List<CampaignMember> currentChildCams { get; set; }
    public List<CampaignMember> inActiveCampaigns { get; set; }
    public List<CampaignMember> sortList;
    public List<Campaign> parentCampaigns { get; set; }
    public List<Campaign> childCampaigns { get; set; }
    public List<Campaign> fixedChildCampaigns { get; set; }
    public Set<String> currentSet;
    public Set<String> inActiveSet;
    public Set<String> childSearchSet;
    public String searchString { get; set; }
    public String selectedParentCampaignName { get; set; }
    public String selectedChildCampaignName { get; set; }
    public Boolean crProfile { get; set; }
    public String renderedTab { get; set; }

    public CampaignMemberManagementController(ApexPages.StandardController controller) 
    { 
        campaignContact = [SELECT Id 
                           FROM Contact 
                           WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
        contId = campaignContact.Id;
        crRecordTypeId = [SELECT Id
                          FROM RecordType 
                          WHERE Name = 'Corporate Relations'].Id;
        currentCampaigns = [SELECT Id, Campaign.Name, Campaign.ParentId 
                            FROM CampaignMember 
                            WHERE ContactId = :campaignContact.Id
                            AND Campaign_Type__c = 'Corporate Relations'
                            AND Status = 'Active'
                            ORDER BY Campaign.Name];
        inActiveCampaigns = [SELECT Id, Campaign.Name 
                            FROM CampaignMember 
                            WHERE ContactId = :campaignContact.Id
                            AND Campaign_Type__c = 'Corporate Relations'
                            AND Status = 'Inactive'
                            ORDER BY Campaign.Name];
        String profileName = [SELECT Profile.Name 
                              FROM User 
                              WHERE Id = :UserInfo.getUserId()].Profile.Name;
        List<PermissionSetAssignment> userPermissions = [SELECT PermissionSet.Name 
                                                         FROM PermissionSetAssignment 
                                                         WHERE AssigneeId = :UserInfo.getUserId()];
        Boolean hasCRPerm = false;
        if (userPermissions.size() > 0)
        {
            for (PermissionSetAssignment psa : userPermissions)
            {
                if (psa.PermissionSet.Name != null || psa.PermissionSet.Name != '')
                {
                    String temp = psa.PermissionSet.Name;
                    if (temp.contains('Corporate_Relations'))
                    {
                        hasCRPerm = true;
                    }
                }
            }
        }

        if ((profileName.equals('ASU Corporate Relations') || profileName.equals('System Administrator')) || hasCRPerm) 
        {
            crProfile = true;
            renderedTab = 'crTab';
        }
        else
        {
            crProfile = false;
            renderedTab = 'events';
        }
    }

    // Event tab.
    public List<CampaignMember> getEventList() 
    {
        Id eventRecId = [SELECT Id FROM RecordType WHERE Name = 'Event'].Id;
        Id eossRecId = [SELECT Id FROM RecordType WHERE Name = 'EOSS Event'].Id;

        eventList = [SELECT Id, Campaign.Name, Campaign.Type, Campaign.Requested__c, Campaign.Interest_PeopleSoft_Major__c, Campaign.Event_Start_Date__c, Number_Of_Guests__c, Status, Last_Member_Status_Change__c, ContactId, CampaignId 
                     FROM CampaignMember 
                     WHERE ContactId = :ApexPages.currentPage().getParameters().get('id') 
                     AND (Campaign.RecordTypeId = :eventRecId OR Campaign.RecordTypeId = :eossRecId) 
                     LIMIT 40];
        if (eventList != null) 
        {
            return eventList;
        }
        else 
        {
            return null;
        }
    }

    public void doEventSearch() 
    {
        Id eventRecId = [SELECT Id FROM RecordType WHERE Name = 'Event'].Id;
        Id eossRecId = [SELECT Id FROM RecordType WHERE Name = 'EOSS Event'].Id;
        
        String eSearchQuery = 'SELECT Id, Name, Type, Category__c, Event_Start_Date__c, Event_Start_Time__c, Campus_Location__c, Event_Location__c, RecordTypeId FROM Campaign WHERE (Name LIKE \'%' + String.escapeSingleQuotes(eSearchString) + '%\' OR Type LIKE \'%' + String.escapeSingleQuotes(eSearchString) + '%\' OR Category__c LIKE \'%' + String.escapeSingleQuotes(eSearchString) + '%\') AND (Campaign.RecordTypeId = :eventRecId OR Campaign.RecordTypeId = :eossRecId) AND IsActive = true ORDER BY Name ASC LIMIT 40';
        eventSearchResults = Database.query(eSearchQuery);
    }

    public List<Campaign> getEventSearchResults() 
    {
        return eventSearchResults;
    }

    // Interest tab.
    public List<CampaignMember> getInterestList() 
    {
        Id intRecId = [SELECT Id FROM RecordType WHERE Name = 'Interest'].Id;

        interestList = [SELECT Id, Campaign.Name, Campaign.Type, Campaign.Requested__c, Campaign.Interest_PeopleSoft_Major__c, Status, Last_Member_Status_Change__c 
                        FROM CampaignMember 
                        WHERE Campaign.RecordTypeId = :intRecId 
                        AND ContactId = :ApexPages.currentPage().getParameters().get('id') 
                        LIMIT 40];

        if (interestList != null) 
        {
            return interestList;
        }
        else 
        {
            return null;
        }
    }

    public void doInterestSearch() 
    {
        Id intRecId = [SELECT Id FROM RecordType WHERE Name = 'Interest'].Id;
        
        String iSearchQuery = 'SELECT Id, Name, Type, Campaign_External_ID__c FROM Campaign WHERE (Name LIKE \'%' + String.escapeSingleQuotes(iSearchString) + '%\' OR Type LIKE \'%' + String.escapeSingleQuotes(iSearchString) + '%\') AND Campaign.RecordTypeId = :intRecId AND IsActive = true ORDER BY Name ASC LIMIT 40';
        interestSearchResults = Database.query(iSearchQuery);
    }

    public List<Campaign> getInterestSearchResults() 
    {
        return interestSearchResults;
    }

    // Scholarship tab.
    public List<CampaignMember> getScholarList() 
    {
        Id schRecId = [SELECT Id FROM RecordType WHERE Name = 'Scholarship'].Id;

        scholarList = [SELECT Id, Campaign.Name, Campaign.Type, Amount__c, Award_Date__c, Letter_Date__c, Status, Last_Member_Status_Change__c 
                       FROM CampaignMember 
                       WHERE ContactId = :ApexPages.currentPage().getParameters().get('id') 
                       AND Campaign.RecordTypeId = :schRecId];
        
        return scholarList;
    }

    // Cohort tab.
    public List<CampaignMember> getCohortList() 
    {
        Id cohRecId = [SELECT Id FROM RecordType WHERE Name = 'Cohort'].Id;

        cohortList = [SELECT Id, Campaign.Name, Campaign.Type, Campaign.Requested__c, Status, Last_Member_Status_Change__c 
                      FROM CampaignMember 
                      WHERE ContactId = :ApexPages.currentPage().getParameters().get('id') 
                      AND Campaign.RecordTypeId = :cohRecId];
        
        return cohortList;
    }

    // Other Sources tab.
    public List<CampaignMember> getoSourceList() 
    {
        Id sourceRecId = [SELECT Id FROM RecordType WHERE Name = 'Other Source'].Id;
        oSourceList = [SELECT Id, Campaign.Name, Campaign.Type, Campaign.Requested__c, Status, Last_Member_Status_Change__c 
                       FROM CampaignMember 
                       WHERE ContactId = :ApexPages.currentPage().getParameters().get('id') 
                       AND Campaign.RecordTypeId = :sourceRecId];
        
        return oSourceList;
    }

    // Marketing/Communications tab.
    public List<CampaignMember> getMarkCommList() 
    {
        Id markCommRecid = [SELECT Id FROM RecordType WHERE Name = 'Communication'].Id;

        markCommList = [SELECT Id, Campaign.Name, Campaign.Type, Campaign.Requested__c, Status, Last_Member_Status_Change__c 
                        FROM CampaignMember 
                        WHERE ContactId = :ApexPages.currentPage().getParameters().get('id') 
                        AND Campaign.RecordTypeId = :markCommRecId];
        
        return markCommList;
    }

    // Partnered Courses tab.
    public List<CampaignMember> getPartCourseList() 
    {
        Id partCourseRecid = [SELECT Id FROM RecordType WHERE Name = 'Course'].Id;

        partCourseList = [SELECT Id, Campaign.Name, Campaign.Type, Campaign.StartDate, Campaign.EndDate, edX_Enrollment_Date__c, edX_Active_Enrollment__c, Campaign.Requested__c, Status, Last_Member_Status_Change__c 
                          FROM CampaignMember 
                          WHERE ContactId = :ApexPages.currentPage().getParameters().get('id') 
                          AND Campaign.RecordTypeId = :partCourseRecid];
        
        return partCourseList;
    }

    // Add to event button
    public void AddToEvent() 
    {
        camMemEvent = new CampaignMember();
        camMemEvent.Id = null;
        camMemEvent.LeadId = null;
        camMemEvent.CampaignId = elId;
        camMemEvent.ContactId = campaignContact.Id;
        camMemEvent.Status = 'Invited';
        
        insert camMemEvent;
        System.Debug('Inserted a Event Campaign Member');
        System.Debug(camMemEvent);
    }

    // Add Interest button
    public void AddInterest() 
    {
        camMemInterest = new CampaignMember();
        camMemInterest.Id = null;
        camMemInterest.LeadId = null;
        camMemInterest.CampaignId = intId;
        camMemInterest.ContactId = campaignContact.Id;
        camMemInterest.Status = 'Interested';
        
        insert camMemInterest;
        System.Debug('Inserted an Interest Campaign Member');
        System.Debug(camMemInterest);
    }


    // CR methods
    public List<CampaignMember> getSortList() 
    {
        sortList = new List<CampaignMember>();
        for (CampaignMember cm: currentCampaigns)
        {
            if (cm.Campaign.ParentId == null)
            {
                sortList.add(cm);
                for (CampaignMember ch: [SELECT Campaign.Name, Campaign.ParentId
                                         FROM CampaignMember 
                                         WHERE ContactId = :campaignContact.Id 
                                         AND Campaign_Type__c = 'Corporate Relations'
                                         AND Status = 'Active' 
                                         AND Campaign.ParentId = :cm.Campaign.Id
                                         ORDER BY Campaign.Name])
                {
                    sortList.add(ch);
                }
            }
        }   
        return sortList;
    }

    public void parentCampaignSearch()
    {
        parentCampaigns = null;
        childCampaigns = null;
        selectedParentCampaignName = null; 

        String queryString = 'SELECT Id, Name FROM Campaign WHERE RecordTypeId = \'' + crRecordTypeId + '\' AND Name LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\' AND ParentId = null AND isActive = true AND Type = \'Corporate Relations\'';
        parentCampaigns = Database.query(queryString);
    }

    public void childCampaignSearch()
    {
        currentChildCams = [SELECT CampaignId 
                            FROM CampaignMember 
                            WHERE ContactId = :campaignContact.Id 
                            AND Campaign.ParentId = :selectedParentCampaign
                            AND Status = 'Active'];
        childSearchSet = new Set<String>();
        fixedChildCampaigns = new List<Campaign>();
        for (CampaignMember c: currentChildCams)
        {
            childSearchSet.add(c.CampaignId);
        }

        String queryString = 'SELECT Id, Name FROM Campaign WHERE RecordTypeId = \'' + crRecordTypeId + '\' AND ParentId = \'' + selectedParentCampaign + '\' AND isActive = true';
        childCampaigns = Database.query(queryString);
        for (Campaign cc: childCampaigns) 
        {
            if(!childSearchSet.contains(cc.Id))
            {
                fixedChildCampaigns.add(cc);
            }
        }
    }

    public void parentCamNameSearch() {
        parentCampaigns.clear();

        selectedParentCampaignName = [SELECT Name 
                                      FROM Campaign
                                      WHERE Id = :selectedParentCampaign].Name;
    }

    public void childCamNameSearch() {
        selectedChildCampaignName = [SELECT Name 
                                     FROM Campaign
                                     WHERE Id = :selectedChildCampaign].Name;
    }

    public void assignToParentCampaign()
    {
        newParentCamMem = new CampaignMember();
        newParentCamMem.ContactId = campaignContact.Id;
        newParentCamMem.CampaignId = selectedParentCampaign;
        newParentCamMem.Status = 'Active';
        searchString = null;
        childCampaignSearch();
    }

    public void assignToChildCampaign()
    {
        newChildCamMem = new CampaignMember();
        newChildCamMem.ContactId = campaignContact.Id;
        newChildCamMem.CampaignId = selectedChildCampaign;
        newChildCamMem.Status = 'Active';
        childCamNameSearch();
        save();
    } 

    public void inActivateCM() 
    {
        List<CampaignMember> childKillList = new List<CampaignMember>();
        inActivateCamMem = [SELECT Id, Campaign.ParentId, CampaignId, CreatedBy.UserRole.Name 
                            FROM CampaignMember
                            WHERE Id = :inActivateCMId];
        User currentUser = [SELECT Id, UserRole.Name 
                            FROM User 
                            WHERE Id = :UserInfo.getUserId()];
        if (inActivateCamMem.CreatedBy.UserRole.Name == currentUser.UserRole.Name)
        {
            
            inActivateCamMem.Status = 'Inactive';
            if (inActivateCamMem.Campaign.ParentId == null)
            {
                childKillList = [SELECT Id, Status
                                 FROM CampaignMember
                                 WHERE Campaign.ParentId = :inActivateCamMem.CampaignId];
                for (CampaignMember kill: childKillList)
                {
                    kill.Status = 'Inactive';
                }
            }
            try
            {
                update inActivateCamMem;
                update childKillList;
            }
            catch (Exception e)
            {

            }
            shouldRedirect = true;
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You do not have access to remove this Affiliation, only a member of the Department that created it can.'));
        }
    }

    public void save() 
    {
        System.debug('!!!!!!!!!!!! SAVE !!!!!!!!!!!!!!');
        try
        {
            System.debug(newChildCamMem);
            System.debug(newParentCamMem);
            currentSet = new Set<String>();
            for (CampaignMember c: currentCampaigns)
            {
                currentSet.add(c.Campaign.Name);
            }

            inActiveSet = new Set<String>();
            for (CampaignMember ia: inActiveCampaigns)
            {
                inActiveSet.add(ia.Campaign.Name);
            }

            if (!inActiveSet.contains(selectedParentCampaignName))
            {
                if (!currentSet.contains(selectedParentCampaignName))
                {
                    insert newParentCamMem;
                    System.debug('Inserted Parent camMem ' + newParentCamMem);
                }
            }
            else
            {
                activateParentCamMem = [SELECT Id 
                                        FROM CampaignMember
                                        WHERE Campaign.Name = :selectedParentCampaignName
                                        AND ContactId = :ApexPages.currentPage().getParameters().get('id')];
                activateParentCamMem.Status = 'Active';
                update activateParentCamMem;
            }
            if(selectedChildCampaign != null)
            {
                if (!inActiveSet.contains(selectedChildCampaignName))
                {
                    if (!currentSet.contains(selectedChildCampaignName))
                    {
                        insert newChildCamMem;
                        System.debug('Inserted chil camMem ' + newChildCamMem);
                    }
                }
                else 
                {
                    activateChildCamMem = [SELECT Id 
                                           FROM CampaignMember
                                           WHERE Campaign.Name = :selectedChildCampaignName
                                           AND ContactId = :ApexPages.currentPage().getParameters().get('id')];
                    activateChildCamMem.Status = 'Active';
                    update activateChildCamMem;
                }
            }
        }
        catch (Exception e)
        {
            System.debug('EXCEPTION');
            System.debug(e);
        }
        shouldRedirect = true;
    }
}