@isTest
public class Test_EmailAlertArticlesController {
    
    public static FAQ__kav testFAQ;
    public static List<User> lstUser;
    public static List<Group> lstGroup;
    public static List<GroupMember> lstGroupMember;

    
    /*
    Creating Test Data necessary for executing the test class.
    */
    static void testSetup() {
        
        Profile p =[SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testuser1 = new User(Alias = 'standt', Email='testUser1@test.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testUser1@testorg.com');
         
        User testuser2 = new User(Alias = 'standt', Email='testUser2@test.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testUser2@testorg.com');
            
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
    */
    @isTest static void testExecuteMethod() {
            
            testSetup();
            
            EmailAlertArticlesController testCont = new EmailAlertArticlesController();
            SchedulableContext sc;
            
            Test.startTest();
            testCont.execute(sc);
            Test.stopTest();
    }
    
    /* Test Method to check whether the userIds returned for a queue is correct*/
    @isTest static void testUsersinQueue() {
            testSetup();
            
            Test.startTest();
            EmailAlertArticlesController testCont = new EmailAlertArticlesController();
            Set<Id> setRetUserId = testCont.returnUserIds('Test Group', lstGroup);
            
            Test.stopTest();
            List<Id> lstRetUserId = new List<Id>();
            lstRetUserId.addAll(setRetUserId);
            
            List<Id> checkUserIds = new List<Id>();
            checkUserIds.add(lstUser[0].Id);
            checkUserIds.add(lstUser[1].Id);
            System.assertEquals(lstRetUserId, checkUserIds);
                
    }
    
    /*Test Method to check whether an Email is sent via Apex for a stagnant Article */
    @isTest static void testSendEmail() {
            Integer noOfEmailsSent;
            
            testFAQ= new FAQ__kav(Language='en_US', Title = 'Test Article', UrlName='TestArticle');
            testFAQ.Functional_Group__c='Academic Technologies';
            insert testFAQ;
            
            EmailAlertArticlesController testCont = new EmailAlertArticlesController();
            
            String query = 'SELECT Id,ArticleNumber, Title, PublishStatus,Functional_Group__c, ValidationStatus,Article_Expiration_Date__c ' + 
            'FROM FAQ__kav ' + 
            'WHERE PublishStatus=\'Draft\' ' +
                'AND Language=\'en_US\' ' + 
                'AND (ValidationStatus=\'Draft\' OR ValidationStatus=\'Format Review\' OR ValidationStatus=\'Content Review\')';
            Test.startTest();
            testCont.SendEmail(query, true, false);
            noOfEmailsSent = Limits.getEmailInvocations();
            Test.stopTest();
            
            System.assertEquals(noOfEmailsSent, 1);
            
    }
    
    
    
}