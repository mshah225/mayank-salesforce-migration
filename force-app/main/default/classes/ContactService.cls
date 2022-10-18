public class ContactService {
    /**
     * Returns all the fields on Case in a String
     * @return A string containing all the Case fields
     */
    public static String contactFieldsToString() {
        String contactFields = null;

        Map<String, SObjectField> contactFieldMap = ObjectService.getObjectFieldMap('Contact');

        contactFields = ObjectService.objectFieldsToString(contactFieldMap);

        return contactFields;
    }

    /**
     * Creates a test contact. Usually for unit testing.
     * @return A test contact object with all required fields.
     */
    public static Contact createTestContact() {
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.MailingPostalCode = '85282';
        testContact.Email = 'test.user@test.example.com';
        testContact.Birthdate = Date.newInstance(1989, 8, 12);
        testContact.Self_Service_PIN__c = 57483638;
        testContact.PIN_lockout__c = true;
        testContact.ASURite_ID__c = 'testuser';

        return testContact;
    }

    /**
     * Creates a number of test contacts. Usually for unit testing.
     * @param The number of contacts to create
     * @return A list of the contacts with all required fields;
     */
    public static List<Contact> createTestContacts(Integer numOfContacts) {
        List<Contact> contactList = new List<Contact>();

        for (Integer i = 0; i < numOfContacts; i++) {
            Contact con = createTestContact();
            con.FirstName = 'Test' + i;
            con.LastName = 'Contact' + i;
            con.Email = 'test.user' + i + '@test.example.com';
            con.ASURite_ID__c = ObjectService.getGuid().substring(0, 10);
            Integer tempEmplId = 1200000000 + i;
            con.EMPLID__c = String.valueOf(tempEmplId);
            contactList.add(con);
        }

        return contactList;
    }

    /**
     * The currently logged in contact somewhere. Usually the service center.
     * @return The logged in contact
     */
    public static Contact getLoggedInContact() {
        Id loggedInContactId = null;
        Contact loggedInContact = null;
        String EmployeeId;
        List<Contact> lstLoggedInContact;
        String contactFields = contactFieldsToString() + ', Country_of_Citizenship__r.Name ';

        String selectContactInfoByLoggedInUser;
        try {
            //Try community user
            loggedInContactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;

            //Try Employee User
            if (loggedInContactId == null) {
                EmployeeId = [SELECT EmployeeNumber FROM User WHERE Id = :userInfo.getUserId()].EmployeeNumber;
                if (EmployeeId != null && EmployeeId != '') {
                    lstLoggedInContact = [SELECT Id FROM Contact WHERE EmplId__c = :EmployeeId LIMIT 1];
                    if (lstLoggedInContact != null && lstLoggedInContact.size() > 0) {
                        loggedInContactId = lstLoggedInContact[0].Id;
                    }
                }
            }
            if (loggedInContactId != null) {
                selectContactInfoByLoggedInUser =
                    'SELECT ' +
                    contactFields +
                    ' ' +
                    'FROM Contact ' +
                    'WHERE Id = :loggedInContactId';

                loggedInContact = Database.query(selectContactInfoByLoggedInUser);
            }
        } catch (Exception e) {
            throw new ContactServiceException(
                '!!!ERROR!!!: An error occurred trying to get the logged in Contact\n' + e.getMessage()
            );
        }

        return loggedInContact;
    }

    public static Id getLoggedInContactId() {
        Id loggedInContactId = null;
        String employeeId = null;
        List<Contact> loggedInContactList;

        try {
            loggedInContactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
            if (loggedInContactId == null) {
                employeeId = [SELECT EmployeeNumber FROM User WHERE Id = :userInfo.getUserId()].EmployeeNumber;
                if (employeeId != null && employeeId != '') {
                    loggedInContactList = [SELECT Id FROM Contact WHERE EmplId__c = :employeeId LIMIT 1];
                    if (loggedInContactList != null && loggedInContactList.size() > 0) {
                        loggedInContactId = loggedInContactList[0].Id;
                    }
                }
            }
        } catch (Exception e) {
            throw new ContactServiceException(
                '!!!ERROR!!!: An error occurred trying to get the logged in Contact ID\n' + e.getMessage()
            );
        }

        return loggedInContactId;
    }

    /**
     * The contact to view as in the service center.
     * @param The asurite from the My ASU webservice you want to view as
     * @return The contact and all of its fields
     */
    public static Contact getContactToViewAs(String asurite) {
        //Id viewAsContactId = null;
        Contact viewAsContact = null;
        String contactFields = contactFieldsToString() + ', Country_of_Citizenship__r.Name ';
        System.debug(asurite);

        try {
            String selectContactInfoByAsurite =
                'SELECT ' +
                contactFields +
                ' ' +
                'FROM Contact ' +
                'WHERE ASURite_Id__c = :asurite';

            viewAsContact = Database.query(selectContactInfoByAsurite);
        } catch (Exception e) {
            throw new ContactServiceException(
                '!!!ERROR!!!: An error occurred trying to get the Contact by ASURITE\n' + e.getMessage()
            );
        }

        return viewAsContact;
    }

    /**
     * Random pin generator. Generates a random pin for new contact creation.
     * @param dob The Contact's date of birth field
     * @return An autogenerated PIN
     */
    public static Decimal generateRandomPin(Date dateOfBirth) {
        Double rand = Math.random();
        String randString = String.valueOf(rand);
        randString = randString.subString(3, 9);
        Decimal randPin = Math.round(Decimal.valueOf(randString));

        while (!isPinValid(randPin, dateOfBirth)) {
            randPin = randPin + 1000;
        }

        return randPin;
    }

    /**
     * IVR Pin validator. Take a pin and the contact's date of birth and determines whether the pin is valid based on the rules described in SFE-573.
     * @param pinNum The PIN to be validated
     * @param dob The Contact's date of birth field
     * @return A boolean indicating the validitiy of a pin
     */
    public static Boolean isPinValid(Decimal pinNum, Date dob) {
        Decimal randPin = (Decimal) pinNum;

        //Pin length check
        if (randPin.precision() < 6 || randPin.precision() > 10) {
            return false;
        }

        //Repeating digit check
        Pattern pinDupliPattern = Pattern.compile('.*([0-9])\\1{4,}.*');
        Matcher dupliMatches = pinDupliPattern.matcher(randPin.toPlainString());
        if (dupliMatches.matches()) {
            return false;
        }

        //Sequential digit check
        Pattern consecNumbers = Pattern.compile(
            '.*(01234|12345|23456|34567|45678|56789|67890|09876|98765|87654|76543|65432|54321|43210).*'
        );
        Matcher consecMatches = consecNumbers.Matcher(randPin.toPlainString());
        if (consecMatches.matches()) {
            return false;
        }

        //Contains birthdate check
        if (dob != null) {
            Integer dobYear = dob.year();
            Pattern dobPattern = Pattern.compile('.*(' + dobYear + ').*');
            Matcher dobYearMatches = dobPattern.matcher(randPin.toPlainString());

            if (dobYearMatches.matches()) {
                return false;
            }
        }

        return true;
    }

    /**
     * Get all of the information pertaining to the provided contact Id or emplId
     * If emplId is provided and contactId is not, query on emplId. Else always query
     * on the provided contactId.
     * @param contactId A Contact ID
     * @param emplId the contacts EMPLID__c
     * @return contactInfo The corresponding Contact
     */
    public static Contact getContactInformation(String contactId, String emplId) {
        List<Contact> contactInformationList = new List<Contact>();
        Contact contactInfo = null;
        String contactFields = contactFieldsToString() + ', Country_of_Citizenship__r.Name ';
        String contactInfoQuery;

        // Get the list of cases associated with our set of contacts
        try {
            contactInfoQuery = '' + 'SELECT ' + contactFields + ' ' + 'FROM Contact ';
            if (!String.isBlank(emplId)) {
                contactInfoQuery += 'WHERE EMPLID__c = :emplId';
            } else {
                contactInfoQuery += 'WHERE Id = :contactId';
            }

            contactInformationList = Database.query(contactInfoQuery);

            if (!contactInformationList.isEmpty()) {
                return contactInformationList[0];
            } else {
                return null;
            }
        } catch (Exception e) {
            throw new ContactServiceException(
                '!!!ERROR!!!: An error occurred trying to get the Contact\'s information\n' + e.getMessage()
            );
        }

        return contactInfo;
    }

    /**
     * Get all of the information pertaining to the provided contact Id; overloaded for
     * backward comptibility
     * @param contactId A Contact ID
     * @return contactInfo The corresponding Contact
     */
    public static Contact getContactInformation(Id contactId) {
        return getContactInformation(contactId, '');
    }

    public class ContactServiceException extends Exception {
    }
}