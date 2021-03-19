({
    doInit: function (component, event, helper) {
        helper.getOptionsLabelAndValue(component, 'populateRecommendedActionOptions', 'RecommendedActionOptions');
        helper.getOptionsLabelAndValue(component, 'populateReturnTermOptions', 'StudentReturnTermOptions');
        helper.getOptionsLabelAndValue(component, 'populateStudentRiskOptions', 'StudentRiskOptions');
        helper.getOptionsLabelAndValue(component, 'populateReasonNotReturningOptions', 'NotReturningOptions');
        helper.loadCustomMetadata(component);
    },

    updateDynamicFieldVisibility: function (component) {
        // Dependent on Case Status
        if (component.find('caseStatus') && component.find('caseStatus').get('v.value')) {
            if (component.find('caseStatus').get('v.value') === 'Closed: Administratively Resolved (No Outreach)') {
                component.set('v.RenderRequireReasonsAdministrativelyClosed', true);
            } else {
                component.set('v.RenderRequireReasonsAdministrativelyClosed', false);
            }

            if (
                component.find('caseStatus').get('v.value') === 'Conferred with Student by Phone' ||
                component.find('caseStatus').get('v.value') === 'Conferred with Student by Email' ||
                component.find('caseStatus').get('v.value') === 'In Person Meeting'
            ) {
                component.set('v.RequireRecommendedAction', true);
                component.set('v.RequireStudentIntent', true);
            } else {
                component.set('v.RequireRecommendedAction', false);
                component.set('v.RequireStudentIntent', false);
            }
        }

        // Dependent on Recommended Actions
        if (component.find('recommendedActions') && component.find('recommendedActions').get('v.value')) {
            if (component.find('recommendedActions').get('v.value').indexOf('other') !== -1) {
                component.set('v.RenderRequireRecommendedActionOther', true);
            } else {
                component.set('v.RenderRequireRecommendedActionOther', false);
            }
        }

        // Dependent on Student Intent
        if (component.find('studentIntent') && component.find('studentIntent').get('v.value')) {
            if (
                component.find('studentIntent').get('v.value') === 'Not returning ever' ||
                component.find('studentIntent').get('v.value') === 'Not returning temporarily'
            ) {
                component.set('v.RenderRequireNotReturning', true);
            } else {
                component.set('v.RenderRequireNotReturning', false);
            }

            if (component.find('studentIntent').get('v.value') === 'Not returning temporarily') {
                component.set('v.RequireReturnTerm', true);
            } else {
                component.set('v.RequireReturnTerm', false);
            }

            if (component.find('studentIntent').get('v.value') === 'Enrolled') {
                component.set('v.RequireStudentRisk', true);
            } else {
                component.set('v.RequireStudentRisk', false);
            }
        }

        // Dependent on Not Returning Reason (also check student intent to see if any reason is still needed)
        if (
            component.find('notReturning') &&
            component.find('notReturning').get('v.value') &&
            component.find('studentIntent') &&
            component.find('studentIntent').get('v.value')
        ) {
            if (
                component.find('notReturning').get('v.value').indexOf('Other') !== -1 &&
                component.find('studentIntent').get('v.value') !== 'Enrolled'
            ) {
                component.set('v.RenderRequireNotReturningOther', true);
            } else {
                component.set('v.RenderRequireNotReturningOther', false);
            }
        }

        // Dependent on Student Risk
        if (component.find('studentRisk') && component.find('studentRisk').get('v.value')) {
            if (component.find('studentRisk').get('v.value') === 'Other') {
                component.set('v.RenderRequireStudentRiskOther', true);
            } else {
                component.set('v.RenderRequireStudentRiskOther', false);
            }
        }
    },

    toggleMassUpdateModal: function (component, event, helper) {
        helper.toggleUpdateModal(component);
    },

    massUpdate: function (component, event, helper) {
        event.getSource().set('v.disabled', true);

        if (!helper.isFormValid(component)) {
            helper.fireToast('Error', 'Please fill out all required fields.', 'error');
            event.getSource().set('v.disabled', false);
            return;
        }

        let action = component.get('c.updateCases');
        action.setParams({
            casesToUpdate: helper.updateCaseFields(component),
        });
        action.setCallback(this, function (response) {
            if (response.getState() !== 'SUCCESS') {
                helper.fireToast('Error', helper.buildErrorMessage(response.getError()), 'error');
                event.getSource().set('v.disabled', false);
                return;
            }

            helper.fireToast('Success', 'Case(s) Updated.', 'success');
            helper.toggleUpdateModal(component);
            helper.resetComponentValues(component);
            event.getSource().set('v.disabled', false);
            component.getEvent('refreshAdvisorPortalContacts').fire();
        });
        $A.enqueueAction(action);
    },
});
