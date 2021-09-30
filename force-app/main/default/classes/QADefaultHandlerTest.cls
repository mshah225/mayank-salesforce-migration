@isTest
public class QADefaultHandlerTest {
    private static final String userAlias = 'testusr';
    private static QADefaultHandler qadh = new QADefaultHandler();
    private static List<Case> cases = new List<Case>([SELECT OwnerId, RecordTypeId, Most_Recent_Queue__c FROM Case]);

    @TestSetup
    public static void setup() {
        User runAsUser = new User(Id = UserInfo.getUserId());

        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'test.user.Emperor.Of.Byzantium@test.test',
            Email = 'test.user@test.test',
            Alias = userAlias,
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = IDHelper.getProfileID('System Administrator'),
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        Case_Classification__c testFuncGroup = new Case_Classification__c(
            Name = 'Test Functional Group',
            RecordTypeId = IDHelper.getRecordTypeId('Case_Classification__c', 'Functional_Group'),
            Record_Types__c = 'ASU Service',
            Active__c = true,
            Visible__c = true
        );
        insert testFuncGroup;

        List<Case_Classification__c> testCategories = new List<Case_Classification__c>{
            new Case_Classification__c(
                Name = 'Test Outreach Category',
                Parent__c = testFuncGroup.Id,
                RecordTypeId = IDHelper.getRecordTypeId('Case_Classification__c', 'Category'),
                Record_Types__c = 'ASU Service',
                Active__c = true,
                Visible__c = true
            ),
            new Case_Classification__c(
                Name = 'Test Watchlist Category',
                Parent__c = testFuncGroup.Id,
                RecordTypeId = IDHelper.getRecordTypeId('Case_Classification__c', 'Category'),
                Record_Types__c = 'ASU Service',
                Active__c = true,
                Visible__c = true
            )
        };
        insert testCategories;

        Success_Resource__c testResource = new Success_Resource__c(
            IsActive__c = true,
            Role__c = 'User',
            Resource__c = UserInfo.getUserId(),
            RecordTypeId = IDHelper.getRTID('Success_Resource__c', 'Advisor')
        );
        insert testResource;

        Group testGroup = new Group(Name = 'TestGroupName1', Type = 'Queue');
        insert testGroup;

        List<QueueSobject> testQueues = new List<QueueSobject>{
            new QueueSobject(QueueId = testGroup.Id, SobjectType = 'Success_Pod__c'),
            new QueueSobject(QueueId = testGroup.Id, SobjectType = 'Case')
        };
        System.runAs(runAsUser) {
            // Separate transaction to avoid mixed DML
            insert testQueues;
        }

        Success_Pod__c testPod = new Success_Pod__c(
            OwnerId = testGroup.Id,
            RecordTypeId = IDHelper.getRTID('Success_Pod__c', 'Advisor'),
            Primary_Email__c = testGroup.name + '@test.asu.edu',
            Name = 'Test Pod 1',
            Committee__c = 'tp1'
        );
        insert testPod;

        Success_Resource_Pod_Association__c testSRPA = new Success_Resource_Pod_Association__c(
            Success_Resource__c = testResource.Id,
            Success_Pod__c = testPod.Id
        );
        insert testSRPA;

        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            testContacts.add(new contact(FirstName = 'TestContact' + i, LastName = testPod.Name));
        }
        insert testContacts;

        List<Success_Student__c> testStudents = new List<Success_Student__c>();
        for (Integer i = 0; i < testContacts.size(); i++) {
            testStudents.add(
                new Success_Student__c(
                    Is_Active__c = true,
                    Success_Pod__c = testPod.Id,
                    Student__c = testContacts[i].Id,
                    Coaching_Student__c = false
                )
            );
        }
        insert testStudents;

        Id advisorOutReachId = IDHelper.getRTID('Case', 'ASU_Advisor_Outreach');
        List<Case> testCases = new List<Case>();
        for (Integer i = 0; i < 3; i++) {
            // proactive case
            testCases.add(
                new Case(
                    OwnerId = testPod.OwnerId,
                    RecordTypeId = advisorOutReachId,
                    Status = 'Outreach Required',
                    CC_Functional_Group__c = testFuncGroup.Id,
                    CC_Category__c = testCategories[0].Id,
                    Origin__c = 'Outreach',
                    Subject = 'Case Bloat ' + Math.mod(i, 2),
                    Description = 'Case Bloat',
                    ContactId = testStudents[(Integer) Math.rint(Math.random() * (testStudents.size() - 1))].Student__c
                )
            );
            // Watchlist Cases
            testCases.add(
                new Case(
                    OwnerId = testPod.OwnerId,
                    RecordTypeId = advisorOutReachId,
                    Status = 'New',
                    CC_Functional_Group__c = testFuncGroup.Id,
                    CC_Category__c = testCategories[1].Id,
                    Origin__c = 'Outreach',
                    Subject = 'Case Bloat ' + Math.mod(i, 2),
                    Description = 'Case Bloat',
                    ContactId = testStudents[(Integer) Math.rint(Math.random() * (testStudents.size() - 1))].student__c
                )
            );

            cases.add(
                new Case(
                    OwnerId = testUser.Id,
                    RecordTypeId = advisorOutReachId,
                    Status = 'Outreach Required',
                    CC_Functional_Group__c = testFuncGroup.Id,
                    CC_Category__c = testCategories[1].Id,
                    Origin__c = 'Outreach',
                    Subject = 'Case Bloat ' + Math.mod(i, 2),
                    Description = 'Case Bloat',
                    ContactId = testStudents[(Integer) Math.rint(Math.random() * (testStudents.size() - 1))].student__c,
                    Most_Recent_Queue__c = testGroup.Name
                )
            );
        }
        insert testCases;
    }

    /*
     * Tests the QADefaultHandlers ability to identify advisor cases
     *
     * <p>
     * At this point, all cases are advisor cases so this should always be true.
     * </p>
     */
    @isTest
    private static void Test_isAdvisorCase() {
        for (Case c : cases) {
            if (c.recordTypeId == IDHelper.getRTID('Case', 'ASU_Advisor_Outreach')) {
                system.assert(qadh.isAdvisorCase(c));
            } else {
                system.assert(!qadh.isAdvisorCase(c));
            }
        }
    }

    /*
     * Tests the QADefaultHandler's ability to determine if the case is
     * owned by a group as opposed to a user.
     */
    @isTest
    private static void Test_caseOwnedByGroup() {
        for (Case c : cases) {
            if (Validator.validateId(c.OwnerId, Group.class)) {
                system.assert(qadh.caseOwnedByGroup(c));
            } else {
                system.assert(!qadh.caseOwnedByGroup(c));
            }
        }
    }

    /*
     * Tests the QADefaultHandler's ability to determine the from address for the provided case
     */
    @isTest
    private static void Test_getEmailFromAddress() {
        for (Case c : cases) {
            EmailMessage em = new EmailMessage();
            qadh.setEmailFromAndToAddress(c.Id, em);
            if (qadh.isAdvisorCase(c)) {
                if (qadh.caseOwnedByGroup(c)) {
                    system.assertEquals(
                        [SELECT Primary_Email__c FROM Success_Pod__c WHERE OwnerId = :c.OwnerId]
                        .Primary_Email__c,
                        em.FromAddress
                    );
                } else {
                    system.assertEquals(
                        [SELECT Primary_Email__c FROM Success_Pod__c WHERE Owner_Name__c = :c.Most_Recent_Queue__c]
                        .Primary_Email__c,
                        em.FromAddress
                    );
                }
            }
        }
    }

    @isTest
    private static void Test_nullContextId() {
        qadh.setEmailFromAndToAddress(null, null);
        List<Case> errorList = [SELECT Id FROM Case WHERE Origin__c = 'Error Logger'];
        System.assertEquals(1, errorList.size());
    }
}
