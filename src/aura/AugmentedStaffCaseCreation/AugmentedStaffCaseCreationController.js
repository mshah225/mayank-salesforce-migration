({
    onInit: function (component, event, helper) {
        helper.getPermissions(component);
        helper.getCategoryOptions(component);
    },

    updateDynamicFieldVisibility: function (component, event, helper) {
        helper.getSubCategoryOptions(component);
    },

    checkValidId: function (component, event, helper) {
        helper.checkValidId(component);
    },

    createCase: function (component, event, helper) {
        if (
            !component.get('v.foundStudent') ||
            component.get('v.description') == null ||
            component.get('v.description') === ''
        ) {
            component.set(
                'v.message',
                'Please ensure that the ASURITE/EMPLID is Valid, and that the required fields are complete.'
            );
        } else {
            helper.createACase(component);
        }
    },
});
