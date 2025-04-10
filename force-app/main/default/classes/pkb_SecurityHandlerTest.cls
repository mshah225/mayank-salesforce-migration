/**
 * Security Manager Test Methods
 */
@isTest
private class pkb_SecurityHandlerTest {
    @isTest
    private static void testSecurityEnabled() {
        Profile[] profileList = [
            SELECT Id, Name
            FROM Profile
            WHERE Name = 'System Administrator' OR Name = 'Standar User'
            LIMIT 2
        ];

        Map<Id, String> profileMap = new Map<Id, String>();

        for (Profile p : profileList) {
            profileMap.put(p.id, p.Name);
        }
        List<User> u = [SELECT id, profileId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        if (
            profileMap.containsKey(UserInfo.getProfileId()) &&
            profileMap.get(UserInfo.getProfileId()) == 'System Administrator'
        ) {
            for (Profile p : profileList) {
                u[0].profileId = p.id;
                update u;
                System.assertEquals(
                    pkb_SecurityHandler.isAccessible(Case.sObjectType),
                    Case.sObjectType.getDescribe().isAccessible()
                );
                System.assertEquals(
                    pkb_SecurityHandler.isCreateable(Case.sObjectType),
                    Case.sObjectType.getDescribe().isCreateable()
                );
                System.assertEquals(
                    pkb_SecurityHandler.isUpdateable(Case.sObjectType),
                    Case.sObjectType.getDescribe().isUpdateable()
                );
                System.assertEquals(
                    pkb_SecurityHandler.isDeletable(Case.sObjectType),
                    Case.sObjectType.getDescribe().isDeletable()
                );

                System.assertEquals(
                    pkb_SecurityHandler.isAccessible(Case.subject),
                    Case.subject.getDescribe().isAccessible()
                );
                System.assertEquals(
                    pkb_SecurityHandler.isCreateable(Case.subject),
                    Case.subject.getDescribe().isCreateable()
                );
                System.assertEquals(
                    pkb_SecurityHandler.isUpdateable(Case.subject),
                    Case.subject.getDescribe().isUpdateable()
                );

                if (Case.sObjectType.getDescribe().isAccessible())
                    pkb_SecurityHandler.canAccess(Case.sObjectType);
                else
                    try {
                        pkb_SecurityHandler.canAccess(Case.sObjectType);
                        System.assert(false);
                    } catch (SecurityException e) {
                    }

                if (Case.sObjectType.getDescribe().isCreateable())
                    pkb_SecurityHandler.canCreate(Case.sObjectType);
                else
                    try {
                        pkb_SecurityHandler.canCreate(Case.sObjectType);
                        System.assert(false);
                    } catch (SecurityException e) {
                    }

                if (Case.sObjectType.getDescribe().isUpdateable())
                    pkb_SecurityHandler.canUpdate(Case.sObjectType);
                else
                    try {
                        pkb_SecurityHandler.canUpdate(Case.sObjectType);
                        System.assert(false);
                    } catch (SecurityException e) {
                    }

                if (Case.sObjectType.getDescribe().isDeletable())
                    pkb_SecurityHandler.canDelete(Case.sObjectType);
                else
                    try {
                        pkb_SecurityHandler.canDelete(Case.sObjectType);
                        System.assert(false);
                    } catch (SecurityException e) {
                    }

                if (Case.subject.getDescribe().isAccessible())
                    pkb_SecurityHandler.canAccess(Case.subject);
                else
                    try {
                        pkb_SecurityHandler.canAccess(Case.subject);
                        System.assert(false);
                    } catch (SecurityException e) {
                    }

                if (Case.subject.getDescribe().isCreateable())
                    pkb_SecurityHandler.canCreate(Case.subject);
                else
                    try {
                        pkb_SecurityHandler.canCreate(Case.subject);
                        System.assert(false);
                    } catch (SecurityException e) {
                    }

                if (Case.subject.getDescribe().isUpdateable())
                    pkb_SecurityHandler.canUpdate(Case.subject);
                else
                    try {
                        pkb_SecurityHandler.canUpdate(Case.subject);
                        System.assert(false);
                    } catch (SecurityException e) {
                    }
            }
        }
    }

    @isTest
    private static void testSecurityDisabled() {
        pkb_SecurityHandler.securityEnabled = false;
        Profile[] profileList = [
            SELECT Id, Name
            FROM Profile
            WHERE Name = 'System Administrator' OR Name = 'Standar User'
            LIMIT 2
        ];

        Map<Id, String> profileMap = new Map<Id, String>();

        for (Profile p : profileList) {
            profileMap.put(p.id, p.Name);
        }
        List<User> u = [SELECT id, profileId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        if (
            profileMap.containsKey(UserInfo.getProfileId()) &&
            profileMap.get(UserInfo.getProfileId()) == 'System Administrator'
        ) {
            for (Profile p : profileList) {
                u[0].profileId = p.id;
                update u;
                System.assertEquals(pkb_SecurityHandler.isAccessible(Case.sObjectType), true);
                System.assertEquals(pkb_SecurityHandler.isCreateable(Case.sObjectType), true);
                System.assertEquals(pkb_SecurityHandler.isUpdateable(Case.sObjectType), true);
                System.assertEquals(pkb_SecurityHandler.isDeletable(Case.sObjectType), true);

                System.assertEquals(pkb_SecurityHandler.isAccessible(Case.subject), true);
                System.assertEquals(pkb_SecurityHandler.isCreateable(Case.subject), true);
                System.assertEquals(pkb_SecurityHandler.isUpdateable(Case.subject), true);

                pkb_SecurityHandler.canAccess(Case.sObjectType);
                pkb_SecurityHandler.canCreate(Case.sObjectType);
                pkb_SecurityHandler.canUpdate(Case.sObjectType);
                pkb_SecurityHandler.canDelete(Case.sObjectType);

                pkb_SecurityHandler.canAccess(Case.subject);
                pkb_SecurityHandler.canCreate(Case.subject);
                pkb_SecurityHandler.canUpdate(Case.subject);

                List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
                fieldList.add(Case.subject);
                pkb_SecurityHandler.toString(fieldList);

                List<Schema.SObjectType> objectTypeList = new List<Schema.SObjectType>();
                objectTypeList.add(Case.sObjectType);
                pkb_SecurityHandler.toString(objectTypeList);
            }
        }
    }

    @isTest
    private static void testIsGuest() {
        User u = [
            SELECT Id
            FROM User
            WHERE
                ProfileId IN (SELECT Id FROM Profile WHERE Name LIKE '%Admin%' AND UserType = 'Standard')
                AND IsActive = TRUE
            LIMIT 1
        ];
        System.runAs(u) {
            system.assertEquals(pkb_SecurityHandler.isGuestUser(), false);
        }
    }

    @isTest
    private static void testSecurityHandler() {
        String msg = '';
        SObjectType caseObjType = Case.sObjectType;
        // Observed bizarre behavior: if first call is false rest will be false
        System.runAs(readOnlyUser()) {
            //create permission
            try {
                pkb_SecurityHandler.canCreate(caseObjType);
            } catch (pkb_SecurityHandler.SecurityException sEx) {
                msg = pkb_SecurityHandler.formatReplace(
                    pkb_SecurityHandler.ERROR_OBJECT_NOT_CREATEABLE,
                    new List<String>{ pkb_SecurityHandler.toString(new List<Schema.SObjectType>{ caseObjType }) }
                );
                system.assertEquals(sEx.getMessage(), msg);
            }
            //update permissions
            try {
                pkb_SecurityHandler.canUpdate(caseObjType);
            } catch (pkb_SecurityHandler.SecurityException sEx) {
                msg = pkb_SecurityHandler.formatReplace(
                    pkb_SecurityHandler.ERROR_OBJECT_NOT_UPDATEABLE,
                    new List<String>{ pkb_SecurityHandler.toString(new List<Schema.SObjectType>{ caseObjType }) }
                );
                system.assertEquals(sEx.getMessage(), msg);
            }
            //delete permission
            try {
                pkb_SecurityHandler.canDelete(caseObjType);
            } catch (pkb_SecurityHandler.SecurityException sEx) {
                msg = pkb_SecurityHandler.formatReplace(
                    pkb_SecurityHandler.ERROR_OBJECT_NOT_DELETABLE,
                    new List<String>{ pkb_SecurityHandler.toString(new List<Schema.SObjectType>{ caseObjType }) }
                );
                system.assertEquals(sEx.getMessage(), msg);
            }
        }
    }

    @isTest
    private static void testQueryFormat() {
        Account account1 = new Account(Name = 'Test Account1');
        Account account2 = new Account(Name = 'Test Account2');
        List<Account> listOfAccountObjects = new List<Account>{ account1, account2 };

        Test.startTest();
        pkb_SecurityHandler.queryFormat(listOfAccountObjects);
        String result = pkb_SecurityHandler.joinList(listOfAccountObjects, '/');
        pkb_SecurityHandler.getKAVPermissions();
        Test.stopTest();

        System.assertEquals(result, 'Account:{Name=Test Account1}/Account:{Name=Test Account2}');
    }

    private static User readOnlyUser() {
        Profile p = [SELECT Id, Name FROM Profile WHERE Name LIKE '%Read Only%'];
        User u = new User(
            UserName = 'asu-test-user2143e@test-company.com',
            FirstName = 'Test-First-Name',
            LastName = 'Test-Last-Name',
            Alias = 'test',
            Email = 'test-user@test-company.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles',
            ProfileId = p.Id
        );
        return u;
    }
}