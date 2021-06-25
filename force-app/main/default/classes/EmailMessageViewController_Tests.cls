@isTest
private class EmailMessageViewController_Tests {
    public static EmailMessage emailMessage;
    public static User user1;
    public static Contact contact1;
    public static EmailMessageViewerController pag;
    public static Case case1;
    public static String contactRecordTypeId;

    @isTest
    static void testPageLoad() {
        createTestData();
        Test.StartTest();

        PageReference pageRef = Page.EmailMessageViewer;
        Test.setCurrentPage(pageRef);
        pag = new EmailMessageViewerController();
        pag.emailId = emailMessage.Id;
        ApexPages.CurrentPage().getParameters().put('id', emailMessage.Id);
        pag.init();

        Test.StopTest();
    }

    static private void createTestData() {
        //Profile RT
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;

        //Contact RT
        contactRecordTypeId = '';
        List<RecordType> rectype1 = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :'External_Mastered' AND SobjectType = 'Contact'
        ];
        if (rectype1.size() > 0)
            contactRecordTypeId = rectype1[0].Id;

        //Case RT
        String caseRecordTypeId = '';
        List<RecordType> rectype2 = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :'ASU_Advisor_Outreach' AND SobjectType = 'Case'
        ];
        if (rectype2.size() > 0)
            caseRecordTypeId = rectype2[0].Id;

        //create user
        user1 = new User();
        user1.Lastname = 'Doe';
        user1.Alias = 'johndoe';
        user1.Email = 'thejohndoeuser@asu.edu.xyz';
        user1.Username = 'thejohndoeuser@asu.edu.xyz';
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
        case1.RecordTypeId = caseRecordTypeId;
        case1.Type = 'Advisor Initiated';
        case1.Subject = 'Drop/Withdrawn';
        case1.Status = 'New';
        case1.Priority = 'Normal';
        case1.Followup_Date__c = System.today();
        case1.OwnerId = user1.Id;
        case1.ASR_Date__c = System.today();
        case1.ASR_Comments__c = 'comments here';
        case1.ASR_Reasons__c = 'reasons here';
        case1.ASR_Actions__c = 'actions here';
        case1.Recommended_Actions__c = 'address financial issues;adjust course balance';
        case1.Reasons_Not_Returning__c = 'Academic;Disqualified';
        insert case1;

        //create email message
        emailMessage = new EmailMessage();
        emailMessage.ParentId = case1.Id;
        emailMessage.Subject = 'Test Email';
        emailMessage.FromName = 'Some name';
        emailMessage.FromAddress = contact1.Email;
        emailMessage.ToAddress = user1.Email;
        emailMessage.Status = '3';
        emailMessage.Incoming = true;
        emailMessage.TextBody = 'Ad Hoc Email';
        emailMessage.HtmlBody = 'Ad Hoc Email';
        insert emailMessage;
    }
}
