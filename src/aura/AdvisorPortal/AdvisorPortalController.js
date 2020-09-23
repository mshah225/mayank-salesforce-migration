({
    populateContacts: function (component, event, helper) {
        component.set('v.isProcessing', true);
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
            component.set('v.isProcessing', false);
            component.set('v.Contacts', result.getReturnValue());
            helper.filterContactsBySelectedOptions(component);
        });
        $A.enqueueAction(action);
    },

    filterContacts: function (component, event, helper) {
        helper.filterContactsBySelectedOptions(component);
    },
});
