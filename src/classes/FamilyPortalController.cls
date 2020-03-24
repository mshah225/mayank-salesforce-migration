public with sharing class FamilyPortalController {
    public String guardianUserId {get; set;}
    public String guardianFirstName {get; set;}
    public String guardianLastName {get; set;}
    public String guardianEmailAddress {get; set;}
    public String guardianZipCode {get; set;}
    public Family_Portal_Guardian__c familyPortalGuardian {get; set;}
    public Family_Portal_Guardian_Interest__c familyPortalGuardianInterest {get; set;}
    public List<String> guardianChosenInterests {get; set;}
    public List<Family_Portal_Student__c> familyPortalStudentList {get; set;}
    public List<FamilyPortalStudentWrapper> studentWrapperList {get;set;}
    private Integer studentRowCount = 0;

    public FamilyPortalController() {
        familyPortalGuardian =  new Family_Portal_Guardian__c();
        familyPortalGuardianInterest = new Family_Portal_Guardian_Interest__c();
        guardianFirstName = familyPortalGuardian.Name;
        guardianEmailAddress = familyPortalGuardian.Email__c;
        guardianZipCode = familyPortalGuardian.Zip_Code__c;
        studentWrapperList =  new List<FamilyPortalStudentWrapper>();
        familyPortalStudentList = new List<Family_Portal_Student__c>();
        addStudentRow();
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

    public class FamilyPortalStudentWrapper {
        public Family_Portal_Student__c familyPortalStudentObj {get;set;}
        public Integer studentIndex {get;set;}
        
        public FamilyPortalStudentWrapper(Family_Portal_Student__c familyPortalStudentObj, Integer studentIndex) {
            this.familyPortalStudentObj = familyPortalStudentObj;
            this.studentIndex = studentIndex;
        }
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

    public PageReference familyPortalStep4() {
        return Page.FamilyPortalStep4;
    }

    public PageReference familyPortalStep5() {
        if (!studentWrapperList.isEmpty()) {
            for (FamilyPortalStudentWrapper studentWrapper : studentWrapperList) {
                Family_Portal_Student__c reportedStudent = studentWrapper.familyPortalStudentObj;
                familyPortalStudentList.add(reportedStudent);
            }
        }

        System.debug(familyPortalGuardian);

        if (familyPortalGuardianInterest != null) {
            System.debug(familyPortalGuardianInterest);
        }

        if (!familyPortalStudentList.isEmpty()) {
            System.debug(familyPortalStudentList);
        }

        Map<String, String> detailFieldsMap = new Map<String, String>();
        //detailFieldsMap.put('asuriteId', guardianUserId);
        detailFieldsMap.put('firstName', familyPortalGuardian.First_Name__c);
        detailFieldsMap.put('lastName', familyPortalGuardian.Last_Name__c);
        detailFieldsMap.put('email', familyPortalGuardian.Email__c);
        ConstituentDetail guardianDetail = new ConstituentDetail(detailFieldsMap);

        ConstituentMatcher contactMatcher = new ConstituentMatcher(guardianDetail, 'Contact');
        contactMatcher.searchConstituents();
        List<ConstituentDetail> matchedDetailsWithContacts = contactMatcher.getListOfConstituentsWithMatches();
        for (ConstituentDetail matchedDetailWithContact : matchedDetailsWithContacts) {
            familyPortalGuardian.Contact__c = matchedDetailWithContact.constituentId;
        }

        ConstituentMatcher leadMatcher = new ConstituentMatcher(guardianDetail, 'Lead');
        leadMatcher.searchConstituents();
        List<ConstituentDetail> matchedDetailsWithLeads = leadMatcher.getListOfConstituentsWithMatches();
        for (ConstituentDetail matchedDetailWithLead : matchedDetailsWithLeads) {
            familyPortalGuardian.Lead__c = matchedDetailWithLead.constituentId;
        }

        insert familyPortalGuardian;
        familyPortalGuardianInterest.Family_Portal_Guardian__c = familyPortalGuardian.Id;
        insert familyPortalGuardianInterest;

        for (Family_Portal_Student__c reportedStudent : familyPortalStudentList) {
            reportedStudent.Family_Portal_Guardian__c = familyPortalGuardian.Id;
        }
        insert familyPortalStudentList;

        return Page.FamilyPortalStep5;
    }
}