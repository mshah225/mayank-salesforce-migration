/**
 * @author Mathew Ruff, Sierra-Cedar
 * @date 2019-04-11
 *
 * Unit Tests for AdvisorPortalTopLevelFilter.cls
 */
@IsTest
private class AdvisorPortalTopLevelFilterTest {
    @IsTest
    private static void testDepartmentManagerViewAsOptions() {
        // Arrange
        UserFactory.makeMeAnAdvisorDepartmentManager(1, 2, 2);

        // Act
        Test.startTest();
        String viewAsOptionListStr = AdvisorPortalTopLevelFilterController.viewAsOptions();
        Test.stopTest();

        List<OrderedMapStringToString.LabelValue> labelValueList = (List<OrderedMapStringToString.LabelValue>) JSON.deserialize(
            viewAsOptionListStr,
            List<OrderedMapStringToString.LabelValue>.class
        );
        Map<String, String> viewAsOptionMap = new Map<String, String>();
        for (OrderedMapStringToString.LabelValue labelValue : labelValueList) {
            viewAsOptionMap.put(labelValue.label, labelValue.value);
        }

        // Assert
        System.assert(
            viewAsOptionMap.keySet().contains('Test Pod 0 - tp0'),
            'View as options should include my Test Pod.'
        );
    }

    @IsTest
    private static void testCollegeManagerViewAsOptions() {
        // Arrange
        UserFactory.makeMeAnAdvisorCollegeManager(1, 2, 2);

        // Act
        Test.startTest();
        String viewAsOptionListStr = AdvisorPortalTopLevelFilterController.viewAsOptions();
        Test.stopTest();

        List<OrderedMapStringToString.LabelValue> labelValueList = (List<OrderedMapStringToString.LabelValue>) JSON.deserialize(
            viewAsOptionListStr,
            List<OrderedMapStringToString.LabelValue>.class
        );
        Map<String, String> viewAsOptionMap = new Map<String, String>();
        for (OrderedMapStringToString.LabelValue labelValue : labelValueList) {
            viewAsOptionMap.put(labelValue.label, labelValue.value);
        }

        // Assert
        System.assert(
            viewAsOptionMap.keySet().contains('Test Pod 0 - tp0'),
            'View as options should include my Test Pod.'
        );
    }

    @IsTest
    private static void testAdvisorUserViewAsOptions() {
        // Arrange
        UserFactory.makeMeAnAdvisorUser(1, 2, 2);

        // Act
        Test.startTest();
        String viewAsOptionListStr = AdvisorPortalTopLevelFilterController.viewAsOptions();
        Test.stopTest();

        List<OrderedMapStringToString.LabelValue> labelValueList = (List<OrderedMapStringToString.LabelValue>) JSON.deserialize(
            viewAsOptionListStr,
            List<OrderedMapStringToString.LabelValue>.class
        );
        Map<String, String> viewAsOptionMap = new Map<String, String>();
        for (OrderedMapStringToString.LabelValue labelValue : labelValueList) {
            viewAsOptionMap.put(labelValue.label, labelValue.value);
        }

        // Assert
        System.assert(
            new Set<String>(viewAsOptionMap.values()).contains(UserInfo.getUserId()),
            'View as options should include my UserId.'
        );
    }

    @IsTest
    private static void testCollegeManagerSubordinateViewAsOptions() {
        // Arrange
        UserFactory.makeMeAnAdvisorCollegeManager(1, 2, 2);

        User testManager = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'test.user@test.example.com',
            Email = 'test.user@test.example.com',
            Alias = 'testUsr',
            CommunityNickname = 'testUsr',
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User']
            .Id
        );
        insert testManager;

        Success_Resource__c myTestResource = new Success_Resource__c(
            Role__c = 'User',
            Success_Pod__c = [SELECT Id FROM Success_Pod__c LIMIT 1]
            .Id,
            Resource__c = testManager.Id,
            IsActive__c = true,
            RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Advisor')
        );
        insert myTestResource;

        Success_Resource_Pod_Association__c testAssociation = new Success_Resource_Pod_Association__c(
            Success_Pod__c = [SELECT Id FROM Success_Pod__c LIMIT 1]
            .Id,
            Success_Resource__c = myTestResource.Id
        );
        insert testAssociation;

        // Act
        Test.startTest();
        String viewAsOptionListStr = AdvisorPortalTopLevelFilterController.viewAsOptions();
        Test.stopTest();

        List<OrderedMapStringToString.LabelValue> labelValueList = (List<OrderedMapStringToString.LabelValue>) JSON.deserialize(
            viewAsOptionListStr,
            List<OrderedMapStringToString.LabelValue>.class
        );
        Map<String, String> viewAsOptionMap = new Map<String, String>();
        for (OrderedMapStringToString.LabelValue labelValue : labelValueList) {
            viewAsOptionMap.put(labelValue.label, labelValue.value);
        }

        // Assert
        System.assert(
            viewAsOptionMap.keySet().contains('Test Pod 0 - tp0'),
            'View as options should include My Test Pod.'
        );
        System.assert(
            viewAsOptionMap.keySet().contains('Test User - testUsr'),
            'View as options should include Subordinate.'
        );
    }
}