public class ObjectScrambleService {
    private ObjectTypes objectType;
    public enum ObjectTypes {
        CONTACT,
        CONTACT_NO_PHONE,
        EDPLUS_CASE,
        LEAD,
        CONVERTED_LEAD,
        USER,
        CAR,
        DELETED_SILVERPOP
    }

    public ObjectScrambleService(ObjectTypes objectType) {
        this.objectType = objectType;
    }

    public String getQueryFromObject() {
        String queryToReturn;
        switch on objectType {
            when CONTACT {
                queryToReturn =
                    'SELECT Email, Corporate_Relations_Email__c, EPO_Email__c, ASU_Email__c, ' +
                    'Last_Case_Email_Used__c, Lead_Email__c, Lead_Secondary_Email__c, me3hs_User_ID__c, ' +
                    'Parent_Email__c, Personal_Email__c, Birthdate FROM Contact WHERE ' +
                    generateNotLikeSandboxDomainStatement('Email');
            }
            when CONTACT_NO_PHONE {
                queryToReturn = 'SELECT Id, HomePhone, Phone FROM Contact WHERE HomePhone = null AND Phone != null';
            }
            when EDPLUS_CASE {
                queryToReturn = 'SELECT Id FROM Case WHERE LastModifiedDate >= 2020-03-01T00:00:00Z AND (CC_Functional_Group__c = \'a240W000001jHG6\' OR CC_Functional_Group__c = \'a240W000001jHH0\' OR CC_Functional_Group__c = \'a240W000001jHG9\'  OR CC_Functional_Group__c = \'a240W000001jHG8\' OR CC_Functional_Group__c = \'a240W000001jHGB\' OR  CC_Functional_Group__c = \'a240W000001jHHr\')';
            }
            when LEAD {
                queryToReturn =
                    'SELECT Id, Date_of_Birth__c, Email, Recruiting_Email__c, Secondary_Email__c FROM LEAD WHERE ' +
                    generateNotLikeSandboxDomainStatement('Email');
            }
            when CONVERTED_LEAD {
                queryToReturn = 'SELECT Id FROM LEAD WHERE IsConverted = true';
            }
            when DELETED_SILVERPOP {
                queryToReturn = 'SELECT Id FROM ' + System.Label.SilverPopName;
            }
            when CAR {
                queryToReturn =
                    'SELECT Id, Email_Address__c, Reply_To_Email_Address__c FROM Case_Assignment_Rule__c WHERE ' +
                    generateNotLikeSandboxDomainStatement('Email_Address__c') +
                    ' AND Do_Not_Change_in_Sandbox_Refresh__c = FALSE';
            }
            when USER {
                Id sysAdminId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
                queryToReturn =
                    'SELECT Id FROM User WHERE IsActive = true AND Sandbox_DEV__c = false AND (NOT Username LIKE \'%@00dn000000091oqeay.com\') AND ProfileId <> \'' +
                    sysAdminId +
                    '\'';
            }
        }

        return queryToReturn;
    }

    public ObjectScramble getScrambleClassForObject(sObject objectToScramble) {
        ObjectScramble objectScrambler;
        switch on objectType {
            when CONTACT {
                objectScrambler = new ContactScrambler((Contact) objectToScramble);
            }
            when CONTACT_NO_PHONE {
                objectScrambler = new ContactPhoneAdder((Contact) objectToScramble);
            }
            when EDPLUS_CASE {
                objectScrambler = new CaseScrambler((Case) objectToScramble);
            }
            when LEAD {
                objectScrambler = new LeadScrambler((Lead) objectToScramble);
            }
            when CONVERTED_LEAD {
                objectScrambler = new LeadDeleter((Lead) objectToScramble);
            }
            when DELETED_SILVERPOP {
                objectScrambler = new SilverpopDeleter(objectToScramble);
            }
            when CAR {
                objectScrambler = new CarScrambler((Case_Assignment_Rule__c) objectToScramble);
            }
            when USER {
                objectScrambler = new UserScrambler((User) objectToScramble);
            }
        }

        return objectScrambler;
    }

    public String getObjectHeader() {
        String header;
        switch on objectType {
            when CONTACT {
                header =
                    'Id,Birthdate,Email,Corporate_Relations_Email__c,EPO_Email__c,ASU_Email__c,Last_Case_Email_Used__c,Lead_Email__c,' +
                    'Lead_Secondary_Email__c,me3hs_User_ID__c,Parent_Email__c,Personal_Email__c,silverpop__Silverpop_RecipientID__c\n';
            }
            when CONTACT_NO_PHONE {
                header = 'Id,HomePhone\n';
            }
            when EDPLUS_CASE {
                header = 'Id,Ed_Plus_Org_Viewable__c\n';
            }
            when LEAD {
                header = 'Id,Date_of_Birth__c,Email,Recruiting_Email__c,Secondary_Email__c,silverpop__Silverpop_RecipientID__c\n';
            }
            when CAR {
                header = 'Id,Email_Address__c,Reply_To_Email_Address__c\n';
            }
            when CONVERTED_LEAD {
                header = 'Id\n';
            }
            when DELETED_SILVERPOP {
                header = 'Id\n';
            }
            when USER {
                header = 'Id,IsActive\n';
            }
        }

        return header;
    }

    @TestVisible
    private static String generateNotLikeSandboxDomainStatement(String fieldName) {
        String sandboxDomain = Scrambler.getSandboxDomain();
        return '(NOT ' + fieldName + ' LIKE \'%.' + sandboxDomain + '\')';
    }
}
