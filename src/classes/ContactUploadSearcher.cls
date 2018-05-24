public class ContactUploadSearcher {
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
        // Search First, Last, PostalCode, street
        createDataMappingForSearch();
        searchContactsForMappedValues();
        associateDetailsWithMatchedContacts();
        insertContactsForUnmatchedDetails();
    }
    
    private void createDataMappingForSearch() {
        for (Contact_Upload_Detail__c detail : detailsToSearch) {
            mapEmplIdIfPresent(detail);
            mapAsuRiteIfPresent(detail);
            mapFirstNameAndEmailIfPresent(detail);
            mapFirstLastBirthdateAndPostalIfPresent(detail);
            mapFirstLastAndPhoneIfPresent(detail);
        }
    }
    
    private void mapEmplIdIfPresent(Contact_Upload_Detail__c detail) {
        if (!String.isBlank(detail.Emplid__c)) {
            emplIdToOriginalDetail.put(detail.Emplid__c, detail);
        }
    }
    
    private void mapAsuRiteIfPresent(Contact_Upload_Detail__c detail) {
        if (!String.isBlank(detail.ASURITE__c)) {
            asuriteToOriginalDetail.put(detail.ASURITE__c, detail);
        }
    }
    
    private void mapFirstNameAndEmailIfPresent(Contact_Upload_Detail__c detail) {
        System.debug(detail.First_Name__c + detail.Email__c);
        if (!String.isBlank(detail.First_Name__c) && !String.isBlank(detail.Email__c)) {
            firstNameAndEmailToOriginalDetail.put(detail.First_Name__c + detail.Email__c, detail);
            firstNameSet.add(detail.First_Name__c);
            emailSet.add(detail.Email__c);
        }
    }
    
    private void mapFirstLastBirthdateAndPostalIfPresent(Contact_Upload_Detail__c detail) {
        if (!String.isBlank(detail.First_Name__c) && 
                !String.isBlank(detail.Last_Name__c) && 
                !String.isBlank(detail.Birthdate__c) &&
                !String.isBlank(detail.Postal_Code__c)) {
            firstLastBirthdatePostalToOriginalDetail.put(
                detail.First_Name__c + detail.Last_Name__c + Date.valueOf(detail.Birthdate__c) + detail.Postal_Code__c, 
                detail);
            firstNameSet.add(detail.First_Name__c);
            lastNameSet.add(detail.Last_Name__c);
            birthdateSet.add(Date.valueOf(detail.Birthdate__c));
            postalCodeSet.add(detail.Postal_Code__c);
        }
    }
    
    private void mapFirstLastAndPhoneIfPresent(Contact_Upload_Detail__c detail) {
        if (!String.isBlank(detail.First_Name__c) && !String.isBlank(detail.Last_Name__c) && !String.isBlank(detail.Phone__c)) {
            firstLastPhoneToOriginalDetail.put(detail.First_Name__c + detail.Last_Name__c + detail.Phone__c, detail);
            firstNameSet.add(detail.First_Name__c);
            lastNameSet.add(detail.Last_Name__c);
            phoneSet.add(detail.Phone__c);
        }
    }
    
    private void searchContactsForMappedValues() {
        matchedContacts = [
            SELECT EMPLID__c, AsuRite_Id__c, FirstName, Email, Lead_Email__c, Lead_Secondary_Email__c, Personal_Email__c, 
                ASU_Email__c, ASU_Gmail__c, EPO_Email__c, LastName, Birthdate, MailingPostalCode, HomePhone,
                MobilePhone, SF_Mobile__c, Phone, OtherPhone, MailingStreet
            FROM Contact
            WHERE EMPLID__c IN :emplIdToOriginalDetail.keySet()
            OR AsuRite_Id__c IN :asuriteToOriginalDetail.keySet()
            OR (
                FirstName IN :firstNameSet 
                AND (Email IN :emailSet
                    OR Lead_Email__c IN :emailSet
                    OR Lead_Secondary_Email__c IN :emailSet
                    OR Personal_Email__c IN :emailSet
                    OR ASU_Email__c IN :emailSet
                    OR ASU_Gmail__c IN :emailSet
                    OR EPO_Email__c IN :emailSet
                )
            ) OR ( 
                FirstName IN :firstNameSet 
                AND LastName IN :lastNameSet 
                AND Birthdate IN :birthdateSet 
                AND MailingPostalCode IN :postalCodeSet
            ) OR (
                FirstName IN :firstNameSet 
                AND LastName IN :lastNameSet 
                AND (
                    HomePhone IN :phoneSet 
                    OR MobilePhone IN :phoneSet 
                    OR SF_Mobile__c IN :phoneSet 
                    OR Phone IN :phoneSet 
                    OR OtherPhone IN :phoneSet
                )
            )
        ];
        System.debug('Contacts:' +  matchedContacts);
    }
    
    private void associateDetailsWithMatchedContacts() {
        for (Contact contactMatch : matchedContacts) {
            if (matchByEmplId(contactMatch)) {}
            else if (matchByAsurite(contactMatch)) {}
            else if (matchByFirstNameAndEmail(contactMatch)) {}
            else if (matchByNameBirthdateAndPostal(contactMatch)) {}
            else if (matchByNameAndPhone(contactMatch)) {}
        }
    }
    
    private Boolean matchByEmplId(Contact contactMatch) {
        if (emplIdToOriginalDetail.containsKey(contactMatch.EMPLID__c)) {
            Contact_Upload_Detail__c matchedDetail = emplIdToOriginalDetail.get(contactMatch.EMPLID__c);
            matchedDetail.Contact__c = contactMatch.Id;
            matchedDetail.Processing_Notes__c += 
                String.format('Found existing Contact ID: {0} Based on EmplId match: {1}', 
                    new String[] {contactMatch.Id, contactMatch.EMPLID__c});
            return true;
        }
        return false;
    }
    
    private Boolean matchByAsurite(Contact contactMatch) {
        if (asuriteToOriginalDetail.containsKey(contactMatch.AsuRite_Id__c)) {
            Contact_Upload_Detail__c matchedDetail = asuriteToOriginalDetail.get(contactMatch.AsuRite_Id__c);
            matchedDetail.Contact__c = contactMatch.Id;
            matchedDetail.Processing_Notes__c += 
                String.format('Found existing Contact ID: {0} Based on ASURITE match: {1}', 
                    new String[] {contactMatch.Id, contactMatch.AsuRite_Id__c});
            return true;
        }
        return false;
    }
    
    private Boolean matchByFirstNameAndEmail(Contact contactMatch) {
        if (firstNameAndEmailToOriginalDetail.containsKey(contactMatch.FirstName + contactMatch.Email)) {
            Contact_Upload_Detail__c matchedDetail = firstNameAndEmailToOriginalDetail.get(contactMatch.FirstName + contactMatch.Email);
            matchedDetail.Contact__c = contactMatch.Id;
            matchedDetail.Processing_Notes__c += 
                String.format('Found existing Contact ID: {0} Based on email match: {1} and name match: {2}', 
                    new String[] {contactMatch.Id, contactMatch.Email, contactMatch.FirstName});
            return true;
        } else if (firstNameAndEmailToOriginalDetail.containsKey(contactMatch.FirstName + contactMatch.Lead_Email__c)) {
            Contact_Upload_Detail__c matchedDetail = firstNameAndEmailToOriginalDetail.get(contactMatch.FirstName + contactMatch.Lead_Email__c);
            matchedDetail.Contact__c = contactMatch.Id;
            matchedDetail.Processing_Notes__c += 
                String.format('Found existing Contact ID: {0} Based on lead email match: {1} and name match: {2}', 
                    new String[] {contactMatch.Id, contactMatch.Lead_Email__c, contactMatch.FirstName});
            return true;
        } else if (firstNameAndEmailToOriginalDetail.containsKey(contactMatch.FirstName + contactMatch.Lead_Secondary_Email__c)) {
            Contact_Upload_Detail__c matchedDetail = firstNameAndEmailToOriginalDetail.get(contactMatch.FirstName + contactMatch.Lead_Secondary_Email__c);
            matchedDetail.Contact__c = contactMatch.Id;
            matchedDetail.Processing_Notes__c += 
                String.format('Found existing Contact ID: {0} Based on lead secondary email match: {1} and name match: {2}', 
                    new String[] {contactMatch.Id, contactMatch.Lead_Secondary_Email__c, contactMatch.FirstName});
            return true;
        } else if (firstNameAndEmailToOriginalDetail.containsKey(contactMatch.FirstName + contactMatch.Personal_Email__c)) {
            Contact_Upload_Detail__c matchedDetail = firstNameAndEmailToOriginalDetail.get(contactMatch.FirstName + contactMatch.Personal_Email__c);
            matchedDetail.Contact__c = contactMatch.Id;
            matchedDetail.Processing_Notes__c += 
                String.format('Found existing Contact ID: {0} Based on personal email match: {1} and name match: {2}', 
                    new String[] {contactMatch.Id, contactMatch.Personal_Email__c, contactMatch.FirstName});
            return true;
        } else if (firstNameAndEmailToOriginalDetail.containsKey(contactMatch.FirstName + contactMatch.ASU_Gmail__c)) {
            Contact_Upload_Detail__c matchedDetail = firstNameAndEmailToOriginalDetail.get(contactMatch.FirstName + contactMatch.ASU_Gmail__c);
            matchedDetail.Contact__c = contactMatch.Id;
            matchedDetail.Processing_Notes__c += 
                String.format('Found existing Contact ID: {0} Based on ASU Gmail email match: {1} and name match: {2}', 
                    new String[] {contactMatch.Id, contactMatch.ASU_Gmail__c, contactMatch.FirstName});
            return true;
        } else if (firstNameAndEmailToOriginalDetail.containsKey(contactMatch.FirstName + contactMatch.EPO_Email__c)) {
            Contact_Upload_Detail__c matchedDetail = firstNameAndEmailToOriginalDetail.get(contactMatch.FirstName + contactMatch.EPO_Email__c);
            matchedDetail.Contact__c = contactMatch.Id;
            matchedDetail.Processing_Notes__c += 
                String.format('Found existing Contact ID: {0} Based on EPO email match: {1} and name match: {2}', 
                    new String[] {contactMatch.Id, contactMatch.EPO_Email__c, contactMatch.FirstName});
            return true;
        }
        return false;
    }
    
    private Boolean matchByNameBirthdateAndPostal(Contact contactMatch) {
        if (firstLastBirthdatePostalToOriginalDetail.containsKey(
                contactMatch.FirstName + 
                contactMatch.LastName + 
                contactMatch.Birthdate + 
                contactMatch.MailingPostalCode)) {
            Contact_Upload_Detail__c matchedDetail = firstLastBirthdatePostalToOriginalDetail.get(
                contactMatch.FirstName + 
                contactMatch.LastName + 
                contactMatch.Birthdate + 
                contactMatch.MailingPostalCode);
            matchedDetail.Contact__c = contactMatch.Id;
            matchedDetail.Processing_Notes__c += 
                String.format('Found existing Contact ID: {0} Based on name match: {1} birthdate match: {2} and postal code match: {3}', 
                    new String[] {contactMatch.Id, 
                        contactMatch.FirstName + contactMatch.LastName, 
                        String.valueOf(contactMatch.Birthdate), 
                        contactMatch.MailingPostalCode});
            return true;
        }
        return false;
    }
    
    private Boolean matchByNameAndPhone(Contact contactMatch) {
        if (firstLastPhoneToOriginalDetail.containsKey(contactMatch.FirstName + contactMatch.LastName + contactMatch.HomePhone)) {
            Contact_Upload_Detail__c matchedDetail = firstLastPhoneToOriginalDetail.get(
                contactMatch.FirstName + contactMatch.LastName + contactMatch.HomePhone);
            matchedDetail.Contact__c = contactMatch.Id;
            matchedDetail.Processing_Notes__c += 
                String.format('Found existing Contact ID: {0} Based on name match: {1} and phone match: {2}', 
                    new String[] {contactMatch.Id, contactMatch.FirstName + contactMatch.LastName, contactMatch.HomePhone});
            return true;
        } else if (firstLastPhoneToOriginalDetail.containsKey(contactMatch.FirstName + contactMatch.LastName + contactMatch.MobilePhone)) {
            Contact_Upload_Detail__c matchedDetail = firstLastPhoneToOriginalDetail.get(
                contactMatch.FirstName + contactMatch.LastName + contactMatch.MobilePhone);
            matchedDetail.Contact__c = contactMatch.Id;
            matchedDetail.Processing_Notes__c += 
                String.format('Found existing Contact ID: {0} Based on name match: {1} and phone match: {2}', 
                    new String[] {contactMatch.Id, contactMatch.FirstName + contactMatch.LastName, contactMatch.MobilePhone});
            return true;
        } else if (firstLastPhoneToOriginalDetail.containsKey(contactMatch.FirstName + contactMatch.LastName + contactMatch.SF_Mobile__c)) {
            Contact_Upload_Detail__c matchedDetail = firstLastPhoneToOriginalDetail.get(
                contactMatch.FirstName + contactMatch.LastName + contactMatch.SF_Mobile__c);
            matchedDetail.Contact__c = contactMatch.Id;
            matchedDetail.Processing_Notes__c += 
                String.format('Found existing Contact ID: {0} Based on name match: {1} and phone match: {2}', 
                    new String[] {contactMatch.Id, contactMatch.FirstName + contactMatch.LastName, contactMatch.SF_Mobile__c});
            return true;
        } else if (firstLastPhoneToOriginalDetail.containsKey(contactMatch.FirstName + contactMatch.LastName + contactMatch.Phone)) {
            Contact_Upload_Detail__c matchedDetail = firstLastPhoneToOriginalDetail.get(
                contactMatch.FirstName + contactMatch.LastName + contactMatch.Phone);
            matchedDetail.Contact__c = contactMatch.Id;
            matchedDetail.Processing_Notes__c += 
                String.format('Found existing Contact ID: {0} Based on name match: {1} and phone match: {2}', 
                    new String[] {contactMatch.Id, contactMatch.FirstName + contactMatch.LastName, contactMatch.Phone});
            return true;
        } else if (firstLastPhoneToOriginalDetail.containsKey(contactMatch.FirstName + contactMatch.LastName + contactMatch.OtherPhone)) {
            Contact_Upload_Detail__c matchedDetail = firstLastPhoneToOriginalDetail.get(
                contactMatch.FirstName + contactMatch.LastName + contactMatch.OtherPhone);
            matchedDetail.Contact__c = contactMatch.Id;
            matchedDetail.Processing_Notes__c += 
                String.format('Found existing Contact ID: {0} Based on name match: {1} and phone match: {2}', 
                    new String[] {contactMatch.Id, contactMatch.FirstName + contactMatch.LastName, contactMatch.OtherPhone});
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
        for (Contact_Upload_Detail__c processedDetail : detailsToSearch) {
            if (processedDetail.Contact__c == null) {
                Contact createdContact = createContact(processedDetail);
                newUnmatchedContacts.add(createdContact);
                unmappedDetailToContact.put(processedDetail, createdContact);
            }
        }
        insert newUnmatchedContacts;
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
            EMPLID__c = unmatchedDetail.EmplId__c,
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
            unmatchedDetail.Contact__c = unmappedDetailToContact.get(unmatchedDetail).Id;
            unmatchedDetail.Processing_Notes__c += 'Created new Contact: ' + unmatchedDetail.Contact__c;
        }
    }
}