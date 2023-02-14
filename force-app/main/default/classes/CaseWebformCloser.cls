public class CaseWebformCloser {
    public static final Id FINANCIAL_AID_CASE_QUEUE = [
        SELECT Id
        FROM Group
        WHERE Name = 'Financial Aid (Case)' AND Type = 'Queue'
        LIMIT 1
    ]
    .Id;
    public static final String CASE_CLOSE_WEBFORM_STATUS = 'Closed: Resolved';

    private Case currentCase;
    private Case previousCaseState;
    private List<String> deepLinksTokens;
    private List<String> subjectTokens;

    public CaseWebformCloser(Case currentCase, Case previousCaseState) {
        this.currentCase = currentCase;
        this.previousCaseState = previousCaseState;
    }

    public void handleWebformCase() {
        if (isPreviouslyClosedWebformCaseUpdatedByDrupal()) {
            revertWebformCaseToPreviousState();
        } else if (isCaseStatusProcessingAndLinksNotNull()) {
            splitDeepLinksAndSubjectOnKeyWord();
            checkSubjectForQueueAndAssignOwnership();
            if (isSubjectTokensNotEmptyAndDeepLinksFilledOut()) {
                setCaseFieldsAndReassignFinancialAidCases();
            }
        }
    }

    private Boolean isPreviouslyClosedWebformCaseUpdatedByDrupal() {
        return UserInfo.getName() == 'API ASU DRUPAL' &&
            previousCaseState.IsClosed &&
            previousCaseState.Deep_Links__c != null &&
            previousCaseState.Deep_Links__c.split('Click Here').size() ==
            (Integer.valueof(currentCase.Number_of_Files__c) + 1);
    }

    private void revertWebformCaseToPreviousState() {
        currentCase.Status = previousCaseState.Status;
        currentCase.Deep_Links__c = previousCaseState.Deep_Links__c;
        currentCase.Subject = previousCaseState.Subject;
    }

    private Boolean isCaseStatusProcessingAndLinksNotNull() {
        return currentCase.Status == 'Processing' && currentCase.Deep_Links__c != null;
    }

    private Boolean isSubjectTokensNotEmptyAndDeepLinksFilledOut() {
        return !subjectTokens.isEmpty() &&
            deepLinksTokens.size() == Integer.valueOf(currentCase.Number_of_Files__c) + 1;
    }

    private void splitDeepLinksAndSubjectOnKeyWord() {
        deepLinksTokens = currentCase.Deep_Links__c.split('Click Here');
        subjectTokens = currentCase.Subject.split('%');
    }

    private void checkSubjectForQueueAndAssignOwnership() {
        for (String subjectToken : subjectTokens) {
            List<String> tokenSplit = subjectToken.split(':');
            if (tokenSplit.size() >= 2 && tokenSplit[0] == 'Queue' && tokenSplit[1] != '') {
                currentCase.OwnerId = tokenSplit[1];
                return;
            }
        }
    }

    private void setCaseFieldsAndReassignFinancialAidCases() {
        currentCase.Status = 'New';
        currentCase.Subject = subjectTokens[0];
        if (currentCase.OwnerId == CaseWebformCloser.FINANCIAL_AID_CASE_QUEUE) {
            currentCase.Visible_By_Contact__c = false;
            currentCase.Status = CASE_CLOSE_WEBFORM_STATUS;
        }
    }
}
