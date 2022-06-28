@isTest
public class ObjectServiceTest {
    private static final List<String> standardUserFieldsToCheckFor = new List<String>{
        'id',
        'name',
        'email',
        'phone',
        'alias',
        'address',
        'city',
        'country',
        'postalcode'
    };

    @isTest
    private static void testGetObjectFieldsMap() {
        Map<String, SObjectField> retrievedFieldsMap = ObjectService.getObjectFieldMap('User');

        List<String> retrievedFields = new List<String>();
        for (String field : retrievedFieldsMap.keySet()) {
            retrievedFields.add(field.trim().toLowerCase());
        }

        for (String field : standardUserFieldsToCheckFor) {
            System.assert(retrievedFields.contains(field), 'Is missing field: ' + field);
        }
    }

    @isTest
    private static void testObjectFieldsToStringByName() {
        String retrievedFieldsString = ObjectService.objectFieldsToString('User');

        List<String> retrievedFields = new List<String>();
        for (String field : retrievedFieldsString.split(',')) {
            retrievedFields.add(field.trim().toLowerCase());
        }

        for (String field : standardUserFieldsToCheckFor) {
            System.assert(retrievedFields.contains(field), 'Is missing field: ' + field);
        }
    }

    @isTest
    private static void testObjectFieldsToStringFromMap() {
        String retrievedFieldsString = ObjectService.objectFieldsToString(ObjectService.getObjectFieldMap('User'));

        List<String> retrievedFields = new List<String>();
        for (String field : retrievedFieldsString.split(',')) {
            retrievedFields.add(field.trim().toLowerCase());
        }

        for (String field : standardUserFieldsToCheckFor) {
            System.assert(retrievedFields.contains(field), 'Is missing field: ' + field);
        }
    }

    @isTest
    private static void testObjectFieldsToStringByStringVsFromMap() {
        String retrievedFieldsString1 = ObjectService.objectFieldsToString('User');
        List<String> retrievedFields1 = retrievedFieldsString1.split(',');

        String retrievedFieldsString2 = ObjectService.objectFieldsToString(ObjectService.getObjectFieldMap('User'));
        List<String> retrievedFields2 = retrievedFieldsString2.split(',');

        System.assert(!retrievedFields1.isEmpty(), 'Need some fields - otherwise testing nothing...');
        System.assertEquals(retrievedFields1.size(), retrievedFields2.size());
        for (String field : retrievedFields1) {
            System.assert(retrievedFields2.contains(field), 'Is missing field: ' + field);
        }
    }

    @isTest
    private static void testGetFieldLabelsToList() {
        Map<String, SObjectField> fieldsForUser = ObjectService.getObjectFieldMap('User');

        List<String> retrievedFieldLabels = ObjectService.getFieldLabelsToList('User');

        for (String key : fieldsForUser.keySet()) {
            System.assert(
                retrievedFieldLabels.contains(fieldsForUser.get(key).getDescribe().getLabel()),
                'Is missing label: ' + key
            );
        }
    }

    @isTest
    private static void testGetFakeId() {
        String fakeId = ObjectService.getFakeId(Case.getSObjectType());

        Case c = new Case(Subject = 'Test Case', Description = 'Hello world!');
        insert c;
        String realId = c.Id;

        System.assert(realId.contains(Case.getSObjectType().getDescribe().getKeyPrefix()));
        System.assert(fakeId.contains(Case.getSObjectType().getDescribe().getKeyPrefix()));
    }

    @isTest
    private static void testGetKeyPrefix() {
        String prefix = ObjectService.getKeyPrefix(Case.getSObjectType());

        System.assert(prefix.contains(Case.getSObjectType().getDescribe().getKeyPrefix()));
    }

    @isTest
    private static void testGetGuid() {
        List<String> seenGuids = new List<String>();
        for (Integer i = 0; i < 500; i++) {
            String guid = ObjectService.getGuid();
            System.assert(!seenGuids.contains(guid), 'Should not repeat guid');
            seenGuids.add(guid);
        }
    }

    @isTest
    private static void testAddToListSafely() {
        Case c = new Case(Subject = 'Test Case', Description = 'Hello world!');
        insert c;

        List<Case> safeList = new List<Case>();
        ObjectService.addToListSafely(safeList, c);
        ObjectService.addToListSafely(safeList, c);

        System.assertEquals(1, safeList.size(), 'Should have only been added once');
    }

    @isTest
    private static void testUpdateSObjectInMapInsertNew() {
        Map<Id, Contact> conIdToCon = new Map<Id, Contact>();
        // Make a new contact
        Contact testCon = new Contact(FirstName = 'ObjectService', LastName = 'Test Contact');
        insert testCon;
        // We need the id
        testCon = [SELECT Id, FirstName, LastName FROM Contact WHERE Id = :testCon.Id];
        // This should add testCon to the map
        ObjectService.updateSObjectInMap(conIdToCon, testCon);
        // Asserts
        System.assert(!conIdToCon.isEmpty(), 'Should have inserted testCon into map');
    }

    @isTest
    private static void testUpdateSObjectInMapUpdateExisting() {
        Map<Id, Contact> conIdToCon = new Map<Id, Contact>();
        // Make a new contact
        Contact testCon = new Contact(FirstName = 'ObjectService', LastName = 'Test Contact');
        insert testCon;
        // We need the id
        testCon = [SELECT Id, FirstName, LastName FROM Contact WHERE Id = :testCon.Id];
        String expectedFName = testCon.FirstName;
        String expectedLName = testCon.LastName;
        // place contact in map
        conIdToCon.put(testCon.Id, testCon);
        // We want to add these details (the email) to the version in the map
        Contact newDetails = new Contact(Id = testCon.Id, Email = 'test@email.test');
        // Should update the Contact in the map with additional details
        ObjectService.updateSObjectInMap(conIdToCon, newDetails);
        String expectedEmail = newDetails.Email;
        // Asserts
        String actualFName = conIdToCon.get(testCon.Id).FirstName;
        String actualLName = conIdToCon.get(testCon.Id).LastName;
        String actualEmail = conIdToCon.get(testCon.Id).Email;
        System.assertEquals(expectedFName, actualFName);
        System.assertEquals(expectedLName, actualLName);
        System.assertEquals(expectedEmail, actualEmail);
    }

    @isTest
    private static void testWait() {
        Long startSecond = System.now().getTime();
        ObjectService.wait(5000);
        Long endSecond = System.now().getTime();

        System.assert(endSecond - startSecond >= 5, 'Should have waited at least 5 seconds');
    }

    @isTest
    private static void testGetPicklistOptionsMap() {
        List<Schema.PicklistEntry> expectedTimeZones = User.getSObjectType()
            .getDescribe()
            .fields.getMap()
            .get('TimeZoneSidKey')
            .getDescribe()
            .getPicklistValues();

        Map<String, String> retrievedTimeZones = ObjectService.getPicklistChoicesMap('User', 'TimeZoneSidKey');

        System.assert(!expectedTimeZones.isEmpty(), 'Must have some timezones');
        System.assertEquals(expectedTimeZones.size(), retrievedTimeZones.size());
        for (Schema.PicklistEntry tz : expectedTimeZones) {
            if (!tz.isActive())
                continue;
            System.assert(retrievedTimeZones.containsKey(tz.getLabel()), 'Missing timezone: ' + tz.getLabel());
            System.assertEquals(
                tz.getValue(),
                retrievedTimeZones.get(tz.getLabel()),
                'Incorrect timezone label -> value: ' +
                tz.getLabel() +
                ' -> ' +
                tz.getValue()
            );
        }
    }

    @isTest
    private static void testGetPicklistOptionsSelectList() {
        List<Schema.PicklistEntry> expectedTimeZones = User.getSObjectType()
            .getDescribe()
            .fields.getMap()
            .get('TimeZoneSidKey')
            .getDescribe()
            .getPicklistValues();

        List<SelectOption> retrievedTimeZones = ObjectService.getPicklistChoicesSelectList('User', 'TimeZoneSidKey');

        System.assert(!expectedTimeZones.isEmpty(), 'Must have some timezones');
        System.assertEquals(expectedTimeZones.size(), retrievedTimeZones.size());
        for (Schema.PicklistEntry tz : expectedTimeZones) {
            if (!tz.isActive())
                continue;

            Boolean foundMatch = false;
            for (SelectOption opt : retrievedTimeZones) {
                if (opt.getValue() == tz.getValue()) {
                    foundMatch = true;
                    break;
                }
            }
            System.assert(foundMatch, 'Missing timezone: ' + tz.getValue());
        }
    }

    @isTest
    private static void testGetPicklistOptionsMapVsSelectList() {
        Map<String, String> retrievedTimeZones1 = ObjectService.getPicklistChoicesMap('User', 'TimeZoneSidKey');
        List<SelectOption> retrievedTimeZones2 = ObjectService.getPicklistChoicesSelectList('User', 'TimeZoneSidKey');

        System.assert(!retrievedTimeZones1.isEmpty(), 'Must have some timezones');
        System.assertEquals(retrievedTimeZones1.size(), retrievedTimeZones2.size());
        for (String key : retrievedTimeZones1.keySet()) {
            String expectedValue = retrievedTimeZones1.get(key);

            Boolean foundMatch = false;
            for (SelectOption opt : retrievedTimeZones2) {
                if (opt.getValue() == expectedValue) {
                    foundMatch = true;
                    break;
                }
            }
            System.assert(foundMatch, 'Missing timezone: ' + expectedValue);
        }
    }
}
