@isTest
public class CaseFactory extends TestFactory {
    public static final Case DEFAULT_CASE = new Case(Subject = 'Test Subject', Description = 'Test Description');

    public CaseFactory(Case templateCase) {
        super(templateCase);
        this.addToFieldsToIncrement('Subject');
        this.addToFieldsToIncrement('Description');
    }

    public Case createOne() {
        return (Case) this.create()[0];
    }

    public class DefaultCase extends TestFactory {
        public DefaultCase() {
            super(new Case(Subject = 'Test Subject', Description = 'Test Description'));
            this.addToFieldsToIncrement('Subject');
            this.addToFieldsToIncrement('Description');
        }
    }

    public class DefaultCaseWithStatus extends TestFactory {
        public DefaultCaseWithStatus() {
            super(new Case(Subject = 'Test Subject', Description = 'Test Description', Status = 'New'));
            this.addToFieldsToIncrement('Subject');
            this.addToFieldsToIncrement('Description');
        }
    }

    public class ClosedWebformCase extends TestFactory {
        public ClosedWebformCase() {
            super(
                new Case(
                    Subject = 'Webform:citizenship_verification%ASURITE:1000815525%Queue:' +
                        CaseWebformCloser.FINANCIAL_AID_CASE_QUEUE +
                        '%First:Keith%Last:Arnold ',
                    Description = 'Form:citizenship_verification. SubmissionID:#00000. UserID:1000815525',
                    Status = CaseWebformCloser.CASE_CLOSE_WEBFORM_STATUS,
                    Functional_Group__c = 'Registrar',
                    Category__c = 'Registrar',
                    Priority = 'Normal',
                    Origin__c = 'Web',
                    Deep_Links__c = 'Sumbission Link: <a href="https://www.google.com" target="_blank">Click Here</a><br>',
                    Number_of_Files__c = '1'
                )
            );
        }
    }

    public class ProcessingWebformCase extends TestFactory {
        public ProcessingWebformCase() {
            super(
                new Case(
                    Subject = 'Webform:citizenship_verification%ASURITE:1000815525%Queue:' +
                        CaseWebformCloser.FINANCIAL_AID_CASE_QUEUE +
                        '%First:Keith%Last:Arnold ',
                    Description = 'Form:citizenship_verification. SubmissionID:#00000. UserID:1000815525',
                    Status = 'Processing',
                    Functional_Group__c = 'Registrar',
                    Category__c = 'Registrar',
                    Priority = 'Normal',
                    Origin__c = 'Web',
                    Deep_Links__c = 'Sumbission Link: <a href="https://www.google.com" target="_blank">Click Here</a><br>',
                    Number_of_Files__c = '1',
                    Visible_By_Contact__c = false
                )
            );
        }
    }

    public class AdvisorOutreachCase extends TestFactory {
        public AdvisorOutreachCase(
            Id userId,
            Id advisorOutReachId,
            String status,
            Id functionalGroup,
            Id category,
            Id advisorStudent,
            String mostRecentQueue
        ) {
            super(
                new Case(
                    OwnerId = userId,
                    RecordTypeId = advisorOutReachId,
                    Status = status,
                    CC_Functional_Group__c = functionalGroup,
                    CC_Category__c = category,
                    Origin__c = 'Outreach',
                    Subject = 'Case Bloat ',
                    Description = 'Case Bloat',
                    contactId = advisorStudent,
                    Most_Recent_Queue__c = mostRecentQueue
                )
            );
            this.addToFieldsToIncrement('Subject');
        }
    }
}
