/**
 * @File Name          : AdvisorPortalHelper.js
 * @Description        :
 * @Author             :
 * @Group              :
 * @Last Modified By   : thom.clark@sierra-cedar.com
 * @Last Modified On   : 10/17/2019, 1:58:18 PM
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0                                               Initial Version
 **/
({
    filterContactsBySelectedOptions: function (component) {
        let contacts = component.get('v.Contacts');

        if (contacts && contacts.length > 0) {
            let selectedIds = [];
            let selectedContacts = [];
            let selectedOptions = component.get('v.SelectedUserOptions');

            for (let key in selectedOptions) {
                if (selectedOptions.hasOwnProperty(key) && selectedOptions[key] && selectedOptions[key].value) {
                    selectedIds.push(selectedOptions[key].value);
                }
            }

            for (let i = 0, len = contacts.length; i < len; i++) {
                let addContact = false;

                if (contacts[i].portalContact.Success_Students__r) {
                    for (let j = 0, len = contacts[i].portalContact.Success_Students__r.length; j < len; j++) {
                        if (contacts[i].portalContact.Success_Students__r[j].Success_Pod__c) {
                            if (
                                selectedIds.includes(
                                    contacts[i].portalContact.Success_Students__r[j].Success_Pod__r.OwnerId
                                )
                            ) {
                                addContact = true;
                                break;
                            }
                        }
                    }
                }

                if (contacts[i].cases && !addContact) {
                    for (let j = 0, len = contacts[i].cases.length; j < len; j++) {
                        if (selectedIds.includes(contacts[i].cases[j].portalCase.OwnerId)) {
                            addContact = true;
                            break;
                        }
                    }
                }

                if (addContact) {
                    selectedContacts.push(contacts[i]);
                }
            }

            component.set('v.ContactsInView', selectedContacts);
        }
    },
    incrementProcessingCounter: function (component, event, helper) {
        let currentValue = component.get('v.processingCounter');
        let newValue = currentValue + 1;

        component.set('v.processingCounter', newValue);
        component.set('v.isProcessing', newValue !== 0);
    },
    decrementProcessingCounter: function (component, event, helper) {
        let currentValue = component.get('v.processingCounter');
        let newValue = currentValue - 1;

        component.set('v.processingCounter', newValue);
        component.set('v.isProcessing', newValue !== 0);
    },
});
