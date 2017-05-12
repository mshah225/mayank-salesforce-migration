@isTest
public class Test_DynamicFeedbackController {
    static pageReference dynamicFeedbackPage;
    static Feedback_Cars__c settings;
    static Case_Assignment_Rule__c car;
    static Contact testContact;
    
	/**
     * Community user is a user that is related to a contact and users community profile
     * Employee user is a user that does not have a contact but does have an employee number
     * Employees who are/were also students have a both a community user and an employee user
     * In this case, the community user has the emplId to match the employee user.
     * 
     * When deciding which contact to associate the case to, the dymanic feedback controller
     * Should handle community users, employee users, or contactIds passed through URL params
     */
    @testSetup
    static void testSetup() {
        Group testGroup;
        QueueSobject testQueue;
        List<User> UsersToCreate = new List<User>();
        Id pId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        
        // Contact needs EMPL so it is searchable from employee user
        testContact = testDataFactory.createContact('DynamicFeedback');
        testContact.EMPLID__c = '1234567890';
        
        test.startTest();
        insert testContact;
        test.stopTest();
        
        usersToCreate.add(testDataFactory.createUser('DynamicFeedbackEmployee', pId));
        
        usersToCreate[0].EmployeeNumber = testContact.EMPLID__c;
        
        usersToCreate.add(testDataFactory.createCommunityUser('DynamicFeedback', testContact.Id));        
        
        insert usersToCreate;
        
        // Config
        testGroup = new Group(
            Name = 'Test Group Name',
            Type = 'Queue'
        );
        
        insert testGroup;
        
        testQueue = new QueueSobject(
            QueueId = testGroup.Id,
            SobjectType = 'Case'
        );
        
        // To avoid MIXED DML ERROR, you need to insert this non-setup object
        // as the system user. In this case, just the admin running the test.
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testQueue;
        }
        
        car = new Case_Assignment_Rule__c(
        	Priority__c = 1,
            Customer_Notice_Email_From_Name__c = 'ASU Student-Centric Initiatives',
            Queue_ID__c = string.valueOf(testGroup.Id).left(15),
            Functional_Group__c = 'Student-Centric Initiatives',
            Category__c = 'Student Profile Feedback',
            Origin__c = 'Web'
        );
        
        insert car;
        
        settings = new Feedback_Cars__c();
        
        settings.Name = 'Student Profile';
        settings.CAR_Id__c = car.Id;
        
        insert settings;
    }
    
    /**
     * Set up the page for every test
     * For testing exceptions, simply override the URL param
     */
    static {
        try {
            string carName = 'Student Profile';
            dynamicFeedbackPage = Page.DynamicFeedback;
            Test.setCurrentPage(dynamicFeedbackPage);
            ApexPages.CurrentPage().getParameters().put('carName', carName);
            ApexPages.CurrentPage().getParameters().put('misc', 'Test');
            settings = Feedback_Cars__c.getAll().get(carName);
            car = [SELECT Id, Queue_Id__c, Origin__c, Functional_Group__c, Category__c,
                      Sub_Category__c, Email_Address__c, Case_Feed_Email_Template_Id__c, Campus__c
                      FROM Case_Assignment_Rule__c WHERE Id = :settings.CAR_Id__c];
            testContact = [SELECT Id FROM Contact WHERE LastName = 'DynamicFeedback'];
        } catch (Exception e) {}
    }
    
    /**
     * Tests dynamic feedback controllers ability to automatically detect the contact
     * when the running user is a community user.
     */
    public static testMethod void Test_CommunityUser() {
        User testUser = [SELECT Id, contactId FROM user WHERE LastName = 'DynamicFeedback' LIMIT 1];
        DynamicFeedbackController controller = new DynamicFeedbackController();
        List<Case> cases;
        
        controller.init();
        
        system.runAs(testUser) {
            test.startTest();
            controller.submit();
            test.stopTest();
        }
        
        cases = [SELECT Id, OwnerId, Origin__c, Functional_Group__c, Category__c,
                    Sub_Category__c, Case_Feed_Email__c, Case_Feed_Email_Template_Id__c, 
                    Campus__c, contactId
                    FROM Case];
        
        system.assertEquals(1, cases.size());
        system.assertEquals(cases[0].OwnerId, car.Queue_ID__c);
        system.assertEquals(cases[0].Origin__c, car.Origin__c);
        system.assertEquals(cases[0].Functional_Group__c, car.Functional_Group__c);
        system.assertEquals(cases[0].Category__c, car.Category__c);
        system.assertEquals(cases[0].Sub_Category__c, car.Sub_Category__c);
        system.assertEquals(cases[0].Case_Feed_Email__c, car.Email_Address__c);
        system.assertEquals(cases[0].Case_Feed_Email_Template_Id__c, car.Case_Feed_Email_Template_Id__c);
        system.assertEquals(cases[0].Campus__c, car.Campus__c);
        system.assertEquals(cases[0].ContactId, testContact.Id);
        
        // Cleanup for next test
        delete cases;
    }
    
    /**
     * Tests dynamic feedback controllers ability to automatically detect the contact
     * when the running user is a community user.
     */
    public static testMethod void Test_EmployeeUser() {
        User testUser = [SELECT Id, ContactId FROM user WHERE LastName = 'DynamicFeedbackEmployee' LIMIT 1];
        DynamicFeedbackController controller = new DynamicFeedbackController();
        List<Case> cases;
        
        controller.init();
        
        system.runAs(testUser) {
            test.startTest();
            controller.submit();
            test.stopTest();
        }
        
        cases = [SELECT Id, OwnerId, Origin__c, Functional_Group__c, Category__c,
                    Sub_Category__c, Case_Feed_Email__c, Case_Feed_Email_Template_Id__c,
                    Campus__c, contactId
                    FROM Case];
        
        system.assertEquals(1, cases.size());
        system.assertEquals(cases[0].OwnerId, car.Queue_ID__c);
        system.assertEquals(cases[0].Origin__c, car.Origin__c);
        system.assertEquals(cases[0].Functional_Group__c, car.Functional_Group__c);
        system.assertEquals(cases[0].Category__c, car.Category__c);
        system.assertEquals(cases[0].Sub_Category__c, car.Sub_Category__c);
        system.assertEquals(cases[0].Case_Feed_Email__c, car.Email_Address__c);
        system.assertEquals(cases[0].Case_Feed_Email_Template_Id__c, car.Case_Feed_Email_Template_Id__c);
        system.assertEquals(cases[0].Campus__c, car.Campus__c);
        system.assertEquals(cases[0].ContactId, testContact.Id);
        
        // Cleanup for next test
        delete cases;
    }
    
    /**
     * Tests dynamic feedback controllers ability to automatically detect the contact
     * when the running user is a community user.
     */
    public static testMethod void Test_ContactIdParameter() {
        ApexPages.CurrentPage().getParameters().put('contactId', testContact.Id);
        DynamicFeedbackController controller = new DynamicFeedbackController();
        List<Case> cases;
        
        controller.init();
        
        test.startTest();
        controller.submit();
        test.stopTest();
        
        cases = [SELECT Id, OwnerId, Origin__c, Functional_Group__c, Category__c,
                    Sub_Category__c, Case_Feed_Email__c, Case_Feed_Email_Template_Id__c,
                    Campus__c, contactId
                    FROM Case];
        
        system.assertEquals(1, cases.size());
        system.assertEquals(cases[0].OwnerId, car.Queue_ID__c);
        system.assertEquals(cases[0].Origin__c, car.Origin__c);
        system.assertEquals(cases[0].Functional_Group__c, car.Functional_Group__c);
        system.assertEquals(cases[0].Category__c, car.Category__c);
        system.assertEquals(cases[0].Sub_Category__c, car.Sub_Category__c);
        system.assertEquals(cases[0].Case_Feed_Email__c, car.Email_Address__c);
        system.assertEquals(cases[0].Case_Feed_Email_Template_Id__c, car.Case_Feed_Email_Template_Id__c);
        system.assertEquals(cases[0].Campus__c, car.Campus__c);
        system.assertEquals(cases[0].ContactId, testContact.Id);
        
        // Cleanup for next test
        delete cases;
    }
    
    /**
     * Tests dynamic feedback controllers ability to handle invalid URL parameters
     */
    public static testMethod void Test_NoDescription() {
        ApexPages.CurrentPage().getParameters().put('contactId', testContact.Id); //The contactId is provided for efficiency
        ApexPages.CurrentPage().getParameters().put('misc', ''); // Override misc with invalid value
        DynamicFeedbackController controller = new DynamicFeedbackController();
        List<Case> cases;
        
        controller.init();
        
        test.startTest();
        controller.submit();
        test.stopTest();
        
        cases = [SELECT Id, OwnerId, Origin__c, Functional_Group__c, Category__c,
                    Sub_Category__c, Case_Feed_Email__c, Case_Feed_Email_Template_Id__c,
                    Campus__c, contactId
                    FROM Case];
        
        system.assertEquals(0, cases.size());
        system.assertEquals(1, controller.alertHandler.alerts.size());
    }
    
    /**
     * Tests Dynamic Feedback Controllers ability to handle invalid URL parameters
     */
    public static testMethod void Test_BadCarName() {
        ApexPages.CurrentPage().getParameters().put('contactId', testContact.Id); //The contactId is provided for efficiency
        ApexPages.CurrentPage().getParameters().put('carName', 'nuts2dalbey'); // Override carname with invalid value
        DynamicFeedbackController controller = new DynamicFeedbackController();
        List<Case> cases;
        
        controller.init();
        
        test.startTest();
        controller.submit();
        test.stopTest();
        
        cases = [SELECT Id, OwnerId, Origin__c, Functional_Group__c, Category__c,
                    Sub_Category__c, Case_Feed_Email__c, Case_Feed_Email_Template_Id__c,
                    Campus__c, contactId, Description
                    FROM Case];
        
        system.assertEquals(2, cases.size());
        system.assertEquals('Error Logger', cases[0].Origin__c);
        
        delete cases;
    }
    
    public static testMethod void Test_NoContact() {
        DynamicFeedbackController controller = new DynamicFeedbackController();
        List<Case> cases;
        
        controller.init();
        
        test.startTest();
        controller.submit();
        test.stopTest();
        
        cases = [SELECT Id, OwnerId, Origin__c, Functional_Group__c, Category__c,
                    Sub_Category__c, Case_Feed_Email__c, Case_Feed_Email_Template_Id__c,
                    Campus__c, contactId
                    FROM Case];
        
        system.assertEquals(1, cases.size());
        system.assertEquals(cases[0].OwnerId, car.Queue_ID__c);
        system.assertEquals(cases[0].Origin__c, car.Origin__c);
        system.assertEquals(cases[0].Functional_Group__c, car.Functional_Group__c);
        system.assertEquals(cases[0].Category__c, car.Category__c);
        system.assertEquals(cases[0].Sub_Category__c, car.Sub_Category__c);
        system.assertEquals(cases[0].Case_Feed_Email__c, car.Email_Address__c);
        system.assertEquals(cases[0].Case_Feed_Email_Template_Id__c, car.Case_Feed_Email_Template_Id__c);
        system.assertEquals(cases[0].Campus__c, car.Campus__c);
        system.assertEquals(cases[0].ContactId, null);
        
        delete cases;
    }
    
    public static testMethod void Test_NoCar() {
        ApexPages.CurrentPage().getParameters().put('carName', '');
        DynamicFeedbackController controller = new DynamicFeedbackController();
        List<Case> cases;
        
        test.startTest();
        controller.init();
        test.stopTest();
        
        cases = [SELECT Id FROM Case];
        
        system.assertEquals(1, cases.size()); // Verify Exception was thrown
        system.assertEquals(1, controller.alertHandler.getFatal().size()); // Verify fatal error was added to alerts
        
        delete cases;
    }
    
    public static testMethod void Test_NoCarWithSubmit() {
        ApexPages.CurrentPage().getParameters().put('carName', '');
        DynamicFeedbackController controller = new DynamicFeedbackController();
        List<Case> cases;
        
        controller.init();
        
        test.startTest();
        controller.submit();
        test.stopTest();
        
        cases = [SELECT Id FROM Case];
        
        system.assertEquals(2, cases.size()); // Verify Exceptiona were thrown
        system.assertEquals(1, controller.alertHandler.getFatal().size()); // Verify only 1 fatal alert (cleared before attempting to submit)
        
        delete cases;
    }
}