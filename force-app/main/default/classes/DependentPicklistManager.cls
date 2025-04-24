/**
 * Salesforce does not readily expose information about which dependent picklist options
 * are valid given the value of the controlling field.
 *
 * This utility class help you get this information.
 *
 * It can be used by creating an instance of the class using the constructor, passing the dependent field
 * reference.
 * ```
 *    DependentPicklistManager checkValidity = new DependentPicklistManager(Opportunity.Lead_Source_Subtype__c);
 *    checkValidity.isValid('Phone Call', 'Graduate Education')
 * ```
 *
 * `getOptions` - Pass the value of the controlling field, and get back the list of PicklistEntrys that are valid
 *                for the dependent field
 * `isValid` - Check if a dependent field value is valid for a controlling field value
 *
 * This is based on [a blog post](https://glyntalkssalesforce.blogspot.com/2018/08/dependent-picklist-values-in-apex.html)
 *
 */
public class DependentPicklistManager {
    private Schema.SObjectField dependentField;
    private Schema.SObjectField controllingField;
    // Map of each controlling picklist to valid options and mapping option value to PicklistEntry object
    private Map<Object, List<String>> controllingToDependentOptions = new Map<Object, List<String>>();
    private Map<String, Schema.PicklistEntry> picklistValueToPicklistEntryMp = new Map<String, Schema.PicklistEntry>();
    // Should be include inactive values?
    private Boolean includeInactive = false;

    public DependentPicklistManager(Schema.SObjectField dependentField) {
        this.dependentField = dependentField;
        this.init();
    }
    public DependentPicklistManager(Schema.SObjectField dependentField, Boolean includeInactive) {
        this.dependentField = dependentField;
        this.includeInactive = includeInactive;
        this.init();
    }

    /**
     * Get a list of valid picklist options when the controlling picklist value is controllingValue
     * @param controllingValue The value of the controlling picklist, this must be either a BOOLEAN or STRING depending on the type
     * of the controlling picklist
     * @return List of valid picklist options
     * @throws IllegalArgumentException When typeof controlling value does not match type of controlling field
     */
    public List<Schema.PicklistEntry> getOptions(Object controllingValue) {
        if (controllingValue == null)
            controllingValue = '';

        if (
            !((controllingValue instanceof Boolean &&
            controllingField.getDescribe().getType() == Schema.DisplayType.BOOLEAN) ||
            (controllingValue instanceof String &&
            controllingField.getDescribe().getType() == Schema.DisplayType.PICKLIST))
        ) {
            throw new IllegalArgumentException(
                'Tried to get dependent picklist options for ' +
                    getFullName(dependentField) +
                    ' using a controlling value="' +
                    controllingValue +
                    '", but this type is invalid for the controlling field'
            );
        }

        List<String> picklistValues = controllingToDependentOptions.get(controllingValue);

        // Add all picklist options
        List<Schema.PicklistEntry> options = new List<Schema.PicklistEntry>();
        if (picklistValues != null && picklistValues.size() > 0)
            for (String val : picklistValues)
                options.add(picklistValueToPicklistEntryMp.get(val));

        return options;
    }

    /**
     * Check if the dependentValue is valid for a specific controllingValue
     * @param controllingValue Value of the controlling picklist, this must be either a BOOLEAN or STRING depending on the type
     * of the controlling picklist
     * @param dependentValue Value of the dependent picklist
     * @return TRUE if valid, FALSE otherwise
     * @throws IllegalArgumentException When typeof controlling value does not match type of controlling field
     */
    public Boolean isValid(Object controllingValue, String dependentValue) {
        if (controllingValue == null)
            controllingValue = '';
        if (String.isBlank(dependentValue))
            return true; // Blank is always valid

        if (
            !((controllingValue instanceof Boolean &&
            controllingField.getDescribe().getType() == Schema.DisplayType.BOOLEAN) ||
            (controllingValue instanceof String &&
            controllingField.getDescribe().getType() == Schema.DisplayType.PICKLIST))
        ) {
            throw new IllegalArgumentException(
                'Tried to get check if "' +
                    dependentValue +
                    '" was a valid option for ' +
                    getFullName(dependentField) +
                    ' using a controlling value="' +
                    controllingValue +
                    '", but this type is invalid for the controlling field'
            );
        }

        List<String> picklistValues = controllingToDependentOptions.get(controllingValue);

        return picklistValues != null && picklistValues.contains(dependentValue);
    }

    /**
     * Primary initialization function - called from all constructors
     * @throws IllegalArgumentException When field is not a dependent picklist
     */
    private void init() {
        Schema.DescribeFieldResult dependentDescribe = dependentField.getDescribe();

        // Throw an error if this isn't a dependent picklist
        if (!dependentDescribe.isDependentPicklist())
            throw new IllegalArgumentException(getFullName(dependentField) + ' is not a dependent picklist');

        // Add all options to value -> PicklistEntry mapping
        for (Schema.PicklistEntry pe : dependentDescribe.getPicklistValues())
            picklistValueToPicklistEntryMp.put(pe.getValue(), pe);

        // Get controlling field value
        controllingField = dependentDescribe.getController();

        // Do hard work
        controllingToDependentOptions = getDependentPicklistValues(dependentField);
    }

    /**
     * Given a field, get the full name of a field, both the object name and the field name
     */
    private static String getFullName(Schema.SObjectField field) {
        Schema.DescribeFieldResult descr = field.getDescribe();
        return descr.getSObjectType().getDescribe().getName() + '.' + descr.getName();
    }

    /**
     * This does the hard work of figuring out the list of controlling values (either Boolean or String
     * depending on the type of the controlling field) and mapping that to a list of allowed
     * Strings for the dependent picklist
     *
     * https://glyntalkssalesforce.blogspot.com/2018/08/dependent-picklist-values-in-apex.html with slight
     * change to check `bitIndex >= base64chars.size()` before accessing `base64chars[bitIndex]`
     */
    private static Map<Object, List<String>> getDependentPicklistValues(Schema.sObjectField dependToken) {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null)
            return null;
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries = (control.getType() == Schema.DisplayType.Boolean
            ? null
            : control.getPicklistValues());

        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<Object, List<String>> dependentPicklistValues = new Map<Object, List<String>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            List<String> base64chars = String.valueOf(
                    ((Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')
                )
                .split('');
            for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                Object controlValue = (controlEntries == null
                    ? (Object) (index == 1)
                    : (Object) (controlEntries[index].getValue()));
                Integer bitIndex = index / 6, bitShift = 5 - Math.mod(index, 6);
                if (bitIndex >= base64chars.size())
                    continue; // Sometimes goes out of bounds for unknown reasons - adding a check here seems to fix it - but I don't really understand this code so not 100% sure why it goes out of bounds ¯\_(ツ)_/¯
                if (controlValue == null || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0)
                    continue;
                if (!dependentPicklistValues.containsKey(controlValue)) {
                    dependentPicklistValues.put(controlValue, new List<String>());
                }
                dependentPicklistValues.get(controlValue).add(entry.getValue());
            }
        }
        return dependentPicklistValues;
    }
}