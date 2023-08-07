/**
 * @author Mathew Ruff, Sierra-Cedar
 * @date 2019-04-11
 *
 * Unit Tests for AdvisorPortalTopLevelFilter.cls
 */
@IsTest
private class AdvisorPortalTopLevelFilterTest {
    public static final String testUserAlias1 = 'testUsr1';
    public static final String testUserAlias2 = 'testUsr2';
    public static final String testUserAlias3 = 'testUsr3';
    public static final String testUserAlias4 = 'testUsr4';
    public static final String testUserAlias5 = 'testUsr5';
    public static final String testUserAlias6 = 'testUsr6';
    public static final String testUserAlias7 = 'testUsr7';
    public static final String testUserAlias8 = 'testUsr8';

    @TestSetup
    static void setup() {
        // Setup objects diagram:  https://asudev.jira.com/wiki/spaces/SFD/pages/2815590423/AdvisorPortalTopLevelFilterTest+Setup+Objects
        User runAsUser = new User(Id = UserInfo.getUserId());

        // Create all the users
        User testUser1 = createUser(testUserAlias1, '1');
        User testUser2 = createUser(testUserAlias2, '2');
        User testUser3 = createUser(testUserAlias3, '3');
        User testUser4 = createUser(testUserAlias4, '4');
        User testUser5 = createUser(testUserAlias5, '5');
        User testUser6 = createUser(testUserAlias6, '6');
        User testUser7 = createUser(testUserAlias7, '7');
        User testUser8 = createUser(testUserAlias8, '8');
        System.runAs(runAsUser) {
            insert new List<User>{
                testUser1,
                testUser2,
                testUser3,
                testUser4,
                testUser5,
                testUser6,
                testUser7,
                testUser8
            };
        }

        // And some groups to own the success pods
        Group group1 = createGroup('1');
        Group group2 = createGroup('2');
        Group group3 = createGroup('3');
        Group group4 = createGroup('4');
        System.runAs(runAsUser) {
            insert new List<Group>{ group1, group2, group3, group4 };
        }

        // Make the success resource for each user
        String sucResrcUgradRecordTypeId = RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Advisor');
        String sucResrcGradRecordTypeId = RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Grad');
        Success_Resource__c sucRes1 = createSuccessResource(testUser1, 'User', sucResrcUgradRecordTypeId);
        Success_Resource__c sucRes2 = createSuccessResource(testUser2, 'User', sucResrcUgradRecordTypeId);
        Success_Resource__c sucRes3 = createSuccessResource(testUser3, 'College Manager', sucResrcUgradRecordTypeId);
        Success_Resource__c sucRes4 = createSuccessResource(testUser4, 'Department Manager', sucResrcUgradRecordTypeId);
        Success_Resource__c sucRes5 = createSuccessResource(testUser5, 'User', sucResrcGradRecordTypeId);
        Success_Resource__c sucRes6 = createSuccessResource(testUser6, 'User', sucResrcGradRecordTypeId);
        Success_Resource__c sucRes7 = createSuccessResource(testUser7, 'College Manager', sucResrcGradRecordTypeId);
        Success_Resource__c sucRes8 = createSuccessResource(testUser8, 'Department Manager', sucResrcGradRecordTypeId);
        Success_Resource__c sucRes9 = createSuccessResource(testUser8, 'Department Manager', sucResrcUgradRecordTypeId);
        System.runAs(runAsUser) {
            insert new List<Success_Resource__c>{
                sucRes1,
                sucRes2,
                sucRes3,
                sucRes4,
                sucRes5,
                sucRes6,
                sucRes7,
                sucRes8,
                sucRes9
            };
        }

        // Queue objects
        QueueSobject queue1 = createQueueSObject(group1.Id);
        QueueSobject queue2 = createQueueSObject(group2.Id);
        QueueSobject queue3 = createQueueSObject(group3.Id);
        QueueSobject queue4 = createQueueSObject(group4.Id);
        System.runAs(runAsUser) {
            insert new List<QueueSobject>{ queue1, queue2, queue3, queue4 };
        }

        // Success pods
        String sucPodUgradRecordTypeId = RecordIdHelper.getRecordTypeId('Success_Pod__c', 'Advisor');
        String sucPodGradRecordTypeId = RecordIdHelper.getRecordTypeId('Success_Pod__c', 'Grad');
        Success_Pod__c sucPod1 = createSuccessPod(group1.Id, sucPodUgradRecordTypeId, '1');
        Success_Pod__c sucPod2 = createSuccessPod(group2.Id, sucPodUgradRecordTypeId, '2');
        Success_Pod__c sucPod3 = createSuccessPod(group3.Id, sucPodGradRecordTypeId, '3');
        Success_Pod__c sucPod4 = createSuccessPod(group4.Id, sucPodGradRecordTypeId, '4');
        System.runAs(runAsUser) {
            insert new List<Success_Pod__c>{ sucPod1, sucPod2, sucPod3, sucPod4 };
        }

        // Success Resource Pod Associations
        Success_Resource_Pod_Association__c sr1p1a = createSRPA(sucRes1, sucPod1);
        Success_Resource_Pod_Association__c sr2p2a = createSRPA(sucRes2, sucPod2);
        Success_Resource_Pod_Association__c sr3p2a = createSRPA(sucRes3, sucPod2);
        Success_Resource_Pod_Association__c sr4p2a = createSRPA(sucRes4, sucPod2);
        Success_Resource_Pod_Association__c sr9p2a = createSRPA(sucRes9, sucPod2);
        Success_Resource_Pod_Association__c sr5p3a = createSRPA(sucRes5, sucPod3);
        Success_Resource_Pod_Association__c sr6p4a = createSRPA(sucRes6, sucPod4);
        Success_Resource_Pod_Association__c sr7p3a = createSRPA(sucRes7, sucPod3);
        Success_Resource_Pod_Association__c sr7p4a = createSRPA(sucRes7, sucPod4);
        Success_Resource_Pod_Association__c sr8p4a = createSRPA(sucRes8, sucPod4);
        System.runAs(runAsUser) {
            insert new List<Success_Resource_Pod_Association__c>{
                sr1p1a,
                sr2p2a,
                sr3p2a,
                sr4p2a,
                sr9p2a,
                sr5p3a,
                sr6p4a,
                sr7p3a,
                sr7p4a,
                sr8p4a
            };
        }
    }

    @isTest
    private static void testUser1() {
        // Test user 1 should see themself and their single pod
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias1];
        List<Success_Resource_Pod_Association__c> srpas = [
            SELECT Success_Pod__r.OwnerId
            FROM Success_Resource_Pod_Association__c
            WHERE
                Success_Resource__r.Resource__c = :testUser.Id
                AND Success_Resource__r.RecordTypeId = :RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Advisor')
                AND Success_Pod__r.RecordTypeId = :RecordIdHelper.getRecordTypeId('Success_Pod__c', 'Advisor')
        ];

        // Get options
        String viewAsOptionListStr;
        List<OrderedMapStringToString.LabelValue> viewAsOptionList;
        System.runAs(testUser) {
            viewAsOptionListStr = AdvisorPortalTopLevelFilterController.viewAsOptions(false);
        }
        viewAsOptionList = (List<OrderedMapStringToString.LabelValue>) JSON.deserialize(
            viewAsOptionListStr,
            List<OrderedMapStringToString.LabelValue>.class
        );
        OrderedMapStringToString viewAsOptionMap = new OrderedMapStringToString(viewAsOptionList);

        List<String> groupIds = new List<String>();
        for (Success_Resource_Pod_Association__c srpa : srpas) {
            groupIds.add(srpa.Success_Pod__r.OwnerId);
        }
        assertContainsAllOptionsInProperOrder(viewAsOptionList, testUser.Id, groupIds, null, null);
    }

    @isTest
    private static void testUser2() {
        // Test user 2 should see themself and their single pod
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias2];
        List<Success_Resource_Pod_Association__c> srpas = [
            SELECT Success_Pod__r.OwnerId
            FROM Success_Resource_Pod_Association__c
            WHERE
                Success_Resource__r.Resource__c = :testUser.Id
                AND Success_Resource__r.RecordTypeId = :RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Advisor')
                AND Success_Pod__r.RecordTypeId = :RecordIdHelper.getRecordTypeId('Success_Pod__c', 'Advisor')
        ];

        // Get options
        String viewAsOptionListStr;
        List<OrderedMapStringToString.LabelValue> viewAsOptionList;
        System.runAs(testUser) {
            viewAsOptionListStr = AdvisorPortalTopLevelFilterController.viewAsOptions(false);
        }
        viewAsOptionList = (List<OrderedMapStringToString.LabelValue>) JSON.deserialize(
            viewAsOptionListStr,
            List<OrderedMapStringToString.LabelValue>.class
        );
        OrderedMapStringToString viewAsOptionMap = new OrderedMapStringToString(viewAsOptionList);

        List<String> groupIds = new List<String>();
        for (Success_Resource_Pod_Association__c srpa : srpas) {
            groupIds.add(srpa.Success_Pod__r.OwnerId);
        }
        assertContainsAllOptionsInProperOrder(viewAsOptionList, testUser.Id, groupIds, null, null);
    }

    @isTest
    private static void testUser3() {
        // Test user 3 should see themself, their managed pod, and users 2, 4, and 8
        List<User> users = [
            SELECT Id, Alias
            FROM User
            WHERE Alias IN (:testUserAlias2, :testUserAlias3, :testUserAlias4, :testUserAlias8)
        ];
        User testUser;
        for (User u : users) {
            if (u.Alias == testUserAlias3) {
                testUser = u;
                break;
            }
        }
        List<Success_Resource_Pod_Association__c> srpas = [
            SELECT Success_Pod__r.OwnerId
            FROM Success_Resource_Pod_Association__c
            WHERE
                Success_Resource__r.Resource__c = :testUser.Id
                AND Success_Resource__r.RecordTypeId = :RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Advisor')
                AND Success_Pod__r.RecordTypeId = :RecordIdHelper.getRecordTypeId('Success_Pod__c', 'Advisor')
        ];

        // Get options
        String viewAsOptionListStr;
        List<OrderedMapStringToString.LabelValue> viewAsOptionList;
        System.runAs(testUser) {
            viewAsOptionListStr = AdvisorPortalTopLevelFilterController.viewAsOptions(false);
        }
        viewAsOptionList = (List<OrderedMapStringToString.LabelValue>) JSON.deserialize(
            viewAsOptionListStr,
            List<OrderedMapStringToString.LabelValue>.class
        );
        OrderedMapStringToString viewAsOptionMap = new OrderedMapStringToString(viewAsOptionList);

        List<String> groupIds = new List<String>();
        for (Success_Resource_Pod_Association__c srpa : srpas) {
            groupIds.add(srpa.Success_Pod__r.OwnerId);
        }
        List<String> subordinateUserIds = new List<String>();
        for (User u : users) {
            if (u.Id == testUser.Id)
                continue;
            subordinateUserIds.add(u.Id);
        }
        assertContainsAllOptionsInProperOrder(viewAsOptionList, testUser.Id, null, groupIds, subordinateUserIds);
    }

    @isTest
    private static void testUser4Ugrad() {
        // Test user 4 (in ugrad mode) should see themself, their managed pod, and users 2, 3, and 8
        List<User> users = [
            SELECT Id, Alias
            FROM User
            WHERE Alias IN (:testUserAlias2, :testUserAlias3, :testUserAlias4, :testUserAlias8)
        ];
        User testUser;
        for (User u : users) {
            if (u.Alias == testUserAlias4) {
                testUser = u;
                break;
            }
        }
        List<Success_Resource_Pod_Association__c> srpas = [
            SELECT Success_Pod__r.OwnerId
            FROM Success_Resource_Pod_Association__c
            WHERE
                Success_Resource__r.Resource__c = :testUser.Id
                AND Success_Resource__r.RecordTypeId = :RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Advisor')
                AND Success_Pod__r.RecordTypeId = :RecordIdHelper.getRecordTypeId('Success_Pod__c', 'Advisor')
        ];

        // Get options
        String viewAsOptionListStr;
        List<OrderedMapStringToString.LabelValue> viewAsOptionList;
        System.runAs(testUser) {
            viewAsOptionListStr = AdvisorPortalTopLevelFilterController.viewAsOptions(false);
        }
        viewAsOptionList = (List<OrderedMapStringToString.LabelValue>) JSON.deserialize(
            viewAsOptionListStr,
            List<OrderedMapStringToString.LabelValue>.class
        );
        OrderedMapStringToString viewAsOptionMap = new OrderedMapStringToString(viewAsOptionList);

        List<String> groupIds = new List<String>();
        for (Success_Resource_Pod_Association__c srpa : srpas) {
            groupIds.add(srpa.Success_Pod__r.OwnerId);
        }
        List<String> subordinateUserIds = new List<String>();
        for (User u : users) {
            if (u.Id == testUser.Id)
                continue;
            subordinateUserIds.add(u.Id);
        }
        assertContainsAllOptionsInProperOrder(viewAsOptionList, testUser.Id, null, groupIds, subordinateUserIds);
    }

    @isTest
    private static void testUser4Grad() {
        // Test user 4 (in grad mode) should see themself
        User testUser = [SELECT Id, Alias FROM User WHERE Alias = :testUserAlias4];
        List<Success_Resource_Pod_Association__c> underGradSRPAs = [
            SELECT Success_Pod__r.OwnerId
            FROM Success_Resource_Pod_Association__c
            WHERE
                Success_Resource__r.Resource__c = :testUser.Id
                AND Success_Resource__r.RecordTypeId = :RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Advisor')
                AND Success_Pod__r.RecordTypeId = :RecordIdHelper.getRecordTypeId('Success_Pod__c', 'Advisor')
        ];

        // Get options
        String viewAsOptionListStr;
        List<OrderedMapStringToString.LabelValue> viewAsOptionList;
        System.runAs(testUser) {
            viewAsOptionListStr = AdvisorPortalTopLevelFilterController.viewAsOptions(true);
        }
        viewAsOptionList = (List<OrderedMapStringToString.LabelValue>) JSON.deserialize(
            viewAsOptionListStr,
            List<OrderedMapStringToString.LabelValue>.class
        );
        OrderedMapStringToString viewAsOptionMap = new OrderedMapStringToString(viewAsOptionList);

        assertContainsAllOptionsInProperOrder(viewAsOptionList, testUser.Id, null, null, null);
    }

    @isTest
    private static void testUser5() {
        // Test user 5 should see themself and their single pod
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias5];
        List<Success_Resource_Pod_Association__c> srpas = [
            SELECT Success_Pod__r.OwnerId
            FROM Success_Resource_Pod_Association__c
            WHERE
                Success_Resource__r.Resource__c = :testUser.Id
                AND Success_Resource__r.RecordTypeId = :RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Grad')
                AND Success_Pod__r.RecordTypeId = :RecordIdHelper.getRecordTypeId('Success_Pod__c', 'Grad')
        ];

        // Get options
        String viewAsOptionListStr;
        List<OrderedMapStringToString.LabelValue> viewAsOptionList;
        System.runAs(testUser) {
            viewAsOptionListStr = AdvisorPortalTopLevelFilterController.viewAsOptions(true);
        }
        viewAsOptionList = (List<OrderedMapStringToString.LabelValue>) JSON.deserialize(
            viewAsOptionListStr,
            List<OrderedMapStringToString.LabelValue>.class
        );
        OrderedMapStringToString viewAsOptionMap = new OrderedMapStringToString(viewAsOptionList);

        List<String> groupIds = new List<String>();
        for (Success_Resource_Pod_Association__c srpa : srpas) {
            groupIds.add(srpa.Success_Pod__r.OwnerId);
        }
        assertContainsAllOptionsInProperOrder(viewAsOptionList, testUser.Id, groupIds, null, null);
    }

    @isTest
    private static void testUser6() {
        // Test user 6 should see themself and their single pod
        User testUser = [SELECT Id FROM User WHERE Alias = :testUserAlias6];
        List<Success_Resource_Pod_Association__c> srpas = [
            SELECT Success_Pod__r.OwnerId
            FROM Success_Resource_Pod_Association__c
            WHERE
                Success_Resource__r.Resource__c = :testUser.Id
                AND Success_Resource__r.RecordTypeId = :RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Grad')
                AND Success_Pod__r.RecordTypeId = :RecordIdHelper.getRecordTypeId('Success_Pod__c', 'Grad')
        ];

        // Get options
        String viewAsOptionListStr;
        List<OrderedMapStringToString.LabelValue> viewAsOptionList;
        System.runAs(testUser) {
            viewAsOptionListStr = AdvisorPortalTopLevelFilterController.viewAsOptions(true);
        }
        viewAsOptionList = (List<OrderedMapStringToString.LabelValue>) JSON.deserialize(
            viewAsOptionListStr,
            List<OrderedMapStringToString.LabelValue>.class
        );
        OrderedMapStringToString viewAsOptionMap = new OrderedMapStringToString(viewAsOptionList);

        List<String> groupIds = new List<String>();
        for (Success_Resource_Pod_Association__c srpa : srpas) {
            groupIds.add(srpa.Success_Pod__r.OwnerId);
        }
        assertContainsAllOptionsInProperOrder(viewAsOptionList, testUser.Id, groupIds, null, null);
    }

    @isTest
    private static void testUser7() {
        // Test user 7 should see themself, pods 3 and 4, and test users 5, 6, and 8
        List<User> users = [
            SELECT Id, Alias
            FROM User
            WHERE Alias IN (:testUserAlias7, :testUserAlias5, :testUserAlias6, :testUserAlias8)
        ];
        User testUser;
        for (User u : users) {
            if (u.Alias == testUserAlias7) {
                testUser = u;
                break;
            }
        }
        List<Success_Resource_Pod_Association__c> srpas = [
            SELECT Success_Pod__r.OwnerId
            FROM Success_Resource_Pod_Association__c
            WHERE
                Success_Resource__r.Resource__c = :testUser.Id
                AND Success_Resource__r.RecordTypeId = :RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Grad')
                AND Success_Pod__r.RecordTypeId = :RecordIdHelper.getRecordTypeId('Success_Pod__c', 'Grad')
        ];

        // Get options
        String viewAsOptionListStr;
        List<OrderedMapStringToString.LabelValue> viewAsOptionList;
        System.runAs(testUser) {
            viewAsOptionListStr = AdvisorPortalTopLevelFilterController.viewAsOptions(true);
        }
        viewAsOptionList = (List<OrderedMapStringToString.LabelValue>) JSON.deserialize(
            viewAsOptionListStr,
            List<OrderedMapStringToString.LabelValue>.class
        );
        OrderedMapStringToString viewAsOptionMap = new OrderedMapStringToString(viewAsOptionList);

        List<String> groupIds = new List<String>();
        for (Success_Resource_Pod_Association__c srpa : srpas) {
            groupIds.add(srpa.Success_Pod__r.OwnerId);
        }
        List<String> subordinateUserIds = new List<String>();
        for (User u : users) {
            if (u.Id == testUser.Id)
                continue;
            subordinateUserIds.add(u.Id);
        }
        assertContainsAllOptionsInProperOrder(viewAsOptionList, testUser.Id, null, groupIds, subordinateUserIds);
    }

    @isTest
    private static void testUser8Ugrad() {
        // Test user 8 (in ugrad mode) should see themself, pod 2, and test users 2, 3, 4
        List<User> users = [
            SELECT Id, Alias
            FROM User
            WHERE Alias IN (:testUserAlias8, :testUserAlias2, :testUserAlias3, :testUserAlias4)
        ];
        User testUser;
        for (User u : users) {
            if (u.Alias == testUserAlias8) {
                testUser = u;
                break;
            }
        }
        List<Success_Resource_Pod_Association__c> srpas = [
            SELECT Success_Pod__r.OwnerId
            FROM Success_Resource_Pod_Association__c
            WHERE
                Success_Resource__r.Resource__c = :testUser.Id
                AND Success_Resource__r.RecordTypeId = :RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Advisor')
                AND Success_Pod__r.RecordTypeId = :RecordIdHelper.getRecordTypeId('Success_Pod__c', 'Advisor')
        ];

        // Get options
        String viewAsOptionListStr;
        List<OrderedMapStringToString.LabelValue> viewAsOptionList;
        System.runAs(testUser) {
            viewAsOptionListStr = AdvisorPortalTopLevelFilterController.viewAsOptions(false);
        }
        viewAsOptionList = (List<OrderedMapStringToString.LabelValue>) JSON.deserialize(
            viewAsOptionListStr,
            List<OrderedMapStringToString.LabelValue>.class
        );
        OrderedMapStringToString viewAsOptionMap = new OrderedMapStringToString(viewAsOptionList);

        List<String> groupIds = new List<String>();
        for (Success_Resource_Pod_Association__c srpa : srpas) {
            groupIds.add(srpa.Success_Pod__r.OwnerId);
        }
        List<String> subordinateUserIds = new List<String>();
        for (User u : users) {
            if (u.Id == testUser.Id)
                continue;
            subordinateUserIds.add(u.Id);
        }
        assertContainsAllOptionsInProperOrder(viewAsOptionList, testUser.Id, null, groupIds, subordinateUserIds);
    }

    @isTest
    private static void testUser8Grad() {
        // Test user 8 (in grad mode) should see themself, pod 4, and users 6 and 7
        List<User> users = [
            SELECT Id, Alias
            FROM User
            WHERE Alias IN (:testUserAlias8, :testUserAlias6, :testUserAlias7)
        ];
        User testUser;
        for (User u : users) {
            if (u.Alias == testUserAlias8) {
                testUser = u;
                break;
            }
        }
        List<Success_Resource_Pod_Association__c> srpas = [
            SELECT Success_Pod__r.OwnerId
            FROM Success_Resource_Pod_Association__c
            WHERE
                Success_Resource__r.Resource__c = :testUser.Id
                AND Success_Resource__r.RecordTypeId = :RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Grad')
                AND Success_Pod__r.RecordTypeId = :RecordIdHelper.getRecordTypeId('Success_Pod__c', 'Grad')
        ];

        // Get options
        String viewAsOptionListStr;
        List<OrderedMapStringToString.LabelValue> viewAsOptionList;
        System.runAs(testUser) {
            viewAsOptionListStr = AdvisorPortalTopLevelFilterController.viewAsOptions(true);
        }
        viewAsOptionList = (List<OrderedMapStringToString.LabelValue>) JSON.deserialize(
            viewAsOptionListStr,
            List<OrderedMapStringToString.LabelValue>.class
        );
        OrderedMapStringToString viewAsOptionMap = new OrderedMapStringToString(viewAsOptionList);

        List<String> groupIds = new List<String>();
        for (Success_Resource_Pod_Association__c srpa : srpas) {
            groupIds.add(srpa.Success_Pod__r.OwnerId);
        }
        List<String> subordinateUserIds = new List<String>();
        for (User u : users) {
            if (u.Id == testUser.Id)
                continue;
            subordinateUserIds.add(u.Id);
        }
        assertContainsAllOptionsInProperOrder(viewAsOptionList, testUser.Id, null, groupIds, subordinateUserIds);
    }

    private static void assertContainsAllOptionsInProperOrder(
        List<OrderedMapStringToString.LabelValue> optionsList,
        String userId,
        List<String> ownersOfPods,
        List<String> ownersOfManagedPods,
        List<String> subordinateIds
    ) {
        Boolean atStart = true, inPodsSection = false, inManagedPodsSection = false, inSubordinateSection = false;
        Boolean foundSelf = false,
            foundPodsHeader = false,
            foundManagedPodsHeader = false,
            foundSubordinateHeader = false;
        Integer podCount = 0, managedPodsCount = 0, subordinateCount = 0;

        if (ownersOfPods == null)
            ownersOfPods = new List<String>();
        if (ownersOfManagedPods == null)
            ownersOfManagedPods = new List<String>();
        if (subordinateIds == null)
            subordinateIds = new List<String>();

        for (OrderedMapStringToString.LabelValue labelValue : optionsList) {
            String label = labelValue.label;
            String value = labelValue.value;

            // Mvoe from section to section
            if (label == '--My Committees--') {
                atStart = false;
                inPodsSection = true;
                inManagedPodsSection = false;
                inSubordinateSection = false;
                foundPodsHeader = true;
                continue;
            } else if (
                label == '--Department Committees--' ||
                label == '--College Committees--' ||
                label == '--School Name or Advising Team--'
            ) {
                atStart = false;
                inPodsSection = false;
                inManagedPodsSection = true;
                inSubordinateSection = false;
                foundManagedPodsHeader = true;
                continue;
            } else if (
                label == '--Department Advisors--' ||
                label == '--College Advisors--' ||
                label == '--Program Advisors--'
            ) {
                atStart = false;
                inPodsSection = false;
                inManagedPodsSection = false;
                inSubordinateSection = true;
                foundSubordinateHeader = true;
                continue;
            }

            if (atStart) {
                // First should be the user themself, ALWAYS
                foundSelf = value == userId;
                atStart = false;
            } else if (inPodsSection) {
                // These are all pods the user is in
                podCount += ownersOfPods.contains(value) ? 1 : 0;
            } else if (inManagedPodsSection) {
                // There are all pods the user manages
                managedPodsCount += ownersOfManagedPods.contains(value) ? 1 : 0;
            } else if (inSubordinateSection) {
                // All subordinates
                subordinateCount += subordinateIds.contains(value) ? 1 : 0;
            }
        }

        System.debug('==================');

        for (OrderedMapStringToString.LabelValue labelValue : optionsList) {
            System.debug(labelValue);
        }
        System.debug('---');
        System.debug(foundSelf);
        System.debug(ownersOfPods);
        System.debug(foundPodsHeader);
        System.debug(podCount);
        System.debug(ownersOfManagedPods);
        System.debug(foundManagedPodsHeader);
        System.debug(managedPodsCount);
        System.debug(subordinateIds);
        System.debug(foundSubordinateHeader);
        System.debug(subordinateCount);
        System.debug('==================');

        System.assert(foundSelf, 'The user themself should ALWAYS be the first option in the list');
        System.assertEquals(
            !ownersOfPods.isEmpty(),
            foundPodsHeader,
            'If-and-only-if there some pods specified should the header be included'
        );
        System.assertEquals(ownersOfPods.size(), podCount);
        System.assertEquals(
            !ownersOfManagedPods.isEmpty(),
            foundManagedPodsHeader,
            'If-and-only-if there some pods specified should the header be included'
        );
        System.assertEquals(ownersOfManagedPods.size(), managedPodsCount);
        System.assertEquals(
            !subordinateIds.isEmpty(),
            foundSubordinateHeader,
            'If-and-only-if there some subordinates specified should the header be included'
        );
        System.assertEquals(subordinateIds.size(), subordinateCount);
    }

    private static User createUser(String alias, String indx) {
        return new User(
            FirstName = 'Test-' + indx,
            LastName = 'User',
            Username = 'test-' + indx + '.user@test.test',
            Email = 'test-' + indx + '.user@test.test',
            Alias = alias,
            CommunityNickname = alias,
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = RecordIdHelper.getProfileId('Standard User')
        );
    }

    private static Group createGroup(String indx) {
        return new Group(Name = 'TestGroup-' + indx, Email = 'test-' + indx + '.group@test.test', Type = 'Queue');
    }

    private static Success_Resource__c createSuccessResource(User u, String role, String recordTypeId) {
        return new Success_Resource__c(
            Role__c = role,
            Resource__c = u.Id,
            IsActive__c = true,
            RecordTypeId = recordTypeId
        );
    }

    private static QueueSobject createQueueSObject(String groupId) {
        return new QueueSobject(QueueId = groupId, SobjectType = 'Success_Pod__c');
    }

    private static Success_Pod__c createSuccessPod(String ownerId, String recordTypeId, String indx) {
        return new Success_Pod__c(
            OwnerId = ownerId,
            RecordTypeId = recordTypeId,
            Name = 'Test Pod ' + indx,
            Committee__c = 'tp-' + indx
        );
    }

    private static Success_Resource_Pod_Association__c createSRPA(Success_Resource__c sucRes, Success_Pod__c sucPod) {
        return new Success_Resource_Pod_Association__c(Success_Resource__c = sucRes.Id, Success_Pod__c = sucPod.Id);
    }
}
