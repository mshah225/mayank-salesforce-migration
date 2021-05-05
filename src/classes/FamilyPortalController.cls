public without sharing class FamilyPortalController {
    public Family_Portal_Guardian__c familyPortalGuardian { get; set; }
    public Family_Portal_Guardian_Interest__c familyPortalGuardianInterest { get; set; }
    public List<FamilyPortalStudentWrapper> studentWrapperList { get; set; }
    private Integer studentRowCount = 0;
    public String businessUnit;
    public String hashId;
    public Boolean isAsuriteUser { get; set; }
    public Boolean isExistingGuardian { get; set; }
    public Map<Integer, Boolean> stepHasBeenViewedMap { get; set; }
    public FamilyPortalProgressBar progressBarController { get; set; }
    public Boolean guardianSelectedCountryIsUnitedStatesOrCanada {
        get {
            if (familyPortalGuardian.Country__c == 'United States' || familyPortalGuardian.Country__c == 'Canada') {
                return true;
            } else {
                if (familyPortalGuardian.State__c == null || familyPortalGuardian.State__c == 'Arizona') {
                    familyPortalGuardian.State__c = '';
                }
                return false;
            }
        }
        set;
    }
    public Boolean guardianSelectedCountryIsUS {
        get {
            if (familyPortalGuardian.Country__c == 'United States') {
                if (familyPortalGuardian.State__c == null) {
                    familyPortalGuardian.State__c = 'Arizona';
                }
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
                if (familyPortalGuardian.State__c == null) {
                    familyPortalGuardian.State__c = 'Alberta';
                }
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
                if (
                    familyPortalGuardianInterest.Interest_Choices__c != null &&
                    familyPortalGuardianInterest.Interest_Choices__c.contains(interest.getValue())
                ) {
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
        setDefaultSafetyChecks();
        setupDefaultGuardian();
        checkUrlAndCookies();
        checkForExistingAsuriteUser();
        checkForExistingGuardian();
    }

    private void setDefaultSafetyChecks() {
        isAsuriteUser = false;
        isExistingGuardian = false;
        stepHasBeenViewedMap = new Map<Integer, Boolean>();
        stepHasBeenViewedMap.put(1, false);
        stepHasBeenViewedMap.put(2, false);
        stepHasBeenViewedMap.put(3, false);
        stepHasBeenViewedMap.put(4, false);
    }

    private void setupDefaultGuardian() {
        progressBarController = new FamilyPortalProgressBar();
        familyPortalGuardian = new Family_Portal_Guardian__c();
        familyPortalGuardian.Country__c = 'United States';
        familyPortalGuardian.State__c = 'Arizona';
        familyPortalGuardianInterest = new Family_Portal_Guardian_Interest__c();
        studentWrapperList = new List<FamilyPortalStudentWrapper>();
    }

    private void checkUrlAndCookies() {
        String hashIdFromUrl = ApexPages.currentPage().getParameters().get('hid');
        Cookie hashIdCookie = ApexPages.currentPage().getCookies().get('hid');
        if (hashIdFromUrl != null) {
            hashId = hashIdFromUrl;
            hashIdCookie = new Cookie('hid', hashIdFromUrl, null, 31556952, true);
            ApexPages.currentPage().setCookies(new List<Cookie>{ hashIdCookie });
        } else if (hashIdCookie != null) {
            hashId = hashIdCookie.getValue();
        }

        String businessUnitFromUrl = ApexPages.currentPage().getParameters().get('bu');
        Cookie businessUnitCookie = ApexPages.currentPage().getCookies().get('bu');
        if (businessUnitFromUrl != null) {
            businessUnit = businessUnitFromUrl;
            businessUnitCookie = new Cookie('bu', businessUnitFromUrl, null, 31556952, true);
            ApexPages.currentPage().setCookies(new List<Cookie>{ businessUnitCookie });
        } else if (businessUnitCookie != null) {
            businessUnit = businessUnitCookie.getValue();
        }
    }

    private void checkForExistingAsuriteUser() {
        if (isAsuriteUser()) {
            try {
                setExistingAsuUserData();
            } catch (Exception e) {
                List<String> vars = new List<String>();
                vars.add(
                    ErrorLogger.convertSObjectToJSON('Could not set existing ASU user data', familyPortalGuardian)
                );
                ErrorLogger.log(e, vars, false);
            }
        }
    }

    private Boolean isAsuriteUser() {
        if (UserInfo.getUserId() != null && !UserInfo.getLastName().containsIgnoreCase('site guest user')) {
            isAsuriteUser = false;

            User guardianUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if (guardianUser.ContactId != null) {
                Contact guardianContact = [
                    SELECT
                        Id,
                        Preferred_First_Name__c,
                        FirstName,
                        Middle_Name__c,
                        LastName,
                        Email,
                        Phone,
                        MailingStreet,
                        MailingCity,
                        MailingState,
                        MailingPostalCode,
                        MailingCountry
                    FROM Contact
                    WHERE Id = :guardianUser.ContactId
                    LIMIT 1
                ];

                if (guardianContact.Preferred_First_Name__c != null) {
                    familyPortalGuardian.First_Name__c = guardianContact.Preferred_First_Name__c;
                } else {
                    familyPortalGuardian.First_Name__c = guardianContact.FirstName;
                }
                familyPortalGuardian.Middle_Name__c = guardianContact.Middle_Name__c;
                familyPortalGuardian.Last_Name__c = guardianContact.LastName;
                familyPortalGuardian.Email__c = guardianContact.Email;
                familyPortalGuardian.Phone__c = guardianContact.Phone;
                familyPortalGuardian.Street__c = guardianContact.MailingStreet;
                familyPortalGuardian.City__c = guardianContact.MailingCity;
                familyPortalGuardian.State__c = guardianContact.MailingState;
                familyPortalGuardian.Zip_Code__c = guardianContact.MailingPostalCode;
                familyPortalGuardian.Country__c = guardianContact.MailingCountry;
            } else {
                familyPortalGuardian.First_Name__c = UserInfo.getFirstName();
                familyPortalGuardian.Last_Name__c = UserInfo.getLastName();
                familyPortalGuardian.Email__c = UserInfo.getUserEmail();
            }
            familyPortalGuardian.Email__c = 'rnordman@asu.edu';
            familyPortalGuardian.Street__c = '1362 S Vineyard Apt 2109';
            familyPortalGuardian.State__c = 'Arizona';

            return false;
        } else if (familyPortalGuardian.ASURITE_ID__c != null) {
            return false;
        }

        return false;
    }

    private void setExistingAsuUserData() {
        if (UserInfo.getUserId() != null) {
            User existingAsuUser = [
                SELECT EmployeeNumber, ASURITE_for_External_ID__c, ContactId
                FROM User
                WHERE Id = :UserInfo.getUserId() AND Email = :UserInfo.getUserEmail()
            ];
            if (existingAsuUser.EmployeeNumber != null) {
                familyPortalGuardian.EMPLID__c = existingAsuUser.EmployeeNumber;
            }
            if (existingAsuUser.ASURITE_for_External_ID__c != null) {
                familyPortalGuardian.ASURITE_ID__c = existingAsuUser.ASURITE_for_External_ID__c;
            }
            if (existingAsuUser.ContactId != null) {
                familyPortalGuardian.Contact__c = existingAsuUser.ContactId;
            }
        }
    }

    private void checkForExistingGuardian() {
        if (isExistingGuardian()) {
            try {
                prepopulateExistingGuardianData();
            } catch (Exception e) {
                List<String> vars = new List<String>();
                vars.add(
                    ErrorLogger.convertSObjectToJSON(
                        'Could not prepopulate existing guardian data',
                        familyPortalGuardian
                    )
                );
                ErrorLogger.log(e, vars, false);
            }
        }
    }

    private Boolean isExistingGuardian() {
        Integer numberOfMatches = [SELECT COUNT() FROM Family_Portal_Guardian__c WHERE Hash_ID__c = :hashId];
        if (numberOfMatches > 0) {
            isExistingGuardian = true;
            return true;
        }

        if (isAsuriteUser) {
            User guardianUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if (guardianUser.ContactId != null) {
                Contact guardianContact = [SELECT Email FROM Contact WHERE Id = :guardianUser.ContactId LIMIT 1];

                numberOfMatches = [
                    SELECT COUNT()
                    FROM Family_Portal_Guardian__c
                    WHERE Email__c = :guardianContact.Email
                ];
                if (numberOfMatches > 0) {
                    Family_Portal_Guardian__c guardian = [
                        SELECT Hash_ID__c
                        FROM Family_Portal_Guardian__c
                        WHERE Email__c = :guardianContact.Email
                        LIMIT 1
                    ];
                    hashId = guardian.Hash_ID__c;
                    isExistingGuardian = true;
                    return true;
                }
            }
        }

        return false;
    }

    @TestVisible
    private void prepopulateExistingGuardianData() {
        Family_Portal_Guardian__c guardian = [
            SELECT
                Id,
                ASU_Alumni__c,
                ASURITE_ID__c,
                Business_Unit_Source__c,
                City__c,
                Contact__c,
                Country__c,
                Email__c,
                EMPLID__c,
                First_Name__c,
                Hash_ID__c,
                Last_Name__c,
                Middle_Name__c,
                Phone__c,
                State__c,
                Street__c,
                Zip_Code__c
            FROM Family_Portal_Guardian__c
            WHERE Hash_ID__c = :hashId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        if (guardian.Id != null) {
            if (guardian.ASURITE_ID__c != null || guardian.Email__c.contains('@asu.edu')) {
                isAsuriteUser = true;
            }
            setExistingGuardianData(guardian);
            setExistingGuardianInterests(guardian);
            setExistingStudents(guardian);
        }
    }

    @TestVisible
    private void setExistingGuardianData(Family_Portal_Guardian__c guardian) {
        if (guardian.ASU_Alumni__c != null) {
            familyPortalGuardian.ASU_Alumni__c = guardian.ASU_Alumni__c;
        }
        if (guardian.ASURITE_ID__c != null) {
            familyPortalGuardian.ASURITE_ID__c = guardian.ASURITE_ID__c;
        }
        if (guardian.Business_Unit_Source__c != null) {
            familyPortalGuardian.Business_Unit_Source__c = guardian.Business_Unit_Source__c;
        }
        if (guardian.City__c != null) {
            familyPortalGuardian.City__c = guardian.City__c;
        }
        if (guardian.Contact__c != null) {
            familyPortalGuardian.Contact__c = guardian.Contact__c;
        }
        if (guardian.Country__c != null) {
            familyPortalGuardian.Country__c = guardian.Country__c;
        }
        if (guardian.Email__c != null) {
            familyPortalGuardian.Email__c = guardian.Email__c;
        }
        if (guardian.EMPLID__c != null) {
            familyPortalGuardian.EMPLID__c = guardian.EMPLID__c;
        }
        if (guardian.First_Name__c != null) {
            familyPortalGuardian.First_Name__c = guardian.First_Name__c;
        }
        if (guardian.Hash_ID__c != null) {
            familyPortalGuardian.Hash_ID__c = guardian.Hash_ID__c;
        }
        if (guardian.Last_Name__c != null) {
            familyPortalGuardian.Last_Name__c = guardian.Last_Name__c;
        }
        if (guardian.Middle_Name__c != null) {
            familyPortalGuardian.Middle_Name__c = guardian.Middle_Name__c;
        }
        if (guardian.Phone__c != null) {
            familyPortalGuardian.Phone__c = guardian.Phone__c;
        }
        if (guardian.State__c != null) {
            familyPortalGuardian.State__c = guardian.State__c;
        }
        if (guardian.Street__c != null) {
            familyPortalGuardian.Street__c = guardian.Street__c;
        }
        if (guardian.Zip_Code__c != null) {
            familyPortalGuardian.Zip_Code__c = guardian.Zip_Code__c;
        }
    }

    @TestVisible
    private void setExistingGuardianInterests(Family_Portal_Guardian__c guardian) {
        List<Family_Portal_Guardian_Interest__c> guardianInterests = [
            SELECT Id, Chosen_Interest__c
            FROM Family_Portal_Guardian_Interest__c
            WHERE Family_Portal_Guardian__c = :guardian.Id AND Active_Interest__c = TRUE
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
    }

    @TestVisible
    private void setExistingStudents(Family_Portal_Guardian__c guardian) {
        List<Family_Portal_Student__c> students = [
            SELECT
                Id,
                Enrollment_Status__c,
                Enrollment_Status_Year__c,
                Type__c,
                Academic_College__c,
                Academic_Year__c,
                Military_Affiliation__c
            FROM Family_Portal_Student__c
            WHERE Family_Portal_Guardian__c = :guardian.Id AND Active_Relationship__c = TRUE
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
                        Academic_Year__c = student.Academic_Year__c,
                        Military_Affiliation__c = student.Military_Affiliation__c
                    ),
                    studentRowCount
                )
            );
        }
    }

    public PageReference sendUserToLoginScreen() {
        String url = '/FamilyPortal/CommunitiesLogin';
        url = composeRedirectUrl(url);

        PageReference pageRef = new PageReference(url);
        pageRef.setRedirect(true);

        return pageRef;
    }

    public String composeRedirectUrl(String url) {
        if (businessUnit != null && hashId != null) {
            url += '?bu=' + businessUnit + '&hid=' + hashId;
        } else if (businessUnit != null) {
            url += '?bu=' + businessUnit;
        } else if (hashId != null) {
            url += '?hid=' + hashId;
        }

        return url;
    }

    public void addStudentRow() {
        studentRowCount++;
        studentWrapperList.add(new FamilyPortalStudentWrapper(new Family_Portal_Student__c(), studentRowCount));
    }

    public void removeStudentRow() {
        Integer indexToRemove = Integer.valueOf(ApexPages.currentPage().getParameters().get('index'));
        for (Integer i = 0; i < studentWrapperList.size(); i++) {
            if (studentWrapperList[i].studentIndex == indexToRemove) {
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
            if (
                stateCode.getLabel() != 'Alberta' &&
                stateCode.getLabel() != 'British Columbia' &&
                stateCode.getLabel() != 'Manitoba' &&
                stateCode.getLabel() != 'New Brunswick' &&
                stateCode.getLabel() != 'Manitoba' &&
                stateCode.getLabel() != 'Newfoundland and Labrador' &&
                stateCode.getLabel() != 'Northwest Territories' &&
                stateCode.getLabel() != 'Nova Scotia' &&
                stateCode.getLabel() != 'Nunavut' &&
                stateCode.getLabel() != 'Ontario' &&
                stateCode.getLabel() != 'Prince Edward Island' &&
                stateCode.getLabel() != 'Quebec' &&
                stateCode.getLabel() != 'Saskatchewan' &&
                stateCode.getLabel() != 'Yukon Territories'
            ) {
                stateCodeOptions.add(new SelectOption(stateCode.getLabel(), stateCode.getLabel()));
            }
        }

        return stateCodeOptions;
    }

    public List<SelectOption> getGuardianProvinceOptions() {
        List<SelectOption> provinceCodeOptions = new List<SelectOption>();
        Schema.DescribeFieldResult provinceCodeFieldResult = User.StateCode.getDescribe();
        List<Schema.PicklistEntry> provinceCodeValues = provinceCodeFieldResult.getPicklistValues();
        for (Schema.PicklistEntry provinceCode : provinceCodeValues) {
            if (
                provinceCode.getLabel() == 'Alberta' ||
                provinceCode.getLabel() == 'British Columbia' ||
                provinceCode.getLabel() == 'Manitoba' ||
                provinceCode.getLabel() == 'New Brunswick' ||
                provinceCode.getLabel() == 'Manitoba' ||
                provinceCode.getLabel() == 'Newfoundland and Labrador' ||
                provinceCode.getLabel() == 'Northwest Territories' ||
                provinceCode.getLabel() == 'Nova Scotia' ||
                provinceCode.getLabel() == 'Nunavut' ||
                provinceCode.getLabel() == 'Ontario' ||
                provinceCode.getLabel() == 'Prince Edward Island' ||
                provinceCode.getLabel() == 'Quebec' ||
                provinceCode.getLabel() == 'Saskatchewan' ||
                provinceCode.getLabel() == 'Yukon Territories'
            ) {
                provinceCodeOptions.add(new SelectOption(provinceCode.getLabel(), provinceCode.getLabel()));
            }
        }

        return provinceCodeOptions;
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

    public void familyPortalStep1OnLoad() {
        stepHasBeenViewedMap.put(1, true);
        progressBarController.progressCounter = 0;
        progressBarController.getProgressBarPercentage();
    }

    public PageReference familyPortalStep1() {
        return Page.FamilyPortalStep1;
    }

    public void familyPortalStep2OnLoad() {
        if (stepHasBeenViewedMap.get(1)) {
            stepHasBeenViewedMap.put(2, true);
            progressBarController.progressCounter = 25;
            progressBarController.getProgressBarPercentage();
        }
    }

    public PageReference familyPortalStep2() {
        return Page.FamilyPortalStep2;
    }

    public void familyPortalStep3OnLoad() {
        if (stepHasBeenViewedMap.get(1) && stepHasBeenViewedMap.get(2)) {
            stepHasBeenViewedMap.put(3, true);
            progressBarController.progressCounter = 50;
            progressBarController.getProgressBarPercentage();
        }
    }

    public PageReference familyPortalStep3() {
        return Page.FamilyPortalStep3;
    }

    public void familyPortalStep4OnLoad() {
        if (stepHasBeenViewedMap.get(1) && stepHasBeenViewedMap.get(2) && stepHasBeenViewedMap.get(3)) {
            stepHasBeenViewedMap.put(4, true);
            progressBarController.progressCounter = 75;
            progressBarController.getProgressBarPercentage();
        }
    }

    public PageReference familyPortalStep4() {
        return Page.FamilyPortalStep4;
    }

    public void familyPortalStep5OnLoad() {
        if (
            stepHasBeenViewedMap.get(1) &&
            stepHasBeenViewedMap.get(2) &&
            stepHasBeenViewedMap.get(3) &&
            stepHasBeenViewedMap.get(4)
        ) {
            progressBarController.progressCounter = 100;
            progressBarController.getProgressBarPercentage();
        }
    }

    public PageReference familyPortalStep5() {
        try {
            beautifyPhoneNumber();
            matchGuardianToExistingContact();
            insertGuardian();
            insertGuardianInterests();
            insertStudents();
        } catch (Exception e) {
            List<String> vars = new List<String>();
            vars.add(
                ErrorLogger.convertSObjectToJSON(
                    'Something went wrong when submitting a guardian',
                    familyPortalGuardian
                )
            );
            ErrorLogger.log(e, vars, false);
        }

        return Page.FamilyPortalStep5;
    }

    private void beautifyPhoneNumber() {
        if (familyPortalGuardian.Phone__c != null) {
            familyPortalGuardian.Phone__c = familyPortalGuardian.Phone__c.replaceAll('\\D', '');
        }
    }

    private void matchGuardianToExistingContact() {
        if (!isAsuriteUser) {
            Map<String, String> detailFieldsMap = new Map<String, String>();
            detailFieldsMap.put('firstName', familyPortalGuardian.First_Name__c);
            detailFieldsMap.put('middleName', familyPortalGuardian.Middle_Name__c);
            detailFieldsMap.put('lastName', familyPortalGuardian.Last_Name__c);
            detailFieldsMap.put('email', familyPortalGuardian.Email__c);
            detailFieldsMap.put('phone', familyPortalGuardian.Phone__c);
            detailFieldsMap.put('mailingStreet', familyPortalGuardian.Street__c);
            ConstituentDetail guardianDetail = new ConstituentDetail(detailFieldsMap);

            ConstituentMatcher contactMatcher = new ConstituentMatcher(guardianDetail, 'Contact', 'familyportal');
            contactMatcher.searchConstituents();
            List<ConstituentDetail> matchedDetailsWithContacts = contactMatcher.getListOfConstituentsWithMatches();
            for (ConstituentDetail matchedDetailWithContact : matchedDetailsWithContacts) {
                familyPortalGuardian.Contact__c = matchedDetailWithContact.constituentId;
                break;
            }

            if (familyPortalGuardian.Contact__c == null) {
                Contact newGuardianContact = new Contact();
                newGuardianContact.FirstName = familyPortalGuardian.First_Name__c;
                newGuardianContact.Middle_Name__c = familyPortalGuardian.Middle_Name__c;
                newGuardianContact.LastName = familyPortalGuardian.Last_Name__c;
                newGuardianContact.Email = familyPortalGuardian.Email__c;
                newGuardianContact.Phone = familyPortalGuardian.Phone__c;
                newGuardianContact.MailingStreet = familyPortalGuardian.Street__c;
                newGuardianContact.MailingCity = familyPortalGuardian.City__c;
                newGuardianContact.MailingPostalCode = familyPortalGuardian.Zip_Code__c;
                newGuardianContact.MailingCountry = familyPortalGuardian.Country__c;

                if (familyPortalGuardian.Country__c == 'United States' || familyPortalGuardian.Country__c == 'Canada') {
                    newGuardianContact.MailingState = familyPortalGuardian.State__c;
                }
                if (familyPortalGuardian.ASU_Alumni__c == 'Yes') {
                    newGuardianContact.Affiliation_Alumni__c = 'Current';
                }

                try {
                    insert newGuardianContact;
                } catch (DmlException e) {
                    List<String> vars = new List<String>();
                    vars.add(ErrorLogger.convertSObjectToJSON('newGuardianContact', newGuardianContact));
                    ErrorLogger.log(e, vars, false);
                } finally {
                    if (newGuardianContact.Id != null) {
                        familyPortalGuardian.Contact__c = newGuardianContact.Id;
                    }
                }
            }
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
        setGuardianReturnUrl();

        try {
            insert familyPortalGuardian;
        } catch (DmlException e) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertSObjectToJSON('familyPortalGuardian', familyPortalGuardian));
            ErrorLogger.log(e, vars, false);
        }
    }

    private void setGuardianReturnUrl() {
        if (familyPortalGuardian.Hash_ID__c != null) {
            String currentHeaderUrl = ApexPages.currentPage().getHeaders().get('Host');
            familyPortalGuardian.Return_URL__c =
                'https://' +
                currentHeaderUrl +
                '/FamilyPortal?hid=' +
                familyPortalGuardian.Hash_ID__c;
        }
    }

    private void insertGuardianInterests() {
        if (familyPortalGuardianInterest.Interest_Choices__c != null) {
            List<String> allInterestList = buildGuardianInterestList();

            List<Family_Portal_Guardian_Interest__c> familyPortalGuardianInterestList = new List<Family_Portal_Guardian_Interest__c>();
            List<String> guardianChosenInterestsFromPicklist = familyPortalGuardianInterest.Interest_Choices__c.split(
                ';'
            );

            Map<String, Boolean> guardianChosenInterestsFromPicklistMap = new Map<String, Boolean>();
            for (String chosenInterest : guardianChosenInterestsFromPicklist) {
                guardianChosenInterestsFromPicklistMap.put(chosenInterest, true);
            }

            for (String interest : allInterestList) {
                if (!guardianChosenInterestsFromPicklistMap.containsKey(interest)) {
                    guardianChosenInterestsFromPicklistMap.put(interest, false);
                }
            }

            for (String guardianChosenInterest : guardianChosenInterestsFromPicklistMap.keySet()) {
                if (guardianChosenInterest != null && guardianChosenInterest != '') {
                    Family_Portal_Guardian_Interest__c guardianInterest = new Family_Portal_Guardian_Interest__c();
                    guardianInterest.Chosen_Interest__c = guardianChosenInterest;
                    guardianInterest.Active_Interest__c = guardianChosenInterestsFromPicklistMap.get(
                        guardianChosenInterest
                    );
                    guardianInterest.Family_Portal_Guardian__c = familyPortalGuardian.Id;
                    guardianInterest.Guardian_Contact__c = familyPortalGuardian.Contact__c;
                    familyPortalGuardianInterestList.add(guardianInterest);
                }
            }

            try {
                insert familyPortalGuardianInterestList;
            } catch (DmlException e) {
                List<String> vars = new List<String>();
                vars.add(
                    ErrorLogger.convertListToJSON('familyPortalGuardianInterestList', familyPortalGuardianInterestList)
                );
                ErrorLogger.log(e, vars, false);
            }
        }
    }

    public List<String> buildGuardianInterestList() {
        List<String> optionsToReturn = new List<String>();
        Schema.DescribeFieldResult describeResult = Family_Portal_Guardian_Interest__c.Interest_Choices__c.getDescribe();
        List<Schema.PicklistEntry> picklistOptions = describeResult.getPicklistValues();
        for (Schema.PicklistEntry picklistItem : picklistOptions) {
            if (picklistItem.isActive()) {
                optionsToReturn.add(picklistItem.getLabel());
            }
        }

        return optionsToReturn;
    }

    private void insertStudents() {
        List<Family_Portal_Student__c> familyPortalStudentList = new List<Family_Portal_Student__c>();
        for (FamilyPortalStudentWrapper studentWrapper : studentWrapperList) {
            Family_Portal_Student__c reportedStudent = studentWrapper.familyPortalStudentObj;
            familyPortalStudentList.add(reportedStudent);
        }

        for (Family_Portal_Student__c reportedStudent : familyPortalStudentList) {
            reportedStudent.Family_Portal_Guardian__c = familyPortalGuardian.Id;
            reportedStudent.Guardian_Contact__c = familyPortalGuardian.Contact__c;
        }

        if (familyPortalStudentList.size() == 0) {
            List<Family_Portal_Guardian__c> matchingGuardians = [
                SELECT Id
                FROM Family_Portal_Guardian__c
                WHERE Hash_ID__c = :hashId
            ];

            Set<Id> guardianIdsForDeactivation = new Set<Id>();
            for (Family_Portal_Guardian__c matchingGuardian : matchingGuardians) {
                guardianIdsForDeactivation.add(matchingGuardian.Id);
            }

            List<Family_Portal_Student__c> studentsToDeactivate = [
                SELECT Id, Active_Relationship__c
                FROM Family_Portal_Student__c
                WHERE Family_Portal_Guardian__c IN :guardianIdsForDeactivation
            ];

            for (Family_Portal_Student__c studentToDeactivate : studentsToDeactivate) {
                studentToDeactivate.Active_Relationship__c = false;
            }

            familyPortalStudentList.addAll(studentsToDeactivate);
        }

        try {
            upsert familyPortalStudentList;
        } catch (DmlException e) {
            List<String> vars = new List<String>();
            vars.add(ErrorLogger.convertListToJSON('familyPortalStudentList', familyPortalStudentList));
            ErrorLogger.log(e, vars, false);
        }
    }

    public class FamilyPortalStudentWrapper {
        public Family_Portal_Student__c familyPortalStudentObj { get; set; }
        public Integer studentIndex { get; set; }
        public List<String> guardianSelectedStudentTypes {
            get {
                List<String> selectedTypes = new List<String>();
                List<SelectOption> typeOptions = getStudentTypeChoices();
                for (SelectOption type : typeOptions) {
                    if (
                        familyPortalStudentObj.Type__c != null &&
                        familyPortalStudentObj.Type__c.contains(type.getValue())
                    ) {
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
        public Decimal currentPercentage { get; set; }
        public Integer progressCounter { get; set; }
        public String statusMessage { get; set; }

        public FamilyPortalProgressBar() {
            currentPercentage = 0;
            statusMessage = '';
            progressCounter = 0;
        }

        public void getProgressBarPercentage() {
            if (progressCounter != 0) {
                currentPercentage = (Decimal.valueOf(progressCounter)) / 100 * 100;
            } else {
                currentPercentage = 0;
            }
        }
    }
}
