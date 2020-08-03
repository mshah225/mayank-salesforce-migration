public class ObjectScrambleService {
    private ObjectTypes objectType;
    public enum ObjectTypes {CONTACT, LEAD, CONVERTED_LEAD, USER, CAR}

    public ObjectScrambleService(ObjectTypes objectType) {
        this.objectType = objectType;
    }

    public String getQueryFromObject() {
        String queryToReturn;
        switch on objectType {
            when CONTACT {
                queryToReturn = 'SELECT Email, Corporate_Relations_Email__c, EPO_Email__c, ASU_Email__c, ' +
                    'Last_Case_Email_Used__c, Lead_Email__c, Lead_Secondary_Email__c, me3hs_User_ID__c, ' +
                    'Parent_Email__c, Personal_Email__c, Birthdate FROM Contact';
            }
            when LEAD {
                queryToReturn = 'SELECT Id, Date_of_Birth__c, Email, Recruiting_Email__c, Secondary_Email__c FROM LEAD';
            }
            when CONVERTED_LEAD {
                queryToReturn = 'SELECT Id FROM LEAD WHERE IsConverted = true';
            }
            when CAR {
                queryToReturn = 'SELECT Id, Email_Address__c, Reply_To_Email_Address__c FROM Case_Assignment_Rule__c';
            }
            when USER {
                Id sysAdminId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
                queryToReturn = 'SELECT Id FROM User WHERE IsActive = true AND Sandbox_DEV__c = false AND (NOT Username LIKE \'%@00dn000000091oqeay.com\') AND ProfileId <> \'' + sysAdminId + '\'';
            }
        }

        return queryToReturn;
    }

    public ObjectScramble getScrambleClassForObject(sObject objectToScramble) {
        ObjectScramble objectScrambler;
        switch on objectType {
            when CONTACT {
                objectScrambler = new ContactScrambler( (Contact) objectToScramble );
            }
            when LEAD {
                objectScrambler = new LeadScrambler( (Lead) objectToScramble);
            }
            when CONVERTED_LEAD {
                objectScrambler = new LeadDeleter( (Lead) objectToScramble);
            }
            when CAR {
                objectScrambler = new CarScrambler( (Case_Assignment_Rule__c) objectToScramble);
            }
            when USER {
                objectScrambler = new UserScrambler( (User) objectToScramble);
            }
        }

        return objectScrambler;
    }

    public String getObjectHeader() {
        String header;
        switch on objectType {
            when CONTACT {
                header =
                    'Id,Birthdate,Email,Corporate_Relations_Email__c,EPO_Email__c,ASU_Email__c,Last_Case_Email_Used__c,Lead_Email__c,'
                    +
                    'Lead_Secondary_Email__c,me3hs_User_ID__c,Parent_Email__c,Personal_Email__c,silverpop__Silverpop_RecipientID__c\n';
            }
            when LEAD {
                header = 
                    'Id,Date_of_Birth__c,Email,Recruiting_Email__c,Secondary_Email__c,silverpop__Silverpop_RecipientID__c\n';
            }
            when CAR {
                header = 
                    'Id,Email_Address__c,Reply_To_Email_Address__c\n';
            }
            when CONVERTED_LEAD {
                header = 
                    'Id\n';
            }
            when USER {
                header = 
                    'Id,IsActive\n';
            }
        }

        return header;
    }
}
