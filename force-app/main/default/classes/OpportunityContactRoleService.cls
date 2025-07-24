public class OpportunityContactRoleService {
    public static void checkUniqueKey(List<OpportunityContactRole> newRoles) {
        Set<String> incomingKeys = new Set<String>();

        for (OpportunityContactRole ocr : newRoles) {
            if (ocr.OpportunityId != null) {
                incomingKeys.add(ocr.OpportunityId);
            }
        }

        Map<String, OpportunityContactRole> existingKeysMap = new Map<String, OpportunityContactRole>();
        if (!incomingKeys.isEmpty()) {
            for (OpportunityContactRole existingOCR : [
                SELECT Id, OpportunityId
                FROM OpportunityContactRole
                WHERE OpportunityId IN :incomingKeys
            ]) {
                existingKeysMap.put(existingOCR.OpportunityId, existingOCR);
            }
        }

        for (OpportunityContactRole ocr : newRoles) {
            if (ocr.OpportunityId != null && existingKeysMap.containsKey(ocr.OpportunityId)) {
                ocr.addError('Duplicate OCR for Opportunity.');
            }
        }
    }

    public static void verifyIsPrimaryTrue(List<OpportunityContactRole> newRoles) {
        for (OpportunityContactRole ocr : newRoles) {
            if (!ocr.IsPrimary) {
                ocr.IsPrimary = true;
            }
        }
    }
}