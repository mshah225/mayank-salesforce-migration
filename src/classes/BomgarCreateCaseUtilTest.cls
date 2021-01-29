@isTest
private class BomgarCreateCaseUtilTest {
    @testSetup
    static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'ASU Community'];

        Profile h = [SELECT Id FROM Profile WHERE Name = 'ASU Service - Help Desk'];

        Contact testContact = ContactService.createTestContact();
        testContact.EMPLID__c = '1231231231';
        testContact.ASURite_Id__c = 'testuser';
        insert testContact;

        UserFactory.DefaultUser userCreator = new UserFactory.DefaultUser();
        List<User> userList = userCreator.create(2);

        User testUser = userList[0];
        testUser.ProfileId = p.Id;
        testUser.ContactId = testContact.Id;
        insert testUser;

        User testBomgarUser = userList[1];
        testBomgarUser.ProfileId = h.Id;
        testBomgarUser.FederationIdentifier = 'testuser@admin.asu.edu';
        testBomgarUser.bomgar__Bomgar_Username__c = 'testuser';
        insert testBomgarUser;

        Case_Classification__c cc = new Case_Classification__c();
        cc.Name = 'Help Desk';
        cc.Active__c = true;
        cc.RecordTypeId = Schema.SObjectType.Case_Classification__c.getRecordTypeInfosByName()
            .get('Functional Group')
            .getRecordTypeId();
        insert cc;

        List<Case_Classification__c> lstCC = new List<Case_Classification__c>();
        Case_Classification__c cc1 = new Case_Classification__c();
        cc1.Name = 'Finances (Help Desk)';
        cc1.Active__c = true;
        cc1.RecordTypeId = Schema.SObjectType.Case_Classification__c.getRecordTypeInfosByName()
            .get('Category')
            .getRecordTypeId();
        cc1.Parent__c = cc.Id;
        lstCC.add(cc1);

        Case_Classification__c cc2 = new Case_Classification__c();
        cc2.Name = 'General Help Desk';
        cc2.Active__c = true;
        cc2.RecordTypeId = Schema.SObjectType.Case_Classification__c.getRecordTypeInfosByName()
            .get('Category')
            .getRecordTypeId();
        cc2.Parent__c = cc.Id;
        lstCC.add(cc2);
        insert lstCC;
    }

    @isTest
    static void testCreateCaseFA() {
        Test.startTest();

        String value = null;
        bomgar__BomgarWebEvent__c webEvent = new bomgar__BomgarWebEvent__c();
        webEvent.bomgar__Username__c = 'joetest123123';
        webEvent.bomgar__ExternalKey__c =
            'SFDC:{' +
            '"employeeNumber":"1231231231", ' +
            '"description":"Bacon ipsum dolor amet bresaola drumstick leberkas, \nmeatloaf ' +
            'picanha turducken tenderloin alcatra biltong cow pastrami tongue swine. Ham ' +
            'meatloaf \bfatback biltong bresaola. \nKevin pork shank, meatball t-bone ball ' +
            'tip hamburger short loin tenderloin prosciutto salami turducken fatback tongue ' +
            'porchetta. Brisket fatback corned beef bacon \\"shankle filet \fmignon doner kevin ' +
            'short loin meatloaf salami. \r\nPork turducken tenderloin brisket corned beef ' +
            'turkey. Pork chop boudin corned beef", ' +
            '"asuriteId":"testc", ' +
            '"externalKey":"Finances"}';
        value = BomgarCreateCaseUtil.createCase(webEvent);

        Case testCase = [SELECT Id, CC_Category__r.Name FROM Case WHERE Id = :value];

        Test.stopTest();

        System.assertEquals('Finances (Help Desk)', testCase.CC_Category__r.Name);
    }

    @isTest
    static void testCreateCaseOther() {
        Test.startTest();

        String value = null;
        bomgar__BomgarWebEvent__c webEvent = new bomgar__BomgarWebEvent__c();
        webEvent.bomgar__Username__c = 'joetest123123';
        webEvent.bomgar__ExternalKey__c =
            'SFDC:{' +
            '"employeeNumber":"1231231231", ' +
            '"description":"Bacon ipsum dolor amet bresaola drumstick leberkas", ' +
            '"asuriteId":"testc", ' +
            '"externalKey":"Other"}';
        value = BomgarCreateCaseUtil.createCase(webEvent);

        Case testCase = [SELECT Id, CC_Category__r.Name FROM Case WHERE Id = :value];

        Test.stopTest();

        System.assertEquals('General Help Desk', testCase.CC_Category__r.Name);
    }

    @isTest
    static void testCreateCaseNoExternalKey() {
        Test.startTest();

        String value = null;
        bomgar__BomgarWebEvent__c webEvent = new bomgar__BomgarWebEvent__c();
        webEvent.bomgar__Username__c = 'joetest123123';
        webEvent.bomgar__ExternalKey__c =
            'SFDC:{' +
            '"employeeNumber":"1231231231", ' +
            '"description":"Bacon ipsum dolor amet bresaola drumstick leberkas", ' +
            '"asuriteId":"testc", ' +
            '"externalKey":""}';
        value = BomgarCreateCaseUtil.createCase(webEvent);

        Case testCase = [SELECT Id, CC_Category__r.Name FROM Case WHERE Id = :value];

        Test.stopTest();

        System.assertEquals('General Help Desk', testCase.CC_Category__r.Name);
    }

    @isTest
    static void testContactLookupNoEmplId() {
        Test.startTest();

        String value = null;
        bomgar__BomgarWebEvent__c webEvent = new bomgar__BomgarWebEvent__c();
        webEvent.bomgar__Username__c = 'joetest123123';
        webEvent.bomgar__ExternalKey__c =
            'SFDC:{' +
            '"employeeNumber":"", ' +
            '"description":"Bacon ipsum dolor amet bresaola drumstick leberkas", ' +
            '"asuriteId":"testuser", ' +
            '"externalKey":"Other"}';
        value = BomgarCreateCaseUtil.createCase(webEvent);

        Case testCase = [SELECT Id, ContactId FROM Case WHERE Id = :value];

        Contact testContact = [SELECT Id FROM Contact WHERE ASURite_ID__c = 'testuser'];

        Test.stopTest();

        System.assertEquals(testContact.Id, testCase.ContactId);
    }

    @isTest
    static void testContactLookupNoEmplIdOrASURite() {
        Test.startTest();
        Contact testContact = ContactService.createTestContact();
        testContact.EMPLID__c = '';
        testContact.ASURite_ID__c = '';
        testContact.FirstName = 'nord';
        testcontact.LastName = 'berg';
        testContact.Email = testContact.FirstName + '.' + testContact.LastName + '@asu.edu';

        String value = null;
        bomgar__BomgarWebEvent__c webEvent = new bomgar__BomgarWebEvent__c();
        webEvent.bomgar__Username__c = 'joetest123123';
        webEvent.bomgar__ExternalKey__c =
            'SFDC:{' +
            '"employeeNumber":"", ' +
            '"description":"Bacon ipsum dolor amet bresaola drumstick leberkas", ' +
            '"asuriteId":"", ' +
            '"externalKey":"Other"}';
        value = BomgarCreateCaseUtil.createCase(webEvent);

        Case testCase = [SELECT Id, ContactId FROM Case WHERE Id = :value];

        Test.stopTest();

        System.assertEquals(testContact.Email, 'nord.berg@asu.edu');
    }

    @isTest
    static void testAssignCase() {
        Test.startTest();

        String value = null;
        BomgarCreateCaseUtil.assignCase('lsid', 'caseId');

        Test.stopTest();
    }

    @isTest
    static void testLookupUserByFederationId() {
        Test.startTest();

        User testUser = BomgarCreateCaseUtil.lookupUserByFederationId('testuser');

        Test.stopTest();

        System.assertNotEquals(null, testUser);
    }

    @isTest
    static void testlookupUserByBomgarUsername() {
        Test.startTest();

        User testUser = BomgarCreateCaseUtil.lookupUserByBomgarUsername('testuser');

        Test.stopTest();

        System.assertNotEquals(null, testUser);
    }

    @isTest
    static void testGetOwnerIdBySessionId() {
        Bomgar__BomgarSession__c bs = new Bomgar__BomgarSession__c(bomgar__Duration__c = '00:00:30');

        insert bs;

        Bomgar__Participant__c bp = new Bomgar__Participant__c(
            bomgar__Username__c = 'testuser',
            bomgar__IsPrimary__c = true,
            bomgar__ParticipantType__c = 'Representative',
            bomgar__BomgarSession__c = bs.Id
        );

        insert bp;

        Test.startTest();

        String value = null;

        bomgar__BomgarWebEvent__c webEvent = new bomgar__BomgarWebEvent__c();
        webEvent.bomgar__Username__c = 'joetest123123';
        webEvent.bomgar__ExternalKey__c =
            'SFDC:{' +
            '"employeeNumber":"1231231231", ' +
            '"description":"Bacon ipsum dolor amet bresaola drumstick leberkas", ' +
            '"asuriteId":"testc", ' +
            '"externalKey":"Other"}';
        value = BomgarCreateCaseUtil.createCase(webEvent);

        Id testId = BomgarCreateCaseUtil.getOwnerIdBySessionId(bs.Id);

        Test.stopTest();

        System.assertNotEquals(null, testId);
    }

    @isTest
    static void testBBChatCaseCreationNoFullName() {
        // This test has an asuriteId passed in the external key
        // however, it only has a first name.
        Test.startTest();

        String value = null;
        bomgar__BomgarWebEvent__c webEvent = new bomgar__BomgarWebEvent__c();
        webEvent.bomgar__Username__c = 'joetest123123';
        webEvent.bomgar__ExternalKey__c =
            'SFDC:{' +
            '"employeeNumber":"", ' +
            '"description":"SPAM: SPAM: How can I reattempt an assessment?' +
            '----------------- User Details-----------------' +
            'ASURITE ID: testyo_@ce.asu.edu' +
            'Full Name: ' +
            'Course Role: NO ROLE FOUND' +
            'Course ID: @X@course.id@X@' +
            'Course Name: @X@course.course_name@X@", ' +
            '"asuriteId":"testyo_@ce.asu.edu", ' +
            '"externalKey":"BB"}';
        value = BomgarCreateCaseUtil.createCase(webEvent);

        Case testCase = [SELECT Id, ContactId, Description FROM Case WHERE Id = :value];

        Contact testContact = [SELECT Id, FirstName, LastName FROM Contact WHERE Id = :testCase.ContactId];

        Test.stopTest();

        System.assertNotEquals(null, testCase.ContactId);
        System.assertEquals('BomgarError', testContact.FirstName);
        System.assertEquals('testyo', testContact.LastName);
    }

    @isTest
    static void testBBChatCaseCreation() {
        // This test passes no asuriteId in the external key
        // but does pass one, including full name, in the description for parsing.
        Test.startTest();

        String value = null;
        bomgar__BomgarWebEvent__c webEvent = new bomgar__BomgarWebEvent__c();
        webEvent.bomgar__Username__c = 'joetest123123';
        webEvent.bomgar__ExternalKey__c =
            'SFDC:{' +
            '"employeeNumber":"", ' +
            '"description":"SPAM: SPAM: How can I reattempt an assessment?' +
            '----------------- User Details-----------------' +
            'ASURITE ID: testyo_@ce.asu.edu' +
            'Full Name: Test Guy' +
            'Course Role: NO ROLE FOUND' +
            'Course ID: @X@course.id@X@' +
            'Course Name: @X@course.course_name@X@", ' +
            '"asuriteId":"", ' +
            '"externalKey":"BB"}';
        value = BomgarCreateCaseUtil.createCase(webEvent);

        Case testCase = [SELECT Id, ContactId FROM Case WHERE Id = :value];

        Test.stopTest();

        System.assertNotEquals(null, testCase.ContactId);
    }

    @isTest
    static void testBBChatNoASURITEError() {
        // This test passes no asuriteId in the external key
        // but does pass one, including full name, in the description for parsing.
        Test.startTest();

        String value = null;
        bomgar__BomgarWebEvent__c webEvent = new bomgar__BomgarWebEvent__c();
        webEvent.bomgar__Username__c = 'joetest123123';
        webEvent.bomgar__ExternalKey__c =
            'SFDC:{' +
            '"employeeNumber":"", ' +
            '"description":"SPAM: SPAM: How can I reattempt an assessment?' +
            '----------------- User Details-----------------' +
            'ASURITE ID: ' +
            'Full Name: Test Guy' +
            'Course Role: NO ROLE FOUND' +
            'Course ID: @X@course.id@X@' +
            'Course Name: @X@course.course_name@X@", ' +
            '"asuriteId":"", ' +
            '"externalKey":"BB"}';
        value = BomgarCreateCaseUtil.createCase(webEvent);

        Case testCase = [SELECT Id, ContactId, Reason FROM Case WHERE Id = :value];

        Test.stopTest();

        System.assertEquals(null, testCase.ContactId);
        System.assertEquals('Bomgar Error', testCase.Reason);
    }
}
