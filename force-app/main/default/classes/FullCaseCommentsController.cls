/*****************************************
 * File: FullCaseCommentsController
 * Author: Mathew Ruff, Sierra-Cedar Inc.
 * Description: Custom controller logic for fullCaseComments.page
 ******************************************/
public with sharing class FullCaseCommentsController {
    private Case theCase;
    private Contact theContact;
    public List<CaseComment> comments { get; set; }

    public FullCaseCommentsController(ApexPages.StandardController stdController) {
        comments = new List<CaseComment>();

        if (ApexPages.currentPage().getParameters().get('id').startsWith('003')) {
            this.theContact = (Contact) stdController.getRecord();

            Map<Id, Case> coachCaseMap = new Map<Id, Case>(
                [
                    SELECT Id
                    FROM Case
                    WHERE ContactId = :theContact.Id AND RecordTypeId = :IDHelper.getRTID('Case', 'ASU_Coach_Outreach')
                ]
            );

            if (coachCaseMap.size() > 0) {
                comments = [
                    SELECT CommentBody, CreatedDate, ParentId
                    FROM CaseComment
                    WHERE ParentId IN :coachCaseMap.keySet()
                    ORDER BY CreatedDate DESC
                ];
            }
        } else {
            this.theCase = (Case) stdController.getRecord();

            comments = [
                SELECT CommentBody, CreatedDate, ParentId
                FROM CaseComment
                WHERE ParentId = :theCase.Id
                ORDER BY CreatedDate DESC
            ];
        }
    }
}
