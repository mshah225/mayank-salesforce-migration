({
    doInit: function (component, event, helper) {
        helper.getOptionsLabelAndValue(component, 'populateRecommendedActionOptions', 'RecommendedActionOptions');
        helper.getOptionsLabelAndValue(component, 'populateReturnTermOptions', 'StudentReturnTermOptions');
        helper.getOptionsLabelAndValue(component, 'populateStudentRiskOptions', 'StudentRiskOptions');
        helper.getOptionsLabelAndValue(component, 'populateReasonNotReturningOptions', 'NotReturningOptions');
        helper.loadCustomMetadata(component);
    },

    updateDynamicFieldVisibility: function (component) {
        // String expected in custom metadata mapped to the required booleans
        const componentIdToRequiredBoolean = {
            reasonsAdminClosed: 'v.RenderRequireReasonsAdministrativelyClosed',
            recommendedActions: 'v.RequireRecommendedAction',
            recommendedActionOther: 'v.RenderRequireRecommendedActionOther',
            studentIntent: 'v.RequireStudentIntent',
            notReturning: 'v.RenderRequireNotReturning',
            notReturningOther: 'v.RenderRequireNotReturningOther',
            returnTerm: 'v.RequireReturnTerm',
            studentRisk: 'v.RequireStudentRisk',
            studentRiskOther: 'v.RenderRequireStudentRiskOther',
        };
        const dropdownNameToDropdownType = {
            caseStatus: 'dropdown',
            recommendedActions: 'dualListBox',
            studentIntent: 'dropdown',
            notReturning: 'dualListBox',
            returnTerm: 'dropdown',
            studentRisk: 'dropdown',
        };

        let componentIdToRequiredStatus = {};

        for (let componentId in componentIdToRequiredBoolean) {
            componentIdToRequiredStatus[componentId] = false;
        }

        const requirements = component.get('v.DynamicallyGeneratedRequirements');
        for (let dropdownName in requirements) {
            // For each dropdown, in the requirements, check if value changes required fields
            if (component.find(dropdownName) && component.find(dropdownName).get('v.value')) {
                for (let value in requirements[dropdownName]) {
                    // If it has a value specified in the custom metadata ...
                    let addRequirements = false;

                    // How to check depends on dropdown type
                    if (dropdownNameToDropdownType[dropdownName] == 'dropdown') {
                        if (component.find(dropdownName).get('v.value') == value) {
                            addRequirements = true;
                        }
                    } else if (dropdownNameToDropdownType[dropdownName] == 'dualListBox') {
                        if (component.find(dropdownName).get('v.value').indexOf(value) !== -1) {
                            addRequirements = true;
                        }
                    }

                    // ... Then require the requirements
                    if (addRequirements) {
                        for (let i in requirements[dropdownName][value]) {
                            let requirement = requirements[dropdownName][value][i];
                            componentIdToRequiredStatus[requirement] = true;
                        }
                    }
                }
            }

            for (let componentId in componentIdToRequiredStatus) {
                component.set(componentIdToRequiredBoolean[componentId], componentIdToRequiredStatus[componentId]);
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
