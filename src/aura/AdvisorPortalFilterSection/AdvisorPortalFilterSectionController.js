({
    doInit: function (component, event, helper) {
        helper.getFilterPicklists(component, event);
    },

    toggleFilterListPanel: function (component, event, helper) {
        component.set('v.isFilterSectionShown', !component.get('v.isFilterSectionShown'));
        helper.handleToggleFilterButtons(component, event, helper, 'FilterToggleState', 'filtersToggle');
    },

    applyFilters: function (component, event, helper) {
        helper.applyFilters(component, component.get('v.AllCasesState'));
    },

    clearFilters: function (component, event, helper) {
        component.set('v.Student', '');
        component.find('campusPicklist').resetMultiSelect();
        component.set('v.Major', '');
        component.find('residencyPicklist').resetMultiSelect();
        component.find('caseStatusPicklist').resetMultiSelect();
        component.find('caseSubjectPicklist').resetMultiSelect();
        component.find('caseCategoryPicklist').resetMultiSelect();
        component.find('academicLevelPicklist').resetMultiSelect();
        component.set('v.StudentGroup', '');
        component.find('outlookScoreOptionsPicklist').resetMultiSelect();
        component.find('outlookChangePicklist').resetMultiSelect();
        component.set('v.CaseCount', null);
        component.set('v.CreatedFromDate', '');
        component.set('v.CreatedToDate', '');
        component.set('v.FollowUpFromDate', '');
        component.set('v.FollowUpToDate', '');
        component.set('v.PersistenceFromDate', '');
        component.set('v.PersistenceToDate', '');
        component.set('v.AllCasesState', false);
        component.find('allCasesFilter').set('v.variant', 'neutral');
        component.set('v.ProactiveCasesState', true);
        component.find('proactiveFilter').set('v.variant', 'brand');
        component.set('v.WatchlistCasesState', false);
        component.find('watchlistFilter').set('v.variant', 'neutral');
        helper.applyFilters(component, component.get('v.AllCasesState'));
    },

    refreshView: function (component, event, helper) {
        helper.applyFilters(component, component.get('v.AllCasesState'));
    },

    returnKeyPressed: function (component, event, helper) {
        if (event.which === 13) {
            helper.applyFilters(component, component.get('v.AllCasesState'));
        }
    },

    handleAllCasesState: function (component, event, helper) {
        helper.handleToggleFilterButtons(component, event, helper, '', 'allCasesFilter');
    },

    handleProactiveCasesState: function (component, event, helper) {
        helper.handleToggleFilterButtons(component, event, helper, '', 'proactiveFilter');
    },

    handleWatchlistCasesState: function (component, event, helper) {
        helper.handleToggleFilterButtons(component, event, helper, '', 'watchlistFilter');
    },

    validateDates: function (component, event, helper) {
        helper.validateDateFields(component);
    },

    viewAsUsersHasChanged: function (component, event, helper) {
        let userIds = component.get('v.SelectedViewAsUserOptions').map((option) => option.value);
        component.set('v.UserIds', userIds);

        let caseSubjectPicklistAction = component.get('c.getCaseSubjectPicklistValues');
        caseSubjectPicklistAction.setParams({viewAsOptions: userIds});
        caseSubjectPicklistAction.setCallback(this, function (response) {
            if (response && response.getReturnValue()) {
                component.set(
                    'v.CaseSubjectPicklistValues',
                    helper.buildPicklistOptionsArray(response.getReturnValue())
                );
            } else {
                console.log(response.getError());
            }
        });
        $A.enqueueAction(caseSubjectPicklistAction);

        let caseClassificationPicklistAction = component.get('c.getCaseClassificationPicklistValues');
        caseClassificationPicklistAction.setParams({viewAsOptions: userIds});
        caseClassificationPicklistAction.setCallback(this, function (response) {
            if (response && response.getReturnValue()) {
                component.set(
                    'v.CaseCategoryPicklistValues',
                    helper.buildPicklistOptionsArray(response.getReturnValue())
                );
            } else {
                console.log(response.getError());
            }
        });
        $A.enqueueAction(caseClassificationPicklistAction);

        helper.applyFilters(component, component.get('v.AllCasesState'));
    },
});
