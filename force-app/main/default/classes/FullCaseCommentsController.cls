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
            this.comments = getComments(theContact.Id);
        } else {
            this.theCase = (Case) stdController.getRecord();
            this.comments = getComments(theCase.Id);
        }
    }

    public static List<CaseComment> getComments(String recordId) {
        List<CaseComment> comments;
        if (recordId == null)
            return new List<CaseComment>();

        if (recordId.startsWith(ObjectService.getKeyPrefix(Contact.getSObjectType()))) {
            comments = [
                SELECT CommentBody, CreatedDate, ParentId, Parent.Subject, Parent.CaseNumber
                FROM CaseComment
                WHERE
                    ParentId IN (
                        SELECT Id
                        FROM Case
                        WHERE
                            ContactId = :recordId
                            AND RecordTypeId = :RecordIdHelper.getRecordTypeId('Case', 'ASU_Coach_Outreach')
                    )
                ORDER BY CreatedDate DESC
            ];
        } else if (recordId.startsWith(ObjectService.getKeyPrefix(Case.getSObjectType()))) {
            comments = [
                SELECT CommentBody, CreatedDate, ParentId, Parent.Subject, Parent.CaseNumber
                FROM CaseComment
                WHERE ParentId = :recordId
                ORDER BY CreatedDate DESC
            ];
        } else {
            throw new FullCaseCommentsControllerIdException(
                'Can only get comments for contacts or cases - this id=' + recordId + ' is neither'
            );
        }

        return comments;
    }

    public class FullCaseCommentsControllerIdException extends Exception {
    }
}
