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
    updateGraduateStudentsOnly: function (component, event, helper) {
        const detail = event.getParams('detail');
        if (component.get('v.GraduateStudentsOnly') !== detail.gradOnly)
            component.set('v.GraduateStudentsOnly', detail.gradOnly);
    },
    setDefaultFilter: function (component, event, helper) {
        const detail = event.getParams('detail');

        if (JSON.stringify(component.get('v.DefaultFilter')) !== detail.filter)
            component.set('v.DefaultFilter', JSON.parse(detail.filter));
    },
    getCurrentFilter: function (component, event, helper) {
        const detail = event.getParams('detail');
        component.find('filterSectionAuraElement').getCurrentFilter(detail.callback);
    },
});
