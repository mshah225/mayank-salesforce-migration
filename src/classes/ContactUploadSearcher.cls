public without sharing class ContactUploadSearcher {
    private List<Contact_Upload_Detail__c> detailsToSearch;
    private Map<String, Contact_Upload_Detail__c> emplIdToOriginalDetail = new Map<String, Contact_Upload_Detail__c>();
    private Map<String, Contact_Upload_Detail__c> asuriteToOriginalDetail = new Map<String, Contact_Upload_Detail__c>();
    private Map<String, Contact_Upload_Detail__c> firstNameAndEmailToOriginalDetail = new Map<String, Contact_Upload_Detail__c>();
    private Set<String> firstNameSet = new Set<String>();
    private Set<String> emailSet = new Set<String>();
    private Map<String, Contact_Upload_Detail__c> firstLastBirthdatePostalToOriginalDetail = new Map<String, Contact_Upload_Detail__c>();
    private Set<String> lastNameSet = new Set<String>();
    private Set<Date> birthdateSet = new Set<Date>();
    private Set<String> postalCodeSet = new Set<String>();
    private Map<String, Contact_Upload_Detail__c> firstLastPhoneToOriginalDetail = new Map<String, Contact_Upload_Detail__c>();
    private Set<String> phoneSet = new Set<String>();
    private List<Contact> matchedContacts;
    private List<Contact_Upload_Detail__c> unmatchedDetails = new List<Contact_Upload_Detail__c>();
    private Map<Contact_Upload_Detail__c, Contact> unmappedDetailToContact = new Map<Contact_Upload_Detail__c, Contact>();

    public ContactUploadSearcher(List<Contact_Upload_Detail__c> detailsToSearch) {
        this.detailsToSearch = detailsToSearch;
    }

    public void searchAndCreateContacts() {
        searchForContacts();
        insertContactsForUnmatchedDetails();
    }

    public void searchForContacts() {
        createDataMappingForSearch();
        getContactsMatchedByMappedValues();
        associateDetailsWithMatchedContacts();
    }

    public void searchContactsToMatch() {
        createDataMappingForSearch();
        searchContactsForMappedValues();
        associateDetailsWithMatchedContacts();
    }

    private void createDataMappingForSearch() {
        for (Contact_Upload_Detail__c detail : detailsToSearch) {
            mapEmplIdIfPresent(detail);
            mapAsuRiteIfPresent(detail);
            mapFirstNameAndEmailIfPresent(detail);
        }
    }

    private void mapEmplIdIfPresent(Contact_Upload_Detail__c detail) {
        if (!String.isBlank(detail.Emplid__c)) {
            emplIdToOriginalDetail.put((detail.Emplid__c).toLowerCase(), detail);
        }
    }

    private void mapAsuRiteIfPresent(Contact_Upload_Detail__c detail) {
        if (!String.isBlank(detail.ASURITE__c)) {
            asuriteToOriginalDetail.put((detail.ASURITE__c).toLowerCase(), detail);
        }
    }

    private void mapFirstNameAndEmailIfPresent(Contact_Upload_Detail__c detail) {
        if (!String.isBlank(detail.First_Name__c) && !String.isBlank(detail.Email__c)) {
            firstNameAndEmailToOriginalDetail.put((detail.First_Name__c + detail.Email__c).toLowerCase(), detail);
            firstNameSet.add(detail.First_Name__c);
            emailSet.add(detail.Email__c);
        }
    }

    private void mapFirstLastBirthdateAndPostalIfPresent(Contact_Upload_Detail__c detail) {
        if (
            !String.isBlank(detail.First_Name__c) &&
            !String.isBlank(detail.Last_Name__c) &&
            !String.isBlank(detail.Birthdate__c) &&
            !String.isBlank(detail.Postal_Code__c)
        ) {
            firstLastBirthdatePostalToOriginalDetail.put(
                (detail.First_Name__c +
                    detail.Last_Name__c +
                    Date.valueOf(detail.Birthdate__c) +
                    detail.Postal_Code__c)
                    .toLowerCase(),
                detail
            );
            firstNameSet.add(detail.First_Name__c);
            lastNameSet.add(detail.Last_Name__c);
            birthdateSet.add(Date.valueOf(detail.Birthdate__c));
            postalCodeSet.add(detail.Postal_Code__c);
        }
    }

    private void mapFirstLastAndPhoneIfPresent(Contact_Upload_Detail__c detail) {
        if (
            !String.isBlank(detail.First_Name__c) &&
            !String.isBlank(detail.Last_Name__c) &&
            !String.isBlank(detail.Phone__c)
        ) {
            firstLastPhoneToOriginalDetail.put(
                (detail.First_Name__c + detail.Last_Name__c + detail.Phone__c).toLowerCase(),
                detail
            );
            firstNameSet.add(detail.First_Name__c);
            lastNameSet.add(detail.Last_Name__c);
            phoneSet.add(detail.Phone__c);
        }
    }

    private void searchContactsForMappedValues() {
        if (!(detailsToSearch.isEmpty()) && detailsToSearch[0].Subscription__c != null) {
            getContactsMatchedByMappedValuesAndSubscriptionId();
        } else {
            getContactsMatchedByMappedValues();
        }
    }

    private void getContactsMatchedByMappedValuesAndSubscriptionId() {
        matchedContacts = [
            SELECT
                EMPLID__c,
                AsuRite_Id__c,
                FirstName,
                Email,
                Lead_Email__c,
                Lead_Secondary_Email__c,
                Personal_Email__c,
                ASU_Email__c,
                ASU_Gmail__c,
                EPO_Email__c,
                LastName,
                Birthdate,
                MailingPostalCode,
                HomePhone,
                MobilePhone,
                SF_Mobile__c,
                Phone,
                OtherPhone,
                MailingStreet
            FROM Contact
            WHERE
                ((FirstName IN :firstNameSet
                AND (Email IN :emailSet
                OR Lead_Email__c IN :emailSet
                OR Lead_Secondary_Email__c IN :emailSet
                OR Personal_Email__c IN :emailSet
                OR ASU_Email__c IN :emailSet
                OR ASU_Gmail__c IN :emailSet
                OR EPO_Email__c IN :emailSet))
                OR AsuRite_Id__c IN :asuriteToOriginalDetail.keySet()
                OR EMPLID__c IN :emplIdToOriginalDetail.keySet())
                AND Id IN (
                    SELECT Contact__c
                    FROM Subscriber__c
                    WHERE Subscription__c = :detailsToSearch[0].Subscription__c
                )
        ];
    }

    private void getContactsMatchedByMappedValues() {
        matchedContacts = [
            SELECT
                EMPLID__c,
                AsuRite_Id__c,
                FirstName,
                Email,
                Lead_Email__c,
                Lead_Secondary_Email__c,
                Personal_Email__c,
                ASU_Email__c,
                ASU_Gmail__c,
                EPO_Email__c,
                LastName,
                Birthdate,
                MailingPostalCode,
                HomePhone,
                MobilePhone,
                SF_Mobile__c,
                Phone,
                OtherPhone,
                MailingStreet
            FROM Contact
            WHERE
                (FirstName IN :firstNameSet
                AND (Email IN :emailSet
                OR Lead_Email__c IN :emailSet
                OR Lead_Secondary_Email__c IN :emailSet
                OR Personal_Email__c IN :emailSet
                OR ASU_Email__c IN :emailSet
                OR ASU_Gmail__c IN :emailSet
                OR EPO_Email__c IN :emailSet))
                OR AsuRite_Id__c IN :asuriteToOriginalDetail.keySet()
                OR EMPLID__c IN :emplIdToOriginalDetail.keySet()
        ];
    }

    private void associateDetailsWithMatchedContacts() {
        for (Contact contactMatch : matchedContacts) {
            if (matchByEmplId(contactMatch)) {
            } else if (matchByAsurite(contactMatch)) {
            } else if (matchByFirstNameAndEmail(contactMatch)) {
            } else if (matchByFirstNameAndLeadEmail(contactMatch)) {
            } else if (matchByFirstNameAndLeadSecondaryEmail(contactMatch)) {
            } else if (matchByFirstNameAndPersonalEmail(contactMatch)) {
            } else if (matchByFirstNameAndAsuGmail(contactMatch)) {
            } else if (matchByFirstNameAndEpoEmail(contactMatch)) {
            } else if (matchByFirstNameAndAsuEmail(contactMatch)) {
            }
        }
    }

    private Boolean matchByEmplId(Contact contactMatch) {
        if (
            contactMatch.EMPLID__c != null && emplIdToOriginalDetail.containsKey((contactMatch.EMPLID__c).toLowerCase())
        ) {
            Contact_Upload_Detail__c matchedDetail = emplIdToOriginalDetail.get((contactMatch.EMPLID__c).toLowerCase());
            matchedDetail.Contact__c = contactMatch.Id;
            matchedDetail.Processing_Notes__c += String.format(
                ' Found existing Contact ID: {0} Based on EmplId match: {1}',
                new List<String>{ contactMatch.Id, contactMatch.EMPLID__c }
            );
            return true;
        }
        return false;
    }

    private Boolean matchByAsurite(Contact contactMatch) {
        if (
            contactMatch.AsuRite_Id__c != null &&
            asuriteToOriginalDetail.containsKey((contactMatch.AsuRite_Id__c).toLowerCase())
        ) {
            Contact_Upload_Detail__c matchedDetail = asuriteToOriginalDetail.get(
                (contactMatch.AsuRite_Id__c).toLowerCase()
            );
            matchedDetail.Contact__c = contactMatch.Id;
            matchedDetail.Processing_Notes__c += String.format(
                ' Found existing Contact ID: {0} Based on ASURITE match: {1}',
                new List<String>{ contactMatch.Id, contactMatch.AsuRite_Id__c }
            );
            return true;
        }
        return false;
    }

    private Boolean matchByFirstNameAndEmail(Contact contactMatch) {
        if (
            contactMatch.FirstName != null &&
            contactMatch.Email != null &&
            firstNameAndEmailToOriginalDetail.containsKey((contactMatch.FirstName + contactMatch.Email).toLowerCase())
        ) {
            Contact_Upload_Detail__c matchedDetail = firstNameAndEmailToOriginalDetail.get(
                (contactMatch.FirstName + contactMatch.Email).toLowerCase()
            );
            matchedDetail.Contact__c = contactMatch.Id;
            matchedDetail.Processing_Notes__c += String.format(
                ' Found existing Contact ID: {0} Based on email match: {1} and name match: {2}',
                new List<String>{ contactMatch.Id, contactMatch.Email, contactMatch.FirstName }
            );
            return true;
        }
        return false;
    }

    private Boolean matchByFirstNameAndLeadEmail(Contact contactMatch) {
        if (
            contactMatch.FirstName != null &&
            contactMatch.Lead_Email__c != null &&
            firstNameAndEmailToOriginalDetail.containsKey(
                (contactMatch.FirstName + contactMatch.Lead_Email__c).toLowerCase()
            )
        ) {
            Contact_Upload_Detail__c matchedDetail = firstNameAndEmailToOriginalDetail.get(
                (contactMatch.FirstName + contactMatch.Lead_Email__c).toLowerCase()
            );
            matchedDetail.Contact__c = contactMatch.Id;
            matchedDetail.Processing_Notes__c += String.format(
                ' Found existing Contact ID: {0} Based on lead email match: {1} and name match: {2}',
                new List<String>{ contactMatch.Id, contactMatch.Lead_Email__c, contactMatch.FirstName }
            );
            return true;
        }
        return false;
    }

    private Boolean matchByFirstNameAndLeadSecondaryEmail(Contact contactMatch) {
        if (
            contactMatch.FirstName != null &&
            contactMatch.Lead_Secondary_Email__c != null &&
            firstNameAndEmailToOriginalDetail.containsKey(
                (contactMatch.FirstName + contactMatch.Lead_Secondary_Email__c).toLowerCase()
            )
        ) {
            Contact_Upload_Detail__c matchedDetail = firstNameAndEmailToOriginalDetail.get(
                (contactMatch.FirstName + contactMatch.Lead_Secondary_Email__c).toLowerCase()
            );
            matchedDetail.Contact__c = contactMatch.Id;
            matchedDetail.Processing_Notes__c += String.format(
                ' Found existing Contact ID: {0} Based on lead secondary email match: {1} and name match: {2}',
                new List<String>{ contactMatch.Id, contactMatch.Lead_Secondary_Email__c, contactMatch.FirstName }
            );
            return true;
        }
        return false;
    }

    private Boolean matchByFirstNameAndPersonalEmail(Contact contactMatch) {
        if (
            contactMatch.FirstName != null &&
            contactMatch.Personal_Email__c != null &&
            firstNameAndEmailToOriginalDetail.containsKey(
                (contactMatch.FirstName + contactMatch.Personal_Email__c).toLowerCase()
            )
        ) {
            Contact_Upload_Detail__c matchedDetail = firstNameAndEmailToOriginalDetail.get(
                (contactMatch.FirstName + contactMatch.Personal_Email__c).toLowerCase()
            );
            matchedDetail.Contact__c = contactMatch.Id;
            matchedDetail.Processing_Notes__c += String.format(
                ' Found existing Contact ID: {0} Based on personal email match: {1} and name match: {2}',
                new List<String>{ contactMatch.Id, contactMatch.Personal_Email__c, contactMatch.FirstName }
            );
            return true;
        }
        return false;
    }

    private Boolean matchByFirstNameAndAsuGmail(Contact contactMatch) {
        if (
            contactMatch.FirstName != null &&
            contactMatch.ASU_Gmail__c != null &&
            firstNameAndEmailToOriginalDetail.containsKey(
                (contactMatch.FirstName + contactMatch.ASU_Gmail__c).toLowerCase()
            )
        ) {
            Contact_Upload_Detail__c matchedDetail = firstNameAndEmailToOriginalDetail.get(
                (contactMatch.FirstName + contactMatch.ASU_Gmail__c).toLowerCase()
            );
            matchedDetail.Contact__c = contactMatch.Id;
            matchedDetail.Processing_Notes__c += String.format(
                ' Found existing Contact ID: {0} Based on ASU Gmail email match: {1} and name match: {2}',
                new List<String>{ contactMatch.Id, contactMatch.ASU_Gmail__c, contactMatch.FirstName }
            );
            return true;
        }
        return false;
    }

    private Boolean matchByFirstNameAndEpoEmail(Contact contactMatch) {
        if (
            contactMatch.FirstName != null &&
            contactMatch.EPO_Email__c != null &&
            firstNameAndEmailToOriginalDetail.containsKey(
                (contactMatch.FirstName + contactMatch.EPO_Email__c).toLowerCase()
            )
        ) {
            Contact_Upload_Detail__c matchedDetail = firstNameAndEmailToOriginalDetail.get(
                (contactMatch.FirstName + contactMatch.EPO_Email__c).toLowerCase()
            );
            matchedDetail.Contact__c = contactMatch.Id;
            matchedDetail.Processing_Notes__c += String.format(
                ' Found existing Contact ID: {0} Based on EPO email match: {1} and name match: {2}',
                new List<String>{ contactMatch.Id, contactMatch.EPO_Email__c, contactMatch.FirstName }
            );
            return true;
        }
        return false;
    }

    private Boolean matchByFirstNameAndAsuEmail(Contact contactMatch) {
        if (
            contactMatch.FirstName != null &&
            contactMatch.ASU_Email__c != null &&
            firstNameAndEmailToOriginalDetail.containsKey(
                (contactMatch.FirstName + contactMatch.ASU_Email__c).toLowerCase()
            )
        ) {
            Contact_Upload_Detail__c matchedDetail = firstNameAndEmailToOriginalDetail.get(
                (contactMatch.FirstName + contactMatch.ASU_Email__c).toLowerCase()
            );
            matchedDetail.Contact__c = contactMatch.Id;
            matchedDetail.Processing_Notes__c += String.format(
                ' Found existing Contact ID: {0} Based on ASU email match: {1} and name match: {2}',
                new List<String>{ contactMatch.Id, contactMatch.ASU_Email__c, contactMatch.FirstName }
            );
            return true;
        }
        return false;
    }

    private void markUnmatchedDetails() {
        for (Contact_Upload_Detail__c processedDetail : detailsToSearch) {
            if (processedDetail.Contact__c == null) {
                unmatchedDetails.add(processedDetail);
            }
        }
    }

    private void insertContactsForUnmatchedDetails() {
        List<Contact> newUnmatchedContacts = new List<Contact>();
        List<Contact_Upload_Detail__c> unmatchedDetails = new List<Contact_Upload_Detail__c>();
        for (Contact_Upload_Detail__c processedDetail : detailsToSearch) {
            if (processedDetail.Contact__c == null) {
                Contact createdContact = createContact(processedDetail);
                newUnmatchedContacts.add(createdContact);
                unmatchedDetails.add(processedDetail);
                unmappedDetailToContact.put(processedDetail, createdContact);
            }
        }

        Database.SaveResult[] saveResults = Database.insert(newUnmatchedContacts, false);
        for (Integer i = 0; i < saveResults.size(); i++) {
            if (!saveResults[i].isSuccess()) {
                Contact_Upload_Detail__c erroredDetail = unmatchedDetails[i];
                erroredDetail.Status__c = 'Error';
                erroredDetail.Processing_Notes__c += ' Error(s) creating Contact: ';
                for (Database.Error saveError : saveResults[i].getErrors()) {
                    erroredDetail.Processing_Notes__c += saveError.getMessage();
                }
            }
        }
        associateContactsToUploadDetails();
    }

    private Contact createContact(Contact_Upload_Detail__c unmatchedDetail) {
        Contact createdContact = new Contact(
            MailingStreet = unmatchedDetail.Address__c,
            ASURite_ID__c = unmatchedDetail.ASURITE__c,
            Birthdate = unmatchedDetail.Birthdate__c == null ? null : Date.valueOf(unmatchedDetail.Birthdate__c),
            MailingCity = unmatchedDetail.City__c,
            MailingCountry = unmatchedDetail.Country__c,
            Email = unmatchedDetail.Email__c,
            FirstName = unmatchedDetail.First_Name__c,
            LastName = unmatchedDetail.Last_Name__c,
            Phone = unmatchedDetail.Phone__c,
            MailingPostalCode = unmatchedDetail.Postal_Code__c,
            MailingState = unmatchedDetail.State__c
        );
        return createdContact;
    }

    private void associateContactsToUploadDetails() {
        for (Contact_Upload_Detail__c unmatchedDetail : unmappedDetailToContact.keySet()) {
            if (unmatchedDetail.Status__c == 'Error') {
                continue;
            }
            unmatchedDetail.Contact__c = unmappedDetailToContact.get(unmatchedDetail).Id;
            if (unmatchedDetail.EMPLID__c != null) {
                unmatchedDetail.Processing_Notes__c +=
                    ' No matching EMPLID; Created new SF Mastered Contact: ' + unmatchedDetail.Contact__c;
            } else {
                unmatchedDetail.Processing_Notes__c += ' Created new Contact: ' + unmatchedDetail.Contact__c;
            }
        }
    }
}
