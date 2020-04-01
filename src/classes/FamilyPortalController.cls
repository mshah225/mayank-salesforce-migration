public with sharing class FamilyPortalController {
    public String existingGuardianUserAsuriteId {get; set;}
    public String existingGuardianUserEmplid {get; set;}
    public Family_Portal_Guardian__c familyPortalGuardian {get; set;}
    public Family_Portal_Guardian_Interest__c familyPortalGuardianInterest {get; set;}
    public List<FamilyPortalStudentWrapper> studentWrapperList {get;set;}
    private Integer studentRowCount = 0;

    public FamilyPortalController() {
        familyPortalGuardian =  new Family_Portal_Guardian__c();
        familyPortalGuardianInterest = new Family_Portal_Guardian_Interest__c();
        studentWrapperList =  new List<FamilyPortalStudentWrapper>();
        addStudentRow();
    }

    public User getGuardianDataFromExistingUser() {
        User existingGuardianUser = [SELECT FirstName, LastName, Email, PostalCode, EmployeeNumber, ASURITE_for_External_ID__c, Id FROM User WHERE Id =: UserInfo.getUserId()];
        return existingGuardianUser;
    }

    public PageReference addStudentRow() {
        studentRowCount++;
        studentWrapperList.add(new FamilyPortalStudentWrapper(new Family_Portal_Student__c(), studentRowCount));
        return null;
    }
    
    public PageReference removeStudentRow() {
        Integer indexToRemove = Integer.valueOf(Apexpages.currentpage().getParameters().get('index'));
        for(Integer i = 0; i < studentWrapperList.size(); i++) {
            if(studentWrapperList[i].studentIndex == indexToRemove ) {
                studentWrapperList.remove(i);     
            }
        }
        return null;
    }

    public PageReference familyPortal() {
        return Page.FamilyPortal;
    }

    public PageReference familyPortalStep2() {
        return Page.FamilyPortalStep2;
    }

    public PageReference familyPortalStep3() {
        return Page.FamilyPortalStep3;
    }

    public PageReference familyPortalStep4a() {
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
        return Page.FamilyPortalStep4a;
    }

    public PageReference familyPortalStep4b() {
        return Page.FamilyPortalStep4b;
    }

    public PageReference familyPortalStep5() {
        List<Family_Portal_Student__c> familyPortalStudentList = new List<Family_Portal_Student__c>();

        if (!studentWrapperList.isEmpty()) {
            for (FamilyPortalStudentWrapper studentWrapper : studentWrapperList) {
                Family_Portal_Student__c reportedStudent = studentWrapper.familyPortalStudentObj;
                familyPortalStudentList.add(reportedStudent);
            }
        }

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
        insert familyPortalGuardian;

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

        for (Family_Portal_Student__c reportedStudent : familyPortalStudentList) {
            reportedStudent.Family_Portal_Guardian__c = familyPortalGuardian.Id;
        }
        insert familyPortalStudentList;

        return Page.FamilyPortalStep5;
    }

    public class FamilyPortalStudentWrapper {
        public Family_Portal_Student__c familyPortalStudentObj {get;set;}
        public Integer studentIndex {get;set;}
        
        public FamilyPortalStudentWrapper(Family_Portal_Student__c familyPortalStudentObj, Integer studentIndex) {
            this.familyPortalStudentObj = familyPortalStudentObj;
            this.studentIndex = studentIndex;
        }
    }
}