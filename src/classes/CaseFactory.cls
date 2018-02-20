@isTest
public class CaseFactory {
    
    public class ClosedWebformCase extends TestFactory {
        public ClosedWebformCase() {
            super(new Case(
                Subject = 'Webform:citizenship_verification%ASURITE:1000815525%Queue:'
                    + CaseWebformCloser.FINANCIAL_AID_CASE_QUEUE + '%First:Keith%Last:Arnold ',
                Description = 'Form:citizenship_verification. SubmissionID:#00000. UserID:1000815525',
                Status = 'Closed: Resolved',
                Functional_Group__c = 'Registrar',
                Category__c = 'Registrar',
                Priority = 'Normal',
                Origin__c = 'Web',
                Deep_Links__c = 'Sumbission Link: <a href="https://www.google.com" target="_blank">Click Here</a><br>',
                Number_of_Files__c = '1'
            ));
        }
    }
    
    public class ProcessingWebformCase extends TestFactory {
        public ProcessingWebformCase() {
            super(new Case(
                Subject = 'Webform:citizenship_verification%ASURITE:1000815525%Queue:'
                    + CaseWebformCloser.FINANCIAL_AID_CASE_QUEUE + '%First:Keith%Last:Arnold ',
                Description = 'Form:citizenship_verification. SubmissionID:#00000. UserID:1000815525',
                Status = 'Processing',
                Functional_Group__c = 'Registrar',
                Category__c = 'Registrar',
                Priority = 'Normal',
                Origin__c = 'Web',
                Deep_Links__c = 'Sumbission Link: <a href="https://www.google.com" target="_blank">Click Here</a><br>',
                Number_of_Files__c = '1',
                Visible_By_Contact__c = FALSE
            ));
        }
    }
}