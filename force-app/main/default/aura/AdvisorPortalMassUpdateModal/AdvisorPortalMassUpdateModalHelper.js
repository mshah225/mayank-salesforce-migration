({
    getOptionsLabelAndValue: function (component, apexMethod, componentAttribute) {
        let action = component.get('c.' + apexMethod);
        action.setCallback(this, function (response) {
            if (response.getState() !== 'SUCCESS') {
                this.fireToast('Error', response.getError()[0].message, 'error');
                return;
            }

            let results = response.getReturnValue();
            let options = [];
            Object.keys(results).forEach(function (key) {
                options.push({label: key, value: results[key]});
            });

            component.set('v.' + componentAttribute, options);
        });
        $A.enqueueAction(action);
    },

    toggleUpdateModal: function (component) {
        let countOfSelectedCases = 0;
        let contacts = component.get('v.Contacts');

        for (let i = 0; i < contacts.length; i++) {
            for (let j = 0; j < contacts[i].cases.length; j++) {
                if (contacts[i].cases[j].isSelected) {
                    countOfSelectedCases++;
                    break;
                }
            }
        }

        if (countOfSelectedCases === 0) {
            this.fireToast('Error', 'Please select a case first.', 'error');
            return;
        }

        $A.util.toggleClass(this.findByAuraId(component, 'modalBackdrop'), 'slds-backdrop_open');
        $A.util.toggleClass(this.findByAuraId(component, 'massUpdateModal'), 'slds-fade-in-open');

        if ($A.util.hasClass(this.findByAuraId(component, 'massUpdateModal'), 'slds-fade-in-open')) {
            this.resetComponentValues(component);
        }

        document.getElementById('massUpdateBody').scrollTop = 0;
    },

    isFormValid: function (component) {
        let isValid = true;

        if (!component.get('v.CaseStatus')) {
            this.findByAuraId(component, 'caseStatus').showHelpMessageIfInvalid();
            isValid = false;
        }

        if (
            component.get('v.RenderRequireReasonsAdministrativelyClosed') &&
            this.findByAuraId(component, 'reasonsAdminClosed') &&
            !component.get('v.ReasonsAdministrativelyClosed')
        ) {
            this.findByAuraId(component, 'reasonsAdminClosed').showHelpMessageIfInvalid();
            isValid = false;
        }
        if (
            component.get('v.RequireRecommendedAction') &&
            this.findByAuraId(component, 'recommendedActions') &&
            (this.findByAuraId(component, 'recommendedActions').get('v.value') === undefined ||
                this.findByAuraId(component, 'recommendedActions').get('v.value').length === 0)
        ) {
            this.findByAuraId(component, 'recommendedActions').showHelpMessageIfInvalid();
            isValid = false;
        }

        if (
            component.get('v.RenderRequireRecommendedActionOther') &&
            this.findByAuraId(component, 'recommendedActionOther') &&
            !component.get('v.RecommendedActionOther')
        ) {
            this.findByAuraId(component, 'recommendedActionOther').showHelpMessageIfInvalid();
            isValid = false;
        }

        if (
            component.get('v.RequireStudentIntent') &&
            this.findByAuraId(component, 'studentIntent') &&
            !component.get('v.StudentsIntentions')
        ) {
            this.findByAuraId(component, 'studentIntent').showHelpMessageIfInvalid();
            isValid = false;
        }

        if (
            component.get('v.RenderRequireNotReturning') &&
            this.findByAuraId(component, 'notReturning') &&
            (this.findByAuraId(component, 'notReturning').get('v.value') === undefined ||
                this.findByAuraId(component, 'notReturning').get('v.value').length === 0)
        ) {
            this.findByAuraId(component, 'notReturning').showHelpMessageIfInvalid();
            isValid = false;
        }

        if (
            component.get('v.RenderRequireNotReturningOther') &&
            this.findByAuraId(component, 'notReturningOther') &&
            !component.get('v.NotReturningOther')
        ) {
            this.findByAuraId(component, 'notReturningOther').showHelpMessageIfInvalid();
            isValid = false;
        }

        if (
            component.get('v.RequireReturnTerm') &&
            this.findByAuraId(component, 'returnTerm') &&
            !component.get('v.StudentReturnTerm')
        ) {
            this.findByAuraId(component, 'returnTerm').showHelpMessageIfInvalid();
            isValid = false;
        }

        if (
            component.get('v.RequireStudentRisk') &&
            this.findByAuraId(component, 'studentRisk') &&
            !component.get('v.StudentRisk')
        ) {
            this.findByAuraId(component, 'studentRisk').showHelpMessageIfInvalid();
            isValid = false;
        }

        if (
            component.get('v.RenderRequireStudentRiskOther') &&
            this.findByAuraId(component, 'studentRiskOther') &&
            !component.get('v.StudentRiskOther')
        ) {
            this.findByAuraId(component, 'studentRiskOther').showHelpMessageIfInvalid();
            isValid = false;
        }

        return isValid;
    },

    updateCaseFields: function (component) {
        let casesToUpdate = [];
        let contacts = component.get('v.Contacts');

        for (let i = 0; i < contacts.length; i++) {
            for (let j = 0; j < contacts[i].cases.length; j++) {
                if (contacts[i].cases[j].isSelected) {
                    let theCase = contacts[i].cases[j].portalCase;
                    theCase.Status = component.get('v.CaseStatus');

                    if (component.get('v.CaseStatus') === 'Closed: Administratively Resolved (No Outreach)') {
                        theCase.Reason_Administratively_Closed__c = component.get('v.ReasonsAdministrativelyClosed');
                    }

                    if (this.findByAuraId(component, 'recommendedActions').get('v.value')) {
                        for (
                            let i = 0;
                            i < this.findByAuraId(component, 'recommendedActions').get('v.value').length;
                            i++
                        ) {
                            if (!theCase.Recommended_Actions__c) {
                                theCase.Recommended_Actions__c = '';
                            }

                            if (this.findByAuraId(component, 'recommendedActions').get('v.value')[i]) {
                                theCase.Recommended_Actions__c +=
                                    this.findByAuraId(component, 'recommendedActions').get('v.value')[i] + ';';
                            }
                        }

                        if (theCase.Recommended_Actions__c && theCase.Recommended_Actions__c.endsWith(';')) {
                            theCase.Recommended_Actions__c = theCase.Recommended_Actions__c.substr(
                                0,
                                theCase.Recommended_Actions__c.length - 1
                            );
                        }
                    }

                    if (component.get('v.RenderRecommendedActionOther')) {
                        theCase.Recommended_Actions_Other__c = component.get('v.RecommendedActionOther');
                    }

                    if (component.get('v.StudentsIntentions')) {
                        theCase.Student_Intention__c = component.get('v.StudentsIntentions');
                    }

                    if (
                        this.findByAuraId(component, 'notReturning') &&
                        this.findByAuraId(component, 'notReturning').get('v.value')
                    ) {
                        theCase.Reasons_Not_Returning__c = '';

                        for (let i = 0; i < this.findByAuraId(component, 'notReturning').get('v.value').length; i++) {
                            if (this.findByAuraId(component, 'notReturning').get('v.value')[i]) {
                                theCase.Reasons_Not_Returning__c +=
                                    this.findByAuraId(component, 'notReturning').get('v.value')[i] + ';';
                            }
                        }

                        if (theCase.Reasons_Not_Returning__c && theCase.Reasons_Not_Returning__c.endsWith(';')) {
                            theCase.Reasons_Not_Returning__c = theCase.Reasons_Not_Returning__c.substr(
                                0,
                                theCase.Reasons_Not_Returning__c.length - 1
                            );
                        }
                    }

                    if (component.get('v.RenderNotReturningOther')) {
                        theCase.Reasons_Not_Returning_Other__c = component.get('v.NotReturningOther');
                    }

                    if (component.get('v.StudentReturnTerm')) {
                        theCase.What_term_is_the_student_planning_to_ret__c = component.get('v.StudentReturnTerm');
                    }

                    if (component.get('v.StudentRisk')) {
                        theCase.Student_Presented_Risk_for__c = component.get('v.StudentRisk');
                    }

                    if (component.get('v.StudentRisk') === 'Other') {
                        theCase.Student_Presented_Risk_for_Other__c = component.get('v.StudentRiskOther');
                    }

                    casesToUpdate.push(theCase);
                }
            }
        }

        return casesToUpdate;
    },

    buildErrorMessage: function (errors) {
        let messageMap = new Map();

        if (errors) {
            for (let i = 0; i < errors.length; i++) {
                if (errors[i].pageErrors) {
                    for (let j = 0; errors[i].pageErrors && j < errors[i].pageErrors.length; j++) {
                        messageMap.set(errors[i].pageErrors[j].message, errors[i].pageErrors[j].message);
                    }
                }

                if (errors[i].fieldErrors) {
                    for (let fieldError in errors[i].fieldErrors) {
                        let thisFieldError = errors[i].fieldErrors[fieldError];
                        for (let j = 0; j < thisFieldError.length; j++) {
                            messageMap.set(thisFieldError[j].message, thisFieldError[j].message);
                        }
                    }
                }

                if (errors[i].message) {
                    messageMap.set(errors[i].message, errors[i].message);
                }
            }
        } else {
            messageMap.set('Unknown error', 'Unknown Error');
        }

        return Array.from(messageMap.values()).join('. ');
    },

    fireToast: function (title, message, type) {
        let lightningToast = $A.get('e.force:showToast');
        if (lightningToast !== undefined) {
            lightningToast.setParams({title: title, message: message, type: type}).fire();
        } else {
            $A.get('e.c:ShowClassicToast').setParams({title: title, message: message, type: type}).fire();
        }
    },

    resetComponentValues: function (component) {
        component.set('v.CaseStatus', '');
        component.set('v.ReasonsAdministrativelyClosed', '');
        component.set('v.RecommendedActionOther', '');
        component.set('v.StudentsIntentions', '');
        component.set('v.StudentReturnTerm', '');
        component.set('v.StudentRisk', '');
        component.set('v.StudentRiskOther', '');
        component.set('v.NotReturningOther', '');

        if (this.findByAuraId(component, 'recommendedActions')) {
            this.findByAuraId(component, 'recommendedActions').set('v.value', []);
        }

        if (this.findByAuraId(component, 'notReturning')) {
            this.findByAuraId(component, 'notReturning').set('v.value', []);
        }

        component.set('v.RenderRequireReasonsAdministrativelyClosed', false);
        component.set('v.RequireRecommendedAction', false);
        component.set('v.RequireStudentIntent', false);
        component.set('v.RenderRequireNotReturning', false);
        component.set('v.RequireReturnTerm', false);
        component.set('v.RequireStudentRisk', false);
        component.set('v.RenderRequireRecommendedActionOther', false);
        component.set('v.RenderRequireNotReturningOther', false);
        component.set('v.RenderRequireStudentRiskOther', false);
    },

    loadCustomMetadata: function (component) {
        // Names of component ids mapped to the variables that contain their options
        const componentIdToOptionsArrayName = {
            caseStatus: 'v.CaseStatusOptions',
            recommendedActions: 'v.RecommendedActionOptions',
            studentIntent: 'v.StudentsIntentionOptions',
            notReturning: 'v.NotReturningOptions',
            returnTerm: 'v.StudentReturnTermOptions',
            studentRisk: 'v.StudentRiskOptions',
        };

        let action = component.get('c.getCustomMetadata');
        action.setCallback(this, function (response) {
            if (response.getState() !== 'SUCCESS') {
                this.fireToast('Error', response.getError()[0].message, 'error');
                return;
            }

            let results = response.getReturnValue();

            let optionsStatus = [];
            let optionsIntent = [];
            let generatedRequirements = {};

            for (let key in results) {
                if (key == 'caseStatus') {
                    for (let key2 in results[key]) {
                        optionsStatus.push(key2);
                    }
                } else if (key == 'studentIntent') {
                    for (let key2 in results[key]) {
                        optionsIntent.push(key2);
                    }
                }

                generatedRequirements[key] = {};

                for (let key2 in results[key]) {
                    generatedRequirements[key][key2] = results[key][key2];
                }
            }

            component.set(componentIdToOptionsArrayName['caseStatus'], optionsStatus);
            component.set(componentIdToOptionsArrayName['studentIntent'], optionsIntent);
            component.set('v.DynamicallyGeneratedRequirements', generatedRequirements);
        });
        $A.enqueueAction(action);
    },

    findByAuraId: function (component, auraId) {
        let c = component.find(auraId);
        if (Array.isArray(c)) {
            if (c.length > 0) c = c[0];
            else c = null;
        }
        return c;
    },
});
