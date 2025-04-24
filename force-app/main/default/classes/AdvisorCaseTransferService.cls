public without sharing class AdvisorCaseTransferService {
    private static final String GRAD_CASE_RECORD_TYPE_NAME = 'ASU_Graduate_Advisor_Portal';

    @AuraEnabled(cacheable=true)
    public static String getTransferOptions(List<String> caseIds, Boolean massTransfer, Boolean grad) {
        if (massTransfer) {
            // Get the user's transfer options
            return JSON.serialize(getTransferToOptionsByUser(UserInfo.getUserId(), grad));
        } else {
            Case c = [SELECT Id, ContactId, RecordType.DeveloperName FROM Case WHERE Id = :caseIds[0]][0];

            grad = (c.RecordType.DeveloperName == GRAD_CASE_RECORD_TYPE_NAME); // grad is set by record id if only one case
            if (String.isEmpty(c.ContactId)) {
                // Get the user's transfer options
                return JSON.serialize(getTransferToOptionsByUser(UserInfo.getUserId(), grad));
            } else {
                // Get the user's transfer options, plus the student's committees
                return JSON.serialize(getTransferToOptionsByUserAndStudent(UserInfo.getUserId(), c.ContactId, grad));
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
    public static List<LabelValue> getTransferToOptionsByUserAndStudent(String userId, String contactId, Boolean grad) {
        UserTransferOptionBuilder builder = new UserTransferOptionBuilder(userId, grad);

        List<LabelValue> options = new List<LabelValue>();

        // =+=+=+=+=+=+= Add the current user =+=+=+=+=+=+=
        options.add(builder.getUser());

        // =+=+=+=+=+=+= PODs for this student/contact =+=+=+=+=+=+=
        List<Success_Student__c> students = [
            SELECT Success_Pod__r.OwnerId, Success_Pod__r.Committee__c, Success_Pod__r.Name
            FROM Success_Student__c
            WHERE Student__c = :contactId AND Is_Active__c = TRUE AND Coaching_Student__c = FALSE
        ];
        // Add the student's success pods
        options.add(new LabelValue('--Student Advising Committees--', '004xa000003DIlo'));
        if (!students.isEmpty()) {
            for (Success_Student__c student : students)
                options.add(new LabelValue(generateLabel(student.Success_Pod__r), student.Success_Pod__r.OwnerId));
        } else {
            String defaultGroupName = grad ? 'Grad Advisor Fallback Queue' : 'UG Advisor Fallback Queue';

            List<Group> defaultGroups = [SELECT Id, Name FROM Group WHERE Name = :defaultGroupName AND Type = 'Queue'];
            for (Group defaultGroup : defaultGroups) {
                options.add(new LabelValue(defaultGroup.Name, defaultGroup.Id));
            }
        }

        // =+=+=+=+=+=+= Add the committees this user has a user role in =+=+=+=+=+=+=
        List<LabelValue> podsAsUser = builder.getDirectPods();
        if (!podsAsUser.isEmpty()) {
            options.add(builder.getDirectPodLabel());
            options.addAll(podsAsUser);
        }

        // =+=+=+=+=+=+= Add the committees this user has a manager role in =+=+=+=+=+=+=
        List<LabelValue> podsAsManager = builder.getManagedPods();
        if (!podsAsManager.isEmpty()) {
            options.add(builder.getManagedPodLabel());
            options.addAll(podsAsManager);
        }

        // =+=+=+=+=+=+= Add the user's subordinates (i.e. which users are in pods this user manages) =+=+=+=+=+=+=
        List<LabelValue> subordinates = builder.getSubordinates();
        if (!subordinates.isEmpty()) {
            options.add(builder.getSubordinatesLabel());
            options.addAll(subordinates);
        }

        return options;
    }

    /**
     * Get all transfer options for this user
     * Which is:
     * 1. The user themself
     * 3. The user's PODs
     * 4. The user's managed PODs
     * 5. The user's subordinates
     */
    public static List<LabelValue> getTransferToOptionsByUser(String userId, Boolean grad) {
        UserTransferOptionBuilder builder = new UserTransferOptionBuilder(userId, grad);

        List<LabelValue> options = new List<LabelValue>();

        // =+=+=+=+=+=+= Add the current user =+=+=+=+=+=+=
        options.add(builder.getUser());

        // =+=+=+=+=+=+= Add the committees this user has a user role in =+=+=+=+=+=+=
        List<LabelValue> podsAsUser = builder.getDirectPods();
        if (!podsAsUser.isEmpty()) {
            options.add(builder.getDirectPodLabel());
            options.addAll(podsAsUser);
        }

        // =+=+=+=+=+=+= Add the committees this user has a manager role in =+=+=+=+=+=+=
        List<LabelValue> podsAsManager = builder.getManagedPods();
        if (!podsAsManager.isEmpty()) {
            options.add(builder.getManagedPodLabel());
            options.addAll(podsAsManager);
        }

        // =+=+=+=+=+=+= Add the user's subordinates (i.e. which users are in pods this user manages) =+=+=+=+=+=+=
        List<LabelValue> subordinates = builder.getSubordinates();
        if (!subordinates.isEmpty()) {
            options.add(builder.getSubordinatesLabel());
            options.addAll(subordinates);
        }

        return options;
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

    public class UserTransferOptionBuilder {
        private Id userId;
        private Boolean gradMode = null;

        private User u;
        private List<Success_Resource__c> allResources = new List<Success_Resource__c>();
        private List<Success_Resource_Pod_Association__c> subordinateSrpas = new List<Success_Resource_Pod_Association__c>();

        public UserTransferOptionBuilder(Id userId, Boolean gradMode) {
            this.userId = userId;
            this.gradMode = gradMode;

            // Query to get name and alias of user
            u = [SELECT Id, Name, Alias FROM User WHERE Id = :userId LIMIT 1][0];

            // Get all resources for this user, and the pods they are associated with
            allResources = [
                SELECT
                    Role__c,
                    (
                        SELECT
                            Success_Pod__c,
                            Success_Pod__r.OwnerId,
                            Success_Pod__r.Name,
                            Success_Pod__r.Committee__c,
                            Success_Pod__r.RecordTypeId
                        FROM Success_Resource_Pod_Associations__r
                        ORDER BY Success_Pod__r.Name
                    ),
                    RecordTypeId
                FROM Success_Resource__c
                WHERE Resource__c = :userId AND IsActive__c = TRUE
            ];
            // Filter to just grad or ugrad if needed
            if (gradMode != null) {
                String successPodRecordId, successResourceRecordId;
                if (gradMode == true) {
                    successPodRecordId = RecordIdHelper.getRecordTypeId('Success_Pod__c', 'Grad');
                    successResourceRecordId = RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Grad');
                } else {
                    successPodRecordId = RecordIdHelper.getRecordTypeId('Success_Pod__c', 'Advisor');
                    successResourceRecordId = RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Advisor');
                }

                List<Success_Resource__c> removeRes = new List<Success_Resource__c>();
                for (Success_Resource__c res : allResources) {
                    if (res.RecordTypeId != successResourceRecordId)
                        removeRes.add(res);

                    List<Success_Resource_Pod_Association__c> removeSrpas = new List<Success_Resource_Pod_Association__c>();
                    for (Success_Resource_Pod_Association__c srpa : res.Success_Resource_Pod_Associations__r)
                        if (srpa.Success_Pod__r.RecordTypeId != successPodRecordId)
                            removeSrpas.add(srpa);

                    for (Success_Resource_Pod_Association__c srpa : removeSrpas)
                        res.Success_Resource_Pod_Associations__r.remove(
                            res.Success_Resource_Pod_Associations__r.indexOf(srpa)
                        );
                }

                for (Success_Resource__c sr : removeRes)
                    allResources.remove(allResources.indexOf(sr));
            }

            // Get list of which pods this user is a manager for
            List<Id> podsUserIsAManagerForLs = new List<Id>();
            for (Success_Resource__c res : this.allResources)
                if (res.Role__c == 'College Manager' || res.Role__c == 'Department Manager')
                    for (Success_Resource_Pod_Association__c srpa : res.Success_Resource_Pod_Associations__r)
                        podsUserIsAManagerForLs.add(srpa.Success_Pod__c);

            // Get list of all OTHER users in the pods this user is a manager for
            subordinateSrpas = [
                SELECT
                    Id,
                    Success_Resource__r.Resource__c,
                    Success_Resource__r.Resource__r.Name,
                    Success_Resource__r.Resource__r.Alias,
                    Success_Resource__r.RecordTypeId,
                    Success_Pod__r.RecordTypeId
                FROM Success_Resource_Pod_Association__c
                WHERE
                    Success_Resource__r.IsActive__c = TRUE
                    AND Success_Pod__c IN :podsUserIsAManagerForLs
                    AND Success_Resource__r.Resource__c != :userId
                ORDER BY Success_Resource__r.Resource__r.Name ASC
            ];

            // Filter to just grad or ugrad if needed
            if (gradMode != null) {
                String successPodRecordId, successResourceRecordId;
                if (gradMode == true) {
                    successPodRecordId = RecordIdHelper.getRecordTypeId('Success_Pod__c', 'Grad');
                    successResourceRecordId = RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Grad');
                } else {
                    successPodRecordId = RecordIdHelper.getRecordTypeId('Success_Pod__c', 'Advisor');
                    successResourceRecordId = RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Advisor');
                }

                List<Success_Resource_Pod_Association__c> removeSubordinates = new List<Success_Resource_Pod_Association__c>();
                for (Success_Resource_Pod_Association__c srpa : subordinateSrpas) {
                    if (
                        srpa.Success_Pod__r.RecordTypeId != successPodRecordId ||
                        srpa.Success_Resource__r.RecordTypeId != successResourceRecordId
                    )
                        removeSubordinates.add(srpa);
                }
                for (Success_Resource_Pod_Association__c srpa : removeSubordinates)
                    subordinateSrpas.remove(subordinateSrpas.indexOf(srpa));
            }
        }

        /**
         * Get the LabelValue option for THIS user
         */
        public LabelValue getUser() {
            return new LabelValue(generateLabel(u), userId);
        }

        /**
         * Get the LabelValue option for this user's committees.
         * @return LabelValue for "My Committees"
         */
        public LabelValue getDirectPodLabel() {
            return new LabelValue('--My Committees--', '001xa000003DIlo');
        }
        /**
         * Get all the user's committees where the user is a User and not a manager.
         * @return LabelValue list, one per committee. Alphabetical ordering.
         */
        public List<LabelValue> getDirectPods() {
            List<LabelValue> options = new List<LabelValue>();
            List<Success_Resource__c> resourcesAsAUser = new List<Success_Resource__c>();

            // Find all resources for this user AS a user (not a manager)
            for (Success_Resource__c res : allResources)
                if (res.Role__c == 'User')
                    resourcesAsAUser.add(res);

            // Create LabelValue for each success pod
            Map<String, LabelValue> labelToLVMp = new Map<String, LabelValue>();
            for (Success_Resource__c res : resourcesAsAUser) {
                for (Success_Resource_Pod_Association__c srpa : res.Success_Resource_Pod_Associations__r) {
                    String label = generateLabel(srpa.Success_Pod__r);
                    LabelValue lv = new LabelValue(label, srpa.Success_Pod__r.OwnerId);
                    labelToLVMp.put(lv.label, lv);
                }
            }

            // Add in alphabetical order
            List<String> lvLabelsInSortedOrder = new List<String>(labelToLVMp.keySet());
            lvLabelsInSortedOrder.sort();
            for (String label : lvLabelsInSortedOrder)
                options.add(labelToLVMp.get(label));

            return options;
        }

        /**
         * Get the LabelValue option for the committees this user manages.
         * This depends on if we are in gradMode or not. If we are in ugrad
         * then it also depends on if the user is a College Manager or
         * Department Manager
         * @return LabelValue for managed PODs
         */
        public LabelValue getManagedPodLabel() {
            if (gradMode == true) {
                return new LabelValue('--School Name or Advising Team--', '002xa000003DIlo');
            } else if (gradMode == false)
                for (Success_Resource__c res : allResources) {
                    if (res.Role__c == 'College Manager')
                        return new LabelValue('--College Committees--', '002xa000003DIlo');
                    else if (res.Role__c == 'Department Manager')
                        return new LabelValue('--Department Committees--', '002xa000003DIlo');
                }
            return new LabelValue('--Managed Committees--', '002xa000003DIlo');
        }
        /**
         * Get all the committees that the user is a manager for.
         * @return LabelValue list, one per committee. Alphabetical ordering.
         */
        public List<LabelValue> getManagedPods() {
            List<LabelValue> options = new List<LabelValue>();
            List<Success_Resource__c> resourcesAsManager = new List<Success_Resource__c>();

            // Find all resources for this user AS a user (not a manager)
            for (Success_Resource__c res : allResources)
                if (res.Role__c == 'College Manager' || res.Role__c == 'Department Manager')
                    resourcesAsManager.add(res);

            // Create LabelValue for each success pod
            Map<String, LabelValue> labelToLVMp = new Map<String, LabelValue>();
            for (Success_Resource__c res : resourcesAsManager) {
                for (Success_Resource_Pod_Association__c srpa : res.Success_Resource_Pod_Associations__r) {
                    String label = generateLabel(srpa.Success_Pod__r);
                    LabelValue lv = new LabelValue(label, srpa.Success_Pod__r.OwnerId);
                    labelToLVMp.put(lv.label, lv);
                }
            }

            // Add in alphabetical order
            List<String> lvLabelsInSortedOrder = new List<String>(labelToLVMp.keySet());
            lvLabelsInSortedOrder.sort();
            for (String label : lvLabelsInSortedOrder)
                options.add(labelToLVMp.get(label));

            return options;
        }

        /**
         * Get the LabelValue option for the committees this user manages.
         * This depends on if we are in gradMode or not. If we are in ugrad
         * then it also depends on if the user is a College Manager or
         * Department Manager
         * @return LabelValue for members of managed pods
         */
        public LabelValue getSubordinatesLabel() {
            if (gradMode == true) {
                return new LabelValue('--Program Advisors--', '003xa000003DIlo');
            } else if (gradMode == false)
                for (Success_Resource__c res : allResources) {
                    if (res.Role__c == 'College Manager')
                        return new LabelValue('--College Advisors--', '003xa000003DIlo');
                    else if (res.Role__c == 'Department Manager')
                        return new LabelValue('--Department Advisors--', '003xa000003DIlo');
                }
            return new LabelValue('--Other Advisors--', '003xa000003DIlo');
        }
        /**
         * Get all the other users in the committees this user manages.
         * @return LabelValue list, one per committee. Alphabetical ordering.
         */
        public List<LabelValue> getSubordinates() {
            List<LabelValue> options = new List<LabelValue>();
            Map<String, LabelValue> labelToLVMp = new Map<String, LabelValue>();

            for (Success_Resource_Pod_Association__c srpa : subordinateSrpas) {
                String label = generateLabel(srpa.Success_Resource__r.Resource__r);
                LabelValue lv = new LabelValue(label, srpa.Success_Resource__r.Resource__c);

                labelToLVMp.put(lv.label, lv);
            }

            // Add in alphabetical order
            List<String> lvLabelsInSortedOrder = new List<String>(labelToLVMp.keySet());
            lvLabelsInSortedOrder.sort();
            for (String label : lvLabelsInSortedOrder)
                options.add(labelToLVMp.get(label));

            return options;
        }
    }

    /**
     * Create a label that refers to a user
     * @return A string that is either the "[name]" or "[name] - [alias]" for the user
     */
    private static String generateLabel(User u) {
        String displayName = u.Name;
        if (u.Alias != null && u.Alias != '')
            displayName += ' - ' + u.Alias;
        return displayName;
    }
    /**
     * Create a label that refers to a success pod
     * @return A string that is either the "[name]" or "[name] - [committee]" for the success pod
     */
    private static String generateLabel(Success_Pod__c sucPod) {
        String displayName = sucPod.Name;
        if (sucPod.Committee__c != null && sucPod.Committee__c != '')
            displayName += ' - ' + sucPod.Committee__c;
        return displayName;
    }
}