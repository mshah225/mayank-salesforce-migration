@isTest
private class PickListDescController_Tests {
    public static User user1;
    public static Contact contact1;
    public static Case case1;
    public static String contactRecordTypeId;
    public static RecordType caseRecordType;

    @isTest
    static void testDescribe1() {
        createTestData();
        Test.StartTest();

        PageReference pageRef = Page.PickListDesc;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('sobjectType', 'Case');
        ApexPages.currentPage().getParameters().put('recordTypeName', 'ASU_Coach_Outreach');
        ApexPages.currentPage().getParameters().put('pickListFieldName', 'Status');
        PickListDescController plc = new PickListDescController();

        Test.StopTest();
    }

    static private void createTestData() {
        contactRecordTypeId = '';
        List<RecordType> rectype1 = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :'External_Mastered' AND SobjectType = 'Contact'
        ];
        if (rectype1.size() > 0)
            contactRecordTypeId = rectype1[0].Id;

        caseRecordType = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :'ASU_Coach_Outreach' AND SobjectType = 'Case'
        ];

        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;

        //create user
        user1 = new User();
        user1.Lastname = 'coach';
        user1.Alias = 'coachu';
        user1.Email = 'thecoachuser@asu.edu.xyz';
        user1.Username = 'thecoachuser@asu.edu.xyz';
        user1.TimeZoneSidKey = 'America/Phoenix';
        user1.LocaleSidKey = 'en_US';
        user1.EmailEncodingKey = 'ISO-8859-1';
        user1.ProfileId = profileId;
        user1.LanguageLocaleKey = 'en_US';
        insert user1;

        //create contact
        contact1 = new Contact();
        contact1.RecordTypeId = contactRecordTypeId;
        contact1.Firstname = 'John';
        contact1.Lastname = 'Doe';
        contact1.Email = 'john.doe@asu.edu.xyz';
        contact1.ASURITE_ID__c = 'jdoe1';
        contact1.Hidden_Selected__c = true;
        contact1.EMPLID__c = '8888';
        insert contact1;

        //create case
        case1 = new Case();
        case1.RecordTypeId = caseRecordType.Id;
        case1.Type = 'Coach Initiated';
        case1.Subject = 'Drop/Withdrawn';
        case1.Status = 'New';
        case1.Priority = 'Normal';
        case1.Followup_Date__c = System.today();
        case1.OwnerId = user1.Id;
        case1.ASR_Date__c = System.today();
        case1.ASR_Comments__c = 'comments here';
        case1.ASR_Reasons__c = 'reasons here';
        case1.ASR_Actions__c = 'actions here';
        insert case1;
    }
}
