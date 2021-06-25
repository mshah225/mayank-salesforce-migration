public without sharing class ConstituentMatcher {
    public String constituentType;
    public String requestSource;
    public List<ConstituentDetail> detailsToSearch;
    public List<ConstituentDetail> detailsToReturn = new List<ConstituentDetail>();
    public List<SObject> matchedConstituents = new List<SObject>();
    public List<SObject> constituentsWithoutInitialMatch;

    public Map<Id, ConstituentDetail> constituentIdWithDetail = new Map<Id, ConstituentDetail>();
    public Map<String, ConstituentDetail> emplidWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> asuriteWithDetail = new Map<String, ConstituentDetail>();

    public Map<String, ConstituentDetail> firstNameEmailWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> firstNameLastNameBirthdateZipWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> firstNameLastNameEmailWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> firstNameLastNameEmailMiddleNameWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> firstNameLastNameEmailPhoneWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> firstNameLastNameEmailStreetWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> firstNameLastNameEmailZipWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> firstNameLastNamePhoneWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> firstNameLastNameStreetZipWithDetail = new Map<String, ConstituentDetail>();

    public Map<String, ConstituentDetail> partialFirstNameEmailWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> partialFirstNameLastNameBirthdateZipWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> partialFirstNameLastNameEmailWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> partialFirstNameLastNameEmailMiddleNameWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> partialFirstNameLastNameEmailPhoneWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> partialFirstNameLastNameEmailStreetWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> partialFirstNameLastNameEmailZipWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> partialFirstNameLastNamePhoneWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> partialFirstNameLastNameStreetZipWithDetail = new Map<String, ConstituentDetail>();

    public Map<String, ConstituentDetail> preferredNameEmailWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> preferredNameLastNameBirthdateZipWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> preferredNameLastNameEmailWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> preferredNameLastNameEmailMiddleNameWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> preferredNameLastNameEmailPhoneWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> preferredNameLastNameEmailStreetWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> preferredNameLastNameEmailZipWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> preferredNameLastNamePhoneWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> preferredNameLastNameStreetZipWithDetail = new Map<String, ConstituentDetail>();

    public Set<Date> birthdateSet = new Set<Date>();
    public Set<String> emailSet = new Set<String>();
    public Set<String> firstNameSet = new Set<String>();
    public Set<String> lastNameSet = new Set<String>();
    public Set<String> middleNameSet = new Set<String>();
    public Set<String> partialFirstNameSet = new Set<String>();
    public Set<String> phoneSet = new Set<String>();
    public Set<String> preferredNameSet = new Set<String>();
    public Set<String> streetSet = new Set<String>();
    public Set<String> zipSet = new Set<String>();

    public ConstituentMatcher(ConstituentDetail detailToSearch) {
        this.detailsToSearch = new List<ConstituentDetail>();
        this.detailsToSearch.add(detailToSearch);
        this.constituentType = 'contact';
        this.requestSource = 'api';
    }

    public ConstituentMatcher(List<ConstituentDetail> detailsToSearch) {
        this.detailsToSearch = detailsToSearch;
        this.constituentType = 'contact';
        this.requestSource = 'api';
    }

    public ConstituentMatcher(ConstituentDetail detailToSearch, String constituentType, String requestSource) {
        this.detailsToSearch = new List<ConstituentDetail>();
        this.detailsToSearch.add(detailToSearch);
        this.constituentType = constituentType.toLowerCase();
        this.requestSource = requestSource.toLowerCase();
    }

    public ConstituentMatcher(List<ConstituentDetail> detailsToSearch, String constituentType, String requestSource) {
        this.detailsToSearch = detailsToSearch;
        this.constituentType = constituentType.toLowerCase();
        this.requestSource = requestSource.toLowerCase();
    }

    public List<ConstituentDetail> getListOfConstituentsWithMatches() {
        return detailsToReturn;
    }

    public List<Contact> getContactsWithMatches() {
        return (List<Contact>) matchedConstituents;
    }

    public String getPartialFirstName(String firstName) {
        String firstNameCopy = firstName;
        String partialFirstName;
        if (firstNameCopy.length() >= 3) {
            partialFirstName = firstName.substring(0, 3) + '%';
        } else if (firstNameCopy.length() < 3) {
            partialFirstName = firstName.substring(0, firstNameCopy.length()) + '%';
        }
        return partialFirstName;
    }

    public void searchConstituents() {
        createDataMappingForSearch();
        if (constituentType == 'contact') {
            getContactsMatchedByMappedValues();
            associateDetailsWithMatchedConstituentContacts();
        } else if (constituentType == 'lead') {
            getLeadsMatchedByMappedValues();
            associateDetailsWithMatchedConstituentLeads();
        }
    }

    public void createDataMappingForSearch() {
        for (ConstituentDetail detail : detailsToSearch) {
            mapAllFields(detail);
        }
    }

    private void mapAllFields(ConstituentDetail detail) {
        mapConstituentId(detail);
        mapEmplid(detail);
        mapAsurite(detail);
        mapFirstNameEmail(detail);
        mapFirstNameLastNameBirthdateZip(detail);
        mapFirstNameLastNameEmail(detail);
        mapFirstNameLastNameEmailMiddleName(detail);
        mapFirstNameLastNameEmailPhone(detail);
        mapFirstNameLastNameEmailStreet(detail);
        mapFirstNameLastNameEmailZip(detail);
        mapFirstNameLastNamePhone(detail);
        mapFirstNameLastNameStreetZip(detail);
    }

    private void mapConstituentId(ConstituentDetail detail) {
        if (detail.constituentId != null) {
            constituentIdWithDetail.put(detail.constituentId, detail);
        }
    }

    private void mapEmplid(ConstituentDetail detail) {
        if (String.isNotBlank(detail.emplid)) {
            emplidWithDetail.put(detail.emplid, detail);
        }
    }

    private void mapAsurite(ConstituentDetail detail) {
        if (String.isNotBlank(detail.asuriteId)) {
            asuriteWithDetail.put((detail.asuriteId).toLowerCase(), detail);
        }
    }

    private void mapFirstNameEmail(ConstituentDetail detail) {
        if (String.isNotBlank(detail.firstName) && String.isNotBlank(detail.email)) {
            firstNameEmailWithDetail.put((detail.firstName + detail.email).toLowerCase(), detail);
            partialFirstNameEmailWithDetail.put((detail.partialFirstName + detail.email).toLowerCase(), detail);

            emailSet.add(detail.email);
            firstNameSet.add(detail.firstName);
            partialFirstNameSet.add(detail.partialFirstName);
        }

        if (String.isNotBlank(detail.preferredName) && String.isNotBlank(detail.email)) {
            preferredNameEmailWithDetail.put((detail.preferredName + detail.email).toLowerCase(), detail);

            emailSet.add(detail.email);
            preferredNameSet.add(detail.preferredName);
        }
    }

    private void mapFirstNameLastNameBirthdateZip(ConstituentDetail detail) {
        if (
            String.isNotBlank(detail.firstName) &&
            String.isNotBlank(detail.lastName) &&
            detail.birthdate != null &&
            String.isNotBlank(detail.mailingPostalCode)
        ) {
            firstNameLastNameBirthdateZipWithDetail.put(
                ((String) (detail.firstName +
                    detail.lastName +
                    detail.birthdate.format() +
                    detail.mailingPostalCode))
                    .toLowerCase(),
                detail
            );
            partialFirstNameLastNameBirthdateZipWithDetail.put(
                ((String) (detail.partialFirstName +
                    detail.lastName +
                    detail.birthdate.format() +
                    detail.mailingPostalCode))
                    .toLowerCase(),
                detail
            );

            birthdateSet.add(Date.valueOf(detail.birthdate));
            firstNameSet.add(detail.firstName);
            lastNameSet.add(detail.lastName);
            partialFirstNameSet.add(detail.partialFirstName);
            zipSet.add(detail.mailingPostalCode);
        }

        if (
            String.isNotBlank(detail.preferredName) &&
            String.isNotBlank(detail.lastName) &&
            detail.birthdate != null &&
            String.isNotBlank(detail.mailingPostalCode)
        ) {
            preferredNameLastNameBirthdateZipWithDetail.put(
                ((String) (detail.preferredName +
                    detail.lastName +
                    detail.birthdate.format() +
                    detail.mailingPostalCode))
                    .toLowerCase(),
                detail
            );

            birthdateSet.add(Date.valueOf(detail.birthdate));
            preferredNameSet.add(detail.preferredName);
            lastNameSet.add(detail.lastName);
            zipSet.add(detail.mailingPostalCode);
        }
    }

    private void mapFirstNameLastNameEmail(ConstituentDetail detail) {
        if (
            String.isNotBlank(detail.firstName) &&
            String.isNotBlank(detail.lastName) &&
            String.isNotBlank(detail.email)
        ) {
            firstNameLastNameEmailWithDetail.put(
                (detail.firstName + detail.lastName + detail.email).toLowerCase(),
                detail
            );
            partialFirstNameLastNameEmailWithDetail.put(
                (detail.partialFirstName + detail.lastName + detail.email).toLowerCase(),
                detail
            );

            emailSet.add(detail.email);
            firstNameSet.add(detail.firstName);
            lastNameSet.add(detail.lastName);
            partialFirstNameSet.add(detail.partialFirstName);
        }

        if (
            String.isNotBlank(detail.preferredName) &&
            String.isNotBlank(detail.lastName) &&
            String.isNotBlank(detail.email)
        ) {
            preferredNameLastNameEmailWithDetail.put(
                (detail.preferredName + detail.lastName + detail.email).toLowerCase(),
                detail
            );

            emailSet.add(detail.email);
            lastNameSet.add(detail.lastName);
            preferredNameSet.add(detail.preferredName);
        }
    }

    private void mapFirstNameLastNameEmailMiddleName(ConstituentDetail detail) {
        if (
            String.isNotBlank(detail.firstName) &&
            String.isNotBlank(detail.lastName) &&
            String.isNotBlank(detail.email) &&
            String.isNotBlank(detail.middleName)
        ) {
            firstNameLastNameEmailMiddleNameWithDetail.put(
                (detail.firstName + detail.lastName + detail.email + detail.middleName).toLowerCase(),
                detail
            );
            partialFirstNameLastNameEmailMiddleNameWithDetail.put(
                (detail.partialFirstName + detail.lastName + detail.email + detail.middleName).toLowerCase(),
                detail
            );

            emailSet.add(detail.email);
            firstNameSet.add(detail.firstName);
            lastNameSet.add(detail.lastName);
            middleNameSet.add(detail.middleName);
            partialFirstNameSet.add(detail.partialFirstName);
        }

        if (
            String.isNotBlank(detail.preferredName) &&
            String.isNotBlank(detail.lastName) &&
            String.isNotBlank(detail.email) &&
            String.isNotBlank(detail.middleName)
        ) {
            preferredNameLastNameEmailMiddleNameWithDetail.put(
                (detail.preferredName + detail.lastName + detail.email + detail.middleName).toLowerCase(),
                detail
            );

            emailSet.add(detail.email);
            lastNameSet.add(detail.lastName);
            middleNameSet.add(detail.middleName);
            preferredNameSet.add(detail.preferredName);
        }
    }

    private void mapFirstNameLastNameEmailPhone(ConstituentDetail detail) {
        if (
            String.isNotBlank(detail.firstName) &&
            String.isNotBlank(detail.lastName) &&
            String.isNotBlank(detail.email) &&
            String.isNotBlank(detail.phone)
        ) {
            firstNameLastNameEmailPhoneWithDetail.put(
                (detail.firstName + detail.lastName + detail.email + detail.phone).toLowerCase(),
                detail
            );
            partialFirstNameLastNameEmailPhoneWithDetail.put(
                (detail.partialFirstName + detail.lastName + detail.email + detail.phone).toLowerCase(),
                detail
            );

            emailSet.add(detail.email);
            firstNameSet.add(detail.firstName);
            lastNameSet.add(detail.lastName);
            partialFirstNameSet.add(detail.partialFirstName);
            phoneSet.add(detail.phone);
        }

        if (
            String.isNotBlank(detail.preferredName) &&
            String.isNotBlank(detail.lastName) &&
            String.isNotBlank(detail.email) &&
            String.isNotBlank(detail.phone)
        ) {
            preferredNameLastNameEmailPhoneWithDetail.put(
                (detail.preferredName + detail.lastName + detail.email + detail.phone).toLowerCase(),
                detail
            );

            emailSet.add(detail.email);
            lastNameSet.add(detail.lastName);
            phoneSet.add(detail.phone);
            preferredNameSet.add(detail.preferredName);
        }
    }

    private void mapFirstNameLastNameEmailStreet(ConstituentDetail detail) {
        if (
            String.isNotBlank(detail.firstName) &&
            String.isNotBlank(detail.lastName) &&
            String.isNotBlank(detail.email) &&
            String.isNotBlank(detail.mailingStreet)
        ) {
            firstNameLastNameEmailStreetWithDetail.put(
                (detail.firstName + detail.lastName + detail.email + detail.mailingStreet).toLowerCase(),
                detail
            );
            partialFirstNameLastNameEmailStreetWithDetail.put(
                (detail.partialFirstName + detail.lastName + detail.email + detail.mailingStreet).toLowerCase(),
                detail
            );

            emailSet.add(detail.email);
            firstNameSet.add(detail.firstName);
            lastNameSet.add(detail.lastName);
            partialFirstNameSet.add(detail.partialFirstName);
            streetSet.add(detail.mailingStreet);
        }

        if (
            String.isNotBlank(detail.preferredName) &&
            String.isNotBlank(detail.lastName) &&
            String.isNotBlank(detail.email) &&
            String.isNotBlank(detail.mailingStreet)
        ) {
            preferredNameLastNameEmailStreetWithDetail.put(
                (detail.preferredName + detail.lastName + detail.email + detail.mailingStreet).toLowerCase(),
                detail
            );

            emailSet.add(detail.email);
            lastNameSet.add(detail.lastName);
            preferredNameSet.add(detail.preferredName);
            streetSet.add(detail.mailingStreet);
        }
    }

    private void mapFirstNameLastNameEmailZip(ConstituentDetail detail) {
        if (
            String.isNotBlank(detail.firstName) &&
            String.isNotBlank(detail.lastName) &&
            String.isNotBlank(detail.email) &&
            String.isNotBlank(detail.mailingPostalCode)
        ) {
            firstNameLastNameEmailZipWithDetail.put(
                (detail.firstName + detail.lastName + detail.email + detail.mailingPostalCode).toLowerCase(),
                detail
            );
            partialFirstNameLastNameEmailZipWithDetail.put(
                (detail.partialFirstName + detail.lastName + detail.email + detail.mailingPostalCode).toLowerCase(),
                detail
            );

            emailSet.add(detail.email);
            firstNameSet.add(detail.firstName);
            lastNameSet.add(detail.lastName);
            partialFirstNameSet.add(detail.partialFirstName);
            zipSet.add(detail.mailingPostalCode);
        }

        if (
            String.isNotBlank(detail.preferredName) &&
            String.isNotBlank(detail.lastName) &&
            String.isNotBlank(detail.email) &&
            String.isNotBlank(detail.mailingPostalCode)
        ) {
            preferredNameLastNameEmailZipWithDetail.put(
                (detail.preferredName + detail.lastName + detail.email + detail.mailingPostalCode).toLowerCase(),
                detail
            );

            emailSet.add(detail.email);
            lastNameSet.add(detail.lastName);
            preferredNameSet.add(detail.preferredName);
            zipSet.add(detail.mailingPostalCode);
        }
    }

    private void mapFirstNameLastNamePhone(ConstituentDetail detail) {
        if (
            String.isNotBlank(detail.firstName) &&
            String.isNotBlank(detail.lastName) &&
            String.isNotBlank(detail.phone)
        ) {
            firstNameLastNamePhoneWithDetail.put(
                (detail.firstName + detail.lastName + detail.phone).toLowerCase(),
                detail
            );
            partialFirstNameLastNamePhoneWithDetail.put(
                (detail.partialFirstName + detail.lastName + detail.phone).toLowerCase(),
                detail
            );

            firstNameSet.add(detail.firstName);
            lastNameSet.add(detail.lastName);
            partialFirstNameSet.add(detail.partialFirstName);
            phoneSet.add(detail.phone);
        }

        if (
            String.isNotBlank(detail.preferredName) &&
            String.isNotBlank(detail.lastName) &&
            String.isNotBlank(detail.phone)
        ) {
            preferredNameLastNamePhoneWithDetail.put(
                (detail.preferredName + detail.lastName + detail.phone).toLowerCase(),
                detail
            );

            lastNameSet.add(detail.lastName);
            preferredNameSet.add(detail.preferredName);
            phoneSet.add(detail.phone);
        }
    }

    private void mapFirstNameLastNameStreetZip(ConstituentDetail detail) {
        if (
            String.isNotBlank(detail.firstName) &&
            String.isNotBlank(detail.lastName) &&
            String.isNotBlank(detail.mailingStreet) &&
            String.isNotBlank(detail.mailingPostalCode)
        ) {
            firstNameLastNameStreetZipWithDetail.put(
                (detail.firstName + detail.lastName + detail.mailingStreet + detail.mailingPostalCode).toLowerCase(),
                detail
            );
            partialFirstNameLastNameStreetZipWithDetail.put(
                (detail.partialFirstName +
                    detail.lastName +
                    detail.mailingStreet +
                    detail.mailingPostalCode)
                    .toLowerCase(),
                detail
            );

            firstNameSet.add(detail.firstName);
            lastNameSet.add(detail.lastName);
            partialFirstNameSet.add(detail.partialFirstName);
            streetSet.add(detail.mailingStreet);
            zipSet.add(detail.mailingPostalCode);
        }

        if (
            String.isNotBlank(detail.preferredName) &&
            String.isNotBlank(detail.lastName) &&
            String.isNotBlank(detail.mailingStreet) &&
            String.isNotBlank(detail.mailingPostalCode)
        ) {
            preferredNameLastNameStreetZipWithDetail.put(
                (detail.preferredName +
                    detail.lastName +
                    detail.mailingStreet +
                    detail.mailingPostalCode)
                    .toLowerCase(),
                detail
            );

            lastNameSet.add(detail.lastName);
            preferredNameSet.add(detail.preferredName);
            streetSet.add(detail.mailingStreet);
            zipSet.add(detail.mailingPostalCode);
        }
    }

    public void getContactsMatchedByMappedValues() {
        List<Contact> matchedContacts = new List<Contact>();

        if (requestSource == 'contactupload') {
            matchedContacts = [
                SELECT
                    Id,
                    EMPLID__c,
                    ASURITE_ID__c,
                    FirstName,
                    SF_First_Name__c,
                    Preferred_First_Name__c,
                    PS_Preferred_First_Name__c,
                    LastName,
                    SF_Last_Name__c,
                    Middle_Name__c,
                    HomePhone,
                    MobilePhone,
                    OtherPhone,
                    Phone,
                    SF_Mobile__c,
                    Email,
                    Lead_Email__c,
                    Lead_Secondary_Email__c,
                    Personal_Email__c,
                    ASU_Email__c,
                    ASU_Gmail__c,
                    EPO_Email__c,
                    MailingStreet,
                    SF_Mailing_Street__c,
                    MailingPostalCode,
                    SF_Mailing_ZIP__c,
                    Birthdate,
                    SF_Birthdate__c
                FROM Contact
                WHERE
                    EMPLID__c IN :emplidWithDetail.keySet()
                    OR ASURITE_ID__c IN :asuriteWithDetail.keySet()
                    OR ((FirstName IN :firstNameSet
                    OR FirstName LIKE :partialFirstNameSet)
                    AND (Email IN :emailSet
                    OR Lead_Email__c IN :emailSet
                    OR Lead_Secondary_Email__c IN :emailSet
                    OR Personal_Email__c IN :emailSet
                    OR ASU_Email__c IN :emailSet
                    OR ASU_Gmail__c IN :emailSet
                    OR EPO_Email__c IN :emailSet))
                LIMIT 10000
            ];
        } else if (requestSource == 'familyportal') {
            matchedContacts = [
                SELECT
                    Id,
                    EMPLID__c,
                    ASURITE_ID__c,
                    FirstName,
                    SF_First_Name__c,
                    Preferred_First_Name__c,
                    PS_Preferred_First_Name__c,
                    LastName,
                    SF_Last_Name__c,
                    Middle_Name__c,
                    HomePhone,
                    MobilePhone,
                    OtherPhone,
                    Phone,
                    SF_Mobile__c,
                    Email,
                    Lead_Email__c,
                    Lead_Secondary_Email__c,
                    Personal_Email__c,
                    ASU_Email__c,
                    ASU_Gmail__c,
                    EPO_Email__c,
                    MailingStreet,
                    SF_Mailing_Street__c,
                    MailingPostalCode,
                    SF_Mailing_ZIP__c,
                    Birthdate,
                    SF_Birthdate__c
                FROM Contact
                WHERE
                    EMPLID__c IN :emplidWithDetail.keySet()
                    OR ASURITE_ID__c IN :asuriteWithDetail.keySet()
                    OR ((FirstName IN :firstNameSet
                    OR FirstName LIKE :partialFirstNameSet
                    OR SF_First_Name__c IN :firstNameSet
                    OR Preferred_First_Name__c IN :preferredNameSet
                    OR PS_Preferred_First_Name__c IN :preferredNameSet)
                    AND (LastName IN :lastNameSet
                    OR SF_Last_Name__c IN :lastNameSet)
                    AND (HomePhone IN :phoneSet
                    OR MobilePhone IN :phoneSet
                    OR OtherPhone IN :phoneSet
                    OR Phone IN :phoneSet
                    OR SF_Mobile__c IN :phoneSet)
                    AND (Email IN :emailSet
                    OR Lead_Email__c IN :emailSet
                    OR Lead_Secondary_Email__c IN :emailSet
                    OR Personal_Email__c IN :emailSet
                    OR ASU_Email__c IN :emailSet
                    OR ASU_Gmail__c IN :emailSet
                    OR EPO_Email__c IN :emailSet))
                    OR ((FirstName IN :firstNameSet
                    OR FirstName LIKE :partialFirstNameSet
                    OR SF_First_Name__c IN :firstNameSet
                    OR Preferred_First_Name__c IN :preferredNameSet
                    OR PS_Preferred_First_Name__c IN :preferredNameSet)
                    AND (LastName IN :lastNameSet
                    OR SF_Last_Name__c IN :lastNameSet)
                    AND Middle_Name__c IN :middleNameSet
                    AND (Email IN :emailSet
                    OR Lead_Email__c IN :emailSet
                    OR Lead_Secondary_Email__c IN :emailSet
                    OR Personal_Email__c IN :emailSet
                    OR ASU_Email__c IN :emailSet
                    OR ASU_Gmail__c IN :emailSet
                    OR EPO_Email__c IN :emailSet))
                    OR ((FirstName IN :firstNameSet
                    OR FirstName LIKE :partialFirstNameSet
                    OR SF_First_Name__c IN :firstNameSet
                    OR Preferred_First_Name__c IN :preferredNameSet
                    OR PS_Preferred_First_Name__c IN :preferredNameSet)
                    AND (LastName IN :lastNameSet
                    OR SF_Last_Name__c IN :lastNameSet)
                    AND (MailingStreet IN :streetSet
                    OR SF_Mailing_Street__c IN :streetSet)
                    AND (Email IN :emailSet
                    OR Lead_Email__c IN :emailSet
                    OR Lead_Secondary_Email__c IN :emailSet
                    OR Personal_Email__c IN :emailSet
                    OR ASU_Email__c IN :emailSet
                    OR ASU_Gmail__c IN :emailSet
                    OR EPO_Email__c IN :emailSet))
                    OR ((FirstName IN :firstNameSet
                    OR FirstName LIKE :partialFirstNameSet
                    OR SF_First_Name__c IN :firstNameSet
                    OR Preferred_First_Name__c IN :preferredNameSet
                    OR PS_Preferred_First_Name__c IN :preferredNameSet)
                    AND (LastName IN :lastNameSet
                    OR SF_Last_Name__c IN :lastNameSet)
                    AND (Email IN :emailSet
                    OR Lead_Email__c IN :emailSet
                    OR Lead_Secondary_Email__c IN :emailSet
                    OR Personal_Email__c IN :emailSet
                    OR ASU_Email__c IN :emailSet
                    OR ASU_Gmail__c IN :emailSet
                    OR EPO_Email__c IN :emailSet))
                    OR ((FirstName IN :firstNameSet
                    OR FirstName LIKE :partialFirstNameSet
                    OR SF_First_Name__c IN :firstNameSet
                    OR Preferred_First_Name__c IN :preferredNameSet
                    OR PS_Preferred_First_Name__c IN :preferredNameSet)
                    AND (Email IN :emailSet
                    OR Lead_Email__c IN :emailSet
                    OR Lead_Secondary_Email__c IN :emailSet
                    OR Personal_Email__c IN :emailSet
                    OR ASU_Email__c IN :emailSet
                    OR ASU_Gmail__c IN :emailSet
                    OR EPO_Email__c IN :emailSet))
                    OR ((FirstName IN :firstNameSet
                    OR FirstName LIKE :partialFirstNameSet
                    OR SF_First_Name__c IN :firstNameSet
                    OR Preferred_First_Name__c IN :preferredNameSet
                    OR PS_Preferred_First_Name__c IN :preferredNameSet)
                    AND (LastName IN :lastNameSet
                    OR SF_Last_Name__c IN :lastNameSet)
                    AND (MailingPostalCode IN :zipSet
                    OR SF_Mailing_ZIP__c IN :zipSet)
                    AND (Email IN :emailSet
                    OR Lead_Email__c IN :emailSet
                    OR Lead_Secondary_Email__c IN :emailSet
                    OR Personal_Email__c IN :emailSet
                    OR ASU_Email__c IN :emailSet
                    OR ASU_Gmail__c IN :emailSet
                    OR EPO_Email__c IN :emailSet))
                LIMIT 10000
            ];
        } else if (requestSource == 'api') {
            matchedContacts = [
                SELECT
                    Id,
                    EMPLID__c,
                    ASURITE_ID__c,
                    FirstName,
                    SF_First_Name__c,
                    Preferred_First_Name__c,
                    PS_Preferred_First_Name__c,
                    LastName,
                    SF_Last_Name__c,
                    Middle_Name__c,
                    HomePhone,
                    MobilePhone,
                    OtherPhone,
                    Phone,
                    SF_Mobile__c,
                    Email,
                    Lead_Email__c,
                    Lead_Secondary_Email__c,
                    Personal_Email__c,
                    ASU_Email__c,
                    ASU_Gmail__c,
                    EPO_Email__c,
                    MailingStreet,
                    SF_Mailing_Street__c,
                    MailingPostalCode,
                    SF_Mailing_ZIP__c,
                    Birthdate,
                    SF_Birthdate__c
                FROM Contact
                WHERE
                    Id IN :constituentIdWithDetail.keySet()
                    OR EMPLID__c IN :emplidWithDetail.keySet()
                    OR ASURITE_ID__c IN :asuriteWithDetail.keySet()
                    OR ((FirstName IN :firstNameSet
                    OR FirstName LIKE :partialFirstNameSet
                    OR SF_First_Name__c IN :firstNameSet
                    OR Preferred_First_Name__c IN :preferredNameSet
                    OR PS_Preferred_First_Name__c IN :preferredNameSet)
                    AND (Email IN :emailSet
                    OR Lead_Email__c IN :emailSet
                    OR Lead_Secondary_Email__c IN :emailSet
                    OR Personal_Email__c IN :emailSet
                    OR ASU_Email__c IN :emailSet
                    OR ASU_Gmail__c IN :emailSet
                    OR EPO_Email__c IN :emailSet))
                    OR ((FirstName IN :firstNameSet
                    OR FirstName LIKE :partialFirstNameSet
                    OR SF_First_Name__c IN :firstNameSet
                    OR Preferred_First_Name__c IN :preferredNameSet
                    OR PS_Preferred_First_Name__c IN :preferredNameSet)
                    AND (LastName IN :lastNameSet
                    OR SF_Last_Name__c IN :lastNameSet)
                    AND (Birthdate IN :birthdateSet
                    OR SF_Birthdate__c IN :birthdateSet)
                    AND (MailingPostalCode IN :zipSet
                    OR SF_Mailing_ZIP__c IN :zipSet))
                    OR ((FirstName IN :firstNameSet
                    OR FirstName LIKE :partialFirstNameSet
                    OR SF_First_Name__c IN :firstNameSet
                    OR Preferred_First_Name__c IN :preferredNameSet
                    OR PS_Preferred_First_Name__c IN :preferredNameSet)
                    AND (LastName IN :lastNameSet
                    OR SF_Last_Name__c IN :lastNameSet)
                    AND (HomePhone IN :phoneSet
                    OR MobilePhone IN :phoneSet
                    OR OtherPhone IN :phoneSet
                    OR Phone IN :phoneSet
                    OR SF_Mobile__c IN :phoneSet))
                    OR ((FirstName IN :firstNameSet
                    OR FirstName LIKE :partialFirstNameSet
                    OR SF_First_Name__c IN :firstNameSet
                    OR Preferred_First_Name__c IN :preferredNameSet
                    OR PS_Preferred_First_Name__c IN :preferredNameSet)
                    AND (LastName IN :lastNameSet
                    OR SF_Last_Name__c IN :lastNameSet)
                    AND (MailingStreet IN :streetSet
                    OR SF_Mailing_Street__c IN :streetSet)
                    AND (MailingPostalCode IN :zipSet
                    OR SF_Mailing_ZIP__c IN :zipSet))
                LIMIT 10000
            ];
        }

        if (matchedContacts.size() > 0) {
            matchedConstituents = (List<SObject>) matchedContacts;
        }
    }

    public void associateDetailsWithMatchedConstituentContacts() {
        for (SObject matchedConstituent : matchedConstituents) {
            if (requestSource == 'contactupload') {
                if (matchContactByEmplid(matchedConstituent)) {
                } else if (matchContactByAsurite(matchedConstituent)) {
                } else if (matchContactByFirstNameEmail(matchedConstituent)) {
                }
            } else if (requestSource == 'familyportal') {
                if (matchContactByEmplid(matchedConstituent)) {
                } else if (matchContactByAsurite(matchedConstituent)) {
                } else if (matchContactByFirstNameLastNameEmailPhone(matchedConstituent)) {
                } else if (matchContactByFirstNameLastNameEmailMiddleName(matchedConstituent)) {
                } else if (matchContactByFirstNameLastNameEmailStreet(matchedConstituent)) {
                } else if (matchContactByFirstNameLastNameEmail(matchedConstituent)) {
                } else if (matchContactByFirstNameEmail(matchedConstituent)) {
                }
            } else if (requestSource == 'api') {
                if (matchContactByContactId(matchedConstituent)) {
                } else if (matchContactByEmplid(matchedConstituent)) {
                } else if (matchContactByFirstNameEmail(matchedConstituent)) {
                } else if (matchContactByFirstNameLastNameBirthdateZip(matchedConstituent)) {
                } else if (matchContactByFirstNameLastNamePhone(matchedConstituent)) {
                } else if (matchContactByFirstNameLastNameStreetZip(matchedConstituent)) {
                }
            }
        }
    }

    private Boolean matchContactByContactId(SObject constituentMatch) {
        Contact contactMatch = (Contact) constituentMatch;
        if (contactMatch.Id != null && constituentIdWithDetail.containsKey(contactMatch.Id)) {
            ConstituentDetail matchedDetail = constituentIdWithDetail.get(contactMatch.Id);
            if (matchedDetail.constituentId != null) {
                return false;
            }
            matchedDetail.constituentId = (Id) contactMatch.Id;
            matchedDetail.processingNotes += String.format(
                'Found existing Contact ID: {0} based on Contact ID match: {0} \n',
                new List<String>{ contactMatch.Id }
            );
            detailsToReturn.add(matchedDetail);
            return true;
        }
        return false;
    }

    private Boolean matchContactByEmplid(SObject constituentMatch) {
        Contact contactMatch = (Contact) constituentMatch;
        if (contactMatch.EMPLID__c != null && emplidWithDetail.containsKey(contactMatch.EMPLID__c)) {
            ConstituentDetail matchedDetail = emplidWithDetail.get(contactMatch.EMPLID__c);
            if (matchedDetail.constituentId != null) {
                return false;
            }
            matchedDetail.constituentId = (Id) contactMatch.Id;
            matchedDetail.processingNotes += String.format(
                'Found existing Contact ID: {0} based on Emplid match: {1} \n',
                new List<String>{ contactMatch.Id, contactMatch.EMPLID__c }
            );
            detailsToReturn.add(matchedDetail);
            return true;
        }
        return false;
    }

    private Boolean matchContactByAsurite(SObject constituentMatch) {
        Contact contactMatch = (Contact) constituentMatch;
        if (
            contactMatch.ASURITE_ID__c != null &&
            asuriteWithDetail.containsKey((contactMatch.ASURITE_ID__c).toLowerCase())
        ) {
            ConstituentDetail matchedDetail = asuriteWithDetail.get((contactMatch.ASURITE_ID__c).toLowerCase());
            if (matchedDetail.constituentId != null) {
                return false;
            }
            matchedDetail.constituentId = (Id) contactMatch.Id;
            matchedDetail.processingNotes += String.format(
                'Found existing Contact ID: {0} based on ASURITE match: {1} \n',
                new List<String>{ contactMatch.Id, contactMatch.ASURITE_ID__c }
            );
            detailsToReturn.add(matchedDetail);
            return true;
        }
        return false;
    }

    private Boolean matchContactByFirstNameEmail(SObject constituentMatch) {
        Contact contactMatch = (Contact) constituentMatch;
        ConstituentDetail matchedDetail;
        String partialFirstName;
        String contactMatchFirstName;
        String contactMatchEmail;
        List<String> contactMatchFirstNameList = new List<String>();
        List<String> contactMatchEmailList = new List<String>();
        Boolean foundMatch = false;

        if (contactMatch.FirstName != null) {
            contactMatchFirstNameList.add(contactMatch.FirstName);
            partialFirstName = getPartialFirstName(String.valueOf(contactMatch.FirstName));
        }
        if (contactMatch.SF_First_Name__c != null) {
            contactMatchFirstNameList.add(contactMatch.SF_First_Name__c);
        }
        if (partialFirstName != null) {
            contactMatchFirstNameList.add(partialFirstName);
        }
        if (contactMatch.Preferred_First_Name__c != null) {
            contactMatchFirstNameList.add(contactMatch.Preferred_First_Name__c);
        }
        if (contactMatch.PS_Preferred_First_Name__c != null) {
            contactMatchFirstNameList.add(contactMatch.PS_Preferred_First_Name__c);
        }

        if (contactMatch.Email != null) {
            contactMatchEmailList.add(contactMatch.Email);
        }
        if (contactMatch.Lead_Email__c != null) {
            contactMatchEmailList.add(contactMatch.Lead_Email__c);
        }
        if (contactMatch.Lead_Secondary_Email__c != null) {
            contactMatchEmailList.add(contactMatch.Lead_Secondary_Email__c);
        }
        if (contactMatch.Personal_Email__c != null) {
            contactMatchEmailList.add(contactMatch.Personal_Email__c);
        }
        if (contactMatch.ASU_Email__c != null) {
            contactMatchEmailList.add(contactMatch.ASU_Email__c);
        }
        if (contactMatch.ASU_Gmail__c != null) {
            contactMatchEmailList.add(contactMatch.ASU_Gmail__c);
        }
        if (contactMatch.EPO_Email__c != null) {
            contactMatchEmailList.add(contactMatch.EPO_Email__c);
        }

        if (contactMatchFirstNameList.size() > 0 && contactMatchEmailList.size() > 0) {
            for (String contactMatchFirstNameListChoice : contactMatchFirstNameList) {
                for (String contactMatchEmailListChoice : contactMatchEmailList) {
                    if (
                        firstNameEmailWithDetail.containsKey(
                            (contactMatchFirstNameListChoice + contactMatchEmailListChoice).toLowerCase()
                        )
                    ) {
                        contactMatchFirstName = contactMatchFirstNameListChoice;
                        contactMatchEmail = contactMatchEmailListChoice;
                        foundMatch = true;
                        break;
                    }
                }

                if (foundMatch) {
                    matchedDetail = firstNameEmailWithDetail.get(
                        (contactMatchFirstName + contactMatchEmail).toLowerCase()
                    );

                    if (matchedDetail.constituentId != null) {
                        return false;
                    }

                    matchedDetail.constituentId = (Id) contactMatch.Id;
                    matchedDetail.processingNotes += String.format(
                        'Found existing Contact ID: {0} based on email match: {1} and name match: {2} \n',
                        new List<String>{ contactMatch.Id, contactMatchEmail, contactMatchFirstName }
                    );
                    detailsToReturn.add(matchedDetail);
                    return true;
                }
            }
        }
        return false;
    }

    private Boolean matchContactByFirstNameLastNameBirthdateZip(SObject constituentMatch) {
        Contact contactMatch = (Contact) constituentMatch;
        ConstituentDetail matchedDetail;
        String partialFirstName;
        String contactMatchFirstName;
        String contactMatchLastName;
        Date contactMatchBirthdate;
        String contactMatchZip;
        List<String> contactMatchFirstNameList = new List<String>();
        List<String> contactMatchLastNameList = new List<String>();
        List<Date> contactMatchBirthdateList = new List<Date>();
        List<String> contactMatchZipList = new List<String>();
        Boolean foundMatch = false;

        if (contactMatch.FirstName != null) {
            contactMatchFirstNameList.add(contactMatch.FirstName);
            partialFirstName = getPartialFirstName(String.valueOf(contactMatch.FirstName));
        }
        if (contactMatch.SF_First_Name__c != null) {
            contactMatchFirstNameList.add(contactMatch.SF_First_Name__c);
        }
        if (partialFirstName != null) {
            contactMatchFirstNameList.add(partialFirstName);
        }
        if (contactMatch.Preferred_First_Name__c != null) {
            contactMatchFirstNameList.add(contactMatch.Preferred_First_Name__c);
        }
        if (contactMatch.PS_Preferred_First_Name__c != null) {
            contactMatchFirstNameList.add(contactMatch.PS_Preferred_First_Name__c);
        }

        if (contactMatch.LastName != null) {
            contactMatchLastNameList.add(contactMatch.LastName);
        }
        if (contactMatch.SF_Last_Name__c != null) {
            contactMatchLastNameList.add(contactMatch.SF_Last_Name__c);
        }

        if (contactMatch.Birthdate != null) {
            contactMatchBirthdateList.add(contactMatch.Birthdate);
        }
        if (contactMatch.SF_Birthdate__c != null) {
            contactMatchBirthdateList.add(contactMatch.SF_Birthdate__c);
        }

        if (contactMatch.MailingPostalCode != null) {
            contactMatchZipList.add(contactMatch.MailingPostalCode);
        }
        if (contactMatch.SF_Mailing_ZIP__c != null) {
            contactMatchZipList.add(contactMatch.SF_Mailing_ZIP__c);
        }

        if (
            contactMatchFirstNameList.size() > 0 &&
            contactMatchLastNameList.size() > 0 &&
            contactMatchBirthdateList.size() > 0 &&
            contactMatchZipList.size() > 0
        ) {
            for (String contactMatchFirstNameListChoice : contactMatchFirstNameList) {
                for (String contactMatchLastNameListChoice : contactMatchLastNameList) {
                    for (Date contactMatchBirthdateListChoice : contactMatchBirthdateList) {
                        for (String contactMatchZipListChoice : contactMatchZipList) {
                            if (
                                firstNameLastNameBirthdateZipWithDetail.containsKey(
                                    (contactMatchFirstNameListChoice +
                                        contactMatchLastNameListChoice +
                                        contactMatchBirthdateListChoice.format() +
                                        contactMatchZipListChoice)
                                        .toLowerCase()
                                )
                            ) {
                                contactMatchFirstName = contactMatchFirstNameListChoice;
                                contactMatchLastName = contactMatchLastNameListChoice;
                                contactMatchBirthdate = contactMatchBirthdateListChoice;
                                contactMatchZip = contactMatchZipListChoice;
                                foundMatch = true;
                                break;
                            }
                        }
                        if (foundMatch) {
                            break;
                        }
                    }
                    if (foundMatch) {
                        break;
                    }
                }

                if (foundMatch) {
                    matchedDetail = firstNameLastNameBirthdateZipWithDetail.get(
                        (contactMatchFirstName +
                            contactMatchLastName +
                            contactMatchBirthdate.format() +
                            contactMatchZip)
                            .toLowerCase()
                    );

                    if (matchedDetail.constituentId != null) {
                        return false;
                    }

                    matchedDetail.constituentId = (Id) contactMatch.Id;
                    matchedDetail.processingNotes += String.format(
                        'Found existing Contact ID: {0} based on first name match: {1} and last name match: {2} and birthdate match: {3} and zip code match: {4} \n',
                        new List<String>{
                            contactMatch.Id,
                            contactMatchFirstName,
                            contactMatchLastName,
                            contactMatchBirthdate.format(),
                            contactMatchZip
                        }
                    );
                    detailsToReturn.add(matchedDetail);
                    return true;
                }
            }
        }

        return false;
    }

    private Boolean matchContactByFirstNameLastNamePhone(SObject constituentMatch) {
        Contact contactMatch = (Contact) constituentMatch;
        ConstituentDetail matchedDetail;
        String partialFirstName;
        String contactMatchFirstName;
        String contactMatchLastName;
        String contactMatchPhone;
        List<String> contactMatchFirstNameList = new List<String>();
        List<String> contactMatchLastNameList = new List<String>();
        List<String> contactMatchPhoneList = new List<String>();
        Boolean foundMatch = false;

        if (contactMatch.FirstName != null) {
            contactMatchFirstNameList.add(contactMatch.FirstName);
            partialFirstName = getPartialFirstName(String.valueOf(contactMatch.FirstName));
        }
        if (contactMatch.SF_First_Name__c != null) {
            contactMatchFirstNameList.add(contactMatch.SF_First_Name__c);
        }
        if (partialFirstName != null) {
            contactMatchFirstNameList.add(partialFirstName);
        }
        if (contactMatch.Preferred_First_Name__c != null) {
            contactMatchFirstNameList.add(contactMatch.Preferred_First_Name__c);
        }
        if (contactMatch.PS_Preferred_First_Name__c != null) {
            contactMatchFirstNameList.add(contactMatch.PS_Preferred_First_Name__c);
        }

        if (contactMatch.LastName != null) {
            contactMatchLastNameList.add(contactMatch.LastName);
        }
        if (contactMatch.SF_Last_Name__c != null) {
            contactMatchLastNameList.add(contactMatch.SF_Last_Name__c);
        }

        if (contactMatch.Phone != null) {
            contactMatchPhoneList.add(contactMatch.Phone);
        }
        if (contactMatch.MobilePhone != null) {
            contactMatchPhoneList.add(contactMatch.MobilePhone);
        }
        if (contactMatch.HomePhone != null) {
            contactMatchPhoneList.add(contactMatch.HomePhone);
        }
        if (contactMatch.OtherPhone != null) {
            contactMatchPhoneList.add(contactMatch.OtherPhone);
        }
        if (contactMatch.SF_Mobile__c != null) {
            contactMatchPhoneList.add(contactMatch.SF_Mobile__c);
        }

        if (
            contactMatchFirstNameList.size() > 0 &&
            contactMatchLastNameList.size() > 0 &&
            contactMatchPhoneList.size() > 0
        ) {
            for (String contactMatchFirstNameListChoice : contactMatchFirstNameList) {
                for (String contactMatchLastNameListChoice : contactMatchLastNameList) {
                    for (String contactMatchPhoneListChoice : contactMatchPhoneList) {
                        if (
                            firstNameLastNamePhoneWithDetail.containsKey(
                                (contactMatchFirstNameListChoice +
                                    contactMatchLastNameListChoice +
                                    contactMatchPhoneListChoice)
                                    .toLowerCase()
                            )
                        ) {
                            contactMatchFirstName = contactMatchFirstNameListChoice;
                            contactMatchLastName = contactMatchLastNameListChoice;
                            contactMatchPhone = contactMatchPhoneListChoice;
                            foundMatch = true;
                            break;
                        }
                    }
                    if (foundMatch) {
                        break;
                    }
                }

                if (foundMatch) {
                    matchedDetail = firstNameLastNamePhoneWithDetail.get(
                        (contactMatchFirstName + contactMatchLastName + contactMatchPhone).toLowerCase()
                    );

                    if (matchedDetail.constituentId != null) {
                        return false;
                    }

                    matchedDetail.constituentId = (Id) contactMatch.Id;
                    matchedDetail.processingNotes += String.format(
                        'Found existing Contact ID: {0} based on first name match: {1} and last name match: {2} and phone match: {3} \n',
                        new List<String>{
                            contactMatch.Id,
                            contactMatchFirstName,
                            contactMatchLastName,
                            contactMatchPhone
                        }
                    );
                    detailsToReturn.add(matchedDetail);
                    return true;
                }
            }
        }
        return false;
    }

    private Boolean matchContactByFirstNameLastNameStreetZip(SObject constituentMatch) {
        Contact contactMatch = (Contact) constituentMatch;
        ConstituentDetail matchedDetail;
        String partialFirstName;
        String contactMatchFirstName;
        String contactMatchLastName;
        String contactMatchStreet;
        String contactMatchZip;
        List<String> contactMatchFirstNameList = new List<String>();
        List<String> contactMatchLastNameList = new List<String>();
        List<String> contactMatchStreetList = new List<String>();
        List<String> contactMatchZipList = new List<String>();
        Boolean foundMatch = false;

        if (contactMatch.FirstName != null) {
            contactMatchFirstNameList.add(contactMatch.FirstName);
            partialFirstName = getPartialFirstName(String.valueOf(contactMatch.FirstName));
        }
        if (contactMatch.SF_First_Name__c != null) {
            contactMatchFirstNameList.add(contactMatch.SF_First_Name__c);
        }
        if (partialFirstName != null) {
            contactMatchFirstNameList.add(partialFirstName);
        }
        if (contactMatch.Preferred_First_Name__c != null) {
            contactMatchFirstNameList.add(contactMatch.Preferred_First_Name__c);
        }
        if (contactMatch.PS_Preferred_First_Name__c != null) {
            contactMatchFirstNameList.add(contactMatch.PS_Preferred_First_Name__c);
        }

        if (contactMatch.LastName != null) {
            contactMatchLastNameList.add(contactMatch.LastName);
        }
        if (contactMatch.SF_Last_Name__c != null) {
            contactMatchLastNameList.add(contactMatch.SF_Last_Name__c);
        }

        if (contactMatch.MailingStreet != null) {
            contactMatchStreetList.add(contactMatch.MailingStreet);
        }
        if (contactMatch.SF_Mailing_Street__c != null) {
            contactMatchStreetList.add(contactMatch.SF_Mailing_Street__c);
        }

        if (contactMatch.MailingPostalCode != null) {
            contactMatchZipList.add(contactMatch.MailingPostalCode);
        }
        if (contactMatch.SF_Mailing_ZIP__c != null) {
            contactMatchZipList.add(contactMatch.SF_Mailing_ZIP__c);
        }

        if (
            contactMatchFirstNameList.size() > 0 &&
            contactMatchLastNameList.size() > 0 &&
            contactMatchStreetList.size() > 0 &&
            contactMatchZipList.size() > 0
        ) {
            for (String contactMatchFirstNameListChoice : contactMatchFirstNameList) {
                for (String contactMatchLastNameListChoice : contactMatchLastNameList) {
                    for (String contactMatchStreetListChoice : contactMatchStreetList) {
                        for (String contactMatchZipListChoice : contactMatchZipList) {
                            if (
                                firstNameLastNameStreetZipWithDetail.containsKey(
                                    (contactMatchFirstNameListChoice +
                                        contactMatchLastNameListChoice +
                                        contactMatchStreetListChoice +
                                        contactMatchZipListChoice)
                                        .toLowerCase()
                                )
                            ) {
                                contactMatchFirstName = contactMatchFirstNameListChoice;
                                contactMatchLastName = contactMatchLastNameListChoice;
                                contactMatchStreet = contactMatchStreetListChoice;
                                contactMatchZip = contactMatchZipListChoice;
                                foundMatch = true;
                                break;
                            }
                        }
                        if (foundMatch) {
                            break;
                        }
                    }
                    if (foundMatch) {
                        break;
                    }
                }

                if (foundMatch) {
                    matchedDetail = firstNameLastNameStreetZipWithDetail.get(
                        (contactMatchFirstName +
                            contactMatchLastName +
                            contactMatchStreet +
                            contactMatchZip)
                            .toLowerCase()
                    );

                    if (matchedDetail.constituentId != null) {
                        return false;
                    }

                    matchedDetail.constituentId = (Id) contactMatch.Id;
                    matchedDetail.processingNotes += String.format(
                        'Found existing Contact ID: {0} based on first name match: {1} and last name match: {2} and street match: {3} and zip code match: {4} \n',
                        new List<String>{
                            contactMatch.Id,
                            contactMatchFirstName,
                            contactMatchLastName,
                            contactMatchStreet,
                            contactMatchZip
                        }
                    );
                    detailsToReturn.add(matchedDetail);
                    return true;
                }
            }
        }

        return false;
    }

    private Boolean matchContactByFirstNameLastNameEmail(SObject constituentMatch) {
        Contact contactMatch = (Contact) constituentMatch;
        ConstituentDetail matchedDetail;
        String partialFirstName;
        String contactMatchFirstName;
        String contactMatchLastName;
        String contactMatchEmail;
        List<String> contactMatchFirstNameList = new List<String>();
        List<String> contactMatchLastNameList = new List<String>();
        List<String> contactMatchEmailList = new List<String>();
        Boolean foundMatch = false;

        if (contactMatch.FirstName != null) {
            contactMatchFirstNameList.add(contactMatch.FirstName);
            partialFirstName = getPartialFirstName(String.valueOf(contactMatch.FirstName));
        }
        if (contactMatch.SF_First_Name__c != null) {
            contactMatchFirstNameList.add(contactMatch.SF_First_Name__c);
        }
        if (partialFirstName != null) {
            contactMatchFirstNameList.add(partialFirstName);
        }
        if (contactMatch.Preferred_First_Name__c != null) {
            contactMatchFirstNameList.add(contactMatch.Preferred_First_Name__c);
        }
        if (contactMatch.PS_Preferred_First_Name__c != null) {
            contactMatchFirstNameList.add(contactMatch.PS_Preferred_First_Name__c);
        }

        if (contactMatch.LastName != null) {
            contactMatchLastNameList.add(contactMatch.LastName);
        }
        if (contactMatch.SF_Last_Name__c != null) {
            contactMatchLastNameList.add(contactMatch.SF_Last_Name__c);
        }

        if (contactMatch.Email != null) {
            contactMatchEmailList.add(contactMatch.Email);
        }
        if (contactMatch.Lead_Email__c != null) {
            contactMatchEmailList.add(contactMatch.Lead_Email__c);
        }
        if (contactMatch.Lead_Secondary_Email__c != null) {
            contactMatchEmailList.add(contactMatch.Lead_Secondary_Email__c);
        }
        if (contactMatch.Personal_Email__c != null) {
            contactMatchEmailList.add(contactMatch.Personal_Email__c);
        }
        if (contactMatch.ASU_Email__c != null) {
            contactMatchEmailList.add(contactMatch.ASU_Email__c);
        }
        if (contactMatch.ASU_Gmail__c != null) {
            contactMatchEmailList.add(contactMatch.ASU_Gmail__c);
        }
        if (contactMatch.EPO_Email__c != null) {
            contactMatchEmailList.add(contactMatch.EPO_Email__c);
        }

        if (
            contactMatchFirstNameList.size() > 0 &&
            contactMatchLastNameList.size() > 0 &&
            contactMatchEmailList.size() > 0
        ) {
            for (String contactMatchFirstNameListChoice : contactMatchFirstNameList) {
                for (String contactMatchLastNameListChoice : contactMatchLastNameList) {
                    for (String contactMatchEmailListChoice : contactMatchEmailList) {
                        if (
                            firstNameLastNameEmailWithDetail.containsKey(
                                (contactMatchFirstNameListChoice +
                                    contactMatchLastNameListChoice +
                                    contactMatchEmailListChoice)
                                    .toLowerCase()
                            )
                        ) {
                            contactMatchFirstName = contactMatchFirstNameListChoice;
                            contactMatchLastName = contactMatchLastNameListChoice;
                            contactMatchEmail = contactMatchEmailListChoice;
                            foundMatch = true;
                            break;
                        }
                    }
                    if (foundMatch) {
                        break;
                    }
                }

                if (foundMatch) {
                    matchedDetail = firstNameLastNameEmailWithDetail.get(
                        (contactMatchFirstName + contactMatchLastName + contactMatchEmail).toLowerCase()
                    );

                    if (matchedDetail.constituentId != null) {
                        return false;
                    }

                    matchedDetail.constituentId = (Id) contactMatch.Id;
                    matchedDetail.processingNotes += String.format(
                        'Found existing Contact ID: {0} based on first name match: {1} and last name match: {2} and email match: {3} \n',
                        new List<String>{
                            contactMatch.Id,
                            contactMatchFirstName,
                            contactMatchLastName,
                            contactMatchEmail
                        }
                    );
                    detailsToReturn.add(matchedDetail);
                    return true;
                }
            }
        }
        return false;
    }

    private Boolean matchContactByFirstNameLastNameEmailPhone(SObject constituentMatch) {
        Contact contactMatch = (Contact) constituentMatch;
        ConstituentDetail matchedDetail;
        String partialFirstName;
        String contactMatchFirstName;
        String contactMatchLastName;
        String contactMatchEmail;
        String contactMatchPhone;
        List<String> contactMatchFirstNameList = new List<String>();
        List<String> contactMatchLastNameList = new List<String>();
        List<String> contactMatchEmailList = new List<String>();
        List<String> contactMatchPhoneList = new List<String>();
        Boolean foundMatch = false;

        if (contactMatch.FirstName != null) {
            contactMatchFirstNameList.add(contactMatch.FirstName);
            partialFirstName = getPartialFirstName(String.valueOf(contactMatch.FirstName));
        }
        if (contactMatch.SF_First_Name__c != null) {
            contactMatchFirstNameList.add(contactMatch.SF_First_Name__c);
        }
        if (partialFirstName != null) {
            contactMatchFirstNameList.add(partialFirstName);
        }
        if (contactMatch.Preferred_First_Name__c != null) {
            contactMatchFirstNameList.add(contactMatch.Preferred_First_Name__c);
        }
        if (contactMatch.PS_Preferred_First_Name__c != null) {
            contactMatchFirstNameList.add(contactMatch.PS_Preferred_First_Name__c);
        }

        if (contactMatch.LastName != null) {
            contactMatchLastNameList.add(contactMatch.LastName);
        }
        if (contactMatch.SF_Last_Name__c != null) {
            contactMatchLastNameList.add(contactMatch.SF_Last_Name__c);
        }

        if (contactMatch.Email != null) {
            contactMatchEmailList.add(contactMatch.Email);
        }
        if (contactMatch.Lead_Email__c != null) {
            contactMatchEmailList.add(contactMatch.Lead_Email__c);
        }
        if (contactMatch.Lead_Secondary_Email__c != null) {
            contactMatchEmailList.add(contactMatch.Lead_Secondary_Email__c);
        }
        if (contactMatch.Personal_Email__c != null) {
            contactMatchEmailList.add(contactMatch.Personal_Email__c);
        }
        if (contactMatch.ASU_Email__c != null) {
            contactMatchEmailList.add(contactMatch.ASU_Email__c);
        }
        if (contactMatch.ASU_Gmail__c != null) {
            contactMatchEmailList.add(contactMatch.ASU_Gmail__c);
        }
        if (contactMatch.EPO_Email__c != null) {
            contactMatchEmailList.add(contactMatch.EPO_Email__c);
        }

        if (contactMatch.Phone != null) {
            contactMatchPhoneList.add(contactMatch.Phone);
        }
        if (contactMatch.MobilePhone != null) {
            contactMatchPhoneList.add(contactMatch.MobilePhone);
        }
        if (contactMatch.HomePhone != null) {
            contactMatchPhoneList.add(contactMatch.HomePhone);
        }
        if (contactMatch.OtherPhone != null) {
            contactMatchPhoneList.add(contactMatch.OtherPhone);
        }
        if (contactMatch.SF_Mobile__c != null) {
            contactMatchPhoneList.add(contactMatch.SF_Mobile__c);
        }

        if (
            contactMatchFirstNameList.size() > 0 &&
            contactMatchLastNameList.size() > 0 &&
            contactMatchEmailList.size() > 0 &&
            contactMatchPhoneList.size() > 0
        ) {
            for (String contactMatchFirstNameListChoice : contactMatchFirstNameList) {
                for (String contactMatchLastNameListChoice : contactMatchLastNameList) {
                    for (String contactMatchEmailListChoice : contactMatchEmailList) {
                        for (String contactMatchPhoneListChoice : contactMatchPhoneList) {
                            if (
                                firstNameLastNameEmailPhoneWithDetail.containsKey(
                                    (contactMatchFirstNameListChoice +
                                        contactMatchLastNameListChoice +
                                        contactMatchEmailListChoice +
                                        contactMatchPhoneListChoice)
                                        .toLowerCase()
                                )
                            ) {
                                contactMatchFirstName = contactMatchFirstNameListChoice;
                                contactMatchLastName = contactMatchLastNameListChoice;
                                contactMatchEmail = contactMatchEmailListChoice;
                                contactMatchPhone = contactMatchPhoneListChoice;
                                foundMatch = true;
                                break;
                            }
                        }
                        if (foundMatch) {
                            break;
                        }
                    }
                    if (foundMatch) {
                        break;
                    }
                }

                if (foundMatch) {
                    matchedDetail = firstNameLastNameEmailPhoneWithDetail.get(
                        (contactMatchFirstName +
                            contactMatchLastName +
                            contactMatchEmail +
                            contactMatchPhone)
                            .toLowerCase()
                    );

                    if (matchedDetail.constituentId != null) {
                        return false;
                    }

                    matchedDetail.constituentId = (Id) contactMatch.Id;
                    matchedDetail.processingNotes += String.format(
                        'Found existing Contact ID: {0} based on first name match: {1} and last name match: {2} and email match: {3} and phone match: {4} \n',
                        new List<String>{
                            contactMatch.Id,
                            contactMatchFirstName,
                            contactMatchLastName,
                            contactMatchEmail,
                            contactMatchPhone
                        }
                    );
                    detailsToReturn.add(matchedDetail);
                    return true;
                }
            }
        }
        return false;
    }

    private Boolean matchContactByFirstNameLastNameEmailMiddleName(SObject constituentMatch) {
        Contact contactMatch = (Contact) constituentMatch;
        ConstituentDetail matchedDetail;
        String partialFirstName;
        String contactMatchFirstName;
        String contactMatchLastName;
        String contactMatchEmail;
        String contactMatchMiddleName;
        List<String> contactMatchFirstNameList = new List<String>();
        List<String> contactMatchLastNameList = new List<String>();
        List<String> contactMatchEmailList = new List<String>();
        List<String> contactMatchMiddleNameList = new List<String>();
        Boolean foundMatch = false;

        if (contactMatch.FirstName != null) {
            contactMatchFirstNameList.add(contactMatch.FirstName);
            partialFirstName = getPartialFirstName(String.valueOf(contactMatch.FirstName));
        }
        if (contactMatch.SF_First_Name__c != null) {
            contactMatchFirstNameList.add(contactMatch.SF_First_Name__c);
        }
        if (partialFirstName != null) {
            contactMatchFirstNameList.add(partialFirstName);
        }
        if (contactMatch.Preferred_First_Name__c != null) {
            contactMatchFirstNameList.add(contactMatch.Preferred_First_Name__c);
        }
        if (contactMatch.PS_Preferred_First_Name__c != null) {
            contactMatchFirstNameList.add(contactMatch.PS_Preferred_First_Name__c);
        }

        if (contactMatch.LastName != null) {
            contactMatchLastNameList.add(contactMatch.LastName);
        }
        if (contactMatch.SF_Last_Name__c != null) {
            contactMatchLastNameList.add(contactMatch.SF_Last_Name__c);
        }

        if (contactMatch.Email != null) {
            contactMatchEmailList.add(contactMatch.Email);
        }
        if (contactMatch.Lead_Email__c != null) {
            contactMatchEmailList.add(contactMatch.Lead_Email__c);
        }
        if (contactMatch.Lead_Secondary_Email__c != null) {
            contactMatchEmailList.add(contactMatch.Lead_Secondary_Email__c);
        }
        if (contactMatch.Personal_Email__c != null) {
            contactMatchEmailList.add(contactMatch.Personal_Email__c);
        }
        if (contactMatch.ASU_Email__c != null) {
            contactMatchEmailList.add(contactMatch.ASU_Email__c);
        }
        if (contactMatch.ASU_Gmail__c != null) {
            contactMatchEmailList.add(contactMatch.ASU_Gmail__c);
        }
        if (contactMatch.EPO_Email__c != null) {
            contactMatchEmailList.add(contactMatch.EPO_Email__c);
        }

        if (contactMatch.Middle_Name__c != null) {
            contactMatchMiddleNameList.add(contactMatch.Middle_Name__c);
        }

        if (
            contactMatchFirstNameList.size() > 0 &&
            contactMatchLastNameList.size() > 0 &&
            contactMatchEmailList.size() > 0 &&
            contactMatchMiddleNameList.size() > 0
        ) {
            for (String contactMatchFirstNameListChoice : contactMatchFirstNameList) {
                for (String contactMatchLastNameListChoice : contactMatchLastNameList) {
                    for (String contactMatchEmailListChoice : contactMatchEmailList) {
                        for (String contactMatchMiddleNameListChoice : contactMatchMiddleNameList) {
                            if (
                                firstNameLastNameEmailMiddleNameWithDetail.containsKey(
                                    (contactMatchFirstNameListChoice +
                                        contactMatchLastNameListChoice +
                                        contactMatchEmailListChoice +
                                        contactMatchMiddleNameListChoice)
                                        .toLowerCase()
                                )
                            ) {
                                contactMatchFirstName = contactMatchFirstNameListChoice;
                                contactMatchLastName = contactMatchLastNameListChoice;
                                contactMatchEmail = contactMatchEmailListChoice;
                                contactMatchMiddleName = contactMatchMiddleNameListChoice;
                                foundMatch = true;
                                break;
                            }
                        }
                        if (foundMatch) {
                            break;
                        }
                    }
                    if (foundMatch) {
                        break;
                    }
                }

                if (foundMatch) {
                    matchedDetail = firstNameLastNameEmailMiddleNameWithDetail.get(
                        (contactMatchFirstName +
                            contactMatchLastName +
                            contactMatchEmail +
                            contactMatchMiddleName)
                            .toLowerCase()
                    );

                    if (matchedDetail.constituentId != null) {
                        return false;
                    }

                    matchedDetail.constituentId = (Id) contactMatch.Id;
                    matchedDetail.processingNotes += String.format(
                        'Found existing Contact ID: {0} based on first name match: {1} and last name match: {2} and email match: {3} and middle name match: {4} \n',
                        new List<String>{
                            contactMatch.Id,
                            contactMatchFirstName,
                            contactMatchLastName,
                            contactMatchEmail,
                            contactMatchMiddleName
                        }
                    );
                    detailsToReturn.add(matchedDetail);
                    return true;
                }
            }
        }
        return false;
    }

    private Boolean matchContactByFirstNameLastNameEmailStreet(SObject constituentMatch) {
        Contact contactMatch = (Contact) constituentMatch;
        ConstituentDetail matchedDetail;
        String partialFirstName;
        String contactMatchFirstName;
        String contactMatchLastName;
        String contactMatchEmail;
        String contactMatchStreet;
        List<String> contactMatchFirstNameList = new List<String>();
        List<String> contactMatchLastNameList = new List<String>();
        List<String> contactMatchEmailList = new List<String>();
        List<String> contactMatchStreetList = new List<String>();
        Boolean foundMatch = false;

        if (contactMatch.FirstName != null) {
            contactMatchFirstNameList.add(contactMatch.FirstName);
            partialFirstName = getPartialFirstName(String.valueOf(contactMatch.FirstName));
        }
        if (contactMatch.SF_First_Name__c != null) {
            contactMatchFirstNameList.add(contactMatch.SF_First_Name__c);
        }
        if (partialFirstName != null) {
            contactMatchFirstNameList.add(partialFirstName);
        }
        if (contactMatch.Preferred_First_Name__c != null) {
            contactMatchFirstNameList.add(contactMatch.Preferred_First_Name__c);
        }
        if (contactMatch.PS_Preferred_First_Name__c != null) {
            contactMatchFirstNameList.add(contactMatch.PS_Preferred_First_Name__c);
        }

        if (contactMatch.LastName != null) {
            contactMatchLastNameList.add(contactMatch.LastName);
        }
        if (contactMatch.SF_Last_Name__c != null) {
            contactMatchLastNameList.add(contactMatch.SF_Last_Name__c);
        }

        if (contactMatch.Email != null) {
            contactMatchEmailList.add(contactMatch.Email);
        }
        if (contactMatch.Lead_Email__c != null) {
            contactMatchEmailList.add(contactMatch.Lead_Email__c);
        }
        if (contactMatch.Lead_Secondary_Email__c != null) {
            contactMatchEmailList.add(contactMatch.Lead_Secondary_Email__c);
        }
        if (contactMatch.Personal_Email__c != null) {
            contactMatchEmailList.add(contactMatch.Personal_Email__c);
        }
        if (contactMatch.ASU_Email__c != null) {
            contactMatchEmailList.add(contactMatch.ASU_Email__c);
        }
        if (contactMatch.ASU_Gmail__c != null) {
            contactMatchEmailList.add(contactMatch.ASU_Gmail__c);
        }
        if (contactMatch.EPO_Email__c != null) {
            contactMatchEmailList.add(contactMatch.EPO_Email__c);
        }

        if (contactMatch.MailingStreet != null) {
            contactMatchStreetList.add(contactMatch.MailingStreet);
        }
        if (contactMatch.SF_Mailing_Street__c != null) {
            contactMatchStreetList.add(contactMatch.SF_Mailing_Street__c);
        }

        if (
            contactMatchFirstNameList.size() > 0 &&
            contactMatchLastNameList.size() > 0 &&
            contactMatchEmailList.size() > 0 &&
            contactMatchStreetList.size() > 0
        ) {
            for (String contactMatchFirstNameListChoice : contactMatchFirstNameList) {
                for (String contactMatchLastNameListChoice : contactMatchLastNameList) {
                    for (String contactMatchEmailListChoice : contactMatchEmailList) {
                        for (String contactMatchStreetListChoice : contactMatchStreetList) {
                            if (
                                firstNameLastNameEmailStreetWithDetail.containsKey(
                                    (contactMatchFirstNameListChoice +
                                        contactMatchLastNameListChoice +
                                        contactMatchEmailListChoice +
                                        contactMatchStreetListChoice)
                                        .toLowerCase()
                                )
                            ) {
                                contactMatchFirstName = contactMatchFirstNameListChoice;
                                contactMatchLastName = contactMatchLastNameListChoice;
                                contactMatchEmail = contactMatchEmailListChoice;
                                contactMatchStreet = contactMatchStreetListChoice;
                                foundMatch = true;
                                break;
                            }
                        }
                        if (foundMatch) {
                            break;
                        }
                    }
                    if (foundMatch) {
                        break;
                    }
                }

                if (foundMatch) {
                    matchedDetail = firstNameLastNameEmailStreetWithDetail.get(
                        (contactMatchFirstName +
                            contactMatchLastName +
                            contactMatchEmail +
                            contactMatchStreet)
                            .toLowerCase()
                    );

                    if (matchedDetail.constituentId != null) {
                        return false;
                    }

                    matchedDetail.constituentId = (Id) contactMatch.Id;
                    matchedDetail.processingNotes += String.format(
                        'Found existing Contact ID: {0} based on first name match: {1} and last name match: {2} and email match: {3} and street match: {4} \n',
                        new List<String>{
                            contactMatch.Id,
                            contactMatchFirstName,
                            contactMatchLastName,
                            contactMatchEmail,
                            contactMatchStreet
                        }
                    );
                    detailsToReturn.add(matchedDetail);
                    return true;
                }
            }
        }
        return false;
    }

    public void getLeadsMatchedByMappedValues() {
        List<Lead> matchedLeads = [
            SELECT Id, EMPLID__c, FirstName, LastName, Email, Secondary_Email__c, Recruiting_Email__c
            FROM Lead
            WHERE
                ((FirstName IN :firstNameSet
                OR FirstName LIKE :partialFirstNameSet)
                AND (Email IN :emailSet
                OR Secondary_Email__c IN :emailSet
                OR Recruiting_Email__c IN :emailSet))
                OR EMPLID__c IN :emplidWithDetail.keySet()
            LIMIT 10000
        ];

        if (matchedLeads.size() > 0) {
            matchedConstituents = (List<SObject>) matchedLeads;
        }
    }

    public void associateDetailsWithMatchedConstituentLeads() {
        for (SObject matchedConstituent : matchedConstituents) {
            if (matchLeadByEmplid(matchedConstituent)) {
            } else if (matchLeadByFirstNameEmail(matchedConstituent)) {
            }
        }
    }

    private Boolean matchLeadByEmplid(SObject constituentMatch) {
        Lead leadMatch = (Lead) constituentMatch;
        if (leadMatch.EMPLID__c != null && emplidWithDetail.containsKey(leadMatch.EMPLID__c)) {
            ConstituentDetail matchedDetail = emplidWithDetail.get(leadMatch.EMPLID__c);
            if (matchedDetail.constituentId != null) {
                return false;
            }
            matchedDetail.constituentId = (Id) leadMatch.Id;
            matchedDetail.processingNotes += String.format(
                'Found existing Lead ID: {0} based on Emplid match: {1} \n',
                new List<String>{ leadMatch.Id, leadMatch.EMPLID__c }
            );
            detailsToReturn.add(matchedDetail);
            return true;
        }
        return false;
    }

    private Boolean matchLeadByFirstNameEmail(SObject constituentMatch) {
        Lead leadMatch = (Lead) constituentMatch;
        ConstituentDetail matchedDetail;
        String partialFirstName;
        String leadMatchFirstName;
        String leadMatchEmail;
        List<String> leadMatchFirstNameList = new List<String>();
        List<String> leadMatchEmailList = new List<String>();
        Boolean foundMatch = false;

        if (leadMatch.FirstName != null) {
            leadMatchFirstNameList.add(leadMatch.FirstName);
            partialFirstName = getPartialFirstName(String.valueOf(leadMatch.FirstName));
        }

        if (leadMatch.Email != null) {
            leadMatchEmailList.add(leadMatch.Email);
        }
        if (leadMatch.Secondary_Email__c != null) {
            leadMatchEmailList.add(leadMatch.Secondary_Email__c);
        }
        if (leadMatch.Recruiting_Email__c != null) {
            leadMatchEmailList.add(leadMatch.Recruiting_Email__c);
        }

        if (leadMatchFirstNameList.size() > 0 && leadMatchEmailList.size() > 0) {
            for (String leadMatchFirstNameListChoice : leadMatchFirstNameList) {
                for (String leadMatchEmailListChoice : leadMatchEmailList) {
                    if (
                        firstNameEmailWithDetail.containsKey(
                            (leadMatchFirstNameListChoice + leadMatchEmailListChoice).toLowerCase()
                        )
                    ) {
                        leadMatchFirstName = leadMatchFirstNameListChoice;
                        leadMatchEmail = leadMatchEmailListChoice;
                        foundMatch = true;
                        break;
                    }
                }

                if (foundMatch) {
                    matchedDetail = firstNameEmailWithDetail.get((leadMatchFirstName + leadMatchEmail).toLowerCase());

                    if (matchedDetail.constituentId != null) {
                        return false;
                    }

                    matchedDetail.constituentId = (Id) leadMatch.Id;
                    matchedDetail.processingNotes += String.format(
                        'Found existing Contact ID: {0} based on email match: {1} and first name match: {2} \n',
                        new List<String>{ leadMatch.Id, leadMatchEmail, leadMatchFirstName }
                    );
                    detailsToReturn.add(matchedDetail);
                    return true;
                }
            }
        }
        return false;
    }
}
