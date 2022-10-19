public without sharing class AdvisorCaseTransferService {
    private static final String GRAD_CASE_RECORD_TYPE_NAME = 'ASU_Graduate_Advisor_Portal';

    @AuraEnabled(cacheable=true)
    public static String getTransferOptions(List<String> caseIds, Boolean massTransfer, Boolean grad) {
        if (massTransfer) {
            // Get the user's transfer options
            return JSON.serialize(getTransferToOptionsByUser(UserInfo.getUserId(), grad).getOrderedList());
        } else {
            Case c = [SELECT Id, ContactId, RecordType.DeveloperName FROM Case WHERE Id = :caseIds[0]][0];

            grad = (c.RecordType.DeveloperName == GRAD_CASE_RECORD_TYPE_NAME); // grad is set by record id if only one case
            if (String.isEmpty(c.ContactId)) {
                // Get the user's transfer options
                return JSON.serialize(getTransferToOptionsByUser(UserInfo.getUserId(), grad).getOrderedList());
            } else {
                // Get the user's transfer options, plus the student's committees
                return JSON.serialize(
                    getTransferToOptionsByUserAndStudent(UserInfo.getUserId(), c.ContactId, grad).getOrderedList()
                );
            }
        }
    }

    /**
     * Get all transfer options for this user and student
     * Which is:
     * 1. The user themself
     * 2. The student's committees (or the fallback queue if the student has none)
     * 3. The user's PODs
     * 4. The user's managed PODs
     * 5. The user's subordinates
     */
    public static OrderedMapStringToString getTransferToOptionsByUserAndStudent(
        String userId,
        String contactId,
        Boolean grad
    ) {
        OrderedMapStringToString labelValueMap = new OrderedMapStringToString();
        // Get all the options for this user (i.e. their PODs, subordinate PODs, and suborindates)
        OrderedMapStringToString userTransferOptionsForUser = getTransferToOptionsByUser(userId, grad);
        List<OrderedMapStringToString.LabelValue> userOptions = userTransferOptionsForUser.getOrderedList();

        // First option is the user themself
        labelValueMap.put(userOptions[0].label, userOptions[0].value);

        // Put student options between the top user options and other user options
        List<Success_Student__c> students = [
            SELECT Success_Pod__r.OwnerId, Success_Pod__r.Committee__c, Success_Pod__r.Name
            FROM Success_Student__c
            WHERE Student__c = :contactId AND Is_Active__c = TRUE AND Coaching_Student__c = FALSE
        ];
        // Add the student's success pods
        labelValueMap.put('--Student Advising Committees--', '006xa000003DIlo');
        if (!students.isEmpty()) {
            for (Success_Student__c student : students)
                labelValueMap.put(generateLabel(student.Success_Pod__r), student.Success_Pod__r.OwnerId);
        } else {
            String defaultGroupName = grad ? 'Grad Advisor Fallback Queue' : 'UG Advisor Fallback Queue';

            List<Group> defaultGroups = [SELECT Id, Name FROM Group WHERE Name = :defaultGroupName AND Type = 'Queue'];
            for (Group defaultGroup : defaultGroups) {
                labelValueMap.put(defaultGroup.Name, defaultGroup.Id);
            }
        }

        // Add other user options
        for (Integer i = 1; i < userOptions.size(); i++) {
            labelValueMap.put(userOptions[i].label, userOptions[i].value);
        }

        return labelValueMap;
    }

    /**
     * Get all transfer options for this user
     * Which is:
     * 1. The user themself
     * 3. The user's PODs
     * 4. The user's managed PODs
     * 5. The user's subordinates
     */
    public static OrderedMapStringToString getTransferToOptionsByUser(String userId, Boolean grad) {
        OrderedMapStringToString labelValueMap = new OrderedMapStringToString();

        String successPodRecordId, successResourceRecordId; // limit to just grad or just ugrad options

        if (grad) {
            successPodRecordId = RecordIdHelper.getRecordTypeId('Success_Pod__c', 'Grad');
            successResourceRecordId = RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Grad');
        } else {
            successPodRecordId = RecordIdHelper.getRecordTypeId('Success_Pod__c', 'Advisor');
            successResourceRecordId = RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Advisor');
        }

        // =+=+=+=+=+=+= Add the current user =+=+=+=+=+=+=
        User thisUser = [SELECT Id, Name, Alias FROM User WHERE Id = :userId LIMIT 1][0];
        labelValueMap.put(generateLabel(thisUser), userId);

        // Get all success resources for this user
        List<Success_Resource__c> allResources = [
            SELECT
                Role__c,
                (
                    SELECT Success_Pod__c, Success_Pod__r.OwnerId, Success_Pod__r.Name, Success_Pod__r.Committee__c
                    FROM Success_Resource_Pod_Associations__r
                    WHERE Success_Pod__r.RecordTypeId = :successPodRecordId
                    ORDER BY Success_Pod__r.Name
                )
            FROM Success_Resource__c
            WHERE Resource__c = :userId AND IsActive__c = TRUE AND RecordTypeId = :successResourceRecordId
        ];

        // Separate out the resources into whether this user has a user or manager role
        List<Success_Resource__c> resourcesAsAUser = new List<Success_Resource__c>();
        List<Success_Resource__c> resourcesAsAManager = new List<Success_Resource__c>();
        String managerType;

        for (Success_Resource__c res : allResources) {
            if (res.Role__c == 'User') {
                resourcesAsAUser.add(res);
            } else if (res.Role__c == 'College Manager' || res.Role__c == 'Department Manager') {
                managerType = res.Role__c == 'College Manager' ? 'College' : 'Department';
                resourcesAsAManager.add(res);
            }
        }

        // =+=+=+=+=+=+= Figure out which committees this user has a user role in =+=+=+=+=+=+=
        Map<String, String> committeesAsAUser = new Map<String, String>();
        for (Success_Resource__c res : resourcesAsAUser) {
            for (Success_Resource_Pod_Association__c srpa : res.Success_Resource_Pod_Associations__r) {
                committeesAsAUser.put(generateLabel(srpa.Success_Pod__r), srpa.Success_Pod__r.OwnerId);
            }
        }
        List<String> committeesAsAUserInSortedOrder = new List<String>(committeesAsAUser.keySet());
        committeesAsAUserInSortedOrder.sort();
        // Add these committees to the map
        if (!committeesAsAUserInSortedOrder.isEmpty()) {
            labelValueMap.put('--My Committees--', '001xa000003DIlo');
            for (String eachCommittee : committeesAsAUserInSortedOrder)
                labelValueMap.put(eachCommittee, committeesAsAUser.get(eachCommittee));
        }

        // =+=+=+=+=+=+= Figure out which committees this user has a manager role in =+=+=+=+=+=+=
        Map<String, String> committeesAsAManager = new Map<String, String>(); // used for query cases/students
        List<String> successPodsAsAManagerIds = new List<String>(); // used to query subordinates
        for (Success_Resource__c res : resourcesAsAManager) {
            for (Success_Resource_Pod_Association__c srpa : res.Success_Resource_Pod_Associations__r) {
                committeesAsAManager.put(generateLabel(srpa.Success_Pod__r), srpa.Success_Pod__r.OwnerId);
                successPodsAsAManagerIds.add(srpa.Success_Pod__c);
            }
        }
        List<String> committeesAsAManagerInSortedOrder = new List<String>(committeesAsAManager.keySet());
        committeesAsAManagerInSortedOrder.sort();
        // Add these committees to the map
        if (!committeesAsAManagerInSortedOrder.isEmpty()) {
            // Add header
            if (managerType == 'Department')
                labelValueMap.put('--Department Committees--', '002xa000003DIlo');
            else if (managerType == 'College')
                labelValueMap.put('--College Committees--', '003xa000003DIlo');

            // Add options
            for (String eachCommittee : committeesAsAManagerInSortedOrder)
                labelValueMap.put(eachCommittee, committeesAsAManager.get(eachCommittee));
        }

        // =+=+=+=+=+=+= Figure out which users are this user's subordinates (i.e. which users are in pods this user manages) =+=+=+=+=+=+=
        Map<String, String> subordinateUsers = new Map<String, String>();
        List<Success_Resource_Pod_Association__c> subordinateSrpas = [
            SELECT
                Id,
                Success_Resource__r.Resource__c,
                Success_Resource__r.Resource__r.Name,
                Success_Resource__r.Resource__r.Alias
            FROM Success_Resource_Pod_Association__c
            WHERE
                Success_Resource__r.IsActive__c = TRUE
                AND Success_Pod__c IN :successPodsAsAManagerIds
                AND Success_Pod__r.RecordTypeId = :successPodRecordId
                AND Success_Resource__r.Resource__c != :userId
                AND Success_Resource__r.RecordTypeId = :successResourceRecordId
            ORDER BY Success_Resource__r.Resource__r.Name ASC
        ];
        for (Success_Resource_Pod_Association__c srpa : subordinateSrpas) {
            subordinateUsers.put(
                generateLabel(srpa.Success_Resource__r.Resource__r),
                srpa.Success_Resource__r.Resource__c
            );
        }
        List<String> subordinateUsersInSortedOrder = new List<String>(subordinateUsers.keySet());
        subordinateUsersInSortedOrder.sort();
        // Add these committees to the map
        if (!subordinateUsersInSortedOrder.isEmpty()) {
            // Add header
            if (managerType == 'Department')
                labelValueMap.put('--Department Advisors--', '004xa000003DIlo');
            else if (managerType == 'College')
                labelValueMap.put('--College Advisors--', '005xa000003DIlo');

            // Add options
            for (String eachUser : subordinateUsersInSortedOrder)
                labelValueMap.put(eachUser, subordinateUsers.get(eachUser));
        }
        return labelValueMap;
    }

    @AuraEnabled
    public static void transferSingleCase(String caseId, String ownerId) {
        transferMultipleCases(new List<String>{ caseId }, ownerId);
    }

    @AuraEnabled
    public static void transferMultipleCases(List<String> caseIds, String ownerId) {
        List<Case> updatedCases = new List<Case>();

        // Transfer each case
        for (String caseId : new Set<String>(caseIds))
            updatedCases.add(new Case(Id = caseId, OwnerId = ownerId));

        // And do the transfer
        update updatedCases;
    }

    /**
     * Create a label that refers to this user
     * @return A string that is either the "[name]" or "[name] - [alias]" for the user
     */
    private static String generateLabel(User u) {
        String displayName = u.Name;
        if (u.Alias != null && u.Alias != '')
            displayName += ' - ' + u.Alias;
        return displayName;
    }
    /**
     * Create a label that refers to this success pod
     * @return A string that is either the "[name]" or "[name] - [committee]" for the success pod
     */
    private static String generateLabel(Success_Pod__c sucPod) {
        String displayName = sucPod.Name;
        if (sucPod.Committee__c != null && sucPod.Committee__c != '')
            displayName += ' - ' + sucPod.Committee__c;
        return displayName;
    }
}