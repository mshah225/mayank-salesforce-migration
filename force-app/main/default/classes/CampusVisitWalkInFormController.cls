public with sharing class CampusVisitWalkInFormController {
    @AuraEnabled
    public static Campaign searchCampaign(String campaignRecordId) {
        List<Campaign> campaignRecord = [
            SELECT Name, Event_Start_Date__c, Event_Start_Time__c
            FROM Campaign
            WHERE Id = :campaignRecordId
            LIMIT 1
        ];

        if (campaignRecord.size() > 0) {
            return campaignRecord[0];
        }

        return null;
    }

    @AuraEnabled
    public static List<Contact> searchContact(Contact conToSearch) {
        
        List<Contact> matchedDetailsWithContacts = Database.query(buildContactQuery(conToSearch));

        String soslSearch = buildContactSosl(conToSearch);
        if (matchedDetailsWithContacts.size() == 0 && (conToSearch.FirstName != null || conToSearch.LastName != null)) {
            matchedDetailsWithContacts = Search.query(soslSearch);
        }

        if (matchedDetailsWithContacts.size() > 0) {
            return matchedDetailsWithContacts;
        }

        return null;
    }

    private static String buildContactQuery(Contact conToSearch) {
        String query = 'SELECT Id, ASURITE_ID__c, FirstName, LastName, Middle_Name__c, Name, Phone, Email, MailingStreet, MailingPostalCode, Birthdate, Country_of_Citizenship__c, ' 
        + ' MailingState, MailingCountry, MailingCountryCode ' 
        + 'FROM Contact '
        + 'WHERE ';

        if (!String.isBlank(conToSearch.ASURite_ID__c)) {
            query += 'ASURite_ID__c = \'' + conToSearch.ASURite_ID__c.trim() + '\' ';
        } else {
            if (!String.isBlank(conToSearch.FirstName)) {
                query += 'FirstName = \'' + conToSearch.FirstName.trim() + '\' AND ';
            }
            if (!String.isBlank(conToSearch.LastName)) {
                query += 'LastName = \'' + conToSearch.LastName.trim() + '\' AND ';
            }
            if (!String.isBlank(conToSearch.Phone)) {
                query += 'Phone = \'' + conToSearch.Phone + '\' AND ';
            }
            if (!String.isBlank(conToSearch.MailingPostalCode)) {
                query += 'MailingPostalCode = \'' + conToSearch.MailingPostalCode + '\' AND ';
            }
            if (!String.isBlank(conToSearch.Email)) {
                query += 'Email = \'' + conToSearch.Email.trim() + '\' AND ';
            }
            if (conToSearch.Birthdate != null) {
                query += 'Birthdate = \'' + conToSearch.Birthdate + '\' AND ';
            }

            query = query.removeEnd(' AND ');
        }

        return query;
    }

    private static String buildContactSosl(Contact conToSearch) {
        String temp = 'FIND {' + conToSearch.FirstName + ' ' + conToSearch.LastName + '} IN NAME FIELDS ' +
        'RETURNING Contact(ASURITE_ID__c, FirstName, LastName, Middle_Name__c, Name, Phone, Email, MailingStreet, MailingPostalCode, Birthdate, Country_of_Citizenship__c, ' +
        ' MailingState, MailingCountry, MailingCountryCode ' +
        ' WHERE ';

        if (!String.isBlank(conToSearch.Phone)) {
            temp += 'Phone = \'' + conToSearch.Phone + '\' AND ';
        }
        if (!String.isBlank(conToSearch.MailingPostalCode)) {
            temp += 'MailingPostalCode = \'' + conToSearch.MailingPostalCode + '\' AND ';
        }
        if (!String.isBlank(conToSearch.Email)) {
            temp += 'Email = \'' + conToSearch.Email.trim() + '\' AND ';
        }
        if (conToSearch.Birthdate != null) {
            temp += 'Birthdate = \'' + conToSearch.Birthdate + '\' AND ';
        }

        temp = temp.removeEnd(' AND ');
        temp = temp.removeEnd(' WHERE ');

        temp += ') WITH SPELL_CORRECTION = true';

        

        return temp;
    }

    @AuraEnabled
    public static List<Opportunity> getOpportunities(String contactId) {
        List<Opportunity> oppsForContact = [
            SELECT Name, Career__c, Type, International_Student__c, StageName, Term__r.Name, College__r.Name, Plan__c
            FROM Opportunity
            WHERE Contact__r.Id = :contactId AND CloseDate > TODAY
        ];

        return oppsForContact;
    }

    @AuraEnabled
    public static String submitRecordsForWalkin(
        Contact contactRecordSubmitted,
        CampaignMember campaignMemberSubmitted,
        Opportunity opportunityRecordSubmitted
    ) {
        String result;
        try {
            result = 'Contact Record Failed to be created/updated';
            contactRecordSubmitted = handleContactRecordSubmission(contactRecordSubmitted);

            result = 'Opportunity Record Failed to be created/updated';
            if (contactRecordSubmitted.Id != null) {
                opportunityRecordSubmitted = handleOpportunityRecordSubmission(
                    opportunityRecordSubmitted,
                    contactRecordSubmitted.Id
                );

                result = 'Campaign Member Record Failed to be created/updated';
                if (opportunityRecordSubmitted.Id != null) {
                    handleCampaignMemberRecordSubmission(
                        campaignMemberSubmitted,
                        contactRecordSubmitted.Id,
                        opportunityRecordSubmitted.Id
                    );
                }
            }
        } catch (Exception e) {
            return result;
        }

        return null;
    }

    private static Contact handleContactRecordSubmission(Contact conIn) {
        if (conIn.RecordType == null) {
            conIn.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
                .get('SF_Mastered')
                .getRecordTypeId();
        }

        Database.upsert(conIn);

        return conIn;
    }

    private static Boolean handleCampaignMemberRecordSubmission(
        CampaignMember camMemberIn,
        Id contactId,
        Id opportunityId
    ) {
        camMemberIn.ContactId = contactId;
        camMemberIn.Opportunity__c = opportunityId;

        Database.insert(camMemberIn);
        return false;
    }

    private static Opportunity handleOpportunityRecordSubmission(Opportunity oppIn, Id contactId) {

        if (oppIn.Id == null) {
            Contact contactWithAccountValue = [
                SELECT Id, AccountId, FirstName, LastName
                FROM Contact
                WHERE Id = :contactId
                LIMIT 1
            ];
            
            oppIn.Contact__c = contactWithAccountValue.Id;
            oppIn.AccountId = contactWithAccountValue.AccountId;
            oppIn.Name =
                contactWithAccountValue.FirstName +
                ' ' +
                contactWithAccountValue.LastName +
                ' ' +
                String.valueOf(Date.today()).removeEnd(' 00:00:00');
            oppIn.StageName = 'Prospect';

            if (oppIn.Term__c != null) {
                Term__c termForOpp = [SELECT Session_A_C_Start_Date__c FROM Term__c WHERE Id = :oppIn.Term__c LIMIT 1];
                Date closeDate = termForOpp.Session_A_C_Start_Date__c.addDays(21);
                oppIn.CloseDate = closeDate;
            } else {
                oppIn.CloseDate = Date.today().addDays(21);
            }

            if (oppIn.Career__c == 'Undergraduate') {
                oppIn.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                    .get('Undergraduate_Prospect')
                    .getRecordTypeId();
            } else if (oppIn.Career__c == 'Graduate') {
                oppIn.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                    .get('Graduate_Prospect')
                    .getRecordTypeId();
            }
        }

        Database.upsert(oppIn);

        return oppIn;
    }
}