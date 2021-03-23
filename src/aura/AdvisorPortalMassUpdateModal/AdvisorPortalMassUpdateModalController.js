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
        // For each dropdown, in the requirements, check if value changes required fields
        for (let dropdownNameCSL in requirements) {
            // Split dropdown name by comma since it might be a multi-dropdown conditional
            let dropdownNames = dropdownNameCSL.split(',');
            for (let i = 0; i < dropdownNames.length; i++) {
                dropdownNames[i] = dropdownNames[i].trim();
            }

            // Check to make sure all dropdowns are set
            let noNulls = true;
            for (let i = 0; i < dropdownNames.length; i++) {
                let eachDropdown = dropdownNames[i];
                if (!(component.find(eachDropdown) && component.find(eachDropdown).get('v.value'))) {
                    noNulls = false;
                }
            }
            if (noNulls) {
                for (let valueCSL in requirements[dropdownNameCSL]) {
                    let addRequirements = true;

                    let values = valueCSL.split(',');
                    for (let i = 0; i < values.length; i++) {
                        values[i] = values[i].trim();
                    }

                    console.assert(dropdownNames.length == values.length);

                    // If all values and dropdowns match up as specified in the custom metadata ...
                    for (let i = 0; i < dropdownNames.length; i++) {
                        let dropdownName = dropdownNames[i];
                        let value = values[i];

                        // How to check depends on dropdown type
                        if (dropdownNameToDropdownType[dropdownName] == 'dropdown') {
                            addRequirements = addRequirements && component.find(dropdownName).get('v.value') == value;
                        } else if (dropdownNameToDropdownType[dropdownName] == 'dualListBox') {
                            addRequirements =
                                addRequirements && component.find(dropdownName).get('v.value').indexOf(value) !== -1;
                        }
                    }

                    // ... Then require the requirements
                    if (addRequirements) {
                        for (let i in requirements[dropdownNameCSL][valueCSL]) {
                            let requirement = requirements[dropdownNameCSL][valueCSL][i];
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
