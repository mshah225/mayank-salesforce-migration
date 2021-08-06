@isTest
public with sharing class ListViewControllerTest {
    @TestSetup
    private static void setup() {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 3; i++) {
            contacts.add(new Contact(FirstName = 'John' + i, LastName = 'TestContact'));
        }
        for (Integer i = 0; i < 50; i++) {
            contacts.add(new Contact(FirstName = 'Robert' + i, LastName = 'TestContact'));
        }
        for (Integer i = 0; i < 25; i++) {
            contacts.add(new Contact(FirstName = 'Samantha' + i, LastName = 'TestContact'));
        }
        for (Integer i = 0; i < 5; i++) {
            for (Integer j = 0; j < 3; j++) {
                contacts.add(new Contact(FirstName = 'Alexa' + i, LastName = 'TestContact' + j));
            }
        }
        insert contacts;
    }

    @isTest
    private static void testQuery() {
        List<Contact> allContacts = [SELECT Id FROM Contact WHERE FirstName LIKE 'John%' ORDER BY FirstName ASC];

        ListViewController controller = new ListViewController();

        Test.startTest();
        controller.queryAttr = 'SELECT Id FROM Contact WHERE FirstName LIKE \'John%\' ORDER BY FirstName ASC';
        Test.stopTest();

        System.assertEquals(3, controller.recordList.size());
        for (Integer i = 0; i < 3; i++) {
            System.assertEquals(allContacts[i].Id, controller.recordList[i].Id);
        }
    }

    @isTest
    private static void testPageSize() {
        List<Contact> allContacts = [SELECT Id FROM Contact WHERE FirstName LIKE 'Robert%' ORDER BY FirstName ASC];

        ListViewController controller = new ListViewController();

        Test.startTest();
        controller.queryAttr = 'SELECT Id FROM Contact WHERE FirstName LIKE \'Robert%\' ORDER BY FirstName ASC';
        Test.stopTest();

        System.assertEquals(25, controller.recordList.size());
        for (Integer i = 0; i < 25; i++) {
            System.assertEquals(allContacts[i].Id, controller.recordList[i].Id);
        }

        // Test.startTest();
        controller.pageSize = 50;
        // Test.stopTest();

        System.assertEquals(50, controller.recordList.size());
        for (Integer i = 0; i < 50; i++) {
            System.assertEquals(allContacts[i].Id, controller.recordList[i].Id);
        }
    }

    @isTest
    private static void testSorting() {
        List<Contact> allContactsAsc = [SELECT Id FROM Contact WHERE FirstName LIKE 'Samantha%' ORDER BY FirstName ASC];
        List<Contact> allContactsDesc = new List<Contact>();
        for (Integer i = allContactsAsc.size() - 1; i >= 0; i--) {
            allContactsDesc.add(allContactsAsc[i]);
        }

        ListViewController controller = new ListViewController();

        Test.startTest();
        controller.queryAttr = 'SELECT Id FROM Contact WHERE FirstName LIKE \'Samantha%\'';
        controller.sortDir = 'ASC';
        controller.sortField = 'FirstName';
        Test.stopTest();

        System.assertEquals(25, controller.recordList.size());
        for (Integer i = 0; i < 25; i++) {
            System.assertEquals(allContactsAsc[i].Id, controller.recordList[i].Id);
        }

        // Test.startTest();
        controller.sortDir = 'ASC'; // Set to ASC - so it flips to DESC when setting sortField
        controller.sortField = 'FirstName';
        // Test.stopTest();

        System.assertEquals(25, controller.recordList.size());
        for (Integer i = 0; i < 25; i++) {
            System.assertEquals(allContactsDesc[i].Id, controller.recordList[i].Id);
        }

        // Test.startTest();
        controller.sortDir = 'DESC'; // Set to DESC - so it flips to ASC when setting sortField
        controller.sortField = 'FirstName';
        // Test.stopTest();

        System.assertEquals(25, controller.recordList.size());
        for (Integer i = 0; i < 25; i++) {
            System.assertEquals(allContactsAsc[i].Id, controller.recordList[i].Id);
        }
    }

    @isTest
    private static void testNextPrevPages() {
        List<Contact> allContacts = [SELECT Id FROM Contact WHERE FirstName LIKE 'Robert%' ORDER BY FirstName ASC];

        ListViewController controller = new ListViewController();

        Test.startTest();
        controller.queryAttr = 'SELECT Id FROM Contact WHERE FirstName LIKE \'Robert%\' ORDER BY FirstName ASC';
        Test.stopTest();

        System.assertEquals(25, controller.recordList.size());
        for (Integer i = 0; i < 25; i++) {
            System.assertEquals(allContacts[i].Id, controller.recordList[i].Id);
        }

        // Test.startTest();
        controller.setConNext();
        // Test.stopTest();

        System.assertEquals(25, controller.recordList.size());
        for (Integer i = 0; i < 25; i++) {
            System.assertEquals(allContacts[25 + i].Id, controller.recordList[i].Id);
        }

        // Test.startTest();
        controller.setConPrev();
        // Test.stopTest();

        System.assertEquals(25, controller.recordList.size());
        for (Integer i = 0; i < 25; i++) {
            System.assertEquals(allContacts[i].Id, controller.recordList[i].Id);
        }
    }

    @isTest
    private static void testRefresh() {
        List<Contact> allContacts = [SELECT Id FROM Contact WHERE FirstName LIKE 'John%' ORDER BY FirstName ASC];

        ListViewController controller = new ListViewController();

        Test.startTest();
        controller.queryAttr = 'SELECT Id FROM Contact WHERE FirstName LIKE \'John%\' ORDER BY FirstName ASC';
        Test.stopTest();

        System.assertEquals(3, controller.recordList.size());
        for (Integer i = 0; i < 3; i++) {
            System.assertEquals(allContacts[i].Id, controller.recordList[i].Id);
        }

        Contact c = new Contact(FirstName = 'John9', LastName = 'TestContact');
        insert c;
        allContacts.add(c);
        // Test.startTest();
        controller.refreshList = true;
        // Test.stopTest();

        System.assertEquals(4, controller.recordList.size());
        for (Integer i = 0; i < 4; i++) {
            System.assertEquals(allContacts[i].Id, controller.recordList[i].Id);
        }
    }

    @isTest
    private static void testExtractingSortDir() {
        ListViewController controller = null;

        controller = new ListViewController();
        controller.queryAttr = 'SELECT Id FROM Contact WHERE FirstName LIKE \'John%\' ORDER BY FirstName ASC';
        System.assertEquals('ASC', controller.sortDir);
        System.assertEquals('FirstName', controller.sortField);

        controller = new ListViewController();
        controller.queryAttr = 'SELECT Id FROM Contact WHERE FirstName LIKE \'John%\' ORDER BY FirstName DESC';
        System.assertEquals('DESC', controller.sortDir);

        controller = new ListViewController();
        controller.queryAttr = 'SELECT Id FROM Contact WHERE FirstName LIKE \'John%\'';
        System.assertEquals('ASC', controller.sortDir);

        controller = new ListViewController();
        System.assertEquals('ASC', controller.sortDir);
    }

    @isTest
    private static void testMultiFieldSort() {
        List<Contact> allContacts = [
            SELECT Id
            FROM Contact
            WHERE FirstName LIKE 'Alexa%'
            ORDER BY FirstName ASC NULLS LAST, LastName ASC NULLS LAST
        ];

        ListViewController controller = new ListViewController();

        Test.startTest();
        controller.queryAttr = 'SELECT Id FROM Contact WHERE FirstName LIKE \'Alexa%\'';
        controller.sortDir = 'ASC';
        controller.sortField = 'FirstName,LastName';
        Test.stopTest();

        System.assertEquals(15, controller.recordList.size());
        for (Integer i = 0; i < 15; i++) {
            System.assertEquals(allContacts[i].Id, controller.recordList[i].Id);
        }
    }
}
