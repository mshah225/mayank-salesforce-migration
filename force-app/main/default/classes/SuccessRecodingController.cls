/*****************************************
 * File: SuccessRecodingController
 * Author: Mathew Ruff, Sierra-Cedar
 * Description: Custom controller for successRecoding.page
 * Last Modified By: Kaleb Anderson - lines 133 and 156
 ******************************************/

public class SuccessRecodingController {
    public Boolean coachPath { get; set; }
    public Boolean allStudentsChecked { get; set; }
    public Id selectedCoachId { get; set; }
    public Id transferToCoachId { get; set; }
    public Id selectedContactId { get; set; }
    public Integer page { get; set; }
    public List<User> resourceResults { get; set; }
    public String coachSearchString { get; set; }
    public String studentSearchString { get; set; }
    public String selectedInitOpt { get; set; }
    public String selectedCoachName { get; set; }
    public String transferToCoachName { get; set; }
    public String selectedStudentName { get; set; }
    public List<StudentWrapper> studentsResults { get; set; }
    public List<StudentWrapper> selectedStudents { get; set; }
    public List<Contact> contactResults { get; set; }
    public String coachProfile = System.Label.Success_Coach_Recode_Profile;

    public SuccessRecodingController() {
        page = 1;
        coachPath = false;
        resourceResults = new List<User>();
        studentsResults = new List<StudentWrapper>();
        selectedStudents = new List<StudentWrapper>();
        contactResults = new List<Contact>();
    }

    public List<SelectOption> getInitOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--Select--'));
        options.add(new SelectOption('Student', 'Student'));
        options.add(new SelectOption('Coach', 'Coach'));

        return options;
    }

    public void populateResourceResults() {
        resourceResults = new List<User>(
            [
                SELECT Name, ASURITE_Id__c, Alias, EmplId__c, Email
                FROM User
                WHERE Profile.Name = :coachProfile AND IsActive = TRUE
                ORDER BY Name ASC
                LIMIT 50
            ]
        );
    }

    public void searchForCoaches() {
        if (coachSearchString.length() < 3) {
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.ERROR, 'Search terms must be at least 3 characters long.')
            );
            return;
        }
        resourceResults = searchUsersByCoachSearchString();
    }

    private List<User> searchUsersByCoachSearchString() {
        List<List<SObject>> results = [
            FIND :String.escapeSingleQuotes(coachSearchString)
            IN ALL FIELDS
            RETURNING
                User(
                    Name,
                    Alias,
                    ASURITE_Id__c,
                    EMPLID__c,
                    Email
                    WHERE Profile.Name = :coachProfile AND IsActive = TRUE AND Id != :selectedCoachId
                    LIMIT 50)
        ];
        if (!results[0].isEmpty()) {
            return (List<User>) results[0];
        } else {
            return new List<User>();
        }
    }

    public void searchForStudents() {
        if (studentSearchString.length() < 3) {
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.ERROR, 'Search terms must be at least 3 characters long.')
            );
            return;
        }
        contactResults = searchContactsByStudentSearchString();
    }

    private List<Contact> searchContactsByStudentSearchString() {
        List<List<SObject>> results = new List<List<SObject>>();
        results = [
            FIND :String.escapeSingleQuotes(studentSearchString)
            IN ALL FIELDS
            RETURNING
                Contact(
                    Name,
                    FirstName,
                    LastName,
                    ASURite_ID__c,
                    EMPLID__c,
                    Email
                    WHERE
                        Id IN (
                            SELECT Student__c
                            FROM Success_Student__c
                            WHERE Is_Active__c = TRUE AND Coaching_Student__c = TRUE
                        )
                    ORDER BY Name ASC
                    LIMIT 50)
        ];
        if (!results[0].isEmpty()) {
            return (List<Contact>) results[0];
        } else {
            return new List<Contact>();
        }
    }

    public void selectContactAndFindSuccessStudent() {
        studentsResults = new List<StudentWrapper>();

        List<Success_Student__c> tempStudents = new List<Success_Student__c>(
            [
                SELECT Student_Name__c, ASURiteID__c, EMPLID__c, Student__c, Plan_Code__r.Name
                FROM Success_Student__c
                WHERE Student__r.Id = :selectedContactId AND Is_Active__c = TRUE AND Coaching_Student__c = TRUE
                LIMIT 1000
            ]
        );

        studentsResults.add(new StudentWrapper(tempStudents[0]));

        // Override the contructor and select the students.
        for (StudentWrapper sw : studentsResults) {
            sw.selected = true;
        }

        selectStudentsForTransfer();
    }

    public void findCoachStudents() {
        allStudentsChecked = false;
        studentsResults = new List<StudentWrapper>();

        List<Success_Student__c> tempStudents = ([
            SELECT Student_Name__c, ASURiteID__c, EMPLID__c, Student__c, Plan_Code__r.Name
            FROM Success_Student__c
            WHERE
                Success_Resource__r.Resource__r.Id = :selectedCoachId
                AND Is_Active__c = TRUE
                AND Coaching_Student__c = TRUE
            LIMIT 1000
        ]);

        for (Success_Student__c ss : tempStudents) {
            studentsResults.add(new StudentWrapper(ss));
        }

        page3();
    }

    public void selectStudentsForTransfer() {
        Integer numSelected = 0;
        selectedStudents = new List<StudentWrapper>();

        for (StudentWrapper s : studentsResults) {
            if (s.selected) {
                selectedStudents.add(s);
                numSelected++;
            }
        }

        if (numSelected == 0) {
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least one student to transfer.')
            );
            return;
        }

        coachSearchString = '';
        resourceResults = new List<User>();
        populateResourceResults();
        page2();
    }

    public void checkAllStudents() {
        if (allStudentsChecked) {
            for (StudentWrapper s : studentsResults) {
                s.selected = true;
            }
        } else if (!allStudentsChecked) {
            for (StudentWrapper s : studentsResults) {
                s.selected = false;
            }
        }
    }

    public void transferStudents() {
        Set<Id> studentContactIds = new Set<Id>();
        List<Success_Student__c> studentsToUpdate = new List<Success_Student__c>();
        List<Case> casesToUpdate = new List<Case>();

        List<Success_Resource__c> newResource = new List<Success_Resource__c>(
            [SELECT Id FROM Success_Resource__c WHERE Resource__c = :transferToCoachId LIMIT 1]
        );

        if (newResource.size() > 0) {
            for (StudentWrapper s : selectedStudents) {
                s.student.Success_Resource__c = newResource[0].Id;
                studentContactIds.add(s.student.Student__c);
                studentsToUpdate.add(s.student);
            }

            // Find current Open Cases owned by the previous coach to transfer.
            List<Case> openCases = new List<Case>(
                [
                    SELECT Subject, Description
                    FROM Case
                    WHERE
                        IsClosed = FALSE
                        AND ContactId IN :studentContactIds
                        AND Functional_Group__c = 'ASU Coach Outreach'
                    LIMIT 50000
                ]
            );

            for (Case c : openCases) {
                c.OwnerId = transferToCoachId;
                casesToUpdate.add(c);
            }

            try {
                update studentsToUpdate;

                if (casesToUpdate.size() > 0) {
                    update casesToUpdate;
                }

                page5();
            } catch (DmlException e) {
                System.debug('ERROR: problem updating students: ' + e.getMessage());
            }
        } else {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'ERROR: Cannot find Success Resource for: ' +
                    transferToCoachId +
                    ' please try again or select another Coach.'
                )
            );
            return;
        }
    }

    public void deselectStudentAndBack() {
        selectedStudents = new List<StudentWrapper>();

        if (!coachPath) {
            page6();
        } else {
            page3();
        }
    }

    public void setPath() {
        if (selectedInitOpt == 'Coach') {
            populateResourceResults();
            coachPath = true;
            page2();
        } else if (selectedInitOpt == 'Student') {
            page6();
        }
    }

    public void page1Reset() {
        allStudentsChecked = false;
        resourceResults = null;
        coachSearchString = '';
        studentSearchString = '';
        selectedCoachName = '';
        transferToCoachName = '';
        selectedStudentName = '';
        studentsResults = new List<StudentWrapper>();
        selectedStudents = new List<StudentWrapper>();
        contactResults = new List<Contact>();

        selectedInitOpt = '--Select--';
        coachPath = false;
        page = 1;
    }

    // Select path page
    public void page1() {
        selectedInitOpt = '--Select--';
        coachPath = false;
        page = 1;
    }

    // Coach search page
    public void page2() {
        page = 2;
    }

    // Select students for transfer page
    public void page3() {
        page = 3;
    }

    // Transfer confirmation page
    public void page4() {
        page = 4;
    }

    // Final success page
    public void page5() {
        page = 5;
    }

    // Student search page
    public void page6() {
        page = 6;
    }

    public class StudentWrapper {
        public Boolean selected { get; set; }
        public Success_Student__c student { get; set; }

        public StudentWrapper(Success_Student__c ss) {
            student = ss;
            selected = false;
        }
    }
}
