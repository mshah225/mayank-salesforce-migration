public class CaseService
{

    /**
    * Returns all the fields on Case in a String
    * @return A string containing all the Case fields
    */
    public static String caseFieldsToString()
    {
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
    public static Case getCaseDetails(Id caseId)
    {
        Case requestedCase = [
            SELECT Id, CaseNumber, CC_Functional_Group__c, CC_Functional_Group__r.Name, Subject, Description,
            Feedback_Link__c, CreatedDate, Status, ClosedDate
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
    public static EmailMessage[] getCaseEmailMessages(Date launchDate, Id caseId, List<String> contactEmails)
    {
        return [
            SELECT FromName, CreatedDate, HtmlBody, LastModifiedDate,
            Subject, TextBody, FromAddress, ToAddress, CCAddress
            FROM EmailMessage
            WHERE ParentId = :ApexPages.currentPage().getParameters().get('id')
            AND Incoming = false
            AND Status !='5'
            AND CreatedDate > :launchDate
            AND ToAddress IN :contactEmails
            ORDER BY CreatedDate DESC
        ];
    }



    /**
    * Get these contact's open visible cases
    * @param A list of contacts
    * @return A map containing the set of contactIds and their associated cases
    */
    public static Map<Id, List<Case>> getVisibleOpenCases(List<Contact> listOfContacts)
    {
        List<Case> openCases = null;
        String caseFields = caseFieldsToString();

        // Create a set of contactIds from our listOfContacts
        Set<Id> contactIds = new Set<Id>();

        for (Contact con : listOfContacts)
        {
            contactIds.add(con.Id);
        }

        // Get the list of cases associated with our set of contacts
        try
        {
            String selectOpenVisibleCases = 'SELECT ' + caseFields + ' ' +
                                            'FROM Case ' +
                                            'WHERE IsClosed = false ' +
                                            'AND Visible_by_Contact__c = true ' +
                                            'AND ContactId IN :contactIds ' +
                                            'ORDER BY CreatedDate DESC';

            openCases = Database.query(selectOpenVisibleCases);
        }
        catch (Exception e)
        {
            throw new CaseServiceException(
                '!!!ERROR!!!: An error occurred trying to get the Contact\'s open visible cases\n' +
                e.getStackTraceString()
            );
        }

        // Iterate through the list cases that we got back and associate them with the list of contacts passed in
        Map<Id, List<Case>> conCaseMap = new Map<Id, List<Case>>();

        for (Case caze : openCases)
        {
            if (conCaseMap.containsKey(caze.ContactId))
            {
                conCaseMap.get(caze.ContactId).add(caze);
            }
            else
            {
                conCaseMap.put(caze.ContactId, new List<Case> { caze });
            }
        }

        return conCaseMap;
    }

    /**
    * Get these contact's closed visible cases
    * @param A list of contacts
    * @return A map containing the set of contactIds and their associated cases
    */
    public static Map<Id, List<Case>> getVisibleClosedCases(List<Contact> listOfContacts)
    {
        List<Case> closedCases = null;

        String caseFields = caseFieldsToString();

        // Create a set of contactIds from our listOfContacts
        Set<Id> contactIds = new Set<Id>();

        for (Contact con : listOfContacts)
        {
            contactIds.add(con.Id);
        }

        // Get the list of cases associated with our set of contacts
        try
        {
            String selectClosedVisibleCases = 'SELECT ' + caseFields + ' ' +
                                              'FROM Case ' +
                                              'WHERE IsClosed = true ' +
                                              'AND Visible_by_Contact__c = true ' +
                                              'AND ContactId IN :contactIds ' +
                                              'ORDER BY ClosedDate DESC';

            closedCases = Database.query(selectClosedVisibleCases);
        }
        catch (Exception e)
        {
            throw new CaseServiceException(
                 '!!!ERROR!!!: An error occurred trying to get the Contact\'s ' +
                 'closed visible cases\n' + e.getStackTraceString()
            );
        }

        // Iterate through the list cases that we got back and associate them with the list of contacts passed in
        Map<Id, List<Case>> conCaseMap = new Map<Id, List<Case>>();

        for (Case caze : closedCases)
        {
            if (conCaseMap.containsKey(caze.ContactId))
            {
                conCaseMap.get(caze.ContactId).add(caze);
            }
            else
            {
                conCaseMap.put(caze.ContactId, new List<Case> { caze });
            }
        }

        return conCaseMap;
    }

    /**
    * Get all open cases for this contact
    * @param the contact Id
    * @return A list of all open cases for that contact
    */
    public static List<Case> getAllOpenCases(Id contactId)
    {
        List<Case> openCases = null;
        String caseFields = caseFieldsToString();


        String selectOpenVisibleCases = 'SELECT ' + caseFields + ' ' +
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
    public static Case getCaseInformation(Id caseId)
    {
        Case caseInfo = null;
        String caseFields = caseFieldsToString();

        // Get the list of cases associated with our set of contacts
        try
        {
            String caseInfoQuery = 'SELECT ' + caseFields + ' ' +
                                   'FROM Case ' +
                                   'WHERE Id = :caseId';

            System.debug('!!!FINE: caseInfoQuery is ' + caseInfoQuery);

            caseInfo = Database.query(caseInfoQuery);
        }
        catch (Exception e)
        {
            throw new CaseServiceException(
                '!!!ERROR!!!: An error occurred trying to get ' +
                'the Case\'s information\n' + e.getMessage()
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
    public static List<Case> createTestCases(Integer numberOfCases, Contact con)
    {
        List<Case> testCases = new List<Case>();

        for (Integer i = 0; i < numberOfCases; i++)
        {
            Case c = new Case();
            c.Subject = 'Test Case ' + i;
            c.Description = 'Auto generated test case';
            c.ContactId = con.Id;
            testCases.add(c);
        }

        return testCases;
    }

    //Handles Webform cases (webforms.asu.edu)
    public static void handleClosingWebformsCases() {
        for (Integer i = 0; i < Trigger.new.size(); i++) {
            Case newCase = (Case) Trigger.new.get(i);
            Case oldCase = (Case) Trigger.old.get(i);


            if (
                oldCase.Status == 'Closed: Resolved (Webforms)' && 
                oldCase.Deep_Links__c != NULL &&
                oldCase.Deep_Links__c.split('Click Here').size() == (Integer.valueof(newCase.Number_of_Files__c) + 1) &&
                UserInfo.getName() == 'API ASU DRUPAL'    
            ) {
                newCase.Status = oldCase.Status;
                newCase.Deep_Links__c = oldCase.Deep_Links__c;
                newCase.Subject = oldCase.Subject;
            } else if (newCase.Status == 'Processing' && newCase.Deep_Links__c != NULL) {
                List<String> deepLinksSplit = newCase.Deep_Links__c.split('Click Here');
                List<String> subjectSplit = newCase.Subject.split('%');

                if (
                  deepLinksSplit.size() == Integer.valueOf(newCase.Number_of_Files__c) + 1 &&
                  subjectSplit.size() >= 2
                ) {
                    newCase.Status = 'New';

                    for (Integer j = 0; j < subjectSplit.size(); j++) {
                        List<String> tokenSplit = subjectSplit[j].split(':');
                        if (
                            tokenSplit.size() >= 2 && 
                            tokenSplit[0] == 'Queue' && 
                            tokenSplit[1] != ''
                        ) {
                            newCase.OwnerId = tokenSplit[1];
                            break;
                        }
                    }

                    newCase.Subject = subjectSplit[0];

                    if (newCase.OwnerId == getFACaseQueueId()) {
                        newCase.Visible_By_Contact__c = FALSE;
                        newCase.Status = 'Closed: Resolved (Webforms)';
                        newCase.IsClosedOnCreate = TRUE;
                    }
                }
            }
        } 
    }

    public static Id getFACaseQueueId() {
        if (faCaseQueueId == null) {
            faCaseQueueId = [
                SELECT Id
                FROM Group
                WHERE Name = 'Financial Aid (Case)'
                AND Type = 'Queue' 
				LIMIT 1
            ].Id;
        } 

        return faCaseQueueId;
    }

    public class CaseServiceException extends Exception {}
}