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
        ConstituentMatcher matcher = new ConstituentMatcher(originalContactDetail, 'Contact');
        matcher.searchConstituents();
        
        // Return matched contacts
        List<ConstituentDetail> matchedDetailsWithContacts = matcher.getListOfConstituentsWithMatches();

        // Force grab first list item since we're expecting only one contact
        ConstituentDetail matchedDetailWithContact = matchedDetailsWithContacts[0];

        // Validate that the returned detail with contact ID and the original contact ID are the same
        System.assertEquals(originalContact.Id, matchedDetailWithContact.constituentId);
    }

    @isTest
    private static void testMatcherWithMultipleContactConstituents() {
        // Create list to store contact constituents for matching
        List<ConstituentDetail> listOfConstituents = new List<ConstituentDetail>();

        // Create list for test contacts
        List<Contact> listOfOriginalContacts = new List<Contact>();
        static Integer numberOfContactsToCreate = 16;

        for (Integer i = 1; i <= numberOfContactsToCreate; i++) {
            Contact testContact = new Contact(
            	FirstName = 'Tester' + i,
                LastName = 'Contact' + i
            );

            // Vary details assigned to contacts as we iterate to explore different matching scenarios
            switch on i {
                when 1 {
                    testContact.EmplId__c = '123456' + i;
                }
                when 2 {
                    testContact.ASURITE_ID__c = 'tcontact' + i;
                }
                when 3, 10 {
                    testContact.Email = 'tcontact' + i + '@test.com';
                }
                when 4, 11 {
                    testContact.Lead_Email__c = 'tcontact' + i + '@test.com';
                }
                when 5, 12 {
                    testContact.Lead_Secondary_Email__c = 'tcontact' + i + '@test.com';
                }
                when 6, 13 {
                    testContact.Personal_Email__c = 'tcontact' + i + '@test.com';
                }
                when 7, 14 {
                    testContact.ASU_Gmail__c = 'tcontact' + i + '@test.com';
                }
                when 8, 15 {
                    testContact.EPO_Email__c = 'tcontact' + i + '@test.com';
                }
                when 9, 16 {
                    testContact.ASU_Email__c = 'tcontact' + i + '@test.com';
                }
            }
            listOfOriginalContacts.add(testContact);
        }
        insert listOfOriginalContacts;

        // Give contact #10-16 a nickname after insertion to test partial name search
        for (Integer i = 10; i <= numberOfContactsToCreate; i++) {
            listOfOriginalContacts[i - 1].FirstName = 'Test';    
        }

        // Create map of field values from contact to search on
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
        ConstituentMatcher matcher = new ConstituentMatcher(listOfConstituents, 'Contact');
        matcher.searchConstituents();
        
        // Return matched constituents
        List<ConstituentDetail> matchedDetailsWithConstituents = matcher.getListOfConstituentsWithMatches();

        // Validate that the returned detail list contains the same number of inserted contacts
        System.assertEquals(numberOfContactsToCreate, matchedDetailsWithConstituents.size());
    }

    @isTest
    private static void testMatcherWithMultipleLeadConstituents() {
        // Create list to store lead constituents for matching
        List<ConstituentDetail> listOfConstituents = new List<ConstituentDetail>();

        // Create list for test leads
        List<Lead> listOfOriginalLeads = new List<Lead>();
        Integer numberOfLeadsToCreate = 7;

        for (Integer i = 1; i <= numberOfLeadsToCreate; i++) {
            Lead testLead = new Lead(
            	FirstName = 'Tester' + i,
                LastName = 'Lead' + i
            );

            // Vary details assigned to leads as we iterate to explore different matching scenarios
            switch on i {
                when 1 {
                    testLead.EmplId__c = '123456' + i;
                }
                when 2, 5 {
                    testLead.Email = 'tlead' + i + '@test.com';
                }
                when 3, 6 {
                    testLead.Secondary_Email__c = 'tlead' + i + '@test.com';
                }
                when 4, 7 {
                    testLead.Recruiting_Email__c = 'tlead' + i + '@test.com';
                }
            }
            listOfOriginalLeads.add(testLead);
        }
        insert listOfOriginalLeads;

        // Give lead #5-7 a nickname after insertion to test partial name search
        for (Integer i = 5; i <= numberOfContactsToCreate; i++) {
            listOfOriginalLeads[i - 1].FirstName = 'Test';    
        }

        // Create map of field values from lead to search on
        for (Lead originalLead : listOfOriginalLeads) {
            Map<String, String> detailFieldsMap = new Map<String, String>();
            detailFieldsMap.put('emplid', originalLead.EMPLID__c);
            detailFieldsMap.put('firstName', originalLead.FirstName);
            detailFieldsMap.put('lastName', originalLead.LastName);

            if (originalLead.Email != null) {
                detailFieldsMap.put('email', originalLead.Email);
            } else if (originalLead.Secondary_Email__c != null) {
                detailFieldsMap.put('email', originalLead.Secondary_Email__c);
            } else if (originalLead.Recruiting_Email__c != null) {
                detailFieldsMap.put('email', originalLead.Recruiting_Email__c);
            }
            
            ConstituentDetail originalLeadDetail = new ConstituentDetail(detailFieldsMap);
            listOfConstituents.add(originalLeadDetail);
        }

        // Pass constituent details to constituent matcher
        ConstituentMatcher matcher = new ConstituentMatcher(listOfConstituents, 'Lead');
        matcher.searchConstituents();
        
        // Return matched constituents
        List<ConstituentDetail> matchedDetailsWithConstituents = matcher.getListOfConstituentsWithMatches();

        // Validate that the returned detail list contains the same number of inserted contacts
        System.assertEquals(numberOfLeadsToCreate, matchedDetailsWithConstituents.size());
    }
}