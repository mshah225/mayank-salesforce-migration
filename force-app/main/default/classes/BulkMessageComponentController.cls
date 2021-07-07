public class BulkMessageComponentController {
    @AuraEnabled
    public static FYSStudentWrapper studentList(Id userId) {
        Boolean firstLoad = false;
        if (userId == null) {
            userId = UserInfo.getUserId();
            firstLoad = true;
        }
        FYSStudentWrapper wrapper = new FYSStudentWrapper();
        Set<User> coaches = new Set<User>();
        String deviceType = '';
        Set<String> fieldsToSelect = new Set<String>();
        fieldsToSelect.add('sg_contact__r.id');
        for (Schema.FieldSetMember f : getContactFields(deviceType)) {
            fieldsToSelect.add('sg_contact__r.' + f.getFieldPath().toLowerCase());
            wrapper.addFieldDetailEntry(f.getLabel(), f.getFieldPath(), String.valueOf(f.getType()));
        }
        wrapper.addFieldDetailEntry();

        List<String> peopleSoftCodeList = new List<String>();
        for (Success_Coach_Mapping__c successMap : [
            SELECT
                Id,
                PeopleSoft_Student_Group_Code__c,
                Supervisor__c,
                Supervisor__r.name,
                Success_Coach__c,
                Success_Coach__r.name
            FROM Success_Coach_Mapping__c
            WHERE Supervisor__c = :userId OR Success_Coach__c = :userId
        ]) {
            if (firstLoad && userId.equals(successMap.Supervisor__c)) {
                coaches.add(new User(Id = successMap.Success_Coach__c, firstName = successMap.Success_Coach__r.name));
            }
            if (
                userId.equals(successMap.Success_Coach__c) &&
                !peopleSoftCodeList.contains(successMap.PeopleSoft_Student_Group_Code__c)
            ) {
                peopleSoftCodeList.add(successMap.PeopleSoft_Student_Group_Code__c);
            }
        }
        wrapper.coaches = coaches;
        if (peopleSoftCodeList != null && peopleSoftCodeList.size() > 0) {
            List<Contact> studentList = new List<Contact>();
            String query = 'SELECT Id, {0} FROM Student_Group__c WHERE SG_PeopleSoft_Code__c in :peopleSoftCodeList and SG_Status__c = true';
            String fieldsToSelectCSV = String.join(new List<String>(fieldsToSelect), ',');
            query = String.format(query, new List<String>{ fieldsToSelectCSV });
            List<Student_Group__c> stGroupList = Database.query(query);
            for (Student_Group__c stGroup : stGroupList) {
                studentList.add(stGroup.SG_Contact__r);
            }
            wrapper.students = studentList;
        }
        return wrapper;
    }

    public static list<Schema.FieldSetMember> getContactFields(String deviceType) {
        if ('PHONE'.equalsIgnoreCase(deviceType))
            return SObjectType.Contact.FieldSets.Bulk_SMS_Mobile_View.getFields();
        else
            return SObjectType.Contact.FieldSets.Bulk_SMS_desktop_View.getFields();
    }
}
