@isTest
private class EmailAlertArticleScheduleTest {
    private static List<User> lstUser;
    private static List<Group> lstGroup;
    private static List<GroupMember> lstGroupMember;

    /*
    Creating Test Data necessary for executing the test class.
    */
    private static void testSetup() {
        Profile p =[SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testuser1 = new User(Alias = 'standt', Email='testUser1@test.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='testKBUser1@testorg.com');

        User testuser2 = new User(Alias = 'standt', Email='testUser2@test.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='testKBUser2@testorg.com');

        lstUser=new List<User>();
        lstUser.add(testuser1);
        lstUser.add(testuser2);
        insert lstUser;

        lstGroup=new List<Group>();
        Group testGroup = new Group(Name='Test Group', Type = 'Queue');
        lstGroup.add(testGroup);
        insert lstGroup;

        lstGroupMember= new List<GroupMember>();
        GroupMember grpMember1 = new GroupMember(UserOrGroupId=lstUser[0].Id, GroupId=lstGroup[0].Id);
        GroupMember grpMember2 = new GroupMember(UserOrGroupId=lstUser[1].Id, GroupId=lstGroup[0].Id);

        lstGroupMember.add(grpMember1);
        lstGroupMember.add(grpMember2);
        insert lstGroupMember;
    }

    /*
    Test Method to test Execute Method of EmailAlertArticle Class.
    Coverage code only. Tests will not send emails.
    */
    private static testMethod void testExecuteMethod() {
        testSetup();
        EmailAlertArticleSchedule testCont = new EmailAlertArticleSchedule();
        SchedulableContext sc;

        Test.startTest();
        testCont.execute(null);
        Test.stopTest();
    }

    /* Test Method to check whether an Email is sent via Apex for a stagnant Article */
    private static testMethod void testStagnantcreateEmails() {
            Integer noOfEmailsSent;

            FAQ__kav testFAQ1 = new FAQ__kav(Language='en_US', Title = 'Test Article', UrlName='TestArticle');
            testFAQ1.Functional_Group__c='Academic Technologies';
            insert testFAQ1;

            EmailAlertArticleSchedule testCont = new EmailAlertArticleSchedule();
            testCont.dataSetup();

            List<FAQ__kav> stagnantQuery = [
                SELECT 
                    Id, 
                    ArticleNumber, 
                    Title, 
                    PublishStatus, 
                    Functional_Group__c, 
                    ValidationStatus, 
                    Article_Expiration_Date__c, 
                    LastModifiedDate
                FROM FAQ__kav
                WHERE PublishStatus = 'Draft'
                    AND Language = 'en_US'
                    AND (ValidationStatus = 'Draft'
                        OR ValidationStatus = 'Format Review'
                        OR ValidationStatus = 'Content Review')
            ];

            Test.startTest();
            List<Messaging.SingleEmailMessage> emailsToSend = testCont.createEmails(stagnantQuery);
            Test.stopTest();

            System.assertEquals(1, emailsToSend.size());
    }

    /* Test Method to check whether an Email is sent via Apex for Expired Article */
    private static testMethod void testExpiredcreateEmails() {
            Integer noOfEmailsSent;
            List<Id> lstArtId = new List<Id>();

            FAQ__kav testFAQ2 = new FAQ__kav(Language='en_US', Title = 'Test Article 2', UrlName='TestArticle2');
            testFAQ2.Functional_Group__c='Academic Technologies';
            testFAQ2.Article_Expiration_Date__c=System.Today().addDays(-1);
            insert testFAQ2;

            FAQ__kav testFAQ3 = new FAQ__kav(Language='en_US', Title = 'Test Article 3', UrlName='TestArticle3');
            testFAQ3.Functional_Group__c='Academic Technologies';
            testFAQ3.Article_Expiration_Date__c=System.Today().addDays(30);
            insert testFAQ3;

            lstArtId.add(testFAQ2.Id);
            lstArtId.add(testFAQ3.Id);

            List<FAQ__kav> lstArtFAQ = [SELECT Id, KnowledgeArticleId FROM FAQ__kav WHERE Id IN: lstArtId];
            KbManagement.PublishingService.publishArticle(lstArtFAQ[0].KnowledgeArticleId, true);
            KbManagement.PublishingService.publishArticle(lstArtFAQ[1].KnowledgeArticleId, true);
            EmailAlertArticleSchedule testCont = new EmailAlertArticleSchedule();
            testCont.dataSetup();

            List<FAQ__kav> expiredQuery = [
                SELECT 
                    Id,
                    ArticleNumber,
                    Title,
                    PublishStatus, 
                    Functional_Group__c, 
                    ValidationStatus, 
                    Article_Expiration_Date__c, 
                    LastModifiedDate
                FROM FAQ__kav
                WHERE PublishStatus = 'Online'
                    AND Language = 'en_US'
                    AND (Article_Expiration_Date__c < :System.Today()
                        OR Article_Expiration_Date__c = :System.Today().addDays(30))
            ];

            Test.startTest();
            List<Messaging.SingleEmailMessage> emailsToSend = testCont.createEmails(expiredQuery);
            Test.stopTest();

            System.assertEquals(2, emailsToSend.size());
    }
}