@isTest
public with sharing class ConstituentMatcherTest {

    @isTest
    private static void testMatcherWithSingleConstituent() {
        // Create a test contact
        Contact originalContact = new Contact(
        	FirstName = 'Tester',
            LastName = 'Contact',
            EMPLID__c = '12345611'
        );
        insert originalContact;

        // Create map of field values from contact to search on
        Map<String, String> detailFieldsMap = new Map<String, String>();
        detailFieldsMap.put('emplid', originalContact.EMPLID__c);
        detailFieldsMap.put('firstName', originalContact.FirstName);
        detailFieldsMap.put('lastName', originalContact.LastName);
        
        // Create new constituent detail from field map values
        ConstituentDetail originalContactDetail = new ConstituentDetail(detailFieldsMap);

        // Pass constituent detail to constituent matcher
        ConstituentMatcher matcher = new ConstituentMatcher(originalContactDetail);
        matcher.searchContacts();
        
        // Return matched contacts
        List<ConstituentDetail> matchedDetailsWithContacts = matcher.getListOfConstituentsWithMatches();

        // Force grab first list item since we're expecting only one contact
        ConstituentDetail matchedDetailWithContact = matchedDetailsWithContacts[0];

        // Validate that the returned detail with contact ID and the original contact ID are the same
        System.assertEquals(originalContact.Id, matchedDetailWithContact.contactId);
    }

    @isTest
    private static void testMatcherWithMultipleConstituents() {
        // Create list for test contacts
        List<Contact> listOfOriginalContacts = new List<Contact>();
        Integer numberOfContactsToCreate = 16;

        for (Integer i = 1; i <= numberOfContactsToCreate; i++) {
            Contact con = new Contact(
            	FirstName = 'Tester' + i,
                LastName = 'Contact' + i
            );

            // Vary details assigned to contacts as we iterate to explore different matching scenarios
            switch on i {
                when 1 {
                    con.EmplId__c = '123456' + i;
                }
                when 2 {
                    con.ASURITE_ID__c = 'tcontact' + i;
                }
                when 3, 10 {
                    con.Email = 'tcontact' + i + '@test.com';
                }
                when 4, 11 {
                    con.Lead_Email__c = 'tcontact' + i + '@test.com';
                }
                when 5, 12 {
                    con.Lead_Secondary_Email__c = 'tcontact' + i + '@test.com';
                }
                when 6, 13 {
                    con.Personal_Email__c = 'tcontact' + i + '@test.com';
                }
                when 7, 14 {
                    con.ASU_Gmail__c = 'tcontact' + i + '@test.com';
                }
                when 8, 15 {
                    con.EPO_Email__c = 'tcontact' + i + '@test.com';
                }
                when 9, 16 {
                    con.ASU_Email__c = 'tcontact' + i + '@test.com';
                }
            }
            listOfOriginalContacts.add(con);
        }

        insert listOfOriginalContacts;

        // Give contact #10-16 a nickname after insertion to test wildcard search
        for (Integer i = 10; i <= numberOfContactsToCreate; i++) {
            listOfOriginalContacts[i - 1].FirstName = 'Test';    
        }

        // Create map of field values from contact to search on
        List<ConstituentDetail> listOfConstituents = new List<ConstituentDetail>();
        for (Contact originalContact : listOfOriginalContacts) {
            Map<String, String> detailFieldsMap = new Map<String, String>();
            detailFieldsMap.put('asuriteId', originalContact.ASURITE_ID__c);
            detailFieldsMap.put('emplid', originalContact.EMPLID__c);
            detailFieldsMap.put('firstName', originalContact.FirstName);
            detailFieldsMap.put('lastName', originalContact.LastName);

            if (originalContact.Email != null) {
                detailFieldsMap.put('email', originalContact.Email);
            } else if (originalContact.Lead_Email__c != null) {
                detailFieldsMap.put('email', originalContact.Lead_Email__c);
            } else if (originalContact.Lead_Secondary_Email__c != null) {
                detailFieldsMap.put('email', originalContact.Lead_Secondary_Email__c);
            } else if (originalContact.Personal_Email__c != null) {
                detailFieldsMap.put('email', originalContact.Personal_Email__c);
            } else if (originalContact.ASU_Gmail__c != null) {
                detailFieldsMap.put('email', originalContact.ASU_Gmail__c);
            } else if (originalContact.EPO_Email__c != null) {
                detailFieldsMap.put('email', originalContact.EPO_Email__c);
            } else if (originalContact.ASU_Email__c != null) {
                detailFieldsMap.put('email', originalContact.ASU_Email__c);
            }
            
            ConstituentDetail originalContactDetail = new ConstituentDetail(detailFieldsMap);
            listOfConstituents.add(originalContactDetail);
        }

        // Pass constituent details to constituent matcher
        ConstituentMatcher matcher = new ConstituentMatcher(listOfConstituents);
        matcher.searchContacts();
        
        // Return matched contacts
        List<ConstituentDetail> matchedDetailsWithContacts = matcher.getListOfConstituentsWithMatches();

        // Validate that the returned detail list contains the same number of inserted contacts
        System.assertEquals(numberOfContactsToCreate, matchedDetailsWithContacts.size());
    }
}