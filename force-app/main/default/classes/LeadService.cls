public class LeadService {
    public static boolean ranLeadConversion = false;

    /**
     * Creates a Lead with all required fields, usually for unit testing
     * @return testLead A lead with all required fields
     */
    public static Lead createTestLead() {
        Lead testLead = new Lead();
        testLead.FirstName = 'Jonny';
        testLead.LastName = 'Test';
        testLead.Email = 'test@nomail.com';
        testLead.Company = 'Test Company';

        return testLead;
    }

    /**
     * Generates a set of test leads to convert
     * @param contactsToConvertOn a set of Contacts to convert to
     * @return leads a list of test lead data
     */
    public static List<Lead> createTestLeadsToConvert(List<Contact> contactsToConvertOn) {
        List<Lead> leads = new List<Lead>();

        for (Contact con : contactsToConvertOn) {
            Lead testLead = new Lead();
            testLead.FirstName = con.FirstName;
            testLead.LastName = con.LastName;
            testLead.Email = con.Email;
            testLead.LeadSource = 'Email';
            testLead.Company = 'TestCompany';
            testLead.Career__c = 'Undergraduate';
            testLead.Online__c = true;
            testLead.International_Student__c = true;
            testLead.First_Generation__c = true;
            testLead.Potential_National_Scholar__c = true;
            testLead.Potential_WUE__c = true;
            testLead.Search_Segment__c = 'Scholar';
            testLead.Self_Reported_SES__c = 'Moderate';
            testLead.Veteran_Status__c = 'Veteran';
            testLead.Convert_Contact__c = con.Id;

            leads.add(testLead);
        }

        return leads;
    }

    /**
     * Generates a list of previous education records that should be inserted as a result of conversion
     * @param  leadIds A set of Lead Ids
     * @return peList A list of previous education records
     */
    public static List<Previous_Education__c> createConvertedPreviousEducation(Set<Id> leadIds) {
        List<Previous_Education__c> peList = new List<Previous_Education__c>();

        if (leadIds.size() == 0) {
            return peList;
        }

        List<Lead> leadList = new List<Lead>(
            [
                SELECT
                    Id,
                    ConvertedContactId,
                    Last_Institution_Attended__c,
                    Last_Institution_Attended__r.Institution_Type__c,
                    Last_Institution_GPA__c,
                    Last_Institution_GPA_Scale__c,
                    College_Transfer_Hours__c,
                    High_School_Class_Percent__c,
                    High_School_Class_Rank__c,
                    High_School_Class_Size__c
                FROM Lead
                WHERE Id IN :leadIds
            ]
        );

        for (Lead l : leadList) {
            Previous_Education__c pe = new Previous_Education__c(
                Contact__c = l.ConvertedContactId,
                Account__c = l.Last_Institution_Attended__c
            );

            if (l.Last_Institution_Attended__r.Institution_Type__c == 'HS') {
                pe.Class_Rank__c = l.High_School_Class_Rank__c;
                pe.Class_Size__c = l.High_School_Class_Size__c;
            }

            pe.GPA__c = l.Last_Institution_GPA__c;
            peList.add(pe);
        }

        return peList;
    }
    /**
     * Creates a new contact
     * @param strFirstName First Name of the lead.
     * @param strLastName Last Name of the lead.
     * @return objContact An instance of the contact returned.
     */
    public static Contact createContact(
        String strFirstName,
        String strLastName,
        String strPhone,
        String strMobPhone,
        String strEmail
    ) {
        Contact objContact = new Contact();
        if (strFirstName != null) {
            objContact.FirstName = strFirstName;
        }
        if (strPhone != null) {
            objContact.Phone = strPhone;
        }
        if (strEmail != null) {
            objContact.Email = strEmail;
        }
        if (strMobPhone != null) {
            objContact.MobilePhone = strMobPhone;
        }
        objContact.LastName = strLastName;
        return objContact;
    }

    /**
     * Generates a map of integers to a List of LeadConvert objects
     * @param leadList A list of leads that have not been converted yet
     * @param conversionStatus The MasterLabel from a LeadStatus that these leads should be converted to
     * @return leadConvertBatches A map of all the leadConvert objects in batches
     */
    public static Map<Integer, List<Database.LeadConvert>> generateLeadConvertBatches(
        List<Lead> leadList,
        String conversionStatus
    ) {
        Map<Id, Lead> leadMap = new Map<Id, Lead>(
            [
                SELECT id, FirstName, LastName, Phone, Email, MobilePhone, Convert_Contact__c
                FROM Lead
                WHERE Id IN :leadList
            ]
        );
        Map<Id, Contact> leadIdtoContactMap = new Map<Id, Contact>();
        Map<Id, List<Lead>> accountToLeadMap = new Map<Id, List<Lead>>();
        Map<Integer, List<Database.LeadConvert>> leadConvertBatches = new Map<Integer, List<Database.LeadConvert>>();
        Id thisLeadsAccount;

        Integer numberOfBatches = 1;
        Integer additionalBatches = 0;

        for (Lead eachlead : leadMap.values()) {
            if (eachLead.Convert_Contact__c == null) {
                leadIdToContactMap.put(
                    eachLead.Id,
                    createContact(
                        eachLead.FirstName,
                        eachLead.LastName,
                        eachLead.Phone,
                        eachLead.MobilePhone,
                        eachLead.Email
                    )
                );
            }
        }

        try {
            if (leadIdToContactMap != null && leadIdToContactMap.size() > 0) {
                insert leadIdToContactMap.values();

                for (Id leadId : leadIdToContactMap.keySet()) {
                    if (leadMap.containsKey(leadId) && leadIdToContactMap.containsKey(leadId)) {
                        leadMap.get(leadId).Convert_Contact__c = leadIdToContactMap.get(leadId).Id;
                    }
                }
                update leadMap.values();
            }
        } catch (Exception e) {
            List<String> vars = new List<String>();
            for (Contact objContact : leadIdToContactMap.values()) {
                vars.add(
                    ErrorLogger.convertStringToJSON('Contact Name', objContact.FirstName + ' ' + objContact.LastName)
                );
            }
            ErrorLogger.log(e, vars, false);
        }

        // Map leads to a single account and track the number of LeadConvert batches we need
        for (Lead thisLead : [
            SELECT
                Id,
                FirstName,
                LastName,
                Convert_Contact__c,
                Convert_Contact_Account_ID__c,
                Convert_Create_Opportunity__c
            FROM Lead
            WHERE Id IN :leadList
        ]) {
            thisLeadsAccount = thisLead.Convert_Contact_Account_ID__c;

            // This a lead insertion, so it has no account Id, but we need a unique Id so we can batch properly
            if (thisLeadsAccount == null) {
                thisLeadsAccount = ObjectService.getFakeId(Account.SObjectType);
            }

            if (accountToLeadMap.containsKey(thisLeadsAccount)) {
                List<Lead> thisList = accountToLeadMap.get(thisLeadsAccount);
                thisList.add(thisLead);
                if (thisList.size() > numberOfBatches) {
                    numberOfBatches = thisList.size();
                }
            } else {
                List<Lead> newListOfLeads = new List<Lead>{ thisLead };
                accountToLeadMap.put(thisLeadsAccount, newListOfLeads);
            }
        }

        reparentAndUpdateIndividualEmailResults(leadList, leadMap);
        reparentAndUpdateSubscribers(leadList, leadMap);
        reparentAndUpdateMe3s(leadList, leadMap);

        // Create LeadConvert objects from the leads and batch them up
        for (Integer batchNumber = 0; batchNumber < numberOfBatches; batchNumber++) {
            List<Database.LeadConvert> leadConvertList = new List<Database.LeadConvert>();

            for (List<Lead> leads : accountToLeadMap.values()) {
                if (batchNumber < leads.size()) {
                    Lead thisLead = leads.get(batchNumber);

                    // Create a lead convert object for this lead
                    Database.LeadConvert lc = new Database.LeadConvert();
                    lc.setLeadId(thisLead.Id);
                    lc.setDoNotCreateOpportunity(!thisLead.Convert_Create_Opportunity__c);
                    lc.setConvertedStatus(conversionStatus);

                    if (thisLead.Convert_Contact__c != null) {
                        lc.setContactId(thisLead.Convert_Contact__c);
                        lc.setAccountId(thisLead.Convert_Contact_Account_ID__c);
                    }

                    leadConvertList.add(lc);
                }

                // Check to make sure our lead convert list hasn't grown beyond the limit of Database.convertLeads()
                // Handle it by putting the current contents into the map as a new batch and clearing the list
                if (leadConvertList.size() == 99) {
                    additionalBatches++;
                    List<Database.LeadConvert> batchCut = leadConvertList.clone();
                    leadConvertBatches.put(numberOfBatches + additionalBatches, batchCut);
                    leadConvertList.clear();
                }
            }

            leadConvertBatches.put(batchNumber, leadConvertList);
        }

        return leadConvertBatches;
    }

    private static void reparentAndUpdateIndividualEmailResults(List<Lead> leadList, Map<Id, Lead> leadMap) {
        List<et4ae5__IndividualEmailResult__c> emailsToAddContact = new List<et4ae5__IndividualEmailResult__c>();
        for (et4ae5__IndividualEmailResult__c leadEmailResult : [
            SELECT Id, et4ae5__Contact__c, et4ae5__Lead__c
            FROM et4ae5__IndividualEmailResult__c
            WHERE et4ae5__Lead__c IN :leadList
        ]) {
            if (leadMap.containsKey(leadEmailResult.et4ae5__Lead__c)) {
                leadEmailResult.et4ae5__Contact__c = leadMap.get(leadEmailResult.et4ae5__Lead__c).Convert_Contact__c;
                emailsToAddContact.add(leadEmailResult);
            }
        }

        if (!emailsToAddContact.isEmpty()) {
            update emailsToAddContact;
        }
    }

    private static void reparentAndUpdateSubscribers(List<Lead> leadList, Map<Id, Lead> leadMap) {
        List<Subscriber__c> subscribersToReparent = new List<Subscriber__c>();
        for (Subscriber__c leadSubscriber : [
            SELECT Lead__c, Contact__c
            FROM Subscriber__c
            WHERE Lead__c IN :leadList
        ]) {
            if (leadMap.containsKey(leadSubscriber.Lead__c)) {
                leadSubscriber.Contact__c = leadMap.get(leadSubscriber.Lead__c).Convert_Contact__c;
                subscribersToReparent.add(leadSubscriber);
            }
        }
        if (!subscribersToReparent.isEmpty()) {
            Database.update(subscribersToReparent, false);
        }
    }

    private static void reparentAndUpdateMe3s(List<Lead> leadList, Map<Id, Lead> leadMap) {
        List<Me3__c> me3ToAddContact = new List<Me3__c>();
        for (Me3__c leadMe3 : [SELECT Id, Contact__c, Lead__c FROM Me3__c WHERE Lead__c IN :leadList]) {
            if (leadMap.containsKey(leadMe3.Lead__c)) {
                leadMe3.Contact__c = leadMap.get(leadMe3.Lead__c).Convert_Contact__c;
                me3ToAddContact.add(leadMe3);
            }
        }

        if (!me3ToAddContact.isEmpty()) {
            update me3ToAddContact;
        }
    }

    public static void setLeadAssignmentNumber(List<Lead> newLeads) {
        for (Lead newLead : newLeads) {
            newLead.Lead_Assignment_Number__c = OpportunityService.generateOpportunityAssignmentNumber();
        }
    }

    public static void queueHashIdAssignment(Map<Id, Lead> updatedLeadsMap) {
        setHashId(updatedLeadsMap.keySet());
    }

    @future
    static void setHashId(Set<Id> leadIds) {
        List<Lead> leadsToUpdate = new List<Lead>();
        for (Id leadId : leadIds) {
            Lead leadToUpdate = new Lead(Id = leadId, HashLeadID__c = Hasher.hashId(leadId));
            leadsToUpdate.add(leadToUpdate);
        }
        update leadsToUpdate;
    }

    public static void determineLeadsToConvert(List<Lead> newLeads, Map<Id, Lead> oldLeadsMap) {
        List<Lead> leadsToConvert = new List<Lead>();
        if (oldLeadsMap == null) {
            for (Lead newLead : newLeads) {
                if (newLead.Convert_Perform_Conversion__c) {
                    leadsToConvert.add(newLead);
                }
            }
            if (leadsToConvert.size() > 0) {
                convertLeads(leadsToConvert);
            }
        } else {
            for (Lead newLead : newLeads) {
                Lead previousLead = oldLeadsMap.get(newLead.Id);
                if (newLead.Convert_Perform_Conversion__c && previousLead.Convert_Perform_Conversion__c == false) {
                    leadsToConvert.add(newLead);
                }
            }
            if (leadsToConvert.size() > 0 && !ranLeadConversion) {
                ranLeadConversion = true;
                convertLeads(leadsToConvert);
                ranLeadConversion = false;
            }
        }
    }

    public static void convertLeads(List<Lead> leadsToConvert) {
        if (leadsToConvert.size() == 0) {
            return;
        }

        /*
         * Primary lead conversion logic
         */
        LeadStatus convertedStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
        List<Database.LeadConvertResult> leadConversionResults = new List<Database.LeadConvertResult>();
        Set<Id> leadsNeedingPreviousEducation = new Set<Id>();
        Integer count = 0;

        Map<Integer, List<Database.LeadConvert>> leadConvertBatchMap = LeadService.generateLeadConvertBatches(
            leadsToConvert,
            convertedStatus.MasterLabel
        );

        for (List<Database.LeadConvert> lcBatch : leadConvertBatchMap.values()) {
            List<Database.LeadConvertResult> lcResultList = Database.convertLead(lcBatch, false);
            leadConversionResults.addAll(lcResultList);
        }

        Set<Id> convertedLeadIds = new Set<Id>();
        List<String> vars = new List<String>();
        for (Database.LeadConvertResult lcr : leadConversionResults) {
            try {
                if (lcr.isSuccess()) {
                    convertedLeadIds.add(lcr.getLeadId());
                } else
                    throw new LeadConversionException('Failed Lead Conversion');
            } catch (Exception e) {
                vars.add(ErrorLogger.convertIdToJSON('Lead Id', lcr.getLeadId()));
            }
        }
        if (vars != null && vars.size() > 0) {
            Exception e = new LeadConversionException('Failed Lead Conversion');
            ErrorLogger.log(e, vars, false);
        }

        // Map convert lead data to associated opportunities, if any
        if (convertedLeadIds.size() > 0) {
            List<Opportunity> oppsToUpdate = OpportunityService.mapLeadDataToOpportunity(convertedLeadIds);
            update oppsToUpdate;

            /*
             * Create necessary records and perform data processing as a result of lead conversion
             */
            for (Lead l : leadsToConvert) {
                // If Leads has Last Institution Attended populated, add to the List that
                // needs a Previous Education entry added
                if (l.Last_Institution_Attended__c != null) {
                    leadsNeedingPreviousEducation.add(l.Id);
                }
            }

            if (leadsNeedingPreviousEducation.size() > 0) {
                List<Previous_Education__c> previousEducationList = LeadService.createConvertedPreviousEducation(
                    leadsNeedingPreviousEducation
                );
                insert previousEducationList;
            }
        }
    }

    class LeadConversionException extends Exception {
    }
}