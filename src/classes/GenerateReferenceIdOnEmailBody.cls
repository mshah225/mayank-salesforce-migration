public class GenerateReferenceIdOnEmailBody {
    public static String addReferenceIdToEmailBody(String caseId) {
        if (caseId.length() > 15) {
            caseId = caseId.left(15);
        }
        String orgId = UserInfo.getOrganizationId().left(15);
        String emailReferenceId = '_';
        emailReferenceId += orgId.left(5);
        emailReferenceId += orgId.right(10);
        emailReferenceId += '._';
        emailReferenceId += caseId.left(5);
        emailReferenceId += caseId.right(10);
        return 'ref:' + emailReferenceId + ':ref';
    }
}
