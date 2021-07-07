public class PickListDescController {
    public Sobject sobj { get; set; }
    public String pickListFieldName { get; set; }

    public PickListDescController() {
        Map<String, String> reqParams = ApexPages.currentPage().getParameters();
        String sobjId = reqParams.get('id');
        String recordTypeId = reqParams.get('recordTypeId');
        String recordTypeName = reqParams.get('recordTypeName');
        String sobjectTypeName = reqParams.get('sobjectType');
        this.pickListFieldName = reqParams.get('picklistFieldName');

        Schema.SobjectType sobjectType = null;

        if (sobjectTypeName != null && sobjectTypeName.trim().length() > 0) {
            sobjectType = Schema.getGlobalDescribe().get(sobjectTypeName);
            // create blank sobject record
            sobj = sobjectType.newSobject();

            // if no recordTypeId passed explicitly by user, try loading one from the RecordType table
            if (isBlank(recordTypeId) && !isBlank(recordTypeName)) {
                // queryexception is fine, we don't want to return anything good for bad recordtype
                RecordType recType = [
                    SELECT Id
                    FROM RecordType
                    WHERE SobjectType = :sobjectTypeName AND DeveloperName LIKE :recordTypeName
                ];
                recordTypeid = recType.id;
            }
            sobj.put('RecordTypeId', recordTypeid);
        }
    }

    static boolean isBlank(String val) {
        return val == null || val.trim().length() == 0;
    }
}
