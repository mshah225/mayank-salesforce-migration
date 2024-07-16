@isTest
public class ObjectHelperTest {
    // Tests the getDataCategoryLabelByName method for a valid data category
    @isTest
    private static void testGetDataCategoryLabelByName_ValidCategory() {
        String objectType = 'KnowledgeArticleVersion';
        String categoryGroup = 'Finances';
        String category = 'Card_Services';
        String label = ObjectHelper.getDataCategoryLabelByName(objectType, categoryGroup, category);

        System.assert(label.containsOnly('Card Services'), 'Label should match for valid categories');
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

        System.assert(result.name == null, 'Data category name should be empty when label is not found');
        System.assert(result.label == null, 'Data category label should be empty when label is not found');
        System.assert(result.parentGroup == null, 'Data category group name should be empty when label is not found');
        System.assert(result.objectType == null, 'Data category object should be empty when label is not found');
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
}