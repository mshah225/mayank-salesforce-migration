({
    onInit: function (component, event, helper) {
        helper.getCategoryOptions(component);
    },

    updateDynamicFieldVisibility: function (component, event, helper) {
        helper.getSubCategoryOptions(component);
    },
    
    checkValidId: function (component, event, helper) {
        helper.checkValidId(component);
    },
 
    createCase: function (component, event, helper) {
       helper.createACase(component);
    }
})
