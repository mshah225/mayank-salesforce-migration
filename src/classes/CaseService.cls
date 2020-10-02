public class CaseService {
    /**
     * Returns all the fields on Case in a String
     * @return A string containing all the Case fields
     */
    public static String caseFieldsToString() {
        String caseFields = null;

        Map<String, SObjectField> caseFieldMap = ObjectService.getObjectFieldMap('Case');

        caseFields = ObjectService.objectFieldsToString(caseFieldMap);

        return caseFields;
    }

    /**
     * Returns the fields needed on the Service Center for a given case
     * @param The Case Id to look up
     * @return The Case Object
     */
    public static Case getCaseDetails(Id caseId) {
        Case requestedCase = [
            SELECT
                Id,
                CaseNumber,
                CC_Functional_Group__c,
                CC_Functional_Group__r.Name,
                Subject,
                Description,
                Feedback_Link__c,
                CreatedDate,
                Status,
                ClosedDate
            FROM Case
            WHERE Id = :caseId
        ];

        return requestedCase;
    }

    /**
     * Returns the email messages for the requested case
     * @param The Case Id to look up
     * @return The Case Objects Email Messages
     */
    public static EmailMessage[] getCaseEmailMessages(Date launchDate, Id caseId, List<String> contactEmails) {
        return [
            SELECT
                FromName,
                CreatedDate,
                MessageDate,
                HtmlBody,
                LastModifiedDate,
                Subject,
                TextBody,
                FromAddress,
                ToAddress,
                CCAddress
            FROM EmailMessage
            WHERE
                ParentId = :ApexPages.currentPage().getParameters().get('id')
                AND Status != '5'
                AND CreatedDate > :launchDate
                AND (ToAddress IN :contactEmails
                OR FromAddress IN :contactEmails)
            ORDER BY CreatedDate DESC
        ];
    }

    /**
     * Get these contact's open visible cases
     * @param A list of contacts
     * @return A map containing the set of contactIds and their associated cases
     */
    public static Map<Id, List<Case>> getVisibleOpenCases(List<Contact> listOfContacts) {
        return getVisibleOpenCases(listOfContacts, 0);
    }

    /**
     * Get these contact's open visible cases
     * @param A list of contacts
     * @param An integer representing the amount of contacts to return
     * @return A map containing the set of contactIds and their associated cases
     */
    public static Map<Id, List<Case>> getVisibleOpenCases(List<Contact> listOfContacts, Integer queryLimit) {
        List<Case> openCases = null;
        String caseFields = caseFieldsToString();

        // Create a set of contactIds from our listOfContacts
        Set<Id> contactIds = new Set<Id>();

        for (Contact con : listOfContacts) {
            contactIds.add(con.Id);
        }

        // Get the list of cases associated with our set of contacts
        try {
            String selectOpenVisibleCases =
                'SELECT ' +
                caseFields +
                ' ' +
                'FROM Case ' +
                'WHERE IsClosed = false ' +
                'AND Visible_by_Contact__c = true ' +
                'AND ContactId IN :contactIds ' +
                'ORDER BY CreatedDate DESC';

            if (queryLimit != 0) {
                selectOpenVisibleCases += ' LIMIT ' + queryLimit;
            }

            openCases = Database.query(selectOpenVisibleCases);
        } catch (Exception e) {
            throw new CaseServiceException(
                '!!!ERROR!!!: An error occurred trying to get the Contact\'s open visible cases\n' +
                e.getStackTraceString()
            );
        }

        // Iterate through the list cases that we got back and associate them with the list of contacts passed in
        Map<Id, List<Case>> conCaseMap = new Map<Id, List<Case>>();

        for (Case caze : openCases) {
            if (conCaseMap.containsKey(caze.ContactId)) {
                conCaseMap.get(caze.ContactId).add(caze);
            } else {
                conCaseMap.put(caze.ContactId, new List<Case>{ caze });
            }
        }

        return conCaseMap;
    }

    /**
     * Get these contact's closed visible cases
     * @param A list of contacts
     * @return A map containing the set of contactIds and their associated cases
     */
    public static Map<Id, List<Case>> getVisibleClosedCases(List<Contact> listOfContacts) {
        return getVisibleClosedCases(listOfContacts, 0);
    }

    /**
     * Get these contact's closed visible cases
     * @param A list of contacts
     * @param An integer representing the amount of contacts to return
     * @return A map containing the set of contactIds and their associated cases
     */
    public static Map<Id, List<Case>> getVisibleClosedCases(List<Contact> listOfContacts, Integer queryLimit) {
        List<Case> closedCases = null;

        String caseFields = caseFieldsToString();

        // Create a set of contactIds from our listOfContacts
        Set<Id> contactIds = new Set<Id>();

        for (Contact con : listOfContacts) {
            contactIds.add(con.Id);
        }

        // Get the list of cases associated with our set of contacts
        try {
            String selectClosedVisibleCases =
                'SELECT ' +
                caseFields +
                ' ' +
                'FROM Case ' +
                'WHERE IsClosed = true ' +
                'AND Visible_by_Contact__c = true ' +
                'AND ContactId IN :contactIds ' +
                'ORDER BY ClosedDate DESC';

            if (queryLimit != 0) {
                selectClosedVisibleCases += ' LIMIT ' + queryLimit;
            }

            closedCases = Database.query(selectClosedVisibleCases);
        } catch (Exception e) {
            throw new CaseServiceException(
                '!!!ERROR!!!: An error occurred trying to get the Contact\'s ' +
                'closed visible cases\n' +
                e.getStackTraceString()
            );
        }

        // Iterate through the list cases that we got back and associate them with the list of contacts passed in
        Map<Id, List<Case>> conCaseMap = new Map<Id, List<Case>>();

        for (Case caze : closedCases) {
            if (conCaseMap.containsKey(caze.ContactId)) {
                conCaseMap.get(caze.ContactId).add(caze);
            } else {
                conCaseMap.put(caze.ContactId, new List<Case>{ caze });
            }
        }

        return conCaseMap;
    }

    /**
     * Get all open cases for this contact
     * @param the contact Id
     * @return A list of all open cases for that contact
     */
    public static List<Case> getAllOpenCases(Id contactId) {
        List<Case> openCases = null;
        String caseFields = caseFieldsToString();

        String selectOpenVisibleCases =
            'SELECT ' +
            caseFields +
            ' ' +
            'FROM Case ' +
            'WHERE IsClosed = false ' +
            'AND ContactId = :contactId ' +
            'ORDER BY CreatedDate DESC';

        openCases = Database.query(selectOpenVisibleCases);

        return openCases;
    }

    /**
     * Get all of the information pertaining to the provided case Id
     * @param caseId A Case ID
     * @return caseInfo The corresponding Case
     */
    public static Case getCaseInformation(Id caseId) {
        Case caseInfo = null;
        String caseFields = caseFieldsToString();

        // Get the list of cases associated with our set of contacts
        try {
            String caseInfoQuery = 'SELECT ' + caseFields + ' ' + 'FROM Case ' + 'WHERE Id = :caseId';

            System.debug('!!!FINE: caseInfoQuery is ' + caseInfoQuery);

            caseInfo = Database.query(caseInfoQuery);
        } catch (Exception e) {
            throw new CaseServiceException(
                '!!!ERROR!!!: An error occurred trying to get ' +
                'the Case\'s information\n' +
                e.getMessage()
            );
        }

        return caseInfo;
    }

    /**
     * Create a number of test cases. Usually for unit tests.
     * @param An integer describing the number of cases to create
     * @param The contact to associate the cases to
     * @return A list of cases
     */
    public static List<Case> createTestCases(Integer numberOfCases, Contact con) {
        List<Case> testCases = new List<Case>();

        for (Integer i = 0; i < numberOfCases; i++) {
            Case c = new Case();
            c.Subject = 'Test Case ' + i;
            c.Description = 'Auto generated test case';
            c.ContactId = con.Id;
            testCases.add(c);
        }

        return testCases;
    }

    public class CaseServiceException extends Exception {
    }
}
