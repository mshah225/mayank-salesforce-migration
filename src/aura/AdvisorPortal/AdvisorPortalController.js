({
    refreshUsersAndCaseContactWrappers: function (component, event, helper) {
        component.find('filterSectionAuraElement').forceApplyFilters();
    },

    updateViewAsOptions: function (component, event, helper) {
        helper.updateViewAsOptions(component, event, helper);
    },
    updateCaseContactWrappers: function (component, event, helper) {
        component.set('v.FilteredContacts', event.getParam('caseContactWrapperList'));
    },
    callsIncrementProcessingCounter: function (component, event, helper) {
        helper.incrementProcessingCounter(component);
    },
    callsDecrementProcessingCounter: function (component, event, helper) {
        helper.decrementProcessingCounter(component);
    },
    updateAllUserOptions: function (component, event, helper) {
        component.set('v.AllUserOptions', event.getParam('allUserOptions'));
    },
    updateGlobalFilterData: function (component, event, helper) {
        let globalFilter = component.get('v.GlobalFilterData');
        if (globalFilter == null) {
            globalFilter = new Map();
        }

        // If param is set - change it in the global shared variable
        if(event.getParam('allStudentsState') != null)
            globalFilter['allStudentsState'] = event.getParam('allStudentsState');    

        component.set('v.GlobalFilterData', globalFilter);
    },
});
