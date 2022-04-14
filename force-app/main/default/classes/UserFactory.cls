@isTest
public class UserFactory {
    public class DefaultUser extends TestFactory {
        public DefaultUser() {
            super(
                new User(
                    FirstName = 'Test',
                    LastName = 'User',
                    Username = 'test.user.Emperor.Of.Byzantium@test.example.com',
                    Email = 'test.user@test.example.com',
                    Alias = 'testuser',
                    CommunityNickname = 'testuserEmperorOfByzantium',
                    TimeZoneSidKey = 'America/Phoenix',
                    LocaleSidKey = 'en_US',
                    EmailEncodingKey = 'ISO-8859-1',
                    ProfileId = '00ed00000017Iob',
                    LanguageLocaleKey = 'en_US'
                )
            );
            this.addToFieldsToIncrement('LastName');
            this.addToFieldsToIncrement('CommunityNickname');
            this.addToFieldsToIncrement('Email');
            this.addToFieldsToIncrement('UserName');
        }
    }

    public static void makeMeAnAdvisorDepartmentManager(
        Integer numberOfPods,
        Integer numberOfCases,
        Integer numberOfStudents
    ) {
        SuccessResourceFactory.DefaultAdvisorDepartmentManagerResource myAdvisorResourceMaker = new SuccessResourceFactory.DefaultAdvisorDepartmentManagerResource();
        Success_Resource__c myAdvisorResource = (Success_Resource__c) myAdvisorResourceMaker.create(1)[0];
        insert myAdvisorResource;
        makeMeAnAdvisor(numberOfPods, numberOfCases, numberOfStudents, myAdvisorResource);
    }

    public static void makeMeAnAdvisorCollegeManager(
        Integer numberOfPods,
        Integer numberOfCases,
        Integer numberOfStudents
    ) {
        SuccessResourceFactory.DefaultAdvisorCollegeManagerResource myAdvisorResourceMaker = new SuccessResourceFactory.DefaultAdvisorCollegeManagerResource();
        Success_Resource__c myAdvisorResource = (Success_Resource__c) myAdvisorResourceMaker.create(1)[0];
        insert myAdvisorResource;
        makeMeAnAdvisor(numberOfPods, numberOfCases, numberOfStudents, myAdvisorResource);
    }

    public static void makeMeAnAdvisorUser(Integer numberOfPods, Integer numberOfCases, Integer numberOfStudents) {
        SuccessResourceFactory.DefaultAdvisorUserResource myAdvisorResourceMaker = new SuccessResourceFactory.DefaultAdvisorUserResource();
        Success_Resource__c myAdvisorResource = (Success_Resource__c) myAdvisorResourceMaker.create(1)[0];
        insert myAdvisorResource;
        makeMeAnAdvisor(numberOfPods, numberOfCases, numberOfStudents, myAdvisorResource);
    }

    /*
     * Generates test data for the current user as if they were an advisor
     */
    public static void makeMeAnAdvisor(
        Integer numberOfPods,
        Integer numberOfCases,
        Integer numberOfStudents,
        Success_Resource__c myAdvisorResource
    ) {
        Id advisorOutReachId = RecordIdHelper.getRecordTypeId('Case', 'ASU_Advisor_Outreach');
        SuccessPodFactory advisorPodMaker = new SuccessPodFactory();
        SuccessStudentFactory successStudentMaker = new SuccessStudentFactory();
        SuccessResourcePodAssociationFactory successResourcePodAssociationMaker = new SuccessResourcePodAssociationFactory();

        List<Success_Pod__c> myAdvisorPods = advisorPodMaker.createRelatedGroupAdvisorPods(numberOfPods);
        List<Success_Student__c> myAdvisorStudents = successStudentMaker.createSuccessPodStudents(
            myAdvisorPods,
            numberOfStudents
        );
        List<Success_Resource_Pod_Association__c> myAdvisorSRPAS = successResourcePodAssociationMaker.createSuccessResourcePodAssociations(
            myAdvisorResource,
            myAdvisorPods
        );

        // Create watchlist and proactive cases for the pods/students
        List<Id> podIds = new List<Id>();

        for (Success_Pod__c sp : myAdvisorPods) {
            podIds.add(sp.id);
        }

        Map<Id, Success_Pod__c> podMap = new Map<Id, Success_Pod__c>(
            [SELECT Owner.Name FROM Success_Pod__c WHERE Id IN :podIds]
        );

        // Create cases
        // Note: This doesn't ensure that pods only contain cases for students in their pod
        // Pods may end up with cases for students not in their pod
        // This can and has happened in the real world so we are accounting for it here
        List<Case> cases = new List<Case>();
        CaseClassificationFactory caseClassificationsMaker = new CaseClassificationFactory();
        List<Case_Classification__c> classifications = caseClassificationsMaker.createAndInsertSetOfAdvisorOutreachCaseClassification();

        Id functionalGroup = classifications[0].Id;
        Id categoryOutreach = classifications[1].Id;
        Id categoryWatchlist = classifications[2].Id;
        // Cases for pods
        for (Success_Pod__c sp : myAdvisorPods) {
            for (Integer i = 0; i < numberOfCases; i++) {
                CaseFactory.AdvisorOutreachCase proactiveCaseMaker = new CaseFactory.AdvisorOutreachCase(
                    sp.OwnerId,
                    advisorOutReachId,
                    'Outreach Required',
                    functionalGroup,
                    categoryOutreach,
                    myAdvisorStudents[(Integer) math.rint(math.random() * (myAdvisorStudents.size() - 1))].student__c,
                    null
                );
                cases.add((Case) proactiveCaseMaker.create(1)[0]);

                CaseFactory.AdvisorOutreachCase watchlistCaseMaker = new CaseFactory.AdvisorOutreachCase(
                    sp.OwnerId,
                    advisorOutReachId,
                    'New',
                    functionalGroup,
                    categoryWatchlist,
                    myAdvisorStudents[(Integer) math.rint(math.random() * (myAdvisorStudents.size() - 1))].student__c,
                    null
                );
                cases.add((Case) watchlistCaseMaker.create(1)[0]);
            }
        }
        // Cases for advisor
        for (Integer i = 0; i < numberOfCases; i++) {
            Success_Pod__c sp = myAdvisorPods[(Integer) math.rint(math.random() * (myAdvisorPods.size() - 1))];
            String mostRecentQueue = podMap.get(sp.Id).Owner.Name;

            CaseFactory.AdvisorOutreachCase advisorCaseMaker = new CaseFactory.AdvisorOutreachCase(
                UserInfo.getUserId(),
                advisorOutReachId,
                'Outreach Required',
                functionalGroup,
                categoryWatchlist,
                myAdvisorStudents[(Integer) math.rint(math.random() * (myAdvisorStudents.size() - 1))].student__c,
                mostRecentQueue
            );
            cases.add((Case) advisorCaseMaker.create(1)[0]);
        }
        insert cases;
    }
}
