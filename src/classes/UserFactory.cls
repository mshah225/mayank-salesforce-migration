@isTest
public class UserFactory {
    public class DefaultUser extends TestFactory {
        public DefaultUser() {
            super(new User(FirstName = 'Test',
                    LastName = 'User',
                    Username = 'test.user@test.example.com',
                    Email = 'test.user@test.example.com',
                    Alias = 'testuser',
                    CommunityNickname = 'testuserCom',
                    TimeZoneSidKey = 'America/Phoenix',
                    LocaleSidKey = 'en_US',
                    EmailEncodingKey = 'ISO-8859-1',
                    LanguageLocaleKey = 'en_US'
                )
            );
            this.addToFieldsToIncrement('LastName');
            this.addToFieldsToIncrement('Email');
            this.addToFieldsToIncrement('UserName');
        }
    }

    public static void makeMeAnAdvisorDepartmentManager(Integer numberOfPods, Integer numberOfCases, Integer numberOfStudents) {
        makeMeAnAdvisor(numberOfPods, numberOfCases, numberOfStudents, 'Department Manager');
    }

    public static void makeMeAnAdvisorCollegeManager(Integer numberOfPods, Integer numberOfCases, Integer numberOfStudents) {
        makeMeAnAdvisor(numberOfPods, numberOfCases, numberOfStudents, 'College Manager');
    }

    public static void makeMeAnAdvisorUser(Integer numberOfPods, Integer numberOfCases, Integer numberOfStudents) {
        makeMeAnAdvisor(numberOfPods, numberOfCases, numberOfStudents, 'User');
    }


    /*
     * Generates test data for the current user as if they were an advisor
     */
    public static void makeMeAnAdvisor(Integer numberOfPods, Integer numberOfCases, Integer numberOfStudents, String role) {
        Id advisorOutReachId = IDHelper.getRTID('Case', 'ASU_Advisor_Outreach');
        Success_Resource__c myAdvisorUserResource = createMyAdvisorUserResource(role);
        List<Success_Pod__c> myAdvisorPods = createAdvisorPods(numberOfPods);
        List<Success_Student__c> myAdvisorStudents = createAdvisorStudents(myAdvisorPods, numberOfStudents);
		List<Success_Resource_Pod_Association__c> myAdvisorSRPAS = createAdvisorSRPAS(myAdvisorUserResource, myAdvisorPods);

        // Create watchlist and proactive cases for the pods/students
        List<Id> podIds = new List<Id>();

        for (Success_Pod__c sp : myAdvisorPods) {
            podIds.add(sp.id);
        }

        Map<Id, Success_Pod__c> podMap = new Map<Id, Success_Pod__c>(
        	[
                SELECT Owner.Name FROM Success_Pod__c WHERE Id IN :podIds
            ]
        );

        // Create cases
        // Note: This doesn't ensure that pods only contain cases for students in their pod
        // Pods may end up with cases for students not in their pod
        // This can and has happened in the real world so we are accounting for it here
        List<Case> cases = new List<Case>();
        CaseClassificationFactory caseClassificationsMaker = new CaseClassificationFactory();
        caseClassificationsMaker.createAndInsertSetOfAdvisorOutreachCaseClassification();

        Id functionalGroup = [Select Id FROM case_classification__c WHERE name = 'ASU Advisor Outreach' LIMIT 1].Id;
        Id categoryOutreach = [Select Id FROM case_classification__c WHERE name = 'Outreach' LIMIT 1].Id;
        Id categoryWatchlist = [Select Id FROM case_classification__c WHERE name = 'Watchlist' LIMIT 1].Id;
        // Cases for pods
        for (Success_Pod__c sp : myAdvisorPods) {
            for (Integer x = 0; x < numberOfCases; x++) {
                CaseFactory.AdvisorOutreachCase proactiveCaseMaker = new CaseFactory.AdvisorOutreachCase(sp.OwnerId,
                    advisorOutReachId, 'Outreach Required', functionalGroup, categoryOutreach,
                    myAdvisorStudents[(Integer) math.rint(math.random() * (myAdvisorStudents.size() - 1))].student__c, null);
                cases.add((Case)proactiveCaseMaker.create(1)[0]);

                CaseFactory.AdvisorOutreachCase watchlistCaseMaker = new CaseFactory.AdvisorOutreachCase(sp.OwnerId,
                    advisorOutReachId, 'New', functionalGroup, categoryWatchlist,
                    myAdvisorStudents[(Integer) math.rint(math.random() * (myAdvisorStudents.size() - 1))].student__c, null);
                cases.add((Case)watchlistCaseMaker.create(1)[0]);
            }
        }
        // Cases for advisor
        for (Integer x = 0; x < numberOfCases; x++) {
            Success_Pod__c sp = myAdvisorPods[(Integer) math.rint(math.random() * (myAdvisorPods.size() - 1))];
            string mostRecentQueue = podMap.get(sp.Id).Owner.Name;

            CaseFactory.AdvisorOutreachCase advisorCaseMaker = new CaseFactory.AdvisorOutreachCase(UserInfo.getUserId(),
                advisorOutReachId, 'Outreach Required', functionalGroup, categoryWatchlist,
                myAdvisorStudents[(Integer) math.rint(math.random() * (myAdvisorStudents.size() - 1))].student__c, mostRecentQueue);
            cases.add((Case)advisorCaseMaker.create(1)[0]);
        }
        insert cases;
    }

    public static List<Success_Pod__c> createAdvisorPods(Integer numberOfPods) {
        Id advisorPodRTID = IDHelper.getRTID('Success_Pod__c', 'Advisor');
        List<Success_Pod__c> result = new List<Success_Pod__c>();
        List<Group> groups = new List<Group>();
        List<QueueSobject> queues = new List<QueueSobject>();

        // Create list of groups
        for (Integer x = 0; x < numberOfPods; x++) {
            groups.add(new Group(
                Name = 'TestGroupName' + x,
                Type = 'Queue'
            ));
        }

        insert groups;

        for (group g : groups) {
            queues.add(new QueueSobject(
            	QueueId = g.Id,
                SobjectType = 'Success_Pod__c'
            ));

            queues.add(new QueueSobject(
            	QueueId = g.Id,
                SobjectType = 'Case'
            ));
        }

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert queues;
        }
        Integer x = 0;

        for (group g : groups) {
            x++;
            result.add(new Success_Pod__c(
                OwnerId = g.Id,
            	RecordTypeId = advisorPodRTID,
                Primary_Email__c = g.name + '@test.asu.edu',
                Name = 'Test Pod ' + x,
                Committee__c = 'tp' + x
            ));
        }

        insert result;
        return result;
    }

    public static Success_Resource__c createMyAdvisorUserResource(String role) {
        Id advisorResourceRTId = IDHelper.getRTID('Success_Resource__c', 'Advisor');

        Success_Resource__c result = new Success_Resource__c(
        	IsActive__c = true,
            Role__c = role,
            Resource__c = UserInfo.getUserId(),
            RecordTypeId =advisorResourceRTId
        );
        insert result;
        return result;
    }

    public static List<Success_Resource_Pod_Association__c> createAdvisorSRPAS(Success_Resource__c advisorUserResource, List<Success_Pod__c> pods) {
        List<Success_Resource_Pod_Association__c> result = new List<Success_Resource_Pod_Association__c>();

        for (Success_Pod__c sp : pods) {
            result.add(new Success_Resource_Pod_Association__c(
            	Success_Resource__c = advisorUserResource.Id,
                Success_Pod__c = sp.Id
            ));
        }
        insert result;
        return result;
    }

    public static List<Success_Student__c> createAdvisorStudents(List<Success_Pod__c> pods, Integer numberOfStudents) {
        // Id advisorStudentRTID = IDHelper.getRTID('Success_Student__c', 'Advisor');
        List<Success_Student__c> result = new List<Success_Student__c>();
        Map<Id, List<Contact>> contacts = new Map<Id, List<Contact>>();

        // Create the specified number of students per pod
        for (Success_Pod__c sp : pods) {
            contacts.put(sp.Id, new List<Contact>());

            for (Integer x = 0; x < numberOfStudents; x++) {
                contacts.get(sp.Id).add(new contact(
                	FirstName = 'TestContact' + x,
                    LastName = sp.Name
                ));
            }
        }

        // I tried coming up with about 6 different ways
        // I know that DML in loop is terrible, but this is the best way to set things up
        // We just can't pass a very high number of pods.
        for (id i : contacts.keySet()) {
            insert contacts.get(i);
        }

        // Now that we have contact id's, create junction objects
        for (Success_Pod__c sp : pods) {
            for (Contact c : contacts.get(sp.Id)) {
                result.add(new Success_Student__c(
                    Is_Active__c = true,
                    Success_Pod__c = sp.Id,
                    Student__c = c.Id,
                    Coaching_Student__c = false
                ));
            }
        }
        insert result;
        return result;
    }

}
