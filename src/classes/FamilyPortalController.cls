public with sharing class FamilyPortalController {
    private String existingGuardianUserAsuriteId {get; set;}
    private String existingGuardianUserEmplid {get; set;}
    public Family_Portal_Guardian__c familyPortalGuardian {get; set;}
    public Family_Portal_Guardian_Interest__c familyPortalGuardianInterest {get; set;}
    public List<FamilyPortalStudentWrapper> studentWrapperList {get; set;}
    private Integer studentRowCount = 0;
    public String businessUnit;
    public String hashId;
    public User loggedInUser {get; set;}
    public Boolean isLoggedInUser {get; set;}
    public Boolean isExistingGuardian {get; set;}
    public FamilyPortalProgressBar progressBarController {get; set;}
    public Boolean guardianSelectedCountryIsUnitedStatesOrCanada {
        get {
            if (familyPortalGuardian.Country__c == 'United States' || familyPortalGuardian.Country__c == 'Canada') {
                return true;
            } else {
                return false;
            }
        }
        set;
    }
    public Boolean guardianSelectedCountryIsUS {
        get {
            if (familyPortalGuardian.Country__c == 'United States') {
                return true;
            } else {
                return false;
            }
        }
        set;
    }
    public Boolean guardianSelectedCountryIsCanada {
        get {
            if (familyPortalGuardian.Country__c == 'Canada') {
                return true;
            } else {
                return false;
            }
        }
        set;
    }
    public List<String> guardianSelectedInterests {
        get {
            List<String> selectedInterests = new List<String>();
            List<SelectOption> interestOptions = getGuardianInterestChoices();
            for (SelectOption interest : interestOptions) {
                if (familyPortalGuardianInterest.Interest_Choices__c != null && familyPortalGuardianInterest.Interest_Choices__c.contains(interest.getValue())) {
                    selectedInterests.add(interest.getValue());
                }
            }
            return selectedInterests;
        }
        set {
            String selectedCheckboxes = '';
            for (String interest : value) {
                if (selectedCheckboxes == '') {
                    selectedCheckboxes += interest;
                } else {
                    selectedCheckboxes += ';' + interest;
                }
            }
            familyPortalGuardianInterest.Interest_Choices__c = selectedCheckboxes;
        }
    }

    public FamilyPortalController() {
        familyPortalGuardian =  new Family_Portal_Guardian__c();
        familyPortalGuardian.Country__c = 'United States';
        familyPortalGuardian.State__c = 'Arizona';
        familyPortalGuardianInterest = new Family_Portal_Guardian_Interest__c();
        studentWrapperList =  new List<FamilyPortalStudentWrapper>();
        progressBarController = new FamilyPortalProgressBar();

        String hashIdFromUrl = ApexPages.currentPage().getParameters().get('id');
        Cookie hashIdCookie = ApexPages.currentPage().getCookies().get('id');
        if (hashIdFromUrl != null) {
            hashId = hashIdFromUrl;
            hashIdCookie = new Cookie('id', hashIdFromUrl, null, -1, true);
            ApexPages.currentPage().setCookies(new Cookie[] {hashIdCookie});
        } else if (hashIdCookie != null) {
            hashId = hashIdCookie.getValue();
        }
        
        String businessUnitFromUrl = ApexPages.currentPage().getParameters().get('bu');
        Cookie businessUnitCookie = ApexPages.currentPage().getCookies().get('bu');
        if (businessUnitFromUrl != null) {
            businessUnit = businessUnitFromUrl;
            businessUnitCookie = new Cookie('bu', businessUnitFromUrl, null, -1, true);
            ApexPages.currentPage().setCookies(new Cookie[] {businessUnitCookie});
        } else if (businessUnitCookie != null) {
            businessUnit = businessUnitCookie.getValue();
        }
    }

    public void addStudentRow() {
        studentRowCount++;
        studentWrapperList.add(new FamilyPortalStudentWrapper(new Family_Portal_Student__c(), studentRowCount));
    }
    
    public void removeStudentRow() {
        Integer indexToRemove = Integer.valueOf(Apexpages.currentpage().getParameters().get('index'));
        for (Integer i = 0; i < studentWrapperList.size(); i++) {
            if (studentWrapperList[i].studentIndex == indexToRemove ) {
                studentWrapperList.remove(i);     
            }
        }
    }

    public List<SelectOption> getGuardianCountryOptions() {
        List<SelectOption> countryCodeOptions = new List<SelectOption>();
        Schema.DescribeFieldResult countryCodeFieldResult = User.CountryCode.getDescribe();
        List<Schema.PicklistEntry> countryCodeValues = countryCodeFieldResult.getPicklistValues();
        for (Schema.PicklistEntry countryCode : countryCodeValues) {
            countryCodeOptions.add(new SelectOption(countryCode.getLabel(), countryCode.getLabel()));
        }
        return countryCodeOptions;
    }

    public List<SelectOption> getGuardianStateOptions() {
        List<SelectOption> stateCodeOptions = new List<SelectOption>();
        Schema.DescribeFieldResult stateCodeFieldResult = User.StateCode.getDescribe();
        List<Schema.PicklistEntry> stateCodeValues = stateCodeFieldResult.getPicklistValues();
        for (Schema.PicklistEntry stateCode : stateCodeValues) {
            stateCodeOptions.add(new SelectOption(stateCode.getLabel(), stateCode.getLabel()));
        }
        return stateCodeOptions;
    }

    public List<SelectOption> getGuardianInterestChoices() {
        List<SelectOption> optionsToReturn = new List<SelectOption>();
        Schema.DescribeFieldResult describeResult = Family_Portal_Guardian_Interest__c.Interest_Choices__c.getDescribe();
        List<Schema.PicklistEntry> picklistOptions = describeResult.getPicklistValues();
        for (Schema.PicklistEntry picklistItem : picklistOptions) {
            if (picklistItem.isActive()) {
                optionsToReturn.add(new SelectOption(picklistItem.getValue(), picklistItem.getLabel()));
            }
        }
        return optionsToReturn;
    }

    public List<SelectOption> getCountryCodePicklistValues() {
        List<SelectOption> optionsToReturn = new List<SelectOption>();
        Schema.DescribeFieldResult describeResult = Family_Portal_Guardian_Interest__c.Interest_Choices__c.getDescribe();
        List<Schema.PicklistEntry> picklistOptions = describeResult.getPicklistValues();
        for (Schema.PicklistEntry picklistItem : picklistOptions) {
            if (picklistItem.isActive()) {
                optionsToReturn.add(new SelectOption(picklistItem.getValue(), picklistItem.getLabel()));
            }
        }
        return optionsToReturn;
    }

    public PageReference generateLoginLink() {
        String loginLinkString = System.Label.Family_Portal_SSO_Login_URL;
        if (businessUnit != null) {
            loginLinkString += '?bu=' + businessUnit;
        }
        if (hashId != null) {
            loginLinkString += '?id=' + hashId;
        }
        PageReference loginLink = new PageReference(loginLinkString);
        loginLink.setRedirect(true);
        return loginLink;
    }

    public PageReference familyPortalStep1() {
        return Page.FamilyPortalStep1;
    }

    public PageReference familyPortalStep1OnLoad() {
        progressBarController.progressCounter = 0;
        progressBarController.getProgressBarPercentage();

        if (UserInfo.getUserId() != null && !UserInfo.getLastName().containsIgnoreCase('guest')) {
            loggedInUser = new User();
            loggedInUser.FirstName = UserInfo.getFirstName();
            loggedInUser.LastName = UserInfo.getLastName();
            loggedInUser.Id = UserInfo.getUserId();
            isLoggedInUser = true;

            try {
                setExistingUserData();
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        } else {
            isLoggedInUser = false;
        }

        if (hashId != null) {
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

    private void setExistingUserData() {
        User existingGuardianUser;
        if (UserInfo.getUserId() != null && familyPortalGuardian.First_Name__c == null && familyPortalGuardian.Last_Name__c == null && familyPortalGuardian.Email__c == null) {
            existingGuardianUser = getExistingUserData();

            if (existingGuardianUser != null) {
                isExistingGuardian = true;
            } else {
                isExistingGuardian = false;
            }

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

    private User getExistingUserData() {
        User existingGuardianUser = [SELECT FirstName, LastName, Email, PostalCode, EmployeeNumber, ASURITE_for_External_ID__c, Id FROM User WHERE Id =: UserInfo.getUserId()];
        return existingGuardianUser;
    }

    private void prefillFormPagesFromHashId() {
        List<Family_Portal_Guardian__c> guardian = [
            SELECT Id, First_Name__c, Last_Name__c, Email__c, Zip_Code__c
            FROM Family_Portal_Guardian__c
            WHERE Hash_ID__c =: hashId
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
            SELECT Id, Enrollment_Status__c, Enrollment_Status_Year__c, Type__c, Academic_College__c, Military_Affiliation__c
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
                        Enrollment_Status_Year__c = student.Enrollment_Status_Year__c,
                        Type__c = student.Type__c,
                        Academic_College__c = student.Academic_College__c,
                        Military_Affiliation__c = student.Military_Affiliation__c
                    ), 
                    studentRowCount
                )
            );
        }
    }

    public PageReference familyPortalStep2() {
        return Page.FamilyPortalStep2;
    }

    public void familyPortalStep2OnLoad() {
        progressBarController.progressCounter = 25;
        progressBarController.getProgressBarPercentage();
    }

    public PageReference familyPortalStep3() {
        return Page.FamilyPortalStep3;
    }

    public void familyPortalStep3OnLoad() {
        progressBarController.progressCounter = 50;
        progressBarController.getProgressBarPercentage();

        try {
            setExistingUserData();
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    public PageReference familyPortalStep4() {
        return Page.FamilyPortalStep4;
    }

    public void familyPortalStep4OnLoad() {
        progressBarController.progressCounter = 75;
        progressBarController.getProgressBarPercentage();
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

    public void familyPortalStep5OnLoad() {
        progressBarController.progressCounter = 100;
        progressBarController.getProgressBarPercentage();
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
        if (businessUnit != null) {
            familyPortalGuardian.Business_Unit_Source__c = businessUnit;
        }

        if (hashId == null) {
            Blob hashData = Blob.valueOf(familyPortalGuardian.First_Name__c + familyPortalGuardian.Email__c);
            Blob hashIdBlob = Crypto.generateDigest('SHA256', hashData);
            String hashIdString = EncodingUtil.base64Encode(hashIdBlob);

            Double randomDouble = Math.random();
            randomDouble = Math.rint(randomDouble * 10);
            Integer randomIntegerFromDouble = (Integer) randomDouble;
            String randomIntegerString = '' + randomIntegerFromDouble;
            String hashIdAlphanumeric = hashIdString.replaceAll('[^a-zA-Z0-9]', randomIntegerString);
            familyPortalGuardian.Hash_ID__c = hashIdAlphanumeric;
        } else {
            familyPortalGuardian.Hash_ID__c = hashId;
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
        mail.setReplyTo('asufamily@asu.edu');
        mail.setSenderDisplayName('ASU Families');
        mail.setSubject('New ASU Families submission: ' + familyPortalGuardian.First_Name__c + ' ' + familyPortalGuardian.Last_Name__c + ' (' + familyPortalGuardian.Id + ')');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setPlainTextBody('Your ASU Families submission for ' + familyPortalGuardian.First_Name__c + ' ' + familyPortalGuardian.Last_Name__c + ' (' + familyPortalGuardian.Id + ')' + ' has been created.' +
            'If you have an ASURITE ID, you can view your submission record directly at https://asu--dev.my.salesforce.com/' + familyPortalGuardian.Id + '. ' + 
            'You can also change your chosen interests or student preferences at any time by revisiting ASU Families at https://asu--dev.my.salesforce.com/apex/FamilyPortalStep1?id=' + familyPortalGuardian.Hash_ID__c + '.');
        mail.setHtmlBody('Your ASU Families submission for <strong>' + familyPortalGuardian.First_Name__c + ' ' + familyPortalGuardian.Last_Name__c + ' (' + familyPortalGuardian.Id + ')</strong> has been created.<p>' +
            'If you have an ASURITE ID, you view your <a href=https://asu--dev.my.salesforce.com/' + familyPortalGuardian.Id + '>submission record</a>. ' + 
            'You can also change your chosen interests or student preferences at any time by revisiting the <strong><a href="https://asu--dev.my.salesforce.com/apex/FamilyPortalStep1?id=' + familyPortalGuardian.Hash_ID__c + '">ASU Families</a></strong>.');

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }

    public class FamilyPortalStudentWrapper {
        public Family_Portal_Student__c familyPortalStudentObj {get; set;}
        public Integer studentIndex {get; set;}
        public List<String> guardianSelectedStudentTypes {
            get {
                List<String> selectedTypes = new List<String>();
                List<SelectOption> typeOptions = getStudentTypeChoices();
                for (SelectOption type : typeOptions) {
                    if (familyPortalStudentObj.Type__c != null && familyPortalStudentObj.Type__c.contains(type.getValue())) {
                        selectedTypes.add(type.getValue());
                    }
                }
                return selectedTypes;
            }
            set {
                String selectedCheckboxes = '';
                for (String studentType : value) {
                    if (selectedCheckboxes == '') {
                        selectedCheckboxes += studentType;
                    } else {
                        selectedCheckboxes += ';' + studentType;
                    }
                }
                familyPortalStudentObj.Type__c = selectedCheckboxes;
            }
        }
        
        public FamilyPortalStudentWrapper(Family_Portal_Student__c familyPortalStudentObj, Integer studentIndex) {
            this.familyPortalStudentObj = familyPortalStudentObj;
            this.studentIndex = studentIndex;
        }

        public List<SelectOption> getStudentTypeChoices() {
            List<SelectOption> optionsToReturn = new List<SelectOption>();
            Schema.DescribeFieldResult describeResult = Family_Portal_Student__c.Type__c.getDescribe();
            List<Schema.PicklistEntry> picklistOptions = describeResult.getPicklistValues();
            for (Schema.PicklistEntry picklistItem : picklistOptions) {
                if (picklistItem.isActive()) {
                    optionsToReturn.add(new SelectOption(picklistItem.getValue(), picklistItem.getLabel()));
                }
            }
            return optionsToReturn;
        }
    }

    public class FamilyPortalProgressBar {
        public Decimal currentPercentage {get; set;}
        public Integer progressCounter {get; set;}
        public String statusMessage {get; set;}
        
        public FamilyPortalProgressBar() {
            currentPercentage = 0;
            statusMessage = '';
            progressCounter = 0;
        }

        public void getProgressBarPercentage() {
            if (progressCounter != 0) {
                if (Decimal.valueOf(progressCounter) > 100) {
                    currentPercentage = 100;
                } else {
                    currentPercentage = (Decimal.valueOf(progressCounter))/100 * 100;
                }
            } else {
                currentPercentage = 0;
            }
        }
    }
}