public class ConstituentMatcher {
    private List<ConstituentDetail> detailsToSearch {get; set;}
    private List<ConstituentDetail> detailsToReturn = new List<ConstituentDetail>();
    private List<Contact> matchedContacts = new List<Contact>();
    private Map<String, ConstituentDetail> asuriteWithDetail = new Map<String, ConstituentDetail>();
    private Map<String, ConstituentDetail> emplidWithDetail = new Map<String, ConstituentDetail>();
    private Map<String, ConstituentDetail> firstNameAndEmailWithDetail = new Map<String, ConstituentDetail>();
    private Map<String, ConstituentDetail> firstNameWildcardAndEmailWithDetail = new Map<String, ConstituentDetail>();
    private Set<String> emailSet = new Set<String>();
    private Set<String> firstNameSet = new Set<String>();
    private Set<String> firstNameWildcardSet = new Set<String>();

    public ConstituentMatcher(ConstituentDetail detailToSearch) {
        this.detailsToSearch.add(detailToSearch);
    }

    public ConstituentMatcher(List<ConstituentDetail> detailsToSearch) {
        this.detailsToSearch = detailsToSearch;
    }

    public List<ConstituentDetail> getListOfConstituentsWithMatches() {
        return detailsToReturn;
    }

    public void searchContacts() {
        createDataMappingForSearch();
        getContactsMatchedByMappedValues();
        pairDetailsWithMatchedContacts();
    }

    private void createDataMappingForSearch() {
        for (ConstituentDetail detail : detailsToSearch) {
            mapEmplidIfPresent(detail);
            mapAsuRiteIfPresent(detail);
            mapFirstNameAndEmailIfPresent(detail);
        }
    }

    private void mapEmplidIfPresent(ConstituentDetail detail) {
        if (String.isNotBlank(detail.emplid)) {
            emplidWithDetail.put((detail.emplid).toLowerCase(), detail);
        }
    }

    private void mapAsuRiteIfPresent(ConstituentDetail detail) {
        if (String.isNotBlank(detail.asuriteId)) {
            asuriteWithDetail.put((detail.asuriteId).toLowerCase(), detail);
        }
    }

    private void mapFirstNameAndEmailIfPresent(ConstituentDetail detail) {
        String firstNameWildcard;
        if (String.isNotBlank(detail.firstName) && String.isNotBlank(detail.email)) {
            firstNameAndEmailWithDetail.put((detail.firstName + detail.email).toLowerCase(), detail);
            firstNameSet.add(detail.firstName);
            emailSet.add(detail.email);
            firstNameWildcard = getFirstNameWildcard(String.valueOf(detail.firstName), String.valueOf(detail.email));
            firstNameWildcardAndEmailWithDetail.put((detail.email).toLowerCase(), detail);
            firstNameWildcardSet.add(firstNameWildcard);
        }
    }

   public String getFirstNameWildcard(String firstName, String email) {
        String originalFirstName = firstName;
        String firstNameWildcard;

        Map<String, String> detailFieldsMap = new Map<String, String>();
        detailFieldsMap.put('email', email);
        detailFieldsMap.put('firstName', firstName);
        ConstituentDetail originalContactDetails = new ConstituentDetail(detailFieldsMap);

        if (firstNameWildcardAndEmailWithDetail.containsKey(email)) {
            originalContactDetails = firstNameWildcardAndEmailWithDetail.get(email);
            originalFirstName = originalContactDetails.firstName;
        }
        if (originalFirstName.length() > 0) {
            firstNameWildcard = firstName.substring(0, originalFirstName.length()) + '%';
        }
        return firstNameWildcard;
    }

    private void getContactsMatchedByMappedValues() {
        matchedContacts = [
            SELECT Id, EMPLID__c, ASURITE_ID__c, FirstName, Email, Lead_Email__c, Lead_Secondary_Email__c, Personal_Email__c,
                ASU_Email__c, ASU_Gmail__c, EPO_Email__c, LastName, Birthdate, MailingPostalCode, HomePhone,
                MobilePhone, SF_Mobile__c, Phone, OtherPhone, MailingStreet
            FROM Contact
            WHERE (
                (FirstName IN :firstNameSet
                    OR FirstName LIKE :firstNameWildcardSet)
                AND (Email IN :emailSet
                    OR Lead_Email__c IN :emailSet
                    OR Lead_Secondary_Email__c IN :emailSet
                    OR Personal_Email__c IN :emailSet
                    OR ASU_Email__c IN :emailSet
                    OR ASU_Gmail__c IN :emailSet
                    OR EPO_Email__c IN :emailSet
                )
            )
            OR ASURITE_ID__c IN :asuriteWithDetail.keySet()
            OR EMPLID__c IN :emplidWithDetail.keySet()
        ];
    }

    private void pairDetailsWithMatchedContacts() {
        for (Contact contactMatch : matchedContacts) {
            if (matchByEmplid(contactMatch)) {} 
            else if (matchByAsurite(contactMatch)) {} 
            else if (matchByFirstNameAndEmail(contactMatch)) {} 
            else if (matchByFirstNameAndLeadEmail(contactMatch)) {} 
            else if (matchByFirstNameAndLeadSecondaryEmail(contactMatch)) {} 
            else if (matchByFirstNameAndPersonalEmail(contactMatch)) {} 
            else if (matchByFirstNameAndAsuGmail(contactMatch)) {} 
            else if (matchByFirstNameAndEpoEmail(contactMatch)) {} 
            else if (matchByFirstNameAndAsuEmail(contactMatch)) {} 
            else if (matchByFirstNameWildcardAndEmail(contactMatch)) {} 
            else if (matchByFirstNameWildcardAndLeadEmail(contactMatch)) {} 
            else if (matchByFirstNameWildcardAndLeadSecondaryEmail(contactMatch)) {} 
            else if (matchByFirstNameWildcardAndPersonalEmail(contactMatch)) {} 
            else if (matchByFirstNameWildcardAndAsuGmail(contactMatch)) {} 
            else if (matchByFirstNameWildcardAndEpoEmail(contactMatch)) {} 
            else if (matchByFirstNameWildcardAndAsuEmail(contactMatch)) {}
        }
    }

    private Boolean matchByEmplid(Contact contactMatch) {
        if (contactMatch.EMPLID__c != null && emplidWithDetail.containsKey((contactMatch.EMPLID__c).toLowerCase())) {
            ConstituentDetail matchedDetail = emplidWithDetail.get((contactMatch.EMPLID__c).toLowerCase());
            matchedDetail.contactId = (Id) contactMatch.Id;
            matchedDetail.processingNotes +=
                String.format('Found existing Contact ID: {0} based on Emplid match: {1} \n',
                new String[] {contactMatch.Id, contactMatch.EMPLID__c});
            detailsToReturn.add(matchedDetail);
            return true;
        }
        return false;
    }

    private Boolean matchByAsurite(Contact contactMatch) {
        if (contactMatch.ASURITE_ID__c != null && asuriteWithDetail.containsKey((contactMatch.ASURITE_ID__c).toLowerCase())) {
            ConstituentDetail matchedDetail = asuriteWithDetail.get((contactMatch.ASURITE_ID__c).toLowerCase());
            matchedDetail.contactId = (Id) contactMatch.Id;
            matchedDetail.processingNotes +=
                String.format('Found existing Contact ID: {0} based on ASURITE match: {1} \n',
                new String[] {contactMatch.Id, contactMatch.ASURITE_ID__c});
            detailsToReturn.add(matchedDetail);
            return true;
        }
        return false;
    }

    private Boolean matchByFirstNameAndEmail(Contact contactMatch) {
        if (contactMatch.FirstName != null && contactMatch.Email != null && firstNameAndEmailWithDetail.containsKey((contactMatch.FirstName + contactMatch.Email).toLowerCase())) {
            ConstituentDetail matchedDetail = firstNameAndEmailWithDetail.get((contactMatch.FirstName + contactMatch.Email).toLowerCase());
            matchedDetail.contactId = (Id) contactMatch.Id;
            matchedDetail.processingNotes +=
                String.format('Found existing Contact ID: {0} based on email match: {1} and name match: {2} \n',
                new String[] {contactMatch.Id, contactMatch.Email, contactMatch.FirstName});
            detailsToReturn.add(matchedDetail);
            return true;
        }
        return false;
    }

    private Boolean matchByFirstNameAndLeadEmail(Contact contactMatch) {
        if (contactMatch.FirstName != null && contactMatch.Lead_Email__c != null && firstNameAndEmailWithDetail.containsKey((contactMatch.FirstName + contactMatch.Lead_Email__c).toLowerCase())) {
            ConstituentDetail matchedDetail = firstNameAndEmailWithDetail.get((contactMatch.FirstName + contactMatch.Lead_Email__c).toLowerCase());
            matchedDetail.contactId = (Id) contactMatch.Id;
            matchedDetail.processingNotes +=
                String.format('Found existing Contact ID: {0} based on lead email match: {1} and name match: {2} \n',
                new String[] {contactMatch.Id, contactMatch.Lead_Email__c, contactMatch.FirstName});
            detailsToReturn.add(matchedDetail);
            return true;
        }
        return false;
    }

    private Boolean matchByFirstNameAndLeadSecondaryEmail(Contact contactMatch) {
        if (contactMatch.FirstName != null && contactMatch.Lead_Secondary_Email__c != null && firstNameAndEmailWithDetail.containsKey((contactMatch.FirstName + contactMatch.Lead_Secondary_Email__c).toLowerCase())) {
            ConstituentDetail matchedDetail = firstNameAndEmailWithDetail.get((contactMatch.FirstName + contactMatch.Lead_Secondary_Email__c).toLowerCase());
            matchedDetail.contactId = (Id) contactMatch.Id;
            matchedDetail.processingNotes +=
                String.format('Found existing Contact ID: {0} based on lead secondary email match: {1} and name match: {2} \n',
                new String[] {contactMatch.Id, contactMatch.Lead_Secondary_Email__c, contactMatch.FirstName});
            detailsToReturn.add(matchedDetail);
            return true;
        }
        return false;
    }

    private Boolean matchByFirstNameAndPersonalEmail(Contact contactMatch) {
        if (contactMatch.FirstName != null && contactMatch.Personal_Email__c != null && firstNameAndEmailWithDetail.containsKey((contactMatch.FirstName + contactMatch.Personal_Email__c).toLowerCase())) {
            ConstituentDetail matchedDetail = firstNameAndEmailWithDetail.get((contactMatch.FirstName + contactMatch.Personal_Email__c).toLowerCase());
            matchedDetail.contactId = (Id) contactMatch.Id;
            matchedDetail.processingNotes +=
                String.format('Found existing Contact ID: {0} based on personal email match: {1} and name match: {2} \n',
                new String[] {contactMatch.Id, contactMatch.Personal_Email__c, contactMatch.FirstName});
            detailsToReturn.add(matchedDetail);
            return true;
        }
        return false;
    }

    private Boolean matchByFirstNameAndAsuGmail(Contact contactMatch) {
        if (contactMatch.FirstName != null && contactMatch.ASU_Gmail__c != null && firstNameAndEmailWithDetail.containsKey((contactMatch.FirstName + contactMatch.ASU_Gmail__c).toLowerCase())) {
            ConstituentDetail matchedDetail = firstNameAndEmailWithDetail.get((contactMatch.FirstName + contactMatch.ASU_Gmail__c).toLowerCase());
            matchedDetail.contactId = (Id) contactMatch.Id;
            matchedDetail.processingNotes +=
                String.format('Found existing Contact ID: {0} based on ASU Gmail email match: {1} and name match: {2} \n',
                new String[] {contactMatch.Id, contactMatch.ASU_Gmail__c, contactMatch.FirstName});
            detailsToReturn.add(matchedDetail);
            return true;
        }
        return false;
    }

    private Boolean matchByFirstNameAndEpoEmail(Contact contactMatch) {
        if (contactMatch.FirstName != null && contactMatch.EPO_Email__c != null && firstNameAndEmailWithDetail.containsKey((contactMatch.FirstName + contactMatch.EPO_Email__c).toLowerCase())) {
            ConstituentDetail matchedDetail = firstNameAndEmailWithDetail.get((contactMatch.FirstName + contactMatch.EPO_Email__c).toLowerCase());
            matchedDetail.contactId = (Id) contactMatch.Id;
            matchedDetail.processingNotes +=
                String.format('Found existing Contact ID: {0} based on EPO email match: {1} and name match: {2} \n',
                new String[] {contactMatch.Id, contactMatch.EPO_Email__c, contactMatch.FirstName});
            detailsToReturn.add(matchedDetail);
            return true;
        }
        return false;
    }

    private Boolean matchByFirstNameAndAsuEmail(Contact contactMatch) {
        if (contactMatch.FirstName != null && contactMatch.ASU_Email__c != null && firstNameAndEmailWithDetail.containsKey((contactMatch.FirstName + contactMatch.ASU_Email__c).toLowerCase())) {
            ConstituentDetail matchedDetail = firstNameAndEmailWithDetail.get((contactMatch.FirstName + contactMatch.ASU_Email__c).toLowerCase());
            matchedDetail.contactId = (Id) contactMatch.Id;
            matchedDetail.processingNotes +=
                String.format('Found existing Contact ID: {0} based on ASU email match: {1} and name match: {2} \n',
                new String[] {contactMatch.Id, contactMatch.ASU_Email__c, contactMatch.FirstName});
            detailsToReturn.add(matchedDetail);
            return true;
        }
        return false;
    }

    private Boolean matchByFirstNameWildcardAndEmail(Contact contactMatch) {
        String firstNameWildcard;
        if (contactMatch.FirstName != null && contactMatch.Email != null) {
            firstNameWildcard = getFirstNameWildcard(String.valueOf(contactMatch.FirstName), String.valueOf(contactMatch.Email));
            if (firstNameWildcardAndEmailWithDetail.containsKey((contactMatch.Email).toLowerCase())) {
                ConstituentDetail matchedDetail = firstNameWildcardAndEmailWithDetail.get((contactMatch.Email).toLowerCase());
                matchedDetail.contactId = (Id) contactMatch.Id;
                matchedDetail.processingNotes +=
                    String.format('Found existing Contact ID: {0} based on email match: {1} and first {2} character(s) of first name match: {3} \n',
                    new String[] {contactMatch.Id, contactMatch.Email, String.valueOf(firstNameWildcard.length() - 1), firstNameWildcard});
                detailsToReturn.add(matchedDetail);
                return true;
            }
        }
        return false;
    }

    private Boolean matchByFirstNameWildcardAndLeadEmail(Contact contactMatch) {
        String firstNameWildcard;
        if (contactMatch.FirstName != null && contactMatch.Lead_Email__c != null) {
            firstNameWildcard = getFirstNameWildcard(String.valueOf(contactMatch.FirstName), String.valueOf(contactMatch.Lead_Email__c));
            if (firstNameWildcardAndEmailWithDetail.containsKey((contactMatch.Lead_Email__c).toLowerCase())) {
                ConstituentDetail matchedDetail = firstNameWildcardAndEmailWithDetail.get((contactMatch.Lead_Email__c).toLowerCase());
                matchedDetail.contactId = (Id) contactMatch.Id;
                matchedDetail.processingNotes +=
                    String.format('Found existing Contact ID: {0} based on lead email match: {1} and first {2} character(s) of first name match: {3} \n',
                    new String[] {contactMatch.Id, contactMatch.Lead_Email__c, String.valueOf(firstNameWildcard.length() - 1), firstNameWildcard});
                detailsToReturn.add(matchedDetail);
                return true;
            }
        }
        return false;
    }

    private Boolean matchByFirstNameWildcardAndLeadSecondaryEmail(Contact contactMatch) {
        String firstNameWildcard;
        if (contactMatch.FirstName != null && contactMatch.Lead_Secondary_Email__c != null) {
            firstNameWildcard = getFirstNameWildcard(String.valueOf(contactMatch.FirstName), String.valueOf(contactMatch.Lead_Secondary_Email__c));
            if (firstNameWildcardAndEmailWithDetail.containsKey((contactMatch.Lead_Secondary_Email__c).toLowerCase())) {
                ConstituentDetail matchedDetail = firstNameWildcardAndEmailWithDetail.get((contactMatch.Lead_Secondary_Email__c).toLowerCase());
                matchedDetail.contactId = (Id) contactMatch.Id;
                matchedDetail.processingNotes +=
                    String.format('Found existing Contact ID: {0} based on lead secondary email match: {1} and first {2} character(s) of first name match: {3} \n',
                    new String[] {contactMatch.Id, contactMatch.Lead_Secondary_Email__c, String.valueOf(firstNameWildcard.length() - 1), firstNameWildcard});
                detailsToReturn.add(matchedDetail);
                return true;
            }
        }
        return false;
    }

    private Boolean matchByFirstNameWildcardAndPersonalEmail(Contact contactMatch) {
        String firstNameWildcard;
        if (contactMatch.FirstName != null && contactMatch.Personal_Email__c != null) {
            firstNameWildcard = getFirstNameWildcard(String.valueOf(contactMatch.FirstName), String.valueOf(contactMatch.Personal_Email__c));
            if (firstNameWildcardAndEmailWithDetail.containsKey((contactMatch.Personal_Email__c).toLowerCase())) {
                ConstituentDetail matchedDetail = firstNameWildcardAndEmailWithDetail.get((contactMatch.Personal_Email__c).toLowerCase());
                matchedDetail.contactId = (Id) contactMatch.Id;
                matchedDetail.processingNotes +=
                    String.format('Found existing Contact ID: {0} based on personal email match: {1} and first {2} character(s) of first name match: {3} \n',
                    new String[] {contactMatch.Id, contactMatch.Personal_Email__c, String.valueOf(firstNameWildcard.length() - 1), firstNameWildcard});
                detailsToReturn.add(matchedDetail);
                return true;
            }
        }
        return false;
    }

    private Boolean matchByFirstNameWildcardAndAsuGmail(Contact contactMatch) {
        String firstNameWildcard;
        if (contactMatch.FirstName != null && contactMatch.ASU_Gmail__c != null) {
            firstNameWildcard = getFirstNameWildcard(String.valueOf(contactMatch.FirstName), String.valueOf(contactMatch.ASU_Gmail__c));
            if (firstNameWildcardAndEmailWithDetail.containsKey((contactMatch.ASU_Gmail__c).toLowerCase())) {
                ConstituentDetail matchedDetail = firstNameWildcardAndEmailWithDetail.get((contactMatch.ASU_Gmail__c).toLowerCase());
                matchedDetail.contactId = (Id) contactMatch.Id;
                matchedDetail.processingNotes +=
                    String.format('Found existing Contact ID: {0} based on ASU Gmail match: {1} and first {2} character(s) of first name match: {3} \n',
                    new String[] {contactMatch.Id, contactMatch.ASU_Gmail__c, String.valueOf(firstNameWildcard.length() - 1), firstNameWildcard});
                detailsToReturn.add(matchedDetail);
                return true;
            }
        }
        return false;
    }

    private Boolean matchByFirstNameWildcardAndEpoEmail(Contact contactMatch) {
        String firstNameWildcard;
        if (contactMatch.FirstName != null && contactMatch.EPO_Email__c != null) {
            firstNameWildcard = getFirstNameWildcard(String.valueOf(contactMatch.FirstName), String.valueOf(contactMatch.EPO_Email__c));
            if (firstNameWildcardAndEmailWithDetail.containsKey((contactMatch.EPO_Email__c).toLowerCase())) {
                ConstituentDetail matchedDetail = firstNameWildcardAndEmailWithDetail.get((contactMatch.EPO_Email__c).toLowerCase());
                matchedDetail.contactId = (Id) contactMatch.Id;
                matchedDetail.processingNotes +=
                    String.format('Found existing Contact ID: {0} based on EPO email match: {1} and first {2} character(s) of first name match: {3} \n',
                    new String[] {contactMatch.Id, contactMatch.EPO_Email__c, String.valueOf(firstNameWildcard.length() - 1), firstNameWildcard});
                detailsToReturn.add(matchedDetail);
                return true;
            }
        }
        return false;
    }

    private Boolean matchByFirstNameWildcardAndAsuEmail(Contact contactMatch) {
        String firstNameWildcard;
        if (contactMatch.FirstName != null && contactMatch.ASU_Email__c != null) {
            firstNameWildcard = getFirstNameWildcard(String.valueOf(contactMatch.FirstName), String.valueOf(contactMatch.ASU_Email__c));
            if (firstNameWildcardAndEmailWithDetail.containsKey((contactMatch.ASU_Email__c).toLowerCase())) {
                ConstituentDetail matchedDetail = firstNameWildcardAndEmailWithDetail.get((contactMatch.ASU_Email__c).toLowerCase());
                matchedDetail.contactId = (Id) contactMatch.Id;
                matchedDetail.processingNotes +=
                    String.format('Found existing Contact ID: {0} based on ASU email match: {1} and first {2} character(s) of first name match: {3} \n',
                    new String[] {contactMatch.Id, contactMatch.ASU_Email__c, String.valueOf(firstNameWildcard.length() - 1), firstNameWildcard});
                detailsToReturn.add(matchedDetail);
                return true;
            }
        }
        return false;
    }
}