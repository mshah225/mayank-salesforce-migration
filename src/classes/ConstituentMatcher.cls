public class ConstituentMatcher {
    public List<ConstituentDetail> detailsToSearch {get; set;}
    public List<ConstituentDetail> detailsToReturn = new List<ConstituentDetail>();
    public List<SObject> matchedConstituents = new List<SObject>();
    public Map<String, ConstituentDetail> asuriteWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> emplidWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> firstNameAndEmailWithDetail = new Map<String, ConstituentDetail>();
    public Map<String, ConstituentDetail> partialFirstNameAndEmailWithDetail = new Map<String, ConstituentDetail>();
    public Set<String> emailSet = new Set<String>();
    public Set<String> firstNameSet = new Set<String>();
    public Set<String> partialFirstNameSet = new Set<String>();

    public ConstituentMatcher(ConstituentDetail detailToSearch) {
        List<ConstituentDetail> singleDetailToList = new List<ConstituentDetail>();
        singleDetailToList.add(detailToSearch);
        this.detailsToSearch = singleDetailToList;
    }

    public ConstituentMatcher(List<ConstituentDetail> detailsToSearch) {
        this.detailsToSearch = detailsToSearch;
    }

    public List<ConstituentDetail> getListOfConstituentsWithMatches() {
        return detailsToReturn;
    }

    public Map<String, ConstituentDetail> getAsuriteWithDetailMap() {
        return asuriteWithDetail;
    }

    public Map<String, ConstituentDetail> getEmplidWithDetailMap() {
        return emplidWithDetail;
    }

    public Set<String> getEmailSet() {
        return emailSet;
    }

    public Set<String> getfirstNameSet() {
        return firstNameSet;
    }

    public Set<String> getPartialFirstNameSet() {
        return partialFirstNameSet;
    }

    private String getSObjectType(SObject sObjectOfUnknownType) {
        String sObjectType = sObjectOfUnknownType.getRecord().getSObjectType().getDescribe().getName();
        return sObjectType;
    }

    public void searchContacts() {
        createDataMappingForSearch();
        getContactsMatchedByMappedValues();
        getLeadsMatchedByMappedValues();
        associateDetailsWithMatchedContacts();
    }

    public void createDataMappingForSearch() {
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
        String partialFirstName;
        if (String.isNotBlank(detail.firstName) && String.isNotBlank(detail.email)) {
            firstNameAndEmailWithDetail.put((detail.firstName + detail.email).toLowerCase(), detail);
            firstNameSet.add(detail.firstName);
            emailSet.add(detail.email);
            partialFirstName = getPartialFirstName(String.valueOf(detail.firstName), String.valueOf(detail.email));
            partialFirstNameAndEmailWithDetail.put((detail.email).toLowerCase(), detail);
            partialFirstNameSet.add(partialFirstName);
        }
    }

   public String getPartialFirstName(String firstName, String email) {
        String originalFirstName = firstName;
        String partialFirstName;

        Map<String, String> detailFieldsMap = new Map<String, String>();
        detailFieldsMap.put('email', email);
        detailFieldsMap.put('firstName', firstName);
        ConstituentDetail originalContactDetails = new ConstituentDetail(detailFieldsMap);

        if (partialFirstNameAndEmailWithDetail.containsKey(email)) {
            originalContactDetails = partialFirstNameAndEmailWithDetail.get(email);
            originalFirstName = originalContactDetails.firstName;
        }
        if (originalFirstName.length() >= 3) {
            partialFirstName = firstName.substring(0, 3) + '%';
        } else if (firstName.length() < 3) {
            partialFirstName = firstName.substring(0, originalFirstName.length()) + '%';
        }

        return partialFirstName;
    }

    public void getLeadsMatchedByMappedValues() {
        List<Contact> matchedLeads = [
            SELECT Id, EMPLID__c, ASURITE_ID__c, FirstName, Email, Lead_Email__c, Lead_Secondary_Email__c, 
                Personal_Email__c, LastName, MailingStreet, MailingPostalCode, MobilePhone, Phone
            FROM Lead
            WHERE (
                (FirstName IN :firstNameSet
                    OR FirstName LIKE :partialFirstNameSet)
                AND (Email IN :emailSet
                    OR Secondary_Email__c IN :emailSet
                    OR Recruiting_Email__c IN :emailSet
                )
            )
            OR EMPLID__c IN :emplidWithDetail.keySet()
        ];
        
        if (matchedLeads.size() > 0) {
            List<SObject> matchedLeadsGeneric = (List<SObject>) matchedLeads;
            matchedConstituents.add(matchedLeadsGeneric);
        }
    }

    public void getContactsMatchedByMappedValues() {
        List<Lead> matchedContacts = [
            SELECT Id, EMPLID__c, FirstName, Email, Secondary_Email__c, Recruiting_Email__c,
                Birthdate, MailingPostalCode, HomePhone, MobilePhone, SF_Mobile__c, Phone, OtherPhone, MailingStreet
            FROM Contact
            WHERE (
                (FirstName IN :firstNameSet
                    OR FirstName LIKE :partialFirstNameSet)
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

        if (matchedContacts.size() > 0) {
            List<SObject> matchedContactsGeneric = (List<SObject>) matchedContacts;
            matchedConstituents.add(matchedContactsGeneric);
        }
    }

    public void associateDetailsWithMatchedContacts() {
        Integer constituentMatchesFound = 0;
        constituentsWithoutInitialMatch = new List<SObject>();

        for (SObject matchedConstituent : matchedConstituents) {
            String sObjectType = getSObjectType(matchedConstituent);
            
            if (matchConstituentByEmplId(matchedConstituent)) {
                constituentMatchesFound++;
            }

            if (sObjectType == 'Contact') {
                if (matchContactByAsurite(matchedConstituent)) {
                    constituentMatchesFound++;
                }
            }

            if (matchConstituentByFirstNameAndEmail(matchedConstituent)) {
                constituentMatchesFound++;
            }
            
            if (sObjectType == 'Contact') {
                if (matchConstituentByFirstNameAndEmail(matchedConstituent)) {
                    constituentMatchesFound++;
                }
                if (matchContactByFirstNameAndLeadEmail(matchedConstituent)) {
                    constituentMatchesFound++;
                }
                if (matchContactByFirstNameAndLeadSecondaryEmail(matchedConstituent)) {
                    constituentMatchesFound++;
                }
                if (matchContactByFirstNameAndPersonalEmail(matchedConstituent)) {
                    constituentMatchesFound++;
                }
                if (matchContactByFirstNameAndAsuGmail(matchedConstituent)) {
                    constituentMatchesFound++;
                }
                if (matchContactByFirstNameAndEpoEmail(matchedConstituent)) {
                    constituentMatchesFound++;
                }
                if (matchContactByFirstNameAndAsuEmail(matchedConstituent)) {
                    constituentMatchesFound++;
                }
            }

            if (sObjectType == 'Lead') {
                if (matchLeadByFirstNameAndSecondaryEmail(matchedConstituent)) {
                    constituentMatchesFound++;
                }
                if (matchLeadByFirstNameAndRecruitingEmail(matchedConstituent)) {
                    constituentMatchesFound++;
                }
            }

            if (constituentMatchesFound == 0) {
                constituentsWithoutInitialMatch.add(matchedConstituent);
            }

            for (SObject unmatchedConstituent : constituentsWithoutInitialMatch) {
                matchConstituentByPartialFirstNameAndEmail(unmatchedConstituent);

                if (sObjectType == 'Contact') {
                    matchContactByPartialFirstNameAndLeadEmail(unmatchedConstituent);
                    matchContactByPartialFirstNameAndLeadSecondaryEmail(unmatchedConstituent);
                    matchContactByPartialFirstNameAndPersonalEmail(unmatchedConstituent);
                    matchContactByPartialFirstNameAndAsuGmail(unmatchedConstituent);
                    matchContactByPartialFirstNameAndEpoEmail(unmatchedConstituent);
                    matchContactByPartialFirstNameAndAsuEmail(unmatchedConstituent);
                }
                
                if (sObjectType == 'Lead') {
                    matchLeadByPartialFirstNameAndSecondaryEmail(unmatchedConstituent);
                    matchLeadByPartialFirstNameAndRecruitingEmail(unmatchedConstituent);
                }
            }
        }
    }

    private Boolean matchConstituentByEmplId(SObject constituentMatch) {
        String sObjectType = getSObjectType(constituentMatch);

        if (sObjectType == 'Contact') {
            Contact contactMatch = (Contact) constituentMatch;
            if (contactMatch.EMPLID__c != null && emplidWithDetail.containsKey((contactMatch.EMPLID__c).toLowerCase())) {
                ConstituentDetail matchedDetail = emplidWithDetail.get((contactMatch.EMPLID__c).toLowerCase());
                if (matchedDetail.constituentId != null) {
                    return false;
                }
                matchedDetail.constituentId = (Id) contactMatch.Id;
                matchedDetail.processingNotes +=
                    String.format('Found existing {0} ID: {1} based on Emplid match: {2} \n',
                    new String[] {sObjectType, contactMatch.Id, contactMatch.EMPLID__c});
                detailsToReturn.add(matchedDetail);
                return true;
            }
        }

        if (sObjectType == 'Lead') {
            Lead leadMatch = (Lead) constituentMatch;
            if (leadMatch.EMPLID__c != null && emplidWithDetail.containsKey((leadMatch.EMPLID__c).toLowerCase())) {
                ConstituentDetail matchedDetail = emplidWithDetail.get((leadMatch.EMPLID__c).toLowerCase());
                if (matchedDetail.constituentId != null) {
                    return false;
                }
                matchedDetail.constituentId = (Id) leadMatch.Id;
                matchedDetail.processingNotes +=
                    String.format('Found existing {0} ID: {1} based on Emplid match: {2} \n',
                    new String[] {sObjectType, leadMatch.Id, leadMatch.EMPLID__c});
                detailsToReturn.add(matchedDetail);
                return true;
            }
        }

        return false;
    }

    private Boolean matchContactByAsurite(SObject constituentMatch) {
        Contact contactMatch = (Contact) constituentMatch;
        if (contactMatch.ASURITE_ID__c != null && asuriteWithDetail.containsKey((contactMatch.ASURITE_ID__c).toLowerCase())) {
            ConstituentDetail matchedDetail = asuriteWithDetail.get((contactMatch.ASURITE_ID__c).toLowerCase());
            if (matchedDetail.constituentId != null) {
                return false;
            }
            matchedDetail.constituentId = (Id) contactMatch.Id;
            matchedDetail.processingNotes +=
                String.format('Found existing Contact ID: {0} based on ASURITE match: {1} \n',
                new String[] {contactMatch.Id, contactMatch.ASURITE_ID__c});
            detailsToReturn.add(matchedDetail);
            return true;
        }
        return false;
    }

    private Boolean matchConstituentByFirstNameAndEmail(SObject constituentMatch) {
        String sObjectType = getSObjectType(constituentMatch);

        if (sObjectType == 'Contact') {
            Contact contactMatch = (Contact) constituentMatch;
            if (contactMatch.FirstName != null && contactMatch.Email != null && firstNameAndEmailWithDetail.containsKey((contactMatch.FirstName + contactMatch.Email).toLowerCase())) {
                ConstituentDetail matchedDetail = firstNameAndEmailWithDetail.get((contactMatch.FirstName + contactMatch.Email).toLowerCase());
                if (matchedDetail.constituentId != null) {
                    return false;
                }
                matchedDetail.constituentId = (Id) contactMatch.Id;
                matchedDetail.processingNotes +=
                    String.format('Found existing {0} ID: {1} based on Emplid match: {2} \n',
                    new String[] {sObjectType, contactMatch.Id, contactMatch.EMPLID__c});
                detailsToReturn.add(matchedDetail);
                return true;
            }
        }

        if (sObjectType == 'Lead') {
            Lead leadMatch = (Lead) constituentMatch;
            if (leadMatch.FirstName != null && leadMatch.Email != null && firstNameAndEmailWithDetail.containsKey((leadMatch.FirstName + leadMatch.Email).toLowerCase())) {
                ConstituentDetail matchedDetail = firstNameAndEmailWithDetail.get((leadMatch.FirstName + leadMatch.Email).toLowerCase());
                if (matchedDetail.constituentId != null) {
                    return false;
                }
                matchedDetail.constituentId = (Id) leadMatch.Id;
                matchedDetail.processingNotes +=
                    String.format('Found existing {0} ID: {1} based on Emplid match: {2} \n',
                    new String[] {sObjectType, leadMatch.Id, leadMatch.EMPLID__c});
                detailsToReturn.add(matchedDetail);
                return true;
            }
        }

        return false;
    }

    private Boolean matchContactByFirstNameAndLeadEmail(SObject constituentMatch) {
        Contact contactMatch = (Contact) constituentMatch;
        if (contactMatch.FirstName != null && contactMatch.Lead_Email__c != null && firstNameAndEmailWithDetail.containsKey((contactMatch.FirstName + contactMatch.Lead_Email__c).toLowerCase())) {
            ConstituentDetail matchedDetail = firstNameAndEmailWithDetail.get((contactMatch.FirstName + contactMatch.Lead_Email__c).toLowerCase());
            if (matchedDetail.constituentId != null) {
                return false;
            }
            matchedDetail.constituentId = (Id) contactMatch.Id;
            matchedDetail.processingNotes +=
                String.format('Found existing Contact ID: {0} based on lead email match: {1} and name match: {2} \n',
                new String[] {contactMatch.Id, contactMatch.Lead_Email__c, contactMatch.FirstName});
            detailsToReturn.add(matchedDetail);
            return true;
        }
        return false;
    }

    private Boolean matchContactByFirstNameAndLeadSecondaryEmail(SObject constituentMatch) {
        Contact contactMatch = (Contact) constituentMatch;
        if (contactMatch.FirstName != null && contactMatch.Lead_Secondary_Email__c != null && firstNameAndEmailWithDetail.containsKey((contactMatch.FirstName + contactMatch.Lead_Secondary_Email__c).toLowerCase())) {
            ConstituentDetail matchedDetail = firstNameAndEmailWithDetail.get((contactMatch.FirstName + contactMatch.Lead_Secondary_Email__c).toLowerCase());
            if (matchedDetail.constituentId != null) {
                return false;
            }
            matchedDetail.constituentId = (Id) contactMatch.Id;
            matchedDetail.processingNotes +=
                String.format('Found existing Contact ID: {0} based on lead secondary email match: {1} and name match: {2} \n',
                new String[] {contactMatch.Id, contactMatch.Lead_Secondary_Email__c, contactMatch.FirstName});
            detailsToReturn.add(matchedDetail);
            return true;
        }
        return false;
    }

    private Boolean matchContactByFirstNameAndPersonalEmail(SObject constituentMatch) {
        Contact contactMatch = (Contact) constituentMatch;
        if (contactMatch.FirstName != null && contactMatch.Personal_Email__c != null && firstNameAndEmailWithDetail.containsKey((contactMatch.FirstName + contactMatch.Personal_Email__c).toLowerCase())) {
            ConstituentDetail matchedDetail = firstNameAndEmailWithDetail.get((contactMatch.FirstName + contactMatch.Personal_Email__c).toLowerCase());
            if (matchedDetail.constituentId != null) {
                return false;
            }
            matchedDetail.constituentId = (Id) contactMatch.Id;
            matchedDetail.processingNotes +=
                String.format('Found existing Contact ID: {0} based on personal email match: {1} and name match: {2} \n',
                new String[] {contactMatch.Id, contactMatch.Personal_Email__c, contactMatch.FirstName});
            detailsToReturn.add(matchedDetail);
            return true;
        }
        return false;
    }

    private Boolean matchContactByFirstNameAndAsuGmail(SObject constituentMatch) {
        Contact contactMatch = (Contact) constituentMatch;
        if (contactMatch.FirstName != null && contactMatch.ASU_Gmail__c != null && firstNameAndEmailWithDetail.containsKey((contactMatch.FirstName + contactMatch.ASU_Gmail__c).toLowerCase())) {
            ConstituentDetail matchedDetail = firstNameAndEmailWithDetail.get((contactMatch.FirstName + contactMatch.ASU_Gmail__c).toLowerCase());
            if (matchedDetail.constituentId != null) {
                return false;
            }
            matchedDetail.constituentId = (Id) contactMatch.Id;
            matchedDetail.processingNotes +=
                String.format('Found existing Contact ID: {0} based on ASU Gmail email match: {1} and name match: {2} \n',
                new String[] {contactMatch.Id, contactMatch.ASU_Gmail__c, contactMatch.FirstName});
            detailsToReturn.add(matchedDetail);
            return true;
        }
        return false;
    }

    private Boolean matchContactByFirstNameAndEpoEmail(SObject constituentMatch) {
        Contact contactMatch = (Contact) constituentMatch;
        if (contactMatch.FirstName != null && contactMatch.EPO_Email__c != null && firstNameAndEmailWithDetail.containsKey((contactMatch.FirstName + contactMatch.EPO_Email__c).toLowerCase())) {
            ConstituentDetail matchedDetail = firstNameAndEmailWithDetail.get((contactMatch.FirstName + contactMatch.EPO_Email__c).toLowerCase());
            if (matchedDetail.constituentId != null) {
                return false;
            }
            matchedDetail.constituentId = (Id) contactMatch.Id;
            matchedDetail.processingNotes +=
                String.format('Found existing Contact ID: {0} based on EPO email match: {1} and name match: {2} \n',
                new String[] {contactMatch.Id, contactMatch.EPO_Email__c, contactMatch.FirstName});
            detailsToReturn.add(matchedDetail);
            return true;
        }
        return false;
    }

    private Boolean matchContactByFirstNameAndAsuEmail(SObject constituentMatch) {
        Contact contactMatch = (Contact) constituentMatch;
        if (contactMatch.FirstName != null && contactMatch.ASU_Email__c != null && firstNameAndEmailWithDetail.containsKey((contactMatch.FirstName + contactMatch.ASU_Email__c).toLowerCase())) {
            ConstituentDetail matchedDetail = firstNameAndEmailWithDetail.get((contactMatch.FirstName + contactMatch.ASU_Email__c).toLowerCase());
            if (matchedDetail.constituentId != null) {
                return false;
            }
            matchedDetail.constituentId = (Id) contactMatch.Id;
            matchedDetail.processingNotes +=
                String.format('Found existing Contact ID: {0} based on ASU email match: {1} and name match: {2} \n',
                new String[] {contactMatch.Id, contactMatch.ASU_Email__c, contactMatch.FirstName});
            detailsToReturn.add(matchedDetail);
            return true;
        }
        return false;
    }

    private Boolean matchLeadByFirstNameAndSecondaryEmail(SObject constituentMatch) {
        Lead leadMatch = (Lead) constituentMatch;
        if (leadMatch.FirstName != null && leadMatch.Secondary_Email__c != null && firstNameAndEmailWithDetail.containsKey((leadMatch.FirstName + leadMatch.Secondary_Email__c).toLowerCase())) {
            ConstituentDetail matchedDetail = firstNameAndEmailWithDetail.get((leadMatch.FirstName + leadMatch.Secondary_Email__c).toLowerCase());
            if (matchedDetail.constituentId != null) {
                return false;
            }
            matchedDetail.constituentId = (Id) leadMatch.Id;
            matchedDetail.processingNotes +=
                String.format('Found existing Lead ID: {0} based on secondary email match: {1} and name match: {2} \n',
                new String[] {leadMatch.Id, leadMatch.Secondary_Email__c, leadMatch.FirstName});
            detailsToReturn.add(matchedDetail);
            return true;
        }
        return false;
    }

    private Boolean matchLeadByFirstNameAndRecruitingEmail(SObject constituentMatch) {
        Lead leadMatch = (Lead) constituentMatch;
        if (leadMatch.FirstName != null && leadMatch.Recruiting_Email__c != null && firstNameAndEmailWithDetail.containsKey((leadMatch.FirstName + leadMatch.Recruiting_Email__c).toLowerCase())) {
            ConstituentDetail matchedDetail = firstNameAndEmailWithDetail.get((leadMatch.FirstName + leadMatch.Recruiting_Email__c).toLowerCase());
            if (matchedDetail.constituentId != null) {
                return false;
            }
            matchedDetail.constituentId = (Id) leadMatch.Id;
            matchedDetail.processingNotes +=
                String.format('Found existing Lead ID: {0} based on recruiting email match: {1} and name match: {2} \n',
                new String[] {leadMatch.Id, leadMatch.Recruiting_Email__c, leadMatch.FirstName});
            detailsToReturn.add(matchedDetail);
            return true;
        }
        return false;
    }

    private Boolean matchConstituentByPartialFirstNameAndEmail(SObject constituentMatch) {
        String partialFirstName;
        String sObjectType = getSObjectType(constituentMatch);

        if (sObjectType == 'Contact') {
            if (contactMatch.FirstName != null && contactMatch.Email != null) {
                partialFirstName = getPartialFirstName(String.valueOf(contactMatch.FirstName), String.valueOf(contactMatch.Email));
                if (partialFirstNameAndEmailWithDetail.containsKey((contactMatch.Email).toLowerCase())) {
                    ConstituentDetail matchedDetail = partialFirstNameAndEmailWithDetail.get((contactMatch.Email).toLowerCase());
                    if (matchedDetail.constituentId != null) {
                        return false;
                    }
                    matchedDetail.constituentId = (Id) contactMatch.Id;
                    matchedDetail.processingNotes +=
                        String.format('Found existing {0} ID: {1} based on email match: {2} and first {3} character(s) of first name match: {4} \n',
                        new String[] {sObjectType, contactMatch.Id, contactMatch.Email, String.valueOf(partialFirstName.length() - 1), partialFirstName});
                    detailsToReturn.add(matchedDetail);
                    return true;
                }
            }
        }

        if (sObjectType == 'Lead') {
            if (leadMatch.FirstName != null && leadMatch.Email != null) {
                partialFirstName = getPartialFirstName(String.valueOf(leadMatch.FirstName), String.valueOf(leadMatch.Email));
                if (partialFirstNameAndEmailWithDetail.containsKey((leadMatch.Email).toLowerCase())) {
                    ConstituentDetail matchedDetail = partialFirstNameAndEmailWithDetail.get((leadMatch.Email).toLowerCase());
                    if (matchedDetail.constituentId != null) {
                        return false;
                    }
                    matchedDetail.constituentId = (Id) leadMatch.Id;
                    matchedDetail.processingNotes +=
                        String.format('Found existing {0} ID: {1} based on email match: {2} and first {3} character(s) of first name match: {4} \n',
                        new String[] {sObjectType, leadMatch.Id, leadMatch.Email, String.valueOf(partialFirstName.length() - 1), partialFirstName});
                    detailsToReturn.add(matchedDetail);
                    return true;
                }
            }
        }
        
        return false;
    }

    private Boolean matchContactByPartialFirstNameAndLeadEmail(SObject constituentMatch) {
        Contact contactMatch = (Contact) constituentMatch;
        String partialFirstName;
        if (contactMatch.FirstName != null && contactMatch.Lead_Email__c != null) {
            partialFirstName = getPartialFirstName(String.valueOf(contactMatch.FirstName), String.valueOf(contactMatch.Lead_Email__c));
            if (partialFirstNameAndEmailWithDetail.containsKey((contactMatch.Lead_Email__c).toLowerCase())) {
                ConstituentDetail matchedDetail = partialFirstNameAndEmailWithDetail.get((contactMatch.Lead_Email__c).toLowerCase());
                if (matchedDetail.constituentId != null) {
                    return false;
                }
                matchedDetail.constituentId = (Id) contactMatch.Id;
                matchedDetail.processingNotes +=
                    String.format('Found existing Contact ID: {0} based on lead email match: {1} and first {2} character(s) of first name match: {3} \n',
                    new String[] {contactMatch.Id, contactMatch.Lead_Email__c, String.valueOf(partialFirstName.length() - 1), partialFirstName});
                detailsToReturn.add(matchedDetail);
                return true;
            }
        }
        return false;
    }

    private Boolean matchContactByPartialFirstNameAndLeadSecondaryEmail(SObject constituentMatch) {
        Contact contactMatch = (Contact) constituentMatch;
        String partialFirstName;
        if (contactMatch.FirstName != null && contactMatch.Lead_Secondary_Email__c != null) {
            partialFirstName = getPartialFirstName(String.valueOf(contactMatch.FirstName), String.valueOf(contactMatch.Lead_Secondary_Email__c));
            if (partialFirstNameAndEmailWithDetail.containsKey((contactMatch.Lead_Secondary_Email__c).toLowerCase())) {
                ConstituentDetail matchedDetail = partialFirstNameAndEmailWithDetail.get((contactMatch.Lead_Secondary_Email__c).toLowerCase());
                if (matchedDetail.constituentId != null) {
                    return false;
                }
                matchedDetail.constituentId = (Id) contactMatch.Id;
                matchedDetail.processingNotes +=
                    String.format('Found existing Contact ID: {0} based on lead secondary email match: {1} and first {2} character(s) of first name match: {3} \n',
                    new String[] {contactMatch.Id, contactMatch.Lead_Secondary_Email__c, String.valueOf(partialFirstName.length() - 1), partialFirstName});
                detailsToReturn.add(matchedDetail);
                return true;
            }
        }
        return false;
    }

    private Boolean matchContactByPartialFirstNameAndPersonalEmail(SObject constituentMatch) {
        Contact contactMatch = (Contact) constituentMatch;
        String partialFirstName;
        if (contactMatch.FirstName != null && contactMatch.Personal_Email__c != null) {
            partialFirstName = getPartialFirstName(String.valueOf(contactMatch.FirstName), String.valueOf(contactMatch.Personal_Email__c));
            if (partialFirstNameAndEmailWithDetail.containsKey((contactMatch.Personal_Email__c).toLowerCase())) {
                ConstituentDetail matchedDetail = partialFirstNameAndEmailWithDetail.get((contactMatch.Personal_Email__c).toLowerCase());
                if (matchedDetail.constituentId != null) {
                    return false;
                }
                matchedDetail.constituentId = (Id) contactMatch.Id;
                matchedDetail.processingNotes +=
                    String.format('Found existing Contact ID: {0} based on personal email match: {1} and first {2} character(s) of first name match: {3} \n',
                    new String[] {contactMatch.Id, contactMatch.Personal_Email__c, String.valueOf(partialFirstName.length() - 1), partialFirstName});
                detailsToReturn.add(matchedDetail);
                return true;
            }
        }
        return false;
    }

    private Boolean matchContactByPartialFirstNameAndAsuGmail(SObject constituentMatch) {
        Contact contactMatch = (Contact) constituentMatch;
        String partialFirstName;
        if (contactMatch.FirstName != null && contactMatch.ASU_Gmail__c != null) {
            partialFirstName = getPartialFirstName(String.valueOf(contactMatch.FirstName), String.valueOf(contactMatch.ASU_Gmail__c));
            if (partialFirstNameAndEmailWithDetail.containsKey((contactMatch.ASU_Gmail__c).toLowerCase())) {
                ConstituentDetail matchedDetail = partialFirstNameAndEmailWithDetail.get((contactMatch.ASU_Gmail__c).toLowerCase());
                if (matchedDetail.constituentId != null) {
                    return false;
                }
                matchedDetail.constituentId = (Id) contactMatch.Id;
                matchedDetail.processingNotes +=
                    String.format('Found existing Contact ID: {0} based on ASU Gmail match: {1} and first {2} character(s) of first name match: {3} \n',
                    new String[] {contactMatch.Id, contactMatch.ASU_Gmail__c, String.valueOf(partialFirstName.length() - 1), partialFirstName});
                detailsToReturn.add(matchedDetail);
                return true;
            }
        }
        return false;
    }

    private Boolean matchContactByPartialFirstNameAndEpoEmail(SObject constituentMatch) {
        Contact contactMatch = (Contact) constituentMatch;
        String partialFirstName;
        if (contactMatch.FirstName != null && contactMatch.EPO_Email__c != null) {
            partialFirstName = getPartialFirstName(String.valueOf(contactMatch.FirstName), String.valueOf(contactMatch.EPO_Email__c));
            if (partialFirstNameAndEmailWithDetail.containsKey((contactMatch.EPO_Email__c).toLowerCase())) {
                ConstituentDetail matchedDetail = partialFirstNameAndEmailWithDetail.get((contactMatch.EPO_Email__c).toLowerCase());
                if (matchedDetail.constituentId != null) {
                    return false;
                }
                matchedDetail.constituentId = (Id) contactMatch.Id;
                matchedDetail.processingNotes +=
                    String.format('Found existing Contact ID: {0} based on EPO email match: {1} and first {2} character(s) of first name match: {3} \n',
                    new String[] {contactMatch.Id, contactMatch.EPO_Email__c, String.valueOf(partialFirstName.length() - 1), partialFirstName});
                detailsToReturn.add(matchedDetail);
                return true;
            }
        }
        return false;
    }

    private Boolean matchContactByPartialFirstNameAndAsuEmail(SObject constituentMatch) {
        Contact contactMatch = (Contact) constituentMatch;
        String partialFirstName;
        if (contactMatch.FirstName != null && contactMatch.ASU_Email__c != null) {
            partialFirstName = getPartialFirstName(String.valueOf(contactMatch.FirstName), String.valueOf(contactMatch.ASU_Email__c));
            if (partialFirstNameAndEmailWithDetail.containsKey((contactMatch.ASU_Email__c).toLowerCase())) {
                ConstituentDetail matchedDetail = partialFirstNameAndEmailWithDetail.get((contactMatch.ASU_Email__c).toLowerCase());
                if (matchedDetail.constituentId != null) {
                    return false;
                }
                matchedDetail.constituentId = (Id) contactMatch.Id;
                matchedDetail.processingNotes +=
                    String.format('Found existing Contact ID: {0} based on ASU email match: {1} and first {2} character(s) of first name match: {3} \n',
                    new String[] {contactMatch.Id, contactMatch.ASU_Email__c, String.valueOf(partialFirstName.length() - 1), partialFirstName});
                detailsToReturn.add(matchedDetail);
                return true;
            }
        }
        return false;
    }

    private Boolean matchLeadByPartialFirstNameAndSecondaryEmail(SObject constituentMatch) {
        Lead leadMatch = (Lead) constituentMatch;
        String partialFirstName;
        if (leadMatch.FirstName != null && leadMatch.Secondary_Email__c != null) {
            partialFirstName = getPartialFirstName(String.valueOf(leadMatch.FirstName), String.valueOf(leadMatch.Secondary_Email__c));
            if (partialFirstNameAndEmailWithDetail.containsKey((leadMatch.Secondary_Email__c).toLowerCase())) {
                ConstituentDetail matchedDetail = partialFirstNameAndEmailWithDetail.get((leadMatch.Secondary_Email__c).toLowerCase());
                if (matchedDetail.constituentId != null) {
                    return false;
                }
                matchedDetail.constituentId = (Id) leadMatch.Id;
                matchedDetail.processingNotes +=
                    String.format('Found existing Lead ID: {0} based on secondary email match: {1} and first {2} character(s) of first name match: {3} \n',
                    new String[] {leadMatch.Id, leadMatch.Secondary_Email__c, String.valueOf(partialFirstName.length() - 1), partialFirstName});
                detailsToReturn.add(matchedDetail);
                return true;
            }
        }
        return false;
    }

    private Boolean matchLeadByPartialFirstNameAndRecruitingEmail(SObject constituentMatch) {
        Lead leadMatch = (Lead) constituentMatch;
        String partialFirstName;
        if (leadMatch.FirstName != null && leadMatch.Recruiting_Email__c != null) {
            partialFirstName = getPartialFirstName(String.valueOf(leadMatch.FirstName), String.valueOf(leadMatch.Recruiting_Email__c));
            if (partialFirstNameAndEmailWithDetail.containsKey((leadMatch.Recruiting_Email__c).toLowerCase())) {
                ConstituentDetail matchedDetail = partialFirstNameAndEmailWithDetail.get((leadMatch.Recruiting_Email__c).toLowerCase());
                if (matchedDetail.constituentId != null) {
                    return false;
                }
                matchedDetail.constituentId = (Id) leadMatch.Id;
                matchedDetail.processingNotes +=
                    String.format('Found existing Lead ID: {0} based on recruiting email match: {1} and first {2} character(s) of first name match: {3} \n',
                    new String[] {leadMatch.Id, leadMatch.Recruiting_Email__c, String.valueOf(partialFirstName.length() - 1), partialFirstName});
                detailsToReturn.add(matchedDetail);
                return true;
            }
        }
        return false;
    }
}