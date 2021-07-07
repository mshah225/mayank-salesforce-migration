public class OrgWideEmailAddressService {
    /**
     * Returns all the fields on OrgWideEmailAddress in a String
     * @return A string containing all the OrgWideEmailAddress fields
     */
    public static String oweaFieldsToString() {
        String oweaFields = null;

        Map<String, SObjectField> oweaFieldMap = ObjectService.getObjectFieldMap('OrgWideEmailAddress');

        oweaFields = ObjectService.objectFieldsToString(oweaFieldMap);

        return oweaFields;
    }

    /**
     * Returns a matching OrgWideEmailAddress for a given email address
     * @param  emailAddress An email address
     * @return oweaToReturn The matching OrgWideEmailAddress
     */
    public static OrgWideEmailAddress getOrgWideEmailAddress(String emailAddress) {
        OrgWideEmailAddress oweaToReturn = new OrgWideEmailAddress();

        try {
            String oweaQuery =
                'SELECT ' +
                oweaFieldsToString() +
                ' FROM OrgWideEmailAddress WHERE Address = :emailAddress';

            System.debug(oweaQuery);

            oweaToReturn = Database.query(oweaQuery);
        } catch (Exception e) {
            throw new OrgWideEmailAddressServiceException(
                '!!!ERROR!!!: An error occurred trying to get the OrgWideEmailAddress for this address: ' +
                emailAddress +
                '\n' +
                e.getMessage()
            );
        }

        return oweaToReturn;
    }

    public class OrgWideEmailAddressServiceException extends Exception {
    }
}
