@isTest
public class ObjectHelperTest {
    // Tests the getDataCategoryLabelByName method for a valid data category
    @isTest
    private static void testGetDataCategoryLabelByName_ValidCategory() {
        String objectType = 'KnowledgeArticleVersion';
        String categoryGroup = 'Finances';
        String category = 'Card_Services';
        String label = ObjectHelper.getDataCategoryLabelByName(objectType, categoryGroup, category);

        System.assert(label.contains('Card Services'), 'Label should match for valid categories');
    }

    // Tests the getDataCategoryLabelByName method for an invalid data category
    @isTest
    private static void testGetDataCategoryLabelByName_InvalidCategory() {
        String objectType = 'KnowledgeArticleVersion';
        String categoryGroup = 'InvalidGroup';
        String category = 'InvalidCategory';
        String label = ObjectHelper.getDataCategoryLabelByName(objectType, categoryGroup, category);

        System.assert(String.isEmpty(label), 'Label should be empty for invalid categories');
    }

    // Tests the getDataCategoryNameAndGroupByLabel method when the data category label is found
    @isTest
    private static void testGetDataCategoryNameAndGroupByLabel_Found() {
        String objectType = 'KnowledgeArticleVersion';
        String labelName = 'Card Services';
        ObjectHelper.DataCategoryWrapper result = ObjectHelper.getDataCategoryNameAndGroupByLabel(
            objectType,
            labelName
        );

        System.assert(labelName == result.label, 'Data category label should match when label is found');
        System.assert(result.name.contains('Card_Services'), 'Data category name should match when label is found');
        System.assert(
            result.parentGroup.contains('Finances'),
            'Data category group name should match when label is found'
        );
        System.assert(
            objectType == result.objectType,
            'Data category object should be set correctly based on the input type'
        );
    }

    // Tests the getDataCategoryNameAndGroupByLabel method when the data category label is not found
    @isTest
    private static void testGetDataCategoryNameAndGroupByLabel_NotFound() {
        String objectType = 'KnowledgeArticleVersion';
        String labelName = 'Invalid Label';
        ObjectHelper.DataCategoryWrapper result = ObjectHelper.getDataCategoryNameAndGroupByLabel(
            objectType,
            labelName
        );

        System.assert(result.name == null, 'Data category name should be null when label is not found');
        System.assert(result.label == null, 'Data category label should be null when label is not found');
        System.assert(result.parentGroup == null, 'Data category group name should be null when label is not found');
        System.assert(result.objectType == null, 'Data category object should be null when label is not found');
    }

    // Tests the isValidDataCategory method for valid data categories
    @isTest
    private static void testIsValidDataCategory_Valid() {
        String objectType = 'KnowledgeArticleVersion';
        String categoryGroup = 'Finances';
        String category = 'Card_Services';
        Boolean isValid = ObjectHelper.isValidDataCategory(objectType, categoryGroup, category);

        System.assert(isValid, 'isValid should be true for valid categories');
    }

    // Tests the isValidDataCategory method for invalid data categories
    @isTest
    private static void testIsValidDataCategory_Invalid() {
        String objectType = 'KnowledgeArticleVersion';
        String categoryGroup = 'InvalidGroup';
        String category = 'InvalidCategory';
        Boolean isValid = ObjectHelper.isValidDataCategory(objectType, categoryGroup, category);

        System.assert(!isValid, 'isValid should be false for invalid categories');
    }

    @isTest
    private static void testGetFieldDescribeBasic() {
        Schema.DescribeFieldResult expected = Schema.SObjectType.Case.fields.ContactId;
        Schema.DescribeFieldResult actual = ObjectHelper.getFieldDescribe('Case', 'ContactId');

        Assert.areEqual(expected.getSObjectField(), actual.getSObjectField());
    }

    @isTest
    private static void testGetFieldDescribeLookups() {
        Schema.DescribeFieldResult expected = Schema.SObjectType.Case.fields.ContactId.getReferenceTo()[0]
            .getDescribe()
            .fields.getMap()
            .get('Name')
            .getDescribe();
        Schema.DescribeFieldResult actual = ObjectHelper.getFieldDescribe('Case', 'Contact.Name');

        Assert.areEqual(expected.getSObjectField(), actual.getSObjectField());
    }

    @isTest
    private static void testGetFieldDescribeDeepLookup() {
        Schema.DescribeFieldResult expected = Schema.SObjectType.Case.fields.ContactId.getReferenceTo()[0]
                .getDescribe()
                .fields.getMap()
                .get('CreatedById')
                .getDescribe()
                .getReferenceTo()[0]
            .getDescribe()
            .fields.getMap()
            .get('Name')
            .getDescribe();
        Schema.DescribeFieldResult actual = ObjectHelper.getFieldDescribe('Case', 'Contact.CreatedBy.Name');

        Assert.areEqual(expected.getSObjectField(), actual.getSObjectField());
    }

    @isTest
    private static void testGetFieldDescribeDeppLookupFromCache() {
        Schema.DescribeFieldResult expected = Schema.SObjectType.Case.fields.ContactId.getReferenceTo()[0]
                .getDescribe()
                .fields.getMap()
                .get('CreatedById')
                .getDescribe()
                .getReferenceTo()[0]
            .getDescribe()
            .fields.getMap()
            .get('Name')
            .getDescribe();

        Integer start1 = Limits.getCpuTime();
        Schema.DescribeFieldResult actual1 = ObjectHelper.getFieldDescribe('Case', 'Contact.CreatedBy.Name');
        Integer end1 = Limits.getCpuTime();

        Integer start2 = Limits.getCpuTime();
        Schema.DescribeFieldResult actual2 = ObjectHelper.getFieldDescribe('Case', 'Contact.CreatedBy.Name');
        Integer end2 = Limits.getCpuTime();

        Assert.areEqual(expected.getSObjectField(), actual1.getSObjectField());
        Assert.areEqual(expected.getSObjectField(), actual2.getSObjectField());
        // since actual2 is from cache, it should be reference to same object a actual1
        Assert.areEqual(actual1, actual2);
        Assert.isTrue(
            (end2 - start2) < (end1 - start1),
            'Retrieving from cache took ' +
                (end2 - start2) +
                'ms, and initial call took ' +
                (end1 - start1) +
                'ms - cache should be faster but it wasn\'t'
        );
    }

    @isTest
    private static void testGetFieldDescribeWrongType() {
        Exception thrownEx;

        try {
            ObjectHelper.getFieldDescribe('InvalidType', 'ContactId');
        } catch (Exception ex) {
            thrownEx = ex;
        }

        Assert.isInstanceOfType(
            thrownEx,
            ObjectHelper.ObjectHelperObjectNameException.class,
            'Expected to throw an exception of type ObjectHelper.ObjectHelperObjectNameException, but actually threw ' +
            thrownEx?.getTypeName()
        );
        Assert.isTrue(
            thrownEx?.getMessage().contains('no such type exists'),
            'Expected to error message to contain "no such type exists" but it said "' + thrownEx?.getMessage() + '"'
        );
    }

    @isTest
    private static void testGetFieldDescribeEmptyNullOrRootPath() {
        Exception thrownEx1, thrownEx2, thrownEx3;

        try {
            ObjectHelper.getFieldDescribe('Case', '');
        } catch (Exception ex) {
            thrownEx1 = ex;
        }
        try {
            ObjectHelper.getFieldDescribe('Case', null);
        } catch (Exception ex) {
            thrownEx2 = ex;
        }
        try {
            ObjectHelper.getFieldDescribe('Case', '$');
        } catch (Exception ex) {
            thrownEx3 = ex;
        }

        Assert.isInstanceOfType(
            thrownEx1,
            ObjectHelper.ObjectHelperFieldPathException.class,
            'Expected to throw an exception of type ObjectHelper.ObjectHelperFieldPathException, but actually threw ' +
            thrownEx1?.getTypeName()
        );
        Assert.isTrue(
            thrownEx1?.getMessage().contains('path must not be empty'),
            'Expected to error message to contain "path must not be empty" but it said "' +
                thrownEx1?.getMessage() +
                '"'
        );

        Assert.isInstanceOfType(
            thrownEx2,
            ObjectHelper.ObjectHelperFieldPathException.class,
            'Expected to throw an exception of type ObjectHelper.ObjectHelperFieldPathException, but actually threw ' +
            thrownEx2?.getTypeName()
        );
        Assert.isTrue(
            thrownEx2?.getMessage().contains('path must not be empty'),
            'Expected to error message to contain "path must not be empty" but it said "' +
                thrownEx2?.getMessage() +
                '"'
        );

        Assert.isInstanceOfType(
            thrownEx3,
            ObjectHelper.ObjectHelperFieldPathException.class,
            'Expected to throw an exception of type ObjectHelper.ObjectHelperObjectNameException, but actually threw ' +
            thrownEx3?.getTypeName()
        );
        Assert.isTrue(
            thrownEx3?.getMessage().contains('cannot ask for root element'),
            'Expected to error message to contain "cannot ask for root element" but it said "' +
                thrownEx3?.getMessage() +
                '"'
        );
    }

    @isTest
    private static void testGetFieldDescribeInvalidLookup() {
        Exception thrownEx1, thrownEx2;

        try {
            ObjectHelper.getFieldDescribe('Case', 'ContactId.Name');
        } catch (Exception ex) {
            thrownEx1 = ex;
        }
        try {
            ObjectHelper.getFieldDescribe('Case', 'Contact.NotAField');
        } catch (Exception ex) {
            thrownEx2 = ex;
        }

        Assert.isInstanceOfType(
            thrownEx1,
            ObjectHelper.ObjectHelperFieldPathException.class,
            'Expected to throw an exception of type ObjectHelper.ObjectHelperFieldPathException, but actually threw ' +
            thrownEx1?.getTypeName()
        );
        Assert.isTrue(
            thrownEx1?.getMessage().contains('field does not exist or is not a lookup field'),
            'Expected to error message to contain "field does not exist or is not a lookup field" but it said "' +
                thrownEx1?.getMessage() +
                '"'
        );

        Assert.isInstanceOfType(
            thrownEx2,
            ObjectHelper.ObjectHelperFieldPathException.class,
            'Expected to throw an exception of type ObjectHelper.ObjectHelperFieldPathException, but actually threw ' +
            thrownEx2?.getTypeName()
        );
        Assert.isTrue(
            thrownEx2?.getMessage().contains('field does not exist'),
            'Expected to error message to contain "field does not exist" but it said "' + thrownEx2?.getMessage() + '"'
        );
    }

    @isTest
    private static void testGetFieldDescribeFromCacheError() {
        Exception thrownEx1, thrownEx2;

        try {
            ObjectHelper.getFieldDescribe('Case', 'Contact.NotAField');
        } catch (Exception ex) {
            thrownEx1 = ex;
        }

        try {
            ObjectHelper.getFieldDescribe('Case', 'Contact.NotAField');
        } catch (Exception ex) {
            thrownEx2 = ex;
        }

        Assert.isInstanceOfType(
            thrownEx1,
            ObjectHelper.ObjectHelperFieldPathException.class,
            'Expected to throw an exception of type ObjectHelper.ObjectHelperFieldPathException, but actually threw ' +
            thrownEx1?.getTypeName()
        );
        Assert.isTrue(
            thrownEx1?.getMessage().contains('field does not exist'),
            'Expected to error message to contain "field does not exist" but it said "' + thrownEx1?.getMessage() + '"'
        );

        Assert.isInstanceOfType(
            thrownEx2,
            ObjectHelper.ObjectHelperFieldPathException.class,
            'Expected to throw an exception of type ObjectHelper.ObjectHelperFieldPathException, but actually threw ' +
            thrownEx2?.getTypeName()
        );
        Assert.isTrue(
            thrownEx2?.getMessage().contains('field does not exist'),
            'Expected to error message to contain "field does not exist" but it said "' + thrownEx2?.getMessage() + '"'
        );

        // Since exception 2 is from the cache - it should be the same object reference as exception 1
        Assert.areEqual(thrownEx1, thrownEx2);
    }
}