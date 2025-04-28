@isTest
public class RecordDeleterTest {
    private static final Integer CONTACT_NUM = 10;
    private static final Integer OPPORTUNITIES_PER_CONTACT = 2;
    private static final Integer CASES_PER_CONTACT = 10;

    @TestSetup
    private static void setup() {
        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < CONTACT_NUM; i++)
            testContacts.add(
                new Contact(
                    FirstName = 'Test-Contact-' + i,
                    LastName = 'Record Deleter Test',
                    Email = 'record.deleter.test.' + i + '@test.test'
                )
            );
        insert testContacts;

        List<Id> contactIds = new List<Id>();
        for (Contact c : testContacts)
            contactIds.add(c.Id);
        List<Account> testAccounts = [SELECT Id, Contact__c FROM Account WHERE Contact__c IN :contactIds];
        Map<Id, Account> contactIdToAccountMp = new Map<Id, Account>();
        for (Account a : testAccounts)
            contactIdToAccountMp.put(a.Contact__c, a);

        Map<String, List<Opportunity>> contactIdToOppsMp = new Map<String, List<Opportunity>>();
        // Add one opp for each
        List<Opportunity> testOpportunities = new List<Opportunity>();
        for (Contact c : testContacts) {
            Opportunity o = new Opportunity(
                Name = 'Record Deleter Test Opportunity for ' + c.FirstName + ' #0',
                Contact__c = c.Id,
                AccountId = contactIdToAccountMp.get(c.Id).Id,
                StageName = 'Prospect',
                CloseDate = Date.newInstance(2040, 12, 12)
            );
            contactIdToOppsMp.put(c.Id, new List<Opportunity>{ o });
            testOpportunities.add(o);
        }
        insert testOpportunities;
        testOpportunities.clear();
        // and add rest of opps (first must be inserted only one per contact to avoid issues with flows)
        for (Contact c : testContacts) {
            for (Integer i = 1; i < OPPORTUNITIES_PER_CONTACT; i++) {
                Opportunity o = new Opportunity(
                    Name = 'Record Deleter Test Opportunity for ' + c.FirstName + ' #' + i,
                    Contact__c = c.Id,
                    AccountId = contactIdToAccountMp.get(c.Id).Id,
                    StageName = 'Prospect',
                    CloseDate = Date.newInstance(2040, 12, 12)
                );
                contactIdToOppsMp.get(c.Id).add(o);
                testOpportunities.add(o);
            }
        }
        insert testOpportunities;

        List<Case> testCases = new List<Case>();
        for (Contact c : testContacts)
            for (Integer i = 0; i < CASES_PER_CONTACT; i++) {
                Integer oIndx = Math.mod(i, contactIdToOppsMp.get(c.Id).size());
                Opportunity o = contactIdToOppsMp.get(c.Id)[oIndx];

                Case cs = new Case(
                    Subject = 'Record Deleter Test Case for ' + c.FirstName + ' #' + i,
                    ContactId = c.Id,
                    Opportunity__c = o.Id
                );
                testCases.add(cs);
            }
        insert testCases;
    }

    /**
     * Deletes just the record themselves. This is not very different from just directly calling Database.delete()
     * Contact
     */
    @isTest
    private static void testDeleteBasic() {
        LogSuite.activateLogSuite('testflow');

        // Get all contacts to delete
        List<Contact> testContacts = [SELECT Id FROM Contact];
        List<String> recordIds = new List<String>();
        for (Contact c : testContacts)
            recordIds.add(c.Id);

        // Delete children manually (otherwise we will get an error when we try to delete record)
        delete [SELECT Id FROM Case WHERE ContactId IN :recordIds];
        delete [SELECT Id FROM Opportunity WHERE Contact__c IN :recordIds];

        Assert.isFalse(recordIds.isEmpty(), 'Should have some records - meaning there is nothing to test');

        // Setup metadata to have no child dependencies
        RecordDeleter.TEST_METADATA = new List<Record_Deleter_Setting__mdt>();

        // Mass delete records
        Test.startTest();
        RecordDeleter rd = new RecordDeleter('Contact', recordIds);
        List<RecordDeleter.DeleteStatus> resultLs = rd.deleteRecords();
        Map<String, RecordDeleter.DeleteStatus> resultMp = new Map<String, RecordDeleter.DeleteStatus>();
        for (RecordDeleter.DeleteStatus status : resultLs)
            resultMp.put(status.recordId, status);
        Test.stopTest();

        // Assert
        Assert.areEqual(recordIds.size(), resultMp.size());
        for (String recordId : recordIds) {
            Assert.isTrue(
                resultMp.containsKey(recordId),
                'resultMp should contain a mapping for this each record id, but it is missing ' +
                    recordId +
                    ' and instead contains ' +
                    resultMp.keySet()
            );

            RecordDeleter.DeleteStatus ds = resultMp.get(recordId);

            Assert.isTrue(
                ds.isSuccess(),
                'Should have successfully deleted record id=' +
                    recordId +
                    ' but it failed with message "' +
                    ds.getErrorMessage() +
                    '"'
            );
        }

        List<Contact> remainingRecords = [SELECT Id FROM Contact WHERE Id IN :recordIds];
        Assert.areEqual(0, remainingRecords.size());
    }

    /**
     * Deletes records and its direct children. This is the most basic case of using this since it must delete children before deleting the parent record.
     * Contact
     *   Case
     *   Opportunity
     */
    @isTest
    private static void testDeleteChildren() {
        LogSuite.activateLogSuite('testflow');

        // Get all contacts to delete
        List<Contact> testContacts = [SELECT Id FROM Contact];
        List<String> recordIds = new List<String>();
        for (Contact c : testContacts)
            recordIds.add(c.Id);
        List<Case> testCases = [SELECT Id FROM Case WHERE ContactId = :recordIds];
        List<Opportunity> testOpportunities = [SELECT Id FROM Opportunity WHERE Contact__c = :recordIds];

        Assert.isFalse(recordIds.isEmpty(), 'Should have some records - meaning there is nothing to test');
        Assert.isFalse(testCases.isEmpty(), 'No cases found for contacts - meaning there is nothing to test');
        Assert.isFalse(
            testOpportunities.isEmpty(),
            'No opportunities found for contacts - meaning there is nothing to test'
        );

        // Setup metadata to have case and opportunity as children of contact
        RecordDeleter.TEST_METADATA = new List<Record_Deleter_Setting__mdt>{
            new Record_Deleter_Setting__mdt(
                Parent_Object_Type__c = 'Contact',
                Child_Object_Type__c = 'Case',
                Parent_Field_Key__c = '$.Id',
                Child_Field_Key__c = '$.ContactId'
            ),
            new Record_Deleter_Setting__mdt(
                Parent_Object_Type__c = 'Contact',
                Child_Object_Type__c = 'Opportunity',
                Parent_Field_Key__c = '$.Id',
                Child_Field_Key__c = '$.Contact__c'
            )
        };

        // Mass delete records
        Test.startTest();
        RecordDeleter rd = new RecordDeleter('Contact', recordIds);
        List<RecordDeleter.DeleteStatus> resultLs = rd.deleteRecords();
        Map<String, RecordDeleter.DeleteStatus> resultMp = new Map<String, RecordDeleter.DeleteStatus>();
        for (RecordDeleter.DeleteStatus status : resultLs)
            resultMp.put(status.recordId, status);
        Test.stopTest();

        // Assert
        Assert.areEqual(recordIds.size(), resultMp.size());
        for (String recordId : recordIds) {
            Assert.isTrue(
                resultMp.containsKey(recordId),
                'resultMp should contain a mapping for this each record id, but it is missing ' +
                    recordId +
                    ' and instead contains ' +
                    resultMp.keySet()
            );

            RecordDeleter.DeleteStatus ds = resultMp.get(recordId);

            Assert.isTrue(
                ds.isSuccess(),
                'Should have successfully deleted record id=' +
                    recordId +
                    ' but it failed with message "' +
                    ds.getErrorMessage() +
                    '"'
            );
        }

        // Deleted all the contacts
        List<Contact> remainingRecords = [SELECT Id FROM Contact WHERE Id IN :recordIds];
        Assert.areEqual(0, remainingRecords.size());

        // Deleted all child cases
        List<Case> remainingCases = [SELECT Id FROM Case WHERE ContactId IN :recordIds];
        Assert.areEqual(0, remainingCases.size());

        // Deleted all child opportunities
        List<Opportunity> remainingOpportunities = [
            SELECT Id
            FROM Opportunity
            WHERE Contact__c IN :recordIds
        ];
        Assert.areEqual(0, remainingOpportunities.size());
    }

    /**
     * Deletes records and its direct children when they are linked on a non-Id field
     * (links using Email field)
     * Contact
     *   Case
     *   Opportunity
     */
    @isTest
    private static void testDeleteChildrenNonId() {
        LogSuite.activateLogSuite('testflow');

        // Get all contacts to delete
        List<Contact> testContacts = [SELECT Id FROM Contact];
        List<String> recordIds = new List<String>();
        for (Contact c : testContacts)
            recordIds.add(c.Id);
        List<Case> testCases = [SELECT Id, ContactId FROM Case WHERE ContactId = :recordIds];
        List<Opportunity> testOpportunities = [SELECT Id, Contact__c FROM Opportunity WHERE Contact__c = :recordIds];

        for (Contact c : testContacts)
            c.Department = 'X-' + c.Id;
        update testContacts;
        for (Case c : testCases)
            c.Subject = 'X-' + c.ContactId;
        update testCases;
        for (Opportunity o : testOpportunities)
            o.Name = 'X-' + o.Contact__c;
        update testOpportunities;

        Assert.isFalse(recordIds.isEmpty(), 'Should have some records - meaning there is nothing to test');
        Assert.isFalse(testCases.isEmpty(), 'No cases found for contacts - meaning there is nothing to test');
        Assert.isFalse(
            testOpportunities.isEmpty(),
            'No opportunities found for contacts - meaning there is nothing to test'
        );

        // Setup metadata to have children lookups via non Id fields
        RecordDeleter.TEST_METADATA = new List<Record_Deleter_Setting__mdt>{
            new Record_Deleter_Setting__mdt(
                Parent_Object_Type__c = 'Contact',
                Child_Object_Type__c = 'Case',
                Parent_Field_Key__c = '$.Department',
                Child_Field_Key__c = '$.Subject'
            ),
            new Record_Deleter_Setting__mdt(
                Parent_Object_Type__c = 'Contact',
                Child_Object_Type__c = 'Opportunity',
                Parent_Field_Key__c = '$.Department',
                Child_Field_Key__c = '$.Name'
            )
        };

        // Mass delete records
        Test.startTest();
        RecordDeleter rd = new RecordDeleter('Contact', recordIds);
        List<RecordDeleter.DeleteStatus> resultLs = rd.deleteRecords();
        Map<String, RecordDeleter.DeleteStatus> resultMp = new Map<String, RecordDeleter.DeleteStatus>();
        for (RecordDeleter.DeleteStatus status : resultLs)
            resultMp.put(status.recordId, status);
        Test.stopTest();

        // Assert
        Assert.areEqual(recordIds.size(), resultMp.size());
        for (String recordId : recordIds) {
            Assert.isTrue(
                resultMp.containsKey(recordId),
                'resultMp should contain a mapping for this each record id, but it is missing ' +
                    recordId +
                    ' and instead contains ' +
                    resultMp.keySet()
            );

            RecordDeleter.DeleteStatus ds = resultMp.get(recordId);

            Assert.isTrue(
                ds.isSuccess(),
                'Should have successfully deleted record id=' +
                    recordId +
                    ' but it failed with message "' +
                    ds.getErrorMessage() +
                    '"'
            );
        }

        // Deleted all the contacts
        List<Contact> remainingRecords = [SELECT Id FROM Contact WHERE Id IN :recordIds];
        Assert.areEqual(0, remainingRecords.size());

        // Deleted all child cases
        List<Case> remainingCases = [SELECT Id FROM Case WHERE ContactId IN :recordIds];
        Assert.areEqual(0, remainingCases.size());

        // Deleted all child opportunities
        List<Opportunity> remainingOpportunities = [
            SELECT Id
            FROM Opportunity
            WHERE Contact__c IN :recordIds
        ];
        Assert.areEqual(0, remainingOpportunities.size());
    }

    /**
     * Deletes records and deep children. This is often how we setup multi-layered deletes, which Case not directly looking up to Contact,
     * but looking up to an Opportunity that lookups to Contact.
     * UNLIKE the recursive config, if you were to delete the Opportunity directly (rather than the Contact), it won't delete the Case.
     * Contact
     *   Opportunity
     *      Case
     */
    @isTest
    private static void testDeleteDeepChildren() {
        LogSuite.activateLogSuite('testflow');

        // Get all contacts to delete
        List<Contact> testContacts = [SELECT Id FROM Contact];
        List<String> recordIds = new List<String>();
        for (Contact c : testContacts)
            recordIds.add(c.Id);
        List<Case> testCases = [SELECT Id FROM Case WHERE Opportunity__r.Contact__c = :recordIds];
        List<Opportunity> testOpportunities = [SELECT Id FROM Opportunity WHERE Contact__c = :recordIds];

        Assert.isFalse(recordIds.isEmpty(), 'Should have some records - meaning there is nothing to test');
        Assert.isFalse(testCases.isEmpty(), 'No cases found for contacts - meaning there is nothing to test');
        Assert.isFalse(
            testOpportunities.isEmpty(),
            'No opportunities found for contacts - meaning there is nothing to test'
        );

        // Setup metadata to have deep lookups
        RecordDeleter.TEST_METADATA = new List<Record_Deleter_Setting__mdt>{
            new Record_Deleter_Setting__mdt(
                Parent_Object_Type__c = 'Contact',
                Child_Object_Type__c = 'Opportunity',
                Parent_Field_Key__c = '$.Id',
                Child_Field_Key__c = '$.Contact__c',
                Order__c = 20
            ),
            new Record_Deleter_Setting__mdt(
                Parent_Object_Type__c = 'Contact',
                Child_Object_Type__c = 'Case',
                Parent_Field_Key__c = '$.Id',
                Child_Field_Key__c = '$.Opportunity__r.Contact__c',
                Order__c = 10
            )
        };

        // Mass delete records
        Test.startTest();
        RecordDeleter rd = new RecordDeleter('Contact', recordIds);
        List<RecordDeleter.DeleteStatus> resultLs = rd.deleteRecords();
        Map<String, RecordDeleter.DeleteStatus> resultMp = new Map<String, RecordDeleter.DeleteStatus>();
        for (RecordDeleter.DeleteStatus status : resultLs)
            resultMp.put(status.recordId, status);
        Test.stopTest();

        // Assert
        Assert.areEqual(recordIds.size(), resultMp.size());

        for (String recordId : recordIds) {
            Assert.isTrue(
                resultMp.containsKey(recordId),
                'resultMp should contain a mapping for this each record id, but it is missing ' +
                    recordId +
                    ' and instead contains ' +
                    resultMp.keySet()
            );

            RecordDeleter.DeleteStatus ds = resultMp.get(recordId);

            Assert.isTrue(
                ds.isSuccess(),
                'Should have successfully deleted record id=' +
                    recordId +
                    ' but it failed with message "' +
                    ds.getErrorMessage() +
                    '"'
            );
        }

        // Deleted all the contacts
        List<Contact> remainingRecords = [SELECT Id FROM Contact WHERE Id IN :recordIds];
        Assert.areEqual(0, remainingRecords.size());

        // Deleted all child cases
        List<Case> remainingCases = [SELECT Id FROM Case WHERE ContactId IN :recordIds];
        Assert.areEqual(0, remainingCases.size());

        // Deleted all child opportunities
        List<Opportunity> remainingOppss = [SELECT Id FROM Opportunity WHERE Contact__c IN :recordIds];
        Assert.areEqual(0, remainingOppss.size());
    }

    /**
     * Deletes records and recursive children. This is often how we would setup if we wanted deleting Opportunity to cause deleting case's that lookup to it
     * and if we wanted deleting Contact to delete Opportunities that lookup to it.
     * UNLIKE a simple deep lookup, if you delete the Opportunity is will delete the Case.
     * Contact
     *   Opportunity
     * Opportunity
     *   Case
     */
    @isTest
    private static void testDeleteRecursiveChildren() {
        LogSuite.activateLogSuite('testflow');

        // Get all contacts to delete
        List<Contact> testContacts = [SELECT Id FROM Contact];
        List<String> recordIds = new List<String>();
        for (Contact c : testContacts)
            recordIds.add(c.Id);
        List<Opportunity> testOpportunities = [SELECT Id FROM Opportunity WHERE Contact__c = :recordIds];
        List<String> oppIds = new List<String>();
        for (Opportunity o : testOpportunities)
            oppIds.add(o.Id);
        List<Case> testCases = [SELECT Id FROM Case WHERE Opportunity__c = :oppIds];

        Assert.isFalse(recordIds.isEmpty(), 'Should have some records - meaning there is nothing to test');
        Assert.isFalse(testCases.isEmpty(), 'No cases found for contacts - meaning there is nothing to test');
        Assert.isFalse(
            testOpportunities.isEmpty(),
            'No opportunities found for contacts - meaning there is nothing to test'
        );

        // Setup metadata to have layered children
        RecordDeleter.TEST_METADATA = new List<Record_Deleter_Setting__mdt>{
            new Record_Deleter_Setting__mdt(
                Parent_Object_Type__c = 'Contact',
                Child_Object_Type__c = 'Opportunity',
                Parent_Field_Key__c = '$.Id',
                Child_Field_Key__c = '$.Contact__c'
            ),
            new Record_Deleter_Setting__mdt(
                Parent_Object_Type__c = 'Opportunity',
                Child_Object_Type__c = 'Case',
                Parent_Field_Key__c = '$.Id',
                Child_Field_Key__c = '$.Opportunity__c'
            )
        };

        // Mass delete records
        Test.startTest();
        RecordDeleter rd = new RecordDeleter('Contact', recordIds);
        List<RecordDeleter.DeleteStatus> resultLs = rd.deleteRecords();
        Map<String, RecordDeleter.DeleteStatus> resultMp = new Map<String, RecordDeleter.DeleteStatus>();
        for (RecordDeleter.DeleteStatus status : resultLs)
            resultMp.put(status.recordId, status);
        Test.stopTest();

        // Assert
        Assert.areEqual(recordIds.size(), resultMp.size());

        for (String recordId : recordIds) {
            Assert.isTrue(
                resultMp.containsKey(recordId),
                'resultMp should contain a mapping for this each record id, but it is missing ' +
                    recordId +
                    ' and instead contains ' +
                    resultMp.keySet()
            );

            RecordDeleter.DeleteStatus ds = resultMp.get(recordId);

            Assert.isTrue(
                ds.isSuccess(),
                'Should have successfully deleted record id=' +
                    recordId +
                    ' but it failed with message "' +
                    ds.getErrorMessage() +
                    '"'
            );
        }

        // Deleted all the contacts
        List<Contact> remainingRecords = [SELECT Id FROM Contact WHERE Id IN :recordIds];
        Assert.areEqual(0, remainingRecords.size());

        // Deleted all child cases
        List<Case> remainingCases = [SELECT Id FROM Case WHERE ContactId IN :recordIds];
        Assert.areEqual(0, remainingCases.size());

        // Deleted all child opportunities
        List<Opportunity> remainingOppss = [SELECT Id FROM Opportunity WHERE Contact__c IN :recordIds];
        Assert.areEqual(0, remainingOppss.size());
    }

    /**
     * Report immediate errors
     */
    @isTest
    private static void testDeleteErrorBasic() {
        LogSuite.activateLogSuite('testflow');

        // Get all contacts to delete
        List<Contact> testContacts = [SELECT Id FROM Contact];
        List<String> recordIds = new List<String>();
        for (Contact c : testContacts)
            recordIds.add(c.Id);

        Assert.isFalse(recordIds.isEmpty(), 'Should have some records - meaning there is nothing to test');

        // Set of records which we will successfully delete
        List<String> expectedSuccessfulDeleteContactIds = new List<String>();
        for (Integer i = 0; i < testContacts.size(); i++)
            if (Math.mod(i, 2) == 0)
                expectedSuccessfulDeleteContactIds.add(testContacts[i].Id);
        Assert.isFalse(
            expectedSuccessfulDeleteContactIds.isEmpty(),
            'Should have some records - meaning there is nothing to test'
        );

        // Delete children manually for some contacts, those we don't delete will later cause those contacts
        // to fail deletion
        delete [SELECT Id FROM Case WHERE ContactId IN :expectedSuccessfulDeleteContactIds];
        delete [SELECT Id FROM Opportunity WHERE Contact__c IN :expectedSuccessfulDeleteContactIds];

        // Setup metadata to have no child dependencies
        RecordDeleter.TEST_METADATA = new List<Record_Deleter_Setting__mdt>();

        // Mass delete records
        Test.startTest();
        RecordDeleter rd = new RecordDeleter('Contact', recordIds);
        List<RecordDeleter.DeleteStatus> resultLs = rd.deleteRecords();
        Map<String, RecordDeleter.DeleteStatus> resultMp = new Map<String, RecordDeleter.DeleteStatus>();
        for (RecordDeleter.DeleteStatus status : resultLs)
            resultMp.put(status.recordId, status);
        Test.stopTest();

        // Assert
        Assert.areEqual(recordIds.size(), resultMp.size());
        for (String recordId : recordIds) {
            Assert.isTrue(
                resultMp.containsKey(recordId),
                'resultMp should contain a mapping for this each record id, but it is missing ' +
                    recordId +
                    ' and instead contains ' +
                    resultMp.keySet()
            );

            RecordDeleter.DeleteStatus ds = resultMp.get(recordId);

            Assert.areEqual(
                expectedSuccessfulDeleteContactIds.contains(recordId),
                ds.isSuccess(),
                expectedSuccessfulDeleteContactIds.contains(recordId)
                    ? 'Expected delete success for record id=' + recordId + ' but it reported failure'
                    : 'Expected delete failure for record id=' + recordId + ' but it reported success'
            );
        }

        Map<Id, Contact> remainingRecordsMp = new Map<Id, Contact>([SELECT Id FROM Contact WHERE Id IN :recordIds]);

        Assert.isFalse(
            remainingRecordsMp.isEmpty(),
            'Some records should have failed to deleted, but all successfully deleted'
        );
        Assert.isTrue(
            recordIds.size() > remainingRecordsMp.size(),
            'Some records should have been deleted, but none were'
        );

        for (String expectedDeleteId : expectedSuccessfulDeleteContactIds) {
            Assert.isFalse(
                remainingRecordsMp.containsKey(expectedDeleteId),
                'Expected record id=' + expectedDeleteId + ' to be deleted, but it was not'
            );
        }
        for (Id remainingRecordId : remainingRecordsMp.keySet()) {
            Assert.isFalse(
                expectedSuccessfulDeleteContactIds.contains(remainingRecordId),
                'Record id=' + remainingRecordId + ' was not deleted, but it should have been'
            );
        }
    }

    /**
     * Report child errors
     */
    @isTest
    private static void testDeleteErrorOnChildren() {
        LogSuite.activateLogSuite('testflow');

        // Get all opportunities to delete
        List<Opportunity> testOpps = [SELECT Id, Contact__c FROM Opportunity];
        List<String> recordIds = new List<String>();
        for (Opportunity o : testOpps)
            recordIds.add(o.Id);

        Assert.isFalse(recordIds.isEmpty(), 'Should have some records - meaning there is nothing to test');

        // Setup metadata to auto delete Opp's contact
        RecordDeleter.TEST_METADATA = new List<Record_Deleter_Setting__mdt>{
            new Record_Deleter_Setting__mdt(
                Parent_Object_Type__c = 'Opportunity',
                Child_Object_Type__c = 'Contact',
                Parent_Field_Key__c = '$.Contact__c',
                Child_Field_Key__c = '$.Id'
            )
        };

        // Mass delete records
        Test.startTest();
        RecordDeleter rd = new RecordDeleter('Opportunity', recordIds);
        List<RecordDeleter.DeleteStatus> resultLs = rd.deleteRecords();
        Map<String, RecordDeleter.DeleteStatus> resultMp = new Map<String, RecordDeleter.DeleteStatus>();
        for (RecordDeleter.DeleteStatus status : resultLs)
            resultMp.put(status.recordId, status);
        Test.stopTest();

        // Assert
        Assert.areEqual(recordIds.size(), resultMp.size());
        for (String recordId : recordIds) {
            Assert.isTrue(
                resultMp.containsKey(recordId),
                'resultMp should contain a mapping for this each record id, but it is missing ' +
                    recordId +
                    ' and instead contains ' +
                    resultMp.keySet()
            );

            RecordDeleter.DeleteStatus ds = resultMp.get(recordId);

            Assert.areEqual(
                false,
                ds.isSuccess(),
                'Expected delete failure for record id=' + recordId + ' but it reported success'
            );
            Assert.isTrue(
                ds.getErrorMessage().contains('Failed to delete child Contact record'),
                'Expected error message to propagate child error message and contain "Failed to delete child Contact record" but it instead said "' +
                    ds.getErrorMessage() +
                    '"'
            );
        }

        Map<Id, Opportunity> remainingRecordsMp = new Map<Id, Opportunity>(
            [SELECT Id FROM Opportunity WHERE Id IN :recordIds]
        );

        Assert.areEqual(recordIds.size(), remainingRecordsMp.size(), 'Expected all deletions to fail');
    }
}
