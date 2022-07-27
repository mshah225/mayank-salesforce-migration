public class AdvisorPortalTopLevelFilterController {
    @AuraEnabled(cacheable=true)
    public static Map<String, String> viewAsOptions() {
        Map<String, String> viewAsOptions = new Map<String, String>();

        // Insert myself
        viewAsOptions.put(UserInfo.getName(), UserInfo.getUserId());

        // Insert My Committees
        if (myCommittees.size() > 0) {
            viewAsOptions.put('--My Committees--', '001xa000003DIlo');

            List<SelectOption> sortableCommittee = sortedSelectOptionList(myCommittees);

            for (Integer i = 0; i < sortableCommittee.size(); i++) {
                viewAsOptions.put(sortableCommittee[i].getLabel(), sortableCommittee[i].getValue());
            }
        }

        // Insert The committees for which I am a manager
        if (mySubordinateCommittees.size() > 0) {
            if (myRole == 'Department Manager') {
                viewAsOptions.put('--Department Committees--', '002xa000003DIlo');
            } else if (myRole == 'College Manager') {
                viewAsOptions.put('--College Committees--', '003xa000003DIlo');
            }

            List<SelectOption> sortableSubordinateCommittee = sortedSelectOptionList(mySubordinateCommittees);

            for (Integer i = 0; i < sortableSubordinateCommittee.size(); i++) {
                viewAsOptions.put(
                    sortableSubordinateCommittee[i].getLabel(),
                    sortableSubordinateCommittee[i].getValue()
                );
            }
        }

        // Insert all of the users for all of the committees for which I am a manager
        if (mySubordinates.size() > 0) {
            if (myRole == 'Department Manager') {
                viewAsOptions.put('--Department Advisors--', '004xa000003DIlo');
            } else if (myRole == 'College Manager') {
                viewAsOptions.put('--College Advisors--', '005xa000003DIlo');
            }

            List<SelectOption> sortableAdvisor = sortedSelectOptionList(mySubordinates);

            for (Integer i = 0; i < sortableAdvisor.size(); i++) {
                viewAsOptions.put(sortableAdvisor[i].getLabel(), sortableAdvisor[i].getValue());
            }
        }

        return viewAsOptions;
    }

    public static Map<Id, String> myCommittees {
        get {
            if (myCommittees == null) {
                myCommittees = new Map<Id, String>();

                for (Success_Resource__c sr : myResources) {
                    if (sr.Role__c == 'User') {
                        myCommittees.putAll(viewAsOptionsHelper(sr.Success_Resource_Pod_Associations__r));
                    }
                }
            }

            return myCommittees;
        }
        set;
    }

    public static Map<Id, String> mySubordinateCommittees {
        get {
            if (mySubordinateCommittees == null) {
                mySubordinateCommittees = new Map<Id, String>();

                mySubordinateCommittees = viewAsOptionsHelper(mySubordinatePods.values());
            }

            return mySubordinateCommittees;
        }
        set;
    }

    public static Map<Id, Success_Resource_Pod_Association__c> mySubordinatePods {
        get {
            if (mySubordinatePods == null) {
                mySubordinatePods = new Map<Id, Success_Resource_Pod_Association__c>();

                for (Success_Resource__c sr : myResources) {
                    if (sr.Role__c == 'College Manager' || sr.Role__c == 'Department Manager') {
                        for (Success_Resource_Pod_Association__c srpa : sr.Success_Resource_Pod_Associations__r) {
                            mySubordinatePods.put(srpa.Id, srpa);
                        }
                    }
                }
            }

            return mySubordinatePods;
        }
        set;
    }

    public static Map<Id, String> mySubordinates {
        get {
            String subordinateDisplayName;

            if (mySubordinates == null) {
                mySubordinates = new Map<Id, String>();
                List<Success_Resource_Pod_Association__c> subordinatesAssociationList = getSubordinatesPodIds();

                for (Success_Resource_Pod_Association__c srpa : subordinatesAssociationList) {
                    subordinateDisplayName = srpa.Success_Resource__r.Resource__r.Name;

                    if (
                        srpa.Success_Resource__r.Resource__r.Alias != null &&
                        srpa.Success_Resource__r.Resource__r.Alias != ''
                    ) {
                        subordinateDisplayName =
                            subordinateDisplayName +
                            ' - ' +
                            srpa.Success_Resource__r.Resource__r.Alias;
                    }

                    mySubordinates.put(srpa.Success_Resource__r.Resource__c, subordinateDisplayName);
                }
            }

            return mySubordinates;
        }
        set;
    }

    public static List<Success_Resource__c> myResources {
        get {
            if (myResources == null) {
                myResources = [
                    SELECT
                        Role__c,
                        (
                            SELECT
                                Success_Pod__c,
                                Success_Pod__r.OwnerId,
                                Success_Pod__r.Name,
                                Success_Pod__r.Committee__c
                            FROM Success_Resource_Pod_Associations__r
                            ORDER BY Success_Pod__r.Name
                        )
                    FROM Success_Resource__c
                    WHERE
                        Resource__c = :UserInfo.getUserId()
                        AND IsActive__c = TRUE
                        AND RecordTypeId IN :new List<String>{ AdvisorResourceRTID, GradAdvisorResourceRTID }
                ];
            }

            return myResources;
        }
        set;
    }

    public static String myRole {
        get {
            if (myRole == null) {
                myRole = 'User';
                for (Success_Resource__c sr : myResources) {
                    if (sr.Role__c == 'College Manager') {
                        myRole = 'College Manager';
                        return myRole;
                    }
                    if (sr.Role__c == 'Department Manager') {
                        myRole = 'Department Manager';
                    }
                }
            }

            return myRole;
        }
        set;
    }

    private static Id AdvisorResourceRTID {
        get {
            if (AdvisorResourceRTID == null) {
                AdvisorResourceRTID = RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Advisor');
            }

            return AdvisorResourceRTID;
        }
        set;
    }

    private static Id GradAdvisorResourceRTID {
        get {
            if (GradAdvisorResourceRTID == null) {
                GradAdvisorResourceRTID = RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Grad');
            }

            return GradAdvisorResourceRTID;
        }
        set;
    }

    public static List<SelectOption> sortSelectOptionList(List<SelectOption> source) {
        List<String> sortableSelectOptionList = new List<String>();

        for (SelectOption so : source) {
            // replace blank with '_!' so we know the final split will have two components
            String stringSplitter = (String.isBlank(so.getLabel()) ? '_!' : so.getLabel()) + '@!@';
            stringSplitter = stringSplitter + (String.isBlank(so.getValue()) ? '_!' : so.getValue());
            stringSplitter = stringSplitter.toUpperCase() + stringSplitter;
            sortableSelectOptionList.add(stringSplitter);
        }
        // sort the list
        sortableSelectOptionList.sort();

        //Remove Capital Prefix
        for (Integer i = 0; i < sortableSelectOptionList.size(); i++) {
            sortableSelectOptionList[i] = sortableSelectOptionList[i]
                .substring(sortableSelectOptionList[i].length() / 2);
        }

        List<SelectOption> selectOptionList = new List<SelectOption>();

        // split the value/name components and re create the list
        for (String s : sortableSelectOptionList) {
            selectOptionList.add(
                new SelectOption(s.split('@!@')[1].replace('_!', ''), s.split('@!@')[0].replace('_!', ''))
            );
        }

        return selectOptionList;
    }

    public static Map<Id, String> viewAsOptionsHelper(
        List<Success_Resource_Pod_Association__c> successResourcePodAssociationList
    ) {
        String displayName;
        Map<Id, String> viewAsOptionsHelperMap = new Map<Id, String>();

        for (Success_Resource_Pod_Association__c srpa : successResourcePodAssociationList) {
            displayName = srpa.Success_Pod__r.Name;

            if (srpa.Success_Pod__r.Committee__c != null && srpa.Success_Pod__r.Committee__c != '') {
                displayName = displayName + ' - ' + srpa.Success_Pod__r.Committee__c;
            }

            viewAsOptionsHelperMap.put(srpa.Success_Pod__r.OwnerId, displayName);
        }

        return viewAsOptionsHelperMap;
    }

    public static List<Success_Resource_Pod_Association__c> getSubordinatesPodIds() {
        Set<Id> podIds = new Set<Id>();

        for (Success_Resource_Pod_Association__c srpa : mySubordinatePods.values()) {
            podIds.add(srpa.Success_Pod__c);
        }

        List<Success_Resource_Pod_Association__c> subordinatesPodAssociationList = [
            SELECT
                Success_Resource__r.Resource__c,
                Success_Resource__r.Resource__r.Name,
                Success_Resource__r.Resource__r.Alias,
                Success_Resource__r.IsActive__c
            FROM Success_Resource_Pod_Association__c
            WHERE Success_Resource__r.IsActive__c = TRUE AND Success_Pod__c IN :podIds
            ORDER BY Success_Resource__r.Resource__r.Name ASC
        ];

        return subordinatesPodAssociationList;
    }

    public static List<SelectOption> sortedSelectOptionList(Map<Id, String> selectOptionMap) {
        List<SelectOption> sortedCommittee = new List<SelectOption>();

        for (Id i : selectOptionMap.keySet()) {
            sortedCommittee.add(new SelectOption(i, selectOptionMap.get(i)));
        }

        sortedCommittee = sortSelectOptionList(sortedCommittee);

        return sortedCommittee;
    }
}
