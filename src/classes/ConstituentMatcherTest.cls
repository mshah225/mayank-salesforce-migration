@isTest
public with sharing class ConstituentMatcherTest {

    private static String getFirstNameWildcardForTests(String firstName) {
        String firstNameWildcard;
        if (firstName.length() > 0) {
            firstNameWildcard = firstName.substring(0, firstName.length()) + '%';
        }
        return firstNameWildcard;
    }

    @isTest
    private static void testMatcherWithSingleConstituentWithEmplid() {
        // Create a test contact
        ContactFactory.DefaultContact defaultContactCreator = new ContactFactory.DefaultContact();
        Contact originalContact = (Contact) defaultContactCreator.create(1)[0];
        insert originalContact;

        // Create map of field values from contact to search on
        Map<String, String> detailFieldsMap = new Map<String, String>();
        detailFieldsMap.put('emplid', originalContact.EMPLID__c);
        detailFieldsMap.put('firstName', originalContact.FirstName);
        detailFieldsMap.put('lastName', originalContact.LastName);

        // Pass field map to consituent detail and return detail
        ConstituentDetail originalContactDetail = new ConstituentDetail(detailFieldsMap);

        // Pass detail to constituent matcher and return matched contact if any
        ConstituentMatcher matcher = new ConstituentMatcher(originalContactDetail);
        matcher.searchContacts();
        List<ConstituentDetail> matchedDetailsWithContacts = matcher.getListOfConstituentsWithMatches();

        // Force grab first list item since we're expecting only one
        ConstituentDetail matchedDetailWithContact = matchedDetailsWithContacts[0];

        // Validate that the returned detail with contact ID and the original contact ID are the same
        System.assertEquals(originalContact.Id, matchedDetailWithContact.contactId);
    }

    @isTest
    private static void testMatcherWithSingleConstituentWithAsuriteId() {
        // Create a test contact
        ContactFactory.DefaultContact defaultContactCreator = new ContactFactory.DefaultContact();
        Contact originalContact = (Contact) defaultContactCreator.create(1)[0];
        originalContact.ASURITE_ID__c = 'tcontact10';
        insert originalContact;

        // Create map of field values from contact to search on
        Map<String, String> detailFieldsMap = new Map<String, String>();
        detailFieldsMap.put('asuriteId', originalContact.ASURITE_ID__c);
        detailFieldsMap.put('firstName', originalContact.FirstName);
        detailFieldsMap.put('lastName', originalContact.LastName);

        // Pass field map to consituent detail and return detail
        ConstituentDetail originalContactDetail = new ConstituentDetail(detailFieldsMap);

        // Pass detail to constituent matcher and return matched contact if any
        ConstituentMatcher matcher = new ConstituentMatcher(originalContactDetail);
        matcher.searchContacts();
        List<ConstituentDetail> matchedDetailsWithContacts = matcher.getListOfConstituentsWithMatches();

        // Force grab first list item since we're expecting only one
        ConstituentDetail matchedDetailWithContact = matchedDetailsWithContacts[0];

        // Validate that the returned detail with contact ID and the original contact ID are the same
        System.assertEquals(originalContact.Id, matchedDetailWithContact.contactId);
    }

    @isTest
    private static void testMatcherWithSingleConstituentWithFirstNameAndEmail() {
        // Create a test contact
        ContactFactory.DefaultContact defaultContactCreator = new ContactFactory.DefaultContact();
        Contact originalContact = (Contact) defaultContactCreator.create(1)[0];
        insert originalContact;

        // Create map of field values from contact to search on
        Map<String, String> detailFieldsMap = new Map<String, String>();
        detailFieldsMap.put('email', originalContact.Email);
        detailFieldsMap.put('firstName', originalContact.FirstName);
        detailFieldsMap.put('lastName', originalContact.LastName);

        // Pass field map to consituent detail and return detail
        ConstituentDetail originalContactDetail = new ConstituentDetail(detailFieldsMap);

        // Pass detail to constituent matcher and return matched contact if any
        ConstituentMatcher matcher = new ConstituentMatcher(originalContactDetail);
        matcher.searchContacts();
        List<ConstituentDetail> matchedDetailsWithContacts = matcher.getListOfConstituentsWithMatches();

        // Force grab first list item since we're expecting only one
        ConstituentDetail matchedDetailWithContact = matchedDetailsWithContacts[0];

        // Validate that the returned detail with contact ID and the original contact ID are the same
        System.assertEquals(originalContact.Id, matchedDetailWithContact.contactId);
    }

    @isTest
    private static void testMatcherWithSingleConstituentWithFirstNameAndLeadEmail() {
        // Create a test contact
        ContactFactory.DefaultContact defaultContactCreator = new ContactFactory.DefaultContact();
        Contact originalContact = (Contact) defaultContactCreator.create(1)[0];
        originalContact.Lead_Email__c = originalContact.Email;
        originalContact.Email = '';
        insert originalContact;

        // Create map of field values from contact to search on
        Map<String, String> detailFieldsMap = new Map<String, String>();
        detailFieldsMap.put('email', originalContact.Lead_Email__c);
        detailFieldsMap.put('firstName', originalContact.FirstName);
        detailFieldsMap.put('lastName', originalContact.LastName);

        // Pass field map to consituent detail and return detail
        ConstituentDetail originalContactDetail = new ConstituentDetail(detailFieldsMap);

        // Pass detail to constituent matcher and return matched contact if any
        ConstituentMatcher matcher = new ConstituentMatcher(originalContactDetail);
        matcher.searchContacts();
        List<ConstituentDetail> matchedDetailsWithContacts = matcher.getListOfConstituentsWithMatches();

        // Force grab first list item since we're expecting only one
        ConstituentDetail matchedDetailWithContact = matchedDetailsWithContacts[0];

        // Validate that the returned detail with contact ID and the original contact ID are the same
        System.assertEquals(originalContact.Id, matchedDetailWithContact.contactId);
    }

    @isTest
    private static void testMatcherWithSingleConstituentWithFirstNameAndLeadSecondaryEmail() {
        // Create a test contact
        ContactFactory.DefaultContact defaultContactCreator = new ContactFactory.DefaultContact();
        Contact originalContact = (Contact) defaultContactCreator.create(1)[0];
        originalContact.Lead_Secondary_Email__c = originalContact.Email;
        originalContact.Email = '';
        insert originalContact;

        // Create map of field values from contact to search on
        Map<String, String> detailFieldsMap = new Map<String, String>();
        detailFieldsMap.put('email', originalContact.Lead_Secondary_Email__c);
        detailFieldsMap.put('firstName', originalContact.FirstName);
        detailFieldsMap.put('lastName', originalContact.LastName);

        // Pass field map to consituent detail and return detail
        ConstituentDetail originalContactDetail = new ConstituentDetail(detailFieldsMap);

        // Pass detail to constituent matcher and return matched contact if any
        ConstituentMatcher matcher = new ConstituentMatcher(originalContactDetail);
        matcher.searchContacts();
        List<ConstituentDetail> matchedDetailsWithContacts = matcher.getListOfConstituentsWithMatches();

        // Force grab first list item since we're expecting only one
        ConstituentDetail matchedDetailWithContact = matchedDetailsWithContacts[0];

        // Validate that the returned detail with contact ID and the original contact ID are the same
        System.assertEquals(originalContact.Id, matchedDetailWithContact.contactId);
    }

    @isTest
    private static void testMatcherWithSingleConstituentWithFirstNameAndPersonalEmail() {
        // Create a test contact
        ContactFactory.DefaultContact defaultContactCreator = new ContactFactory.DefaultContact();
        Contact originalContact = (Contact) defaultContactCreator.create(1)[0];
        originalContact.Personal_Email__c = originalContact.Email;
        originalContact.Email = '';
        insert originalContact;

        // Create map of field values from contact to search on
        Map<String, String> detailFieldsMap = new Map<String, String>();
        detailFieldsMap.put('email', originalContact.Personal_Email__c);
        detailFieldsMap.put('firstName', originalContact.FirstName);
        detailFieldsMap.put('lastName', originalContact.LastName);

        // Pass field map to consituent detail and return detail
        ConstituentDetail originalContactDetail = new ConstituentDetail(detailFieldsMap);

        // Pass detail to constituent matcher and return matched contact if any
        ConstituentMatcher matcher = new ConstituentMatcher(originalContactDetail);
        matcher.searchContacts();
        List<ConstituentDetail> matchedDetailsWithContacts = matcher.getListOfConstituentsWithMatches();

        // Force grab first list item since we're expecting only one
        ConstituentDetail matchedDetailWithContact = matchedDetailsWithContacts[0];

        // Validate that the returned detail with contact ID and the original contact ID are the same
        System.assertEquals(originalContact.Id, matchedDetailWithContact.contactId);
    }

    @isTest
    private static void testMatcherWithSingleConstituentWithFirstNameAndAsuGmail() {
        // Create a test contact
        ContactFactory.DefaultContact defaultContactCreator = new ContactFactory.DefaultContact();
        Contact originalContact = (Contact) defaultContactCreator.create(1)[0];
        originalContact.ASU_Gmail__c = originalContact.Email;
        originalContact.Email = '';
        insert originalContact;

        // Create map of field values from contact to search on
        Map<String, String> detailFieldsMap = new Map<String, String>();
        detailFieldsMap.put('email', originalContact.ASU_Gmail__c);
        detailFieldsMap.put('firstName', originalContact.FirstName);
        detailFieldsMap.put('lastName', originalContact.LastName);

        // Pass field map to consituent detail and return detail
        ConstituentDetail originalContactDetail = new ConstituentDetail(detailFieldsMap);

        // Pass detail to constituent matcher and return matched contact if any
        ConstituentMatcher matcher = new ConstituentMatcher(originalContactDetail);
        matcher.searchContacts();
        List<ConstituentDetail> matchedDetailsWithContacts = matcher.getListOfConstituentsWithMatches();

        // Force grab first list item since we're expecting only one
        ConstituentDetail matchedDetailWithContact = matchedDetailsWithContacts[0];

        // Validate that the returned detail with contact ID and the original contact ID are the same
        System.assertEquals(originalContact.Id, matchedDetailWithContact.contactId);
    }

    @isTest
    private static void testMatcherWithSingleConstituentWithFirstNameAndEpoEmail() {
        // Create a test contact
        ContactFactory.DefaultContact defaultContactCreator = new ContactFactory.DefaultContact();
        Contact originalContact = (Contact) defaultContactCreator.create(1)[0];
        originalContact.EPO_Email__c = originalContact.Email;
        originalContact.Email = '';
        insert originalContact;

        // Create map of field values from contact to search on
        Map<String, String> detailFieldsMap = new Map<String, String>();
        detailFieldsMap.put('email', originalContact.EPO_Email__c);
        detailFieldsMap.put('firstName', originalContact.FirstName);
        detailFieldsMap.put('lastName', originalContact.LastName);

        // Pass field map to consituent detail and return detail
        ConstituentDetail originalContactDetail = new ConstituentDetail(detailFieldsMap);

        // Pass detail to constituent matcher and return matched contact if any
        ConstituentMatcher matcher = new ConstituentMatcher(originalContactDetail);
        matcher.searchContacts();
        List<ConstituentDetail> matchedDetailsWithContacts = matcher.getListOfConstituentsWithMatches();

        // Force grab first list item since we're expecting only one
        ConstituentDetail matchedDetailWithContact = matchedDetailsWithContacts[0];

        // Validate that the returned detail with contact ID and the original contact ID are the same
        System.assertEquals(originalContact.Id, matchedDetailWithContact.contactId);
    }

    @isTest
    private static void testMatcherWithSingleConstituentWithFirstNameAndAsuEmail() {
        // Create a test contact
        ContactFactory.DefaultContact defaultContactCreator = new ContactFactory.DefaultContact();
        Contact originalContact = (Contact) defaultContactCreator.create(1)[0];
        originalContact.ASU_Email__c = originalContact.Email;
        originalContact.Email = '';
        insert originalContact;

        // Create map of field values from contact to search on
        Map<String, String> detailFieldsMap = new Map<String, String>();
        detailFieldsMap.put('email', originalContact.ASU_Email__c);
        detailFieldsMap.put('firstName', originalContact.FirstName);
        detailFieldsMap.put('lastName', originalContact.LastName);

        // Pass field map to consituent detail and return detail
        ConstituentDetail originalContactDetail = new ConstituentDetail(detailFieldsMap);

        // Pass detail to constituent matcher and return matched contact if any
        ConstituentMatcher matcher = new ConstituentMatcher(originalContactDetail);
        matcher.searchContacts();
        List<ConstituentDetail> matchedDetailsWithContacts = matcher.getListOfConstituentsWithMatches();

        // Force grab first list item since we're expecting only one
        ConstituentDetail matchedDetailWithContact = matchedDetailsWithContacts[0];

        // Validate that the returned detail with contact ID and the original contact ID are the same
        System.assertEquals(originalContact.Id, matchedDetailWithContact.contactId);
    }

    @isTest
    private static void testMatcherWithSingleConstituentWithFirstNameWildcardAndEmail() {
        // Create a test contact
        ContactFactory.DefaultContact defaultContactCreator = new ContactFactory.DefaultContact();
        Contact originalContact = (Contact) defaultContactCreator.create(1)[0];
        insert originalContact;

        String firstNameWildcard = getFirstNameWildcardForTests(originalContact.FirstName);

        // Create map of field values from contact to search on
        Map<String, String> detailFieldsMap = new Map<String, String>();
        detailFieldsMap.put('email', originalContact.Email);
        detailFieldsMap.put('firstName', firstNameWildcard);
        detailFieldsMap.put('lastName', originalContact.LastName);

        // Pass field map to consituent detail and return detail
        ConstituentDetail originalContactDetail = new ConstituentDetail(detailFieldsMap);

        // Pass detail to constituent matcher and return matched contact if any
        ConstituentMatcher matcher = new ConstituentMatcher(originalContactDetail);
        matcher.searchContacts();
        List<ConstituentDetail> matchedDetailsWithContacts = matcher.getListOfConstituentsWithMatches();

        // Force grab first list item since we're expecting only one
        ConstituentDetail matchedDetailWithContact = matchedDetailsWithContacts[0];

        // Validate that the returned detail with contact ID and the original contact ID are the same
        System.assertEquals(originalContact.Id, matchedDetailWithContact.contactId);
    }

    @isTest
    private static void testMatcherWithSingleConstituentWithFirstNameWildcardAndLeadEmail() {
        // Create a test contact
        ContactFactory.DefaultContact defaultContactCreator = new ContactFactory.DefaultContact();
        Contact originalContact = (Contact) defaultContactCreator.create(1)[0];
        originalContact.Lead_Email__c = originalContact.Email;
        originalContact.Email = '';
        insert originalContact;

        String firstNameWildcard = getFirstNameWildcardForTests(originalContact.FirstName);

        // Create map of field values from contact to search on
        Map<String, String> detailFieldsMap = new Map<String, String>();
        detailFieldsMap.put('email', originalContact.Lead_Email__c);
        detailFieldsMap.put('firstName', firstNameWildcard);
        detailFieldsMap.put('lastName', originalContact.LastName);

        // Pass field map to consituent detail and return detail
        ConstituentDetail originalContactDetail = new ConstituentDetail(detailFieldsMap);

        // Pass detail to constituent matcher and return matched contact if any
        ConstituentMatcher matcher = new ConstituentMatcher(originalContactDetail);
        matcher.searchContacts();
        List<ConstituentDetail> matchedDetailsWithContacts = matcher.getListOfConstituentsWithMatches();

        // Force grab first list item since we're expecting only one
        ConstituentDetail matchedDetailWithContact = matchedDetailsWithContacts[0];

        // Validate that the returned detail with contact ID and the original contact ID are the same
        System.assertEquals(originalContact.Id, matchedDetailWithContact.contactId);
    }

    @isTest
    private static void testMatcherWithSingleConstituentWithFirstNameWildcardAndLeadSecondaryEmail() {
        // Create a test contact
        ContactFactory.DefaultContact defaultContactCreator = new ContactFactory.DefaultContact();
        Contact originalContact = (Contact) defaultContactCreator.create(1)[0];
        originalContact.Lead_Secondary_Email__c = originalContact.Email;
        originalContact.Email = '';
        insert originalContact;

        String firstNameWildcard = getFirstNameWildcardForTests(originalContact.FirstName);

        // Create map of field values from contact to search on
        Map<String, String> detailFieldsMap = new Map<String, String>();
        detailFieldsMap.put('email', originalContact.Lead_Secondary_Email__c);
        detailFieldsMap.put('firstName', firstNameWildcard);
        detailFieldsMap.put('lastName', originalContact.LastName);

        // Pass field map to consituent detail and return detail
        ConstituentDetail originalContactDetail = new ConstituentDetail(detailFieldsMap);

        // Pass detail to constituent matcher and return matched contact if any
        ConstituentMatcher matcher = new ConstituentMatcher(originalContactDetail);
        matcher.searchContacts();
        List<ConstituentDetail> matchedDetailsWithContacts = matcher.getListOfConstituentsWithMatches();

        // Force grab first list item since we're expecting only one
        ConstituentDetail matchedDetailWithContact = matchedDetailsWithContacts[0];

        // Validate that the returned detail with contact ID and the original contact ID are the same
        System.assertEquals(originalContact.Id, matchedDetailWithContact.contactId);
    }

    @isTest
    private static void testMatcherWithSingleConstituentWithFirstNameWildcardAndPersonalEmail() {
        // Create a test contact
        ContactFactory.DefaultContact defaultContactCreator = new ContactFactory.DefaultContact();
        Contact originalContact = (Contact) defaultContactCreator.create(1)[0];
        originalContact.Personal_Email__c = originalContact.Email;
        originalContact.Email = '';
        insert originalContact;

        String firstNameWildcard = getFirstNameWildcardForTests(originalContact.FirstName);

        // Create map of field values from contact to search on
        Map<String, String> detailFieldsMap = new Map<String, String>();
        detailFieldsMap.put('email', originalContact.Personal_Email__c);
        detailFieldsMap.put('firstName', firstNameWildcard);
        detailFieldsMap.put('lastName', originalContact.LastName);

        // Pass field map to consituent detail and return detail
        ConstituentDetail originalContactDetail = new ConstituentDetail(detailFieldsMap);

        // Pass detail to constituent matcher and return matched contact if any
        ConstituentMatcher matcher = new ConstituentMatcher(originalContactDetail);
        matcher.searchContacts();
        List<ConstituentDetail> matchedDetailsWithContacts = matcher.getListOfConstituentsWithMatches();

        // Force grab first list item since we're expecting only one
        ConstituentDetail matchedDetailWithContact = matchedDetailsWithContacts[0];

        // Validate that the returned detail with contact ID and the original contact ID are the same
        System.assertEquals(originalContact.Id, matchedDetailWithContact.contactId);
    }

    @isTest
    private static void testMatcherWithSingleConstituentWithFirstNameWildcardAndAsuGmail() {
        // Create a test contact
        ContactFactory.DefaultContact defaultContactCreator = new ContactFactory.DefaultContact();
        Contact originalContact = (Contact) defaultContactCreator.create(1)[0];
        originalContact.ASU_Gmail__c = originalContact.Email;
        originalContact.Email = '';
        insert originalContact;

        String firstNameWildcard = getFirstNameWildcardForTests(originalContact.FirstName);

        // Create map of field values from contact to search on
        Map<String, String> detailFieldsMap = new Map<String, String>();
        detailFieldsMap.put('email', originalContact.ASU_Gmail__c);
        detailFieldsMap.put('firstName', firstNameWildcard);
        detailFieldsMap.put('lastName', originalContact.LastName);

        // Pass field map to consituent detail and return detail
        ConstituentDetail originalContactDetail = new ConstituentDetail(detailFieldsMap);

        // Pass detail to constituent matcher and return matched contact if any
        ConstituentMatcher matcher = new ConstituentMatcher(originalContactDetail);
        matcher.searchContacts();
        List<ConstituentDetail> matchedDetailsWithContacts = matcher.getListOfConstituentsWithMatches();

        // Force grab first list item since we're expecting only one
        ConstituentDetail matchedDetailWithContact = matchedDetailsWithContacts[0];

        // Validate that the returned detail with contact ID and the original contact ID are the same
        System.assertEquals(originalContact.Id, matchedDetailWithContact.contactId);
    }

    @isTest
    private static void testMatcherWithSingleConstituentWithFirstNameWildcardAndEpoEmail() {
        // Create a test contact
        ContactFactory.DefaultContact defaultContactCreator = new ContactFactory.DefaultContact();
        Contact originalContact = (Contact) defaultContactCreator.create(1)[0];
        originalContact.EPO_Email__c = originalContact.Email;
        originalContact.Email = '';
        insert originalContact;

        String firstNameWildcard = getFirstNameWildcardForTests(originalContact.FirstName);

        // Create map of field values from contact to search on
        Map<String, String> detailFieldsMap = new Map<String, String>();
        detailFieldsMap.put('email', originalContact.EPO_Email__c);
        detailFieldsMap.put('firstName', firstNameWildcard);
        detailFieldsMap.put('lastName', originalContact.LastName);

        // Pass field map to consituent detail and return detail
        ConstituentDetail originalContactDetail = new ConstituentDetail(detailFieldsMap);

        // Pass detail to constituent matcher and return matched contact if any
        ConstituentMatcher matcher = new ConstituentMatcher(originalContactDetail);
        matcher.searchContacts();
        List<ConstituentDetail> matchedDetailsWithContacts = matcher.getListOfConstituentsWithMatches();

        // Force grab first list item since we're expecting only one
        ConstituentDetail matchedDetailWithContact = matchedDetailsWithContacts[0];

        // Validate that the returned detail with contact ID and the original contact ID are the same
        System.assertEquals(originalContact.Id, matchedDetailWithContact.contactId);
    }

    @isTest
    private static void testMatcherWithSingleConstituentWithFirstNameWildcardAndAsuEmail() {
        // Create a test contact
        ContactFactory.DefaultContact defaultContactCreator = new ContactFactory.DefaultContact();
        Contact originalContact = (Contact) defaultContactCreator.create(1)[0];
        originalContact.ASU_Email__c = originalContact.Email;
        originalContact.Email = '';
        insert originalContact;

        String firstNameWildcard = getFirstNameWildcardForTests(originalContact.FirstName);

        // Create map of field values from contact to search on
        Map<String, String> detailFieldsMap = new Map<String, String>();
        detailFieldsMap.put('email', originalContact.ASU_Email__c);
        detailFieldsMap.put('firstName', firstNameWildcard);
        detailFieldsMap.put('lastName', originalContact.LastName);

        // Pass field map to consituent detail and return detail
        ConstituentDetail originalContactDetail = new ConstituentDetail(detailFieldsMap);

        // Pass detail to constituent matcher and return matched contact if any
        ConstituentMatcher matcher = new ConstituentMatcher(originalContactDetail);
        matcher.searchContacts();
        List<ConstituentDetail> matchedDetailsWithContacts = matcher.getListOfConstituentsWithMatches();

        // Force grab first list item since we're expecting only one
        ConstituentDetail matchedDetailWithContact = matchedDetailsWithContacts[0];

        // Validate that the returned detail with contact ID and the original contact ID are the same
        System.assertEquals(originalContact.Id, matchedDetailWithContact.contactId);
    }

    @isTest
    private static void testMatcherWithMultipleConstituents() {
        // Create test contacts
        List<Contact> listOfOriginalContacts = new List<Contact>();
        Integer numberOfContactsToCreate = 5;

        for (Integer i = 1; i <= numberOfContactsToCreate; i++) {
            Contact con = new Contact();
            con.FirstName = 'Test' + i;
            con.LastName = 'Contact' + i;
            con.Email = 'test' + i + '@test.com';
            con.EmplId__c = '123456' + i;
            con.ASURITE_ID__c = 'tcontact' + i;
            listOfOriginalContacts.add(con);
        }
        insert listOfOriginalContacts;

        // Create map of field values from contact to search on
        List<ConstituentDetail> listOfConstituents = new List<ConstituentDetail>();
        for (Contact originalContact : listOfOriginalContacts) {
            Map<String, String> detailFieldsMap = new Map<String, String>();
            detailFieldsMap.put('asuriteId', originalContact.ASURITE_ID__c);
            detailFieldsMap.put('email', originalContact.Email);
            detailFieldsMap.put('emplid', originalContact.EMPLID__c);
            detailFieldsMap.put('firstName', originalContact.FirstName);
            detailFieldsMap.put('lastName', originalContact.LastName);
            ConstituentDetail originalContactDetail = new ConstituentDetail(detailFieldsMap);
            listOfConstituents.add(originalContactDetail);
        }

        // Pass constituent details to constituent matcher and return matched contact if any
        ConstituentMatcher matcher = new ConstituentMatcher(listOfConstituents);
        matcher.searchContacts();
        List<ConstituentDetail> matchedDetailsWithContacts = matcher.getListOfConstituentsWithMatches();

        // Validate that the returned detail list contains the same number of inserted contacts
        System.assertEquals(numberOfContactsToCreate, matchedDetailsWithContacts.size());
    }
}