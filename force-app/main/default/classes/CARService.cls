public with sharing class CARService {
    /**
     * Returns all the fields on Case Assignment Rule in a String
     * @return A string containing all the Case Assignment Rule fields
     */
    public static String CARFieldsToString() {
        Map<String, SObjectField> CARFieldMap = ObjectService.getObjectFieldMap('Case_Assignment_Rule__c');

        String CARFields = ObjectService.objectFieldsToString(CARFieldMap);

        return CARFields;
    }

    /**
     * A list of all CARs that are General
     * @return A list of CARs
     */
    public static List<Case_Assignment_Rule__c> getGeneralCARs() {
        String CARFields = CARFieldsToString();

        String queryString =
            'SELECT ' +
            CARFields +
            ' ' +
            'FROM Case_Assignment_Rule__c ' +
            'WHERE CTPColumn__c != null ' +
            'AND CTPGroup__c != null ' +
            'AND Label__c != null ' +
            'AND CTPVisible__c = true ' +
            'AND Label__c LIKE \'%(General)%\'';

        List<Case_Assignment_Rule__c> allGenCARs = Database.query(queryString);

        return allGenCARs;
    }

    /**
     * A list of all CARs that are NOT General CARs
     * @return A list of CARs that are not General CARs
     */
    public static List<Case_Assignment_Rule__c> getNonGeneralCARs() {
        String CARFields = CARFieldsToString();

        String queryString =
            'SELECT ' +
            CARFields +
            ' ' +
            'FROM Case_Assignment_Rule__c ' +
            'WHERE CTPColumn__c != null ' +
            'AND CTPGroup__c != null ' +
            'AND Label__c != null ' +
            'AND CTPVisible__c = true ' +
            'AND (NOT Label__c LIKE \'%(General)%\') ' +
            'ORDER BY Label__c ASC';

        List<Case_Assignment_Rule__c> allNonGenCARs = Database.query(queryString);

        return allNonGenCARs;
    }

    /**
     * Returns a CAR Object from the Id you pass in.
     * @param the Id of the CAR you would like to query for
     * @return The CAR Object
     */
    public static Case_Assignment_Rule__c getCAR(Id selectedId) {
        String CARFields = CARFieldsToString();

        String queryString = 'SELECT ' + CARFields + ' ' + 'FROM Case_Assignment_Rule__c ' + 'WHERE Id = :selectedId';

        Case_Assignment_Rule__c theCAR = Database.query(queryString);

        return theCAR;
    }

    public static Case_Assignment_Rule__c getCARWithSharingGroup(Id selectedId) {
        String CARFields = CARFieldsToString();

        String queryString =
            'SELECT ' +
            CARFields +
            ', CC_Functional_Group__r.Is_Functional_Group_Private__c ' +
            'FROM Case_Assignment_Rule__c ' +
            'WHERE Id = :selectedId';

        Case_Assignment_Rule__c theCAR = Database.query(queryString);

        return theCAR;
    }
}
