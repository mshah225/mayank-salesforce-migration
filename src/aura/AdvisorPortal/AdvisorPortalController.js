({
    populateContacts: function (component, event, helper) {
        helper.incrementProcessingCounter(component);
        let userOptions = [];
        let selectedOptions;

        if (event.getParam('viewAsOptions')) {
            selectedOptions = event.getParam('viewAsOptions');
            component.set('v.SelectedUserOptions', selectedOptions);
        } else {
            selectedOptions = component.get('v.AllUserOptions');
        }

        for (let key in selectedOptions) {
            if (selectedOptions.hasOwnProperty(key) && selectedOptions[key]) {
                userOptions.push(selectedOptions[key].value);
            }
        }

        let action = component.get('c.getPortalContactsForViewOptions');
        action.setParams({allUserOptions: userOptions});
        action.setCallback(this, function (result) {
            helper.decrementProcessingCounter(component);
            component.set('v.Contacts', result.getReturnValue());
            helper.filterContactsBySelectedOptions(component);
        });
        $A.enqueueAction(action);
    },

    filterContacts: function (component, event, helper) {
        helper.filterContactsBySelectedOptions(component);
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
});
