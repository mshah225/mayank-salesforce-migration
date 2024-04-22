@isTest
public class FieldSetHelperTest {
    @isTest
    private static void testGetFieldsSet() {
        Map<String, SObjectType> sObjects = Schema.getGlobalDescribe();

        String objectName, fieldSetName;
        Boolean foundOne = false;

        // Find at least one non-empty fieldset to test with
        for (String sObjName : sObjects.keySet()) {
            SObjectType sObj = sObjects.get(sObjName);
            Schema.DescribeSObjectResult sObjDescr = sObj.getDescribe();

            Map<String, Schema.FieldSet> fieldSetMp = sObjDescr.fieldSets.getMap();

            for (String fieldSetNm : fieldSetMp.keySet()) {
                Schema.FieldSet fldSet = fieldSetMp.get(fieldSetNm);

                List<Schema.FieldSetMember> lstFSMember = fldSet?.getFields();

                if (!lstFSMember.isEmpty()) {
                    objectName = sObjName;
                    fieldSetName = fieldSetNm;

                    foundOne = true;
                }

                if (foundOne)
                    break;
            }

            if (foundOne)
                break;
        }

        Assert.isTrue(
            foundOne,
            'Could not find ANY non-empty field sets in org to test with - at least one is required'
        );

        Schema.FieldSet expectedFieldSet = sObjects.get(objectName).getDescribe().fieldSets.getMap().get(fieldSetName);
        Map<String, Object> recvFieldSetMp = FieldSetHelper.getFieldsFromFieldSet(objectName, fieldSetName);

        // Response has both fields
        Assert.isTrue(recvFieldSetMp.containsKey('FIELD_LIST'));
        Assert.isTrue(recvFieldSetMp.containsKey('OBJECT_LABEL'));

        // Correct object label
        Assert.areEqual(objectName.toLowerCase(), ((String) recvFieldSetMp.get('OBJECT_LABEL')).toLowerCase());

        // For each field in field set
        for (Schema.FieldSetMember fldSetMember : expectedFieldSet.getFields()) {
            Map<String, Object> returnedObj;

            // Get the corresponding item from the returned payload
            for (Object returnedItemObj : (List<Object>) recvFieldSetMp.get('FIELD_LIST')) {
                Map<String, Object> returnedItemMp = (Map<String, Object>) returnedItemObj;
                if (fldSetMember.getFieldPath() == (String) returnedItemMp.get('fieldPath')) {
                    returnedObj = returnedItemMp;
                    break;
                }
            }

            // And verify all fields that we care about
            Assert.areEqual(fldSetMember.getFieldPath(), returnedObj.get('fieldPath'));
            Assert.areEqual(fldSetMember.getLabel(), returnedObj.get('label'));
            Assert.areEqual(fldSetMember.getRequired(), returnedObj.get('required'));
        }
    }

    @isTest
    private static void testInvalidObjectName() {
        FieldSetHelper.FieldSetHelperException ex = null;

        try {
            Map<String, Object> recvFieldSetMp = FieldSetHelper.getFieldsFromFieldSet('Invalid__err', 'Primary');
        } catch (FieldSetHelper.FieldSetHelperException e) {
            ex = e;
        }

        Assert.isNotNull(ex, 'Expected error to be thrown');
        Assert.areEqual('Invalid__err is not a valid object type', ex.getMessage());
    }

    @isTest
    private static void testInvalidFieldSetName() {
        FieldSetHelper.FieldSetHelperException ex = null;

        try {
            Map<String, Object> recvFieldSetMp = FieldSetHelper.getFieldsFromFieldSet(
                'Account',
                'InvalidFieldSetName__err'
            );
        } catch (FieldSetHelper.FieldSetHelperException e) {
            ex = e;
        }

        Assert.isNotNull(ex, 'Expected error to be thrown');
        Assert.areEqual('There is no fieldset named InvalidFieldSetName__err on the Account object', ex.getMessage());
    }
}
