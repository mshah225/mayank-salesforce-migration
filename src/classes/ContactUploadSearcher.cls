public without sharing class ContactUploadSearcher {
    private List<Contact_Upload_Detail__c> detailsToSearch;
    private List<ConstituentDetail> constituentDetailsToSearch;
    private List<ConstituentDetail> matchedDetailsWithContacts;
    private List<ConstituentDetail> unmatchedDetails = new List<ConstituentDetail>();
    private List<Contact> matchedContacts;
    private List<Contact> contactsWithoutInitialMatch;
    private Map<ConstituentDetail, Contact> unmappedDetailToContact = new Map<ConstituentDetail, Contact>();
    private ConstituentMatcher matcher;
    private Map<String, ConstituentDetail> emplidWithDetail = new Map<String, ConstituentDetail>();
    private Map<String, ConstituentDetail> asuriteWithDetail = new Map<String, ConstituentDetail>();
    private Map<String, ConstituentDetail> firstNameAndEmailWithDetail = new Map<String, ConstituentDetail>();
    private Map<String, ConstituentDetail> firstNameWildcardAndEmailToOriginalDetail = new Map<String, ConstituentDetail>();
    private Set<String> firstNameSet = new Set<String>();
    private Set<String> firstNameWildcardSet = new Set<String>();
    private Set<String> emailSet = new Set<String>();

    public ContactUploadSearcher(List<Contact_Upload_Detail__c> detailsToSearch) {
        this.detailsToSearch = detailsToSearch;
        translateContactUploadDetailToConstituentDetail();
    }

    public void translateContactUploadDetailToConstituentDetail() {
        List<ConstituentDetail> listOfConstituents = new List<ConstituentDetail>();
        for (Contact_Upload_Detail__c contactUploadDetail : detailsToSearch) {
            Map<String, String> detailFieldsMap = new Map<String, String>();
            detailFieldsMap.put('asuriteId', contactUploadDetail.ASURITE__c);
            detailFieldsMap.put('birthdate', contactUploadDetail.Birthdate__c);
            detailFieldsMap.put('email', contactUploadDetail.Email__c);
            detailFieldsMap.put('emplid', contactUploadDetail.EMPLID__c);
            detailFieldsMap.put('firstName', contactUploadDetail.First_Name__c);
            detailFieldsMap.put('lastName', contactUploadDetail.Last_Name__c);
            detailFieldsMap.put('mailingCity', contactUploadDetail.City__c);
            detailFieldsMap.put('mailingCountry', contactUploadDetail.Country__c);
            detailFieldsMap.put('mailingPostalCode', contactUploadDetail.Postal_Code__c);
            detailFieldsMap.put('mailingState', contactUploadDetail.State__c);
            detailFieldsMap.put('mailingStreet', contactUploadDetail.Address__c);
            detailFieldsMap.put('phone', contactUploadDetail.Phone__c);
            
            ConstituentDetail constituentDetail = new ConstituentDetail(detailFieldsMap);
            listOfConstituents.add(constituentDetail);
        }
        this.constituentDetailsToSearch = listOfConstituents;
    }

    public void searchAndCreateContacts() {
        matcher = new ConstituentMatcher(constituentDetailsToSearch);
        matcher.searchContacts();
        matchedDetailsWithContacts = matcher.getListOfConstituentsWithMatches();
        insertContactsForUnmatchedDetails();
    }

    public void searchContactsToMatch() {
        matcher = new ConstituentMatcher(constituentDetailsToSearch);
        matcher.createDataMappingForSearch();
        searchContactsForMappedValues();
        matcher.associateDetailsWithMatchedContacts();
    }

    private void searchContactsForMappedValues() {
        if (!(detailsToSearch.isEmpty()) && detailsToSearch[0].Subscription__c != null) {
            getContactsMatchedByMappedValuesAndSubscriptionId();
        } else {
            matcher.getContactsMatchedByMappedValues();
        }
    }

    private void getContactsMatchedByMappedValuesAndSubscriptionId() {
        asuriteWithDetail = matcher.getAsuriteWithDetailMap;
        emplidWithDetail = matcher.getEmplidWithDetailMap;
        emailSet = matcher.getEmailSet();
        firstNameSet = matcher.getfirstNameSet();
        firstNameWildcardSet = matcher.getFirstNameWildcardSet();

        matchedContacts =  [
            SELECT EMPLID__c, AsuRite_Id__c, FirstName, Email, Lead_Email__c, Lead_Secondary_Email__c, Personal_Email__c,
                ASU_Email__c, ASU_Gmail__c, EPO_Email__c, LastName, Birthdate, MailingPostalCode, HomePhone,
                MobilePhone, SF_Mobile__c, Phone, OtherPhone, MailingStreet
            FROM Contact
            WHERE (
                (
                    (FirstName IN :firstNameSet OR FirstName LIKE :firstNameWildcardSet)
                    AND (Email IN :emailSet
                        OR Lead_Email__c IN :emailSet
                        OR Lead_Secondary_Email__c IN :emailSet
                        OR Personal_Email__c IN :emailSet
                        OR ASU_Email__c IN :emailSet
                        OR ASU_Gmail__c IN :emailSet
                        OR EPO_Email__c IN :emailSet
                    )
                )
                OR AsuRite_Id__c IN :asuriteWithDetail.keySet()
                OR EMPLID__c IN :emplidWithDetail.keySet()
            ) AND Id IN (SELECT Contact__c FROM Subscriber__c WHERE Subscription__c = :detailsToSearch[0].Subscription__c)
            ORDER By RecordType.Name ASC
        ];
    }

    private void markUnmatchedDetails() {
        for (ConstituentDetail processedDetail : constituentDetailsToSearch) {
            if (processedDetail.contactId == null) {
                unmatchedDetails.add(processedDetail);
            }
        }
    }

    private void insertContactsForUnmatchedDetails() {
        List<Contact> newUnmatchedContacts = new List<Contact>();
        List<ConstituentDetail> unmatchedDetails = new List<ConstituentDetail>();
        for (ConstituentDetail processedDetail : constituentDetailsToSearch) {
            if (processedDetail.contactId == null) {
                Contact createdContact = createContact(processedDetail);
                newUnmatchedContacts.add(createdContact);
                unmatchedDetails.add(processedDetail);
                unmappedDetailToContact.put(processedDetail, createdContact);
            }
        }

        Database.SaveResult[] saveResults = Database.insert(newUnmatchedContacts, false);
        for (Integer i = 0; i < saveResults.size(); i++) {
            if (!saveResults[i].isSuccess()) {
                ConstituentDetail erroredDetail = unmatchedDetails[i];
                erroredDetail.status = 'Error';
                erroredDetail.processingNotes += ' Error(s) creating Contact: ' + ' \n';
                for (Database.Error saveError : saveResults[i].getErrors()) {
                    erroredDetail.processingNotes += saveError.getMessage();
                }
            }
        }
        associateContactsToUploadDetails();
    }

    private Contact createContact(ConstituentDetail unmatchedDetail) {
        Contact createdContact = new Contact(
            MailingStreet = unmatchedDetail.mailingStreet,
            ASURite_ID__c = unmatchedDetail.asuriteId,
            Birthdate = unmatchedDetail.birthdate == null ? null : Date.valueOf(unmatchedDetail.birthdate),
            MailingCity = unmatchedDetail.mailingCity,
            MailingCountry = unmatchedDetail.mailingCountry,
            Email = unmatchedDetail.email,
            FirstName = unmatchedDetail.firstName,
            LastName = unmatchedDetail.lastName,
            Phone = unmatchedDetail.phone,
            MailingPostalCode = unmatchedDetail.mailingPostalCode,
            MailingState = unmatchedDetail.mailingState
        );
        return createdContact;
    }

    private void associateContactsToUploadDetails() {
        for (ConstituentDetail unmatchedDetail : unmappedDetailToContact.keySet()) {
            if (unmatchedDetail.status == 'Error') {
                continue;
            }
            unmatchedDetail.contactId = unmappedDetailToContact.get(unmatchedDetail).contactId;
            if (unmatchedDetail.emplid != null) {
                unmatchedDetail.processingNotes += ' No matching EMPLID; Created new SF Mastered Contact: ' + unmatchedDetail.contactId + ' \n';
            } else {
                unmatchedDetail.processingNotes += ' Created new Contact: ' + unmatchedDetail.contactId + ' \n';
            }
        }
    }
}
