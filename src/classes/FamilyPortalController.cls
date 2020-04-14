public with sharing class FamilyPortalController {
    private String existingGuardianUserAsuriteId {get; set;}
    private String existingGuardianUserEmplid {get; set;}
    public Family_Portal_Guardian__c familyPortalGuardian {get; set;}
    public Family_Portal_Guardian_Interest__c familyPortalGuardianInterest {get; set;}
    public List<FamilyPortalStudentWrapper> studentWrapperList {get; set;}
    private Integer studentRowCount = 0;
    public String businessUnitFromUrl;
    public String hashIdFromUrl;

    public FamilyPortalController() {
        familyPortalGuardian =  new Family_Portal_Guardian__c();
        familyPortalGuardianInterest = new Family_Portal_Guardian_Interest__c();
        studentWrapperList =  new List<FamilyPortalStudentWrapper>();
        businessUnitFromUrl = ApexPages.currentPage().getParameters().get('bu');
        hashIdFromUrl = ApexPages.currentPage().getParameters().get('id');
        addStudentRow();
    }

    public class FamilyPortalStudentWrapper {
        public Family_Portal_Student__c familyPortalStudentObj {get;set;}
        public Integer studentIndex {get;set;}
        
        public FamilyPortalStudentWrapper(Family_Portal_Student__c familyPortalStudentObj, Integer studentIndex) {
            this.familyPortalStudentObj = familyPortalStudentObj;
            this.studentIndex = studentIndex;
        }
    }

    public void addStudentRow() {
        studentRowCount++;
        studentWrapperList.add(new FamilyPortalStudentWrapper(new Family_Portal_Student__c(), studentRowCount));
    }
    
    public void removeStudentRow() {
        Integer indexToRemove = Integer.valueOf(Apexpages.currentpage().getParameters().get('index'));
        for(Integer i = 0; i < studentWrapperList.size(); i++) {
            if(studentWrapperList[i].studentIndex == indexToRemove ) {
                studentWrapperList.remove(i);     
            }
        }
    }

    public PageReference generateLoginLink() {
        String loginLinkString = 'https://weblogin.asu.edu/cas/login?service=https%3A%2F%2Fshibboleth-dev.asu.edu%2Fidp%2FAuthn%2FExtCas%3Fconversation%3De1s1&entityId=https%3A%2F%2Fasu--dev.my.salesforce.com/apex/FamilyPortal?bu=' + businessUnitFromUrl;
        if (hashIdFromUrl != null) {
            loginLinkString += '?id=' + hashIdFromUrl;
        }
        PageReference loginLink = new PageReference(loginLinkString);
        loginLink.setRedirect(true);
        return loginLink;
    }

    public PageReference familyPortal() {
        return Page.FamilyPortal;
    }

    public PageReference familyPortalOnLoad() {
        if (hashIdFromUrl != null) {
            try {
                prefillFormPagesFromHashId();
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
            return Page.FamilyPortalStep3;
        } else {
            return null;
        }
    }

    private void prefillFormPagesFromHashId() {
        List<Family_Portal_Guardian__c> guardian = [
            SELECT Id, First_Name__c, Last_Name__c, Email__c, Zip_Code__c
            FROM Family_Portal_Guardian__c
            WHERE Hash_ID__c =: hashIdFromUrl
        ];

        if (guardian[0].First_Name__c != null) {
            familyPortalGuardian.First_Name__c = guardian[0].First_Name__c;
        }
        if (guardian[0].Last_Name__c != null) {
            familyPortalGuardian.Last_Name__c = guardian[0].Last_Name__c;
        }
        if (guardian[0].Email__c != null) {
            familyPortalGuardian.Email__c = guardian[0].Email__c;
        }
        if (guardian[0].Zip_Code__c != null) {
            familyPortalGuardian.Zip_Code__c = guardian[0].Zip_Code__c;   
        }
        
        List<Family_Portal_Guardian_Interest__c> guardianInterests = [
            SELECT Id, Chosen_Interest__c
            FROM Family_Portal_Guardian_Interest__c
            WHERE Family_Portal_Guardian__c =: guardian[0].Id
        ];

        String interestString = '';
        for (Family_Portal_Guardian_Interest__c interest : guardianInterests) {
            if (interestString == null) {
                interestString += (String) interest.Chosen_Interest__c;
            } else {
                interestString += ';' + (String) interest.Chosen_Interest__c;
            }
        }
        if (interestString != null) {
            familyPortalGuardianInterest.Interest_Choices__c = interestString;
        }

        List<Family_Portal_Student__c> students = [
            SELECT Id, Enrollment_Status__c, Enrollment_Status_Year__c
            FROM Family_Portal_Student__c
            WHERE Family_Portal_Guardian__c =: guardian[0].Id
        ];

        for (Family_Portal_Student__c student : students) {
            if (student != students[0]) { 
                studentRowCount++; 
            }
            studentWrapperList.add(
                new FamilyPortalStudentWrapper(
                    new Family_Portal_Student__c(
                        Enrollment_Status__c = student.Enrollment_Status__c,
                        Enrollment_Status_Year__c = student.Enrollment_Status_Year__c
                    ), 
                    studentRowCount
                )
            );
        }
    }

    public PageReference familyPortalStep2() {
        return Page.FamilyPortalStep2;
    }

    public PageReference familyPortalStep3() {
        return Page.FamilyPortalStep3;
    }

    public void familyPortalStep3OnLoad() {
        try {
            setExistingUserData();
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    private void setExistingUserData() {
        User existingGuardianUser;
        if (UserInfo.getUserId() != null && familyPortalGuardian.First_Name__c == null && familyPortalGuardian.Last_Name__c == null && familyPortalGuardian.Email__c == null) {
            existingGuardianUser = getGuardianDataFromExistingUser();
            if (existingGuardianUser.FirstName != null) {
                familyPortalGuardian.First_Name__c = existingGuardianUser.FirstName;
            }
            if (existingGuardianUser.LastName != null) {
                familyPortalGuardian.Last_Name__c = existingGuardianUser.LastName;
            }
            if (existingGuardianUser.Email != null) {
                familyPortalGuardian.Email__c = existingGuardianUser.Email;
            }
            if (existingGuardianUser.PostalCode != null) {
                familyPortalGuardian.Zip_Code__c = existingGuardianUser.PostalCode;
            }
            if (existingGuardianUser.EmployeeNumber != null) {
                existingGuardianUserEmplid = existingGuardianUser.EmployeeNumber;
            }
            if (existingGuardianUser.ASURITE_for_External_ID__c != null) {
                existingGuardianUserAsuriteId = existingGuardianUser.ASURITE_for_External_ID__c;
            }
        }
    }

    private User getGuardianDataFromExistingUser() {
        User existingGuardianUser = [SELECT FirstName, LastName, Email, PostalCode, EmployeeNumber, ASURITE_for_External_ID__c, Id FROM User WHERE Id =: UserInfo.getUserId()];
        return existingGuardianUser;
    }

    public PageReference familyPortalStep4a() {
        return Page.FamilyPortalStep4a;
    }

    public PageReference familyPortalStep4b() {
        return Page.FamilyPortalStep4b;
    }

    public PageReference familyPortalStep5() {
        try {
            matchGuardianToExistingContact();
            insertGuardian();
            insertGuardianInterests();
            insertStudents();
            sendConfirmationEmail();
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        return Page.FamilyPortalStep5;
    }

    private void matchGuardianToExistingContact() {
        Map<String, String> detailFieldsMap = new Map<String, String>();
        detailFieldsMap.put('emplid', existingGuardianUserEmplid);
        detailFieldsMap.put('asuriteId', existingGuardianUserAsuriteId);
        detailFieldsMap.put('firstName', familyPortalGuardian.First_Name__c);
        detailFieldsMap.put('lastName', familyPortalGuardian.Last_Name__c);
        detailFieldsMap.put('email', familyPortalGuardian.Email__c);
        ConstituentDetail guardianDetail = new ConstituentDetail(detailFieldsMap);

        ConstituentMatcher contactMatcher = new ConstituentMatcher(guardianDetail, 'Contact');
        contactMatcher.searchConstituents();
        List<ConstituentDetail> matchedDetailsWithContacts = contactMatcher.getListOfConstituentsWithMatches();
        for (ConstituentDetail matchedDetailWithContact : matchedDetailsWithContacts) {
            familyPortalGuardian.Contact__c = matchedDetailWithContact.constituentId;
            break;
        }

        if (familyPortalGuardian.Contact__c == null) {
            Contact newGuardianContact = new Contact();
            newGuardianContact.FirstName = familyPortalGuardian.First_Name__c;
            newGuardianContact.LastName = familyPortalGuardian.Last_Name__c;
            newGuardianContact.Email = familyPortalGuardian.Email__c;
            
            insert newGuardianContact;
            familyPortalGuardian.Contact__c = newGuardianContact.Id;
        }
    }

    private void insertGuardian() {
        if (businessUnitFromUrl != null) {
            familyPortalGuardian.Business_Unit_Source__c = businessUnitFromUrl;
        }

        if (hashIdFromUrl == null) {
            Blob hashData = Blob.valueOf(familyPortalGuardian.First_Name__c + familyPortalGuardian.Email__c);
            Blob hashId = Crypto.generateDigest('SHA256', hashData);
            String hashIdString = EncodingUtil.base64Encode(hashId);

            Double randomDouble = Math.random();
            randomDouble = Math.rint(randomDouble * 10);
            Integer randomIntegerFromDouble = (Integer) randomDouble;
            String randomIntegerString = '' + randomIntegerFromDouble;
            String hashIdAlphanumeric = hashIdString.replaceAll('[^a-zA-Z0-9]', randomIntegerString);
            familyPortalGuardian.Hash_ID__c = hashIdAlphanumeric;
        } else {
            familyPortalGuardian.Hash_ID__c = hashIdFromUrl;
        }
        insert familyPortalGuardian;
    }

    private void insertGuardianInterests() {
        if (familyPortalGuardianInterest.Interest_Choices__c != null) {
            List<Family_Portal_Guardian_Interest__c> familyPortalGuardianInterestList = new List<Family_Portal_Guardian_Interest__c>();
            List<String> guardianChosenInterestsFromPicklist = familyPortalGuardianInterest.Interest_Choices__c.split(';');

            for (String guardianChosenInterest : guardianChosenInterestsFromPicklist) {
                Family_Portal_Guardian_Interest__c guardianInterest = new Family_Portal_Guardian_Interest__c();
                guardianInterest.Chosen_Interest__c = guardianChosenInterest;
                guardianInterest.Family_Portal_Guardian__c = familyPortalGuardian.Id;
                familyPortalGuardianInterestList.add(guardianInterest);
            }
            insert familyPortalGuardianInterestList;
        }
    }

    private void insertStudents() {
        List<Family_Portal_Student__c> familyPortalStudentList = new List<Family_Portal_Student__c>();
        for (FamilyPortalStudentWrapper studentWrapper : studentWrapperList) {
            Family_Portal_Student__c reportedStudent = studentWrapper.familyPortalStudentObj;
            familyPortalStudentList.add(reportedStudent);
        }

        for (Family_Portal_Student__c reportedStudent : familyPortalStudentList) {
            reportedStudent.Family_Portal_Guardian__c = familyPortalGuardian.Id;
        }
        insert familyPortalStudentList;
    }

    private void sendConfirmationEmail() {
        Messaging.reserveSingleEmailCapacity(2);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(new List<String> {familyPortalGuardian.Email__c});
        mail.setReplyTo('salesforce.support@asu.edu');
        mail.setSenderDisplayName('ASU Salesforce Support');
        mail.setSubject('New family portal submission: ' + familyPortalGuardian.First_Name__c + ' ' + familyPortalGuardian.Last_Name__c + ' (' + familyPortalGuardian.Id + ')');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setPlainTextBody('Your family portal submission for ' + familyPortalGuardian.First_Name__c + ' ' + familyPortalGuardian.Last_Name__c + ' (' + familyPortalGuardian.Id + ')' + ' has been created.' +
            'If you have an ASURITE ID, you can view your submission record directly at https://asu--dev.my.salesforce.com/' + familyPortalGuardian.Id + '. ' + 
            'You can also change your chosen interests or student preferences at any time by revisiting the ASU Family Portal at https://asu--dev.my.salesforce.com/apex/FamilyPortal?id=' + familyPortalGuardian.Hash_ID__c + '.');
        mail.setHtmlBody('Your family portal submission for <strong>' + familyPortalGuardian.First_Name__c + ' ' + familyPortalGuardian.Last_Name__c + ' (' + familyPortalGuardian.Id + ')</strong> has been created.<p>' +
            'If you have an ASURITE ID, you view your <a href=https://asu--dev.my.salesforce.com/' + familyPortalGuardian.Id + '>submission record</a>. ' + 
            'You can also change your chosen interests or student preferences at any time by revisiting the <strong><a href="https://asu--dev.my.salesforce.com/apex/FamilyPortal?id=' + familyPortalGuardian.Hash_ID__c + '">ASU Family Portal</a></strong>.');

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
}