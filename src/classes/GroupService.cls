public class GroupService {
    /**
     * Returns all the fields on Group in a String
     * @return String A string containing all the Group fields
     */
    public static String groupFieldsToString() {
        String groupFields = null;

        Map<String, SObjectField> groupFieldMap = ObjectService.getObjectFieldMap('Group');

        groupFields = ObjectService.objectFieldsToString(groupFieldMap);

        return groupFields;
    }

    /**
     * Returns a map of the Group Names keyed to its Group Id
     * @return Map<Id, String> A map containing Strings keyed to Ids
     */
    public static Map<Id, Group> mapGroupIdToName(List<Id> ownerIDs) {
        Map<ID, Group> groupNameMap;

        try {
            groupNameMap = new Map<ID, Group>([SELECT Id, Name FROM Group WHERE Id IN :OwnerIds]);
        } catch (Exception e) {
            throw new GroupServiceException(
                '!!!ERROR!!!: An error occurred when trying to get the Group names for this org\n' + e.getMessage()
            );
        }

        return groupNameMap;
    }

    /**
     * Get all of the group information that is tied to the specified Group Name
     * @param String The name of a group
     * @return Group A group object
     */
    public static Group getGroupDetails(String groupName) {
        Group groupInfo = null;
        String groupFields = groupFieldsToString();
        String queue = 'Queue';

        try {
            String groupDataQuery =
                'SELECT ' +
                groupFields +
                ' ' +
                'FROM Group ' +
                'WHERE Type = :queue ' +
                'AND Name = :groupName';

            groupInfo = Database.query(groupDataQuery);
        } catch (Exception e) {
            throw new GroupServiceException(
                '!!!ERROR!!!: An error occurred trying to get the Group\'s information\n' + e.getMessage()
            );
        }

        return groupInfo;
    }

    public class GroupServiceException extends Exception {
    }
}
