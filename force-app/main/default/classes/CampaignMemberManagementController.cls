public with sharing class CampaignMemberManagementController {
    private Set<Id> assignedEventIds;
    private Set<Id> assignedIntIds;
    private Map<String, List<CampaignMember>> campaignMemberMap;
    private Map<String, Id> recordTypeIdMap;

    public Boolean crProfile { get; set; }
    public Boolean admin { get; set; }
    public Boolean eventDeets { get; set; }
    public Campaign tempCampaign { get; set; }
    public CampaignMember newParentCamMem;
    public CampaignMember newChildCamMem { get; set; }
    public CampaignMember inActivateCamMem { get; set; }
    public CampaignMember activateParentCamMem { get; set; }
    public CampaignMember activateChildCamMem { get; set; }
    public CampaignMember camMemInterest;
    public CampaignMember camMemEvent { get; set; }
    public Date camStartDate { get; set; }
    public Id selectedParentCampaign { get; set; }
    public Id selectedChildCampaign { get; set; }
    public Id elId { get; set; }
    public Id intId { get; set; }
    public Id contactId { get; set; }
    public List<CampaignMember> activeCrCamMems;
    public List<CampaignMember> currentChildCams { get; set; }
    public List<CampaignMember> inactiveCrCamMems { get; set; }
    public List<Campaign> parentCampaigns { get; set; }
    public List<Campaign> childCampaigns { get; set; }
    public List<Campaign> fixedChildCampaigns { get; set; }
    public List<Campaign> eventSearchResults { get; set; }
    public List<Campaign> interestSearchResults { get; set; }
    public List<Subscriber__c> subscriberList { private get; set; } // New for Marketing Cloud project
    public List<Message> filteredMessageList; // New for Marketing Cloud project
    public List<Message> allMessageList { get; set; } // New for Marketing Cloud project
    public String searchString { get; set; }
    public String selectedParentCampaignName { get; set; }
    public String selectedChildCampaignName { get; set; }
    public String renderedTab { get; set; }
    public String inActivateCMId { get; set; }
    public String eSearchString { get; set; }
    public String iSearchString { get; set; }
    public String deptColl { get; set; }
    public String selectedEventName { get; set; }

    public String commFilterType { get; set; } // New for Marketing Cloud project
    public Date commFilterStartDate { get; set; } // New for Marketing Cloud project
    public Date commFilterEndDate { get; set; } // New for Marketing Cloud project

    public CampaignMemberManagementController(ApexPages.StandardController controller) {
        contactId = ApexPages.currentPage().getParameters().get('id');
        admin = false;
        eventDeets = false;
        recordTypeIdMap = new Map<String, Id>();
        eventSearchResults = new List<Campaign>();
        interestSearchResults = new List<Campaign>();
        parentCampaigns = new List<Campaign>();
        tempCampaign = new Campaign();
        camMemEvent = new CampaignMember();

        buildCampaignMemberMap();
        buildCommMessageList();

        String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;

        List<PermissionSetAssignment> userPermissions = [
            SELECT PermissionSet.Name
            FROM PermissionSetAssignment
            WHERE AssigneeId = :UserInfo.getUserId()
        ];

        Boolean hasCRPerm = false;

        if (userPermissions.size() > 0) {
            for (PermissionSetAssignment psa : userPermissions) {
                if (psa.PermissionSet.Name != null || psa.PermissionSet.Name != '') {
                    String temp = psa.PermissionSet.Name;
                    if (temp.contains('Corporate_Relations')) {
                        hasCRPerm = true;
                    }
                }
            }
        }

        if (profileName.equals('ASU Corporate Relations') || hasCRPerm) {
            crProfile = true;
            renderedTab = 'crTab';
        } else {
            crProfile = false;
            renderedTab = 'events';
        }

        if (profileName.equals('System Administrator')) {
            admin = true;
        }
    }

    public void buildCampaignMemberMap() {
        campaignMemberMap = new Map<String, List<CampaignMember>>();
        activeCRCamMap = new Map<String, List<CampaignMember>>();
        activeCRCamMap.put(null, new List<CampaignMember>());
        List<CampaignMember> contactCamMems = getCampaignMembers(contactId);
        List<CampaignMember> tempCrActiveList = new List<CampaignMember>();
        List<CampaignMember> tempCrInactiveList = new List<CampaignMember>();
        List<CampaignMember> tempEventList = new List<CampaignMember>();
        List<CampaignMember> tempEossList = new List<CampaignMember>();
        List<CampaignMember> tempInterestList = new List<CampaignMember>();
        List<CampaignMember> tempScholList = new List<CampaignMember>();
        List<CampaignMember> tempCohortList = new List<CampaignMember>();
        List<CampaignMember> tempOtherList = new List<CampaignMember>();
        List<CampaignMember> tempCommList = new List<CampaignMember>();
        List<CampaignMember> tempCourseList = new List<CampaignMember>();

        for (CampaignMember cm : contactCamMems) {
            if ((cm.Campaign.RecordType.Name == 'Corporate Relations') && (cm.Status == 'Active')) {
                if (activeCRCamMap.get(cm.Campaign.Parent.Name) == null) {
                    activeCRCamMap.put(cm.Campaign.Parent.Name, new List<CampaignMember>());
                }

                activeCRCamMap.get(cm.Campaign.Parent.Name).add(cm);

                tempCrActiveList.add(cm);
            } else if ((cm.Campaign.RecordType.Name == 'Corporate Relations') && (cm.Status == 'Inactive')) {
                tempCrInactiveList.add(cm);
            } else if (cm.Campaign.RecordType.Name == 'Event') {
                tempEventList.add(cm);
            } else if (cm.Campaign.RecordType.Name == 'EOSS Event') {
                tempEossList.add(cm);
            } else if (cm.Campaign.RecordType.Name == 'Interest') {
                tempInterestList.add(cm);
            } else if (cm.Campaign.RecordType.Name == 'Scholarship') {
                tempScholList.add(cm);
            } else if (cm.Campaign.RecordType.Name == 'Cohort') {
                tempCohortList.add(cm);
            } else if (cm.Campaign.RecordType.Name == 'Other Source') {
                tempOtherList.add(cm);
            } else if (cm.Campaign.RecordType.Name == 'Communication') {
                tempCommList.add(cm);
            } else if (cm.Campaign.RecordType.Name == 'Course') {
                tempCourseList.add(cm);
            }
        }

        campaignMemberMap.put('Active CR', tempCrActiveList);
        campaignMemberMap.put('Inactive CR', tempCrInactiveList);
        campaignMemberMap.put('Event', tempEventList);
        campaignMemberMap.put('EOSS Event', tempEossList);
        campaignMemberMap.put('Interest', tempInterestList);
        campaignMemberMap.put('Scholarship', tempScholList);
        campaignMemberMap.put('Cohort', tempCohortList);
        campaignMemberMap.put('Other Source', tempOtherList);
        campaignMemberMap.put('Communication', tempCommList);
        campaignMemberMap.put('Course', tempCourseList);
    }

    private List<CampaignMember> getCampaignMembers(Id contactId) {
        String camFields = ObjectService.objectFieldsToString(ObjectService.getObjectFieldMap('CampaignMember'));
        String soql =
            '' +
            'SELECT ' +
            camFields +
            ', Campaign.RecordType.Name, Campaign.Name, ' +
            'Campaign.ParentId, Campaign.Type, Campaign.Requested__c, Campaign.Parent.Name, ' +
            'Campaign.Event_Start_Date__c, Campaign.Event_End_Date__c, ' +
            'Campaign.Interest_PeopleSoft_Major__c, Campaign.StartDate, Campaign.EndDate ' +
            'FROM CampaignMember ' +
            'WHERE ContactId = :contactId ';
        List<CampaignMember> camMems = Database.query(soql);

        return camMems;
    }

    public List<Subscriber__c> getSubscriberList() {
        if (subscriberList == null) {
            subscriberList = [
                SELECT
                    Id,
                    Subscriber_Status__c,
                    Last_Subscribed_Date__c,
                    Last_Unsubscribed_Date__c,
                    Subscription__r.Name,
                    Subscription__r.Subscription_Type__c,
                    Subscription__r.Business_Unit__r.Name
                FROM Subscriber__c
                WHERE Contact__c = :contactId
            ];
        }

        return subscriberList;
    }

    public List<Message> getfilteredMessageList() {
        List<Message> messageList = new List<Message>();

        for (Message thisMessage : allMessageList) {
            if (commFilterType == 'Sent') {
                if (commFilterStartDate != null && thisMessage.timeSent < commFilterStartDate) {
                    continue;
                }
                if (commFilterEndDate != null && thisMessage.timeSent > commFilterEndDate.addDays(1)) {
                    continue;
                }
            } else if (commFilterType == 'Opened') {
                if (
                    commFilterStartDate != null &&
                    (thisMessage.timeOpened < commFilterStartDate ||
                    thisMessage.timeOpened == null)
                ) {
                    continue;
                }
                if (
                    (commFilterEndDate != null && thisMessage.timeOpened > commFilterEndDate.addDays(1)) ||
                    thisMessage.timeOpened == null
                ) {
                    continue;
                }
            }
            messageList.add(thisMessage);
        }

        return messageList;
    }

    public List<Message> buildCommMessageList() {
        List<et4ae5__IndividualEmailResult__c> ierList = new List<et4ae5__IndividualEmailResult__c>();
        // Query for the communication history
        ierList = [
            SELECT
                Id,
                Name,
                et4ae5__SubjectLine__c,
                et4ae5__FromName__c,
                et4ae5__FromAddress__c,
                et4ae5__SoftBounce__c,
                et4ae5__HardBounce__c,
                et4ae5__DateSent__c,
                et4ae5__DateOpened__c,
                et4ae5__NumberOfUniqueClicks__c,
                et4ae5__Contact__c,
                et4ae5__SendDefinition__c,
                et4ae5__SendDefinition__r.et4ae5__fBusiness_Unit__c
            FROM et4ae5__IndividualEmailResult__c
            WHERE et4ae5__Contact__c = :contactId
            ORDER BY et4ae5__DateSent__c DESC
            LIMIT 750
        ];

        allMessageList = new List<Message>();
        for (et4ae5__IndividualEmailResult__c ier : ierList) {
            Message thisMessage = new Message();
            thisMessage.id = ier.Id;
            thisMessage.name = ier.Name;
            thisMessage.subject = ier.et4ae5__SubjectLine__c;
            thisMessage.sender = (ier.et4ae5__SendDefinition__c == null
                ? ier.et4ae5__FromName__c
                : ier.et4ae5__SendDefinition__r.et4ae5__fBusiness_Unit__c);

            // Determine the delivery status of the message based on whether or not it returned a hard or soft bounce
            if (ier.et4ae5__HardBounce__c) {
                thisMessage.deliveryStatus = 'Hard Bounce';
            } else if (ier.et4ae5__SoftBounce__c) {
                thisMessage.deliveryStatus = 'Soft Bounce';
            } else {
                thisMessage.deliveryStatus = 'Delivered';
            }

            thisMessage.timeSent = ier.et4ae5__DateSent__c;

            thisMessage.timeOpened = ier.et4ae5__DateOpened__c;
            thisMessage.uniqueClicks = String.valueOf(ier.et4ae5__NumberOfUniqueClicks__c);

            allMessageList.add(thisMessage);
        }

        return filteredMessageList;
    }

    // New for Marketing Cloud project
    public List<SelectOption> getCommFilterOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Sent', 'Date Sent'));
        options.add(new SelectOption('Opened', 'Date Opened'));
        return options;
    }

    // New for Marketing Cloud project
    /*
     * @description: Clears the search filters. As a result, all communication history for the
     * case is displayed.
     */
    public void clearCommFilter() {
        // Reset the input fields for Start Date and End Date
        this.commFilterStartDate = null;
        this.commFilterEndDate = null;
        // Reset the filter type to its default value
        commFilterType = 'Sent';
    }

    public List<SelectOption> getDepartmentsColleges() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--Select--'));

        Schema.DescribeFieldResult fieldResult = Campaign.Requested__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }

        return options;
    }

    public List<SelectOption> getSelectedEventCamMemStatuses() {
        List<CampaignMemberStatus> camStatuses = [
            SELECT Id, Label
            FROM CampaignMemberStatus
            WHERE CampaignId = :elId
            ORDER BY Label ASC
        ];

        List<SelectOption> camOptions = new List<SelectOption>();
        camOptions.add(new SelectOption('', '--Select--'));

        for (CampaignMemberStatus cs : camStatuses) {
            camOptions.add(new SelectOption(cs.Label, cs.Label));
        }

        return camOptions;
    }

    // Event tab.
    public List<CampaignMember> getEventList() {
        List<CampaignMember> tempEvents = campaignMemberMap.get('Event');
        List<CampaignMember> tempEOSSEvents = campaignMemberMap.get('EOSS Event');
        List<CampaignMember> eventList = new List<CampaignMember>();

        if (tempEvents.size() > 0) {
            eventList.addAll(tempEvents);
        }

        if (tempEOSSEvents.size() > 0) {
            eventList.addAll(tempEOSSEvents);
        }

        if (eventList != null) {
            assignedEventIds = new Set<Id>();

            for (CampaignMember cm : eventList) {
                assignedEventIds.add(cm.CampaignId);
            }

            eventList.sort();
        }

        return eventList;
    }

    public void doEventSearch() {
        eventDeets = false;

        if (eSearchString.length() < 2) {
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR, 'You must enter at least 2 characters.')
            );

            return;
        }

        String sosl =
            '' +
            'FIND \'*' +
            String.escapeSingleQuotes(eSearchString.trim()) +
            '*\' ' +
            'IN NAME FIELDS ' +
            'RETURNING Campaign(Id, Name, Type, Category__c, Event_Start_Date__c, ' +
            'Event_Start_Time__c, Campus_Location__c, Event_Location__c, ' +
            'RecordTypeId, Requested__c ' +
            'WHERE (RecordType.Name = \'Event\' ' +
            'OR RecordType.Name = \'EOSS Event\'' +
            ') ' +
            'AND Id NOT IN :assignedEventIds ' +
            'AND IsActive = true ';

        if (deptColl != null) {
            sosl += 'AND Requested__c INCLUDES (:deptColl) ';
        }

        Id location = tempCampaign.Campus_Location__c;
        if (tempCampaign.Campus_Location__c != null) {
            sosl += 'AND Campus_Location__c = :location ';
        }

        if (camStartDate != null) {
            sosl += 'AND Event_Start_Date__c = :camStartDate ';
        }

        sosl += 'ORDER BY Name ASC LIMIT 1000)';

        List<List<SObject>> sObjects = Search.query(sosl);

        if (sObjects.size() > 0) {
            eventSearchResults = sObjects[0];
        } else {
            eventSearchResults = new List<Campaign>();
        }
    }

    // Interest tab.
    public List<CampaignMember> getInterestList() {
        List<CampaignMember> tempInterests = new List<CampaignMember>();
        List<CampaignMember> interestList = new List<CampaignMember>();

        tempInterests = campaignMemberMap.get('Interest');

        if (tempInterests.size() > 0) {
            interestList.addAll(tempInterests);
        }

        if (interestList != null) {
            assignedIntIds = new Set<Id>();

            for (CampaignMember cm : interestList) {
                assignedIntIds.add(cm.CampaignId);
            }
        }

        return interestList;
    }

    public void doInterestSearch() {
        if (iSearchString.length() < 2) {
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR, 'You must enter at least 2 characters.')
            );

            return;
        }

        String sosl =
            '' +
            'FIND \'*' +
            String.escapeSingleQuotes(iSearchString.trim()) +
            '*\' ' +
            'IN NAME FIELDS ' +
            'RETURNING Campaign(Id, Name, Type, Category__c, Event_Start_Date__c, ' +
            'Event_Start_Time__c, Campus_Location__c, ' +
            'Event_Location__c, Campaign_External_ID__c, ' +
            'RecordTypeId, Requested__c ' +
            'WHERE RecordType.Name = \'Interest\' ' +
            'AND IsActive = true ' +
            'AND Id NOT IN :assignedIntIds ' +
            'ORDER BY Name ASC ' +
            ')';

        List<List<SObject>> sObjects = Search.query(sosl);

        if (sObjects.size() > 0) {
            interestSearchResults = sObjects[0];
        } else {
            interestSearchResults = new List<Campaign>();
        }
    }

    // Scholarship tab.
    public List<CampaignMember> getScholarList() {
        List<CampaignMember> tempScholarList = new List<CampaignMember>();
        List<CampaignMember> scholarList = new List<CampaignMember>();

        tempScholarList = campaignMemberMap.get('Scholarship');

        if (tempScholarList.size() > 0) {
            scholarList.addAll(tempScholarList);
        }

        return scholarList;
    }

    // Cohort tab.
    public List<CampaignMember> getCohortList() {
        List<CampaignMember> tempCohortList = new List<CampaignMember>();
        List<CampaignMember> cohortList = new List<CampaignMember>();

        tempCohortList = campaignMemberMap.get('Cohort');

        if (tempCohortList.size() > 0) {
            cohortList.addAll(tempCohortList);
        }

        return cohortList;
    }

    // Other Sources tab.
    public List<CampaignMember> getoSourceList() {
        List<CampaignMember> tempOtherList = new List<CampaignMember>();
        List<CampaignMember> oSourceList = new List<CampaignMember>();

        tempOtherList = campaignMemberMap.get('Other Source');

        if (tempOtherList.size() > 0) {
            oSourceList.addAll(tempOtherList);
        }

        return oSourceList;
    }

    // Marketing/Communications tab.
    public List<CampaignMember> getMarkCommList() {
        List<CampaignMember> tempCommList = new List<CampaignMember>();
        List<CampaignMember> markCommList = new List<CampaignMember>();

        tempCommList = campaignMemberMap.get('Communication');

        if (tempCommList.size() > 0) {
            markCommList.addAll(tempCommList);
        }

        return markCommList;
    }

    // Partnered Courses tab.
    public List<CampaignMember> getPartCourseList() {
        List<CampaignMember> tempCourseList = new List<CampaignMember>();
        List<CampaignMember> partCourseList = new List<CampaignMember>();

        tempCourseList = campaignMemberMap.get('Course');

        if (tempCourseList.size() > 0) {
            partCourseList.addAll(tempCourseList);
        }

        return partCourseList;
    }

    // Add to event button
    public void addToEvent() {
        if (camMemEvent.Status == null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'You must select a Campaign status.'));

            return;
        }

        try {
            camMemEvent.Id = null;
            camMemEvent.LeadId = null;
            camMemEvent.CampaignId = elId;
            camMemEvent.ContactId = contactId;

            insert camMemEvent;

            buildCampaignMemberMap();
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));

            return;
        }

        eventDeets = false;
        eSearchString = null;
    }

    // Add Interest button
    public void addInterest() {
        try {
            camMemInterest = new CampaignMember();
            camMemInterest.Id = null;
            camMemInterest.LeadId = null;
            camMemInterest.CampaignId = intId;
            camMemInterest.ContactId = contactId;
            camMemInterest.Status = 'Interested';

            insert camMemInterest;

            buildCampaignMemberMap();
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));

            return;
        }

        iSearchString = null;
    }

    // CR methods
    public List<CampaignMember> getActiveCRCamMems() {
        activeCrCamMems = campaignMemberMap.get('Active CR');

        return activeCrCamMems;
    }

    public Boolean activeCRCamMapEmpty {
        get {
            if (activeCRCamMap.get(null).size() == 0) {
                return true;
            } else {
                return false;
            }
        }
        set;
    }

    public String activeCRCamPMapKeys {
        get {
            activeCRCamPMapKeys = '';

            for (String s : activeCRCamMap.keySet()) {
                // Use String.Value of since null is an expected key
                activeCRCamPMapKeys += String.ValueOf(s);
            }

            return activeCRCamPMapKeys;
        }
        set;
    }

    public Map<String, List<CampaignMember>> activeCRCamMap {
        get {
            if (activeCRCamMap == null) {
                activeCRCamMap = new Map<String, List<CampaignMember>>();
            }

            return activeCRCamMap;
        }
        set;
    }

    public void parentCampaignSearch() {
        parentCampaigns = null;
        childCampaigns = null;
        selectedParentCampaignName = null;

        if (searchString.length() < 2) {
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR, 'You must enter at least 2 characters.')
            );

            return;
        }

        String sosl =
            '' +
            'FIND \'*' +
            String.escapeSingleQuotes(searchString.trim()) +
            '*\' ' +
            'IN NAME FIELDS ' +
            'RETURNING Campaign(Id, Name ' +
            'WHERE RecordType.Name = \'Corporate Relations\' ' +
            'AND IsActive = true ' +
            'AND ParentId = null ' +
            'AND Type = \'Corporate Relations\' ' +
            'ORDER BY Name ASC ' +
            ')';

        List<List<SObject>> sObjects = Search.query(sosl);

        if (sObjects.size() > 0) {
            parentCampaigns = sObjects[0];
        } else {
            parentCampaigns = new List<Campaign>();
        }
    }

    public void childCampaignSearch() {
        currentChildCams = [
            SELECT CampaignId
            FROM CampaignMember
            WHERE ContactId = :contactId AND Campaign.ParentId = :selectedParentCampaign AND Status = 'Active'
        ];

        Set<String> childSearchSet = new Set<String>();
        fixedChildCampaigns = new List<Campaign>();

        for (CampaignMember c : currentChildCams) {
            childSearchSet.add(c.CampaignId);
        }

        String queryString =
            '' +
            'SELECT Id, Name ' +
            'FROM Campaign ' +
            'WHERE RecordType.Name = \'Corporate Relations\' ' +
            'AND ParentId = \'' +
            selectedParentCampaign +
            '\' ' +
            'AND isActive = true';

        childCampaigns = Database.query(queryString);

        for (Campaign cc : childCampaigns) {
            if (!childSearchSet.contains(cc.Id)) {
                fixedChildCampaigns.add(cc);
            }
        }
    }

    public void assignToParentCampaign() {
        newParentCamMem = new CampaignMember();
        newParentCamMem.ContactId = contactId;
        newParentCamMem.CampaignId = selectedParentCampaign;
        newParentCamMem.Status = 'Active';
        searchString = null;
        childCampaignSearch();
    }

    public void assignToChildCampaign() {
        newChildCamMem = new CampaignMember();
        newChildCamMem.ContactId = contactId;
        newChildCamMem.CampaignId = selectedChildCampaign;
        newChildCamMem.Status = 'Active';
        save();
    }

    public void inActivateCM() {
        inActivateCamMem = [
            SELECT Id, Campaign.ParentId, CampaignId, CreatedBy.UserRole.Name
            FROM CampaignMember
            WHERE Id = :inActivateCMId
        ];

        User currentUser = [SELECT Id, UserRole.Name FROM User WHERE Id = :UserInfo.getUserId()];

        if (inActivateCamMem.CreatedBy.UserRole.Name == currentUser.UserRole.Name) {
            inActivateCamMem.Status = 'Inactive';

            if (inActivateCamMem.Campaign.ParentId == null) {
                List<CampaignMember> ChildKillList = new List<CampaignMember>();

                for (CampaignMember ck : [
                    SELECT Id, Status
                    FROM Campaignmember
                    WHERE Campaign.ParentId = :inActivateCamMem.CampaignId
                ]) {
                    ck.status = 'Inactive';
                    ChildKillList.add(ck);
                }

                update ChildKillList;
            }

            update inActivateCamMem;
        } else {
            ApexPages.addmessage(
                new ApexPages.message(
                    ApexPages.severity.ERROR,
                    'You do not have access to remove this Affiliation, only a ' +
                    'member of the Department that created it can.'
                )
            );
        }

        buildCampaignMemberMap();
        renderedTab = 'crTab';
        system.debug(activeCRCamPMapKeys);
        system.debug(String.ValueOf(activeCRCamMap));
    }

    public void save() {
        try {
            inactiveCrCamMems = campaignMemberMap.get('Inactive CR');
            Set<String> activeCamMemNameSet = new Set<String>();
            Set<String> inactiveCamMemNameSet = new Set<String>();

            for (String s : activeCRCamMap.keySet()) {
                for (CampaignMember acm : activeCRCamMap.get(s)) {
                    activeCamMemNameSet.add(acm.campaign.name);
                }
            }

            for (CampaignMember ia : inactiveCrCamMems) {
                inactiveCamMemNameSet.add(ia.Campaign.Name);
            }

            if (!inactiveCamMemNameSet.contains(selectedParentCampaignName)) {
                if (!activeCamMemNameSet.contains(selectedParentCampaignName)) {
                    insert newParentCamMem;
                }
            } else {
                activateParentCamMem = [
                    SELECT Id
                    FROM CampaignMember
                    WHERE
                        Campaign.Name = :selectedParentCampaignName
                        AND ContactId = :ApexPages.currentPage().getParameters().get('id')
                ];

                activateParentCamMem.Status = 'Active';

                update activateParentCamMem;
            }

            if (selectedChildCampaign != null) {
                if (!inactiveCamMemNameSet.contains(selectedChildCampaignName)) {
                    if (!activeCamMemNameSet.contains(selectedChildCampaignName)) {
                        insert newChildCamMem;
                    }
                } else {
                    activateChildCamMem = [
                        SELECT Id
                        FROM CampaignMember
                        WHERE
                            Campaign.Name = :selectedChildCampaignName
                            AND ContactId = :ApexPages.currentPage().getParameters().get('id')
                    ];

                    activateChildCamMem.Status = 'Active';

                    update activateChildCamMem;
                }
            }

            searchString = null;
            selectedParentCampaignName = null;
            selectedChildCampaignName = null;
            childCampaigns = null;
            buildCampaignMemberMap();
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }
    }

    /*
     * @description: Wrapper class for historical communication
     */
    public class Message {
        public String id { get; set; }
        public String name { get; set; }
        public String subject { get; set; }
        public String sender { get; set; }

        // Hard Bounce, Soft Bounce, Delivered
        public String deliveryStatus { get; set; }

        public Datetime timeSent { get; set; }
        public Datetime timeOpened { get; set; }
        public String uniqueClicks { get; set; }
        public String subscriptionStatus { get; set; }

        public Message() {
            this.id = id;
            this.name = name;
            this.subject = subject;
            this.sender = sender;

            // Formula using hardbounce/softbounce to determine status
            this.deliverystatus = '';
            this.timeSent = timeSent;
            this.timeOpened = timeOpened;
            this.uniqueClicks = uniqueClicks;
            this.subscriptionStatus = subscriptionStatus;
        }
    }
}
