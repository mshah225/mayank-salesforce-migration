({
    toggleMassEmailModal: function (component, event, helper) {
        helper.toggleEmailModal(component);
    },

    massEmail: function (component, event, helper) {
        let contactToCaseToEmailMapping = new Map();
        let isValid = true;
        component.set('v.FormError', '');
        let contacts = component.get('v.Contacts');
        event.getSource().set('v.disabled', true);

        if (!component.get('v.EmailSubject')) {
            isValid = false;
        }

        if (!component.get('v.EmailBody')) {
            isValid = false;
        }

        if (!isValid) {
            component.set('v.FormError', 'Please fill out all required fields.');
            event.getSource().set('v.disabled', false);
            return;
        }

        for (let i = 0; i < contacts.length; i++) {
            if (contacts[i].isSelected) {
                let casesForThisContact = [];
                for (let j = 0; j < contacts[i].cases.length; j++) {
                    if (contacts[i].cases[j].isSelected) {
                        casesForThisContact.push(contacts[i].cases[j].portalCase);
                    }
                }
                contactToCaseToEmailMapping.set(contacts[i].portalContact.Id, casesForThisContact);
            }
        }

        // Tranform to format the Aura expects Maps to be
        let auraMap = {};
        for (var key of contactToCaseToEmailMapping.keys()) {
            auraMap[key] = contactToCaseToEmailMapping.get(key);
        }

        let action = component.get('c.createPortalEmails');
        action.setParams({
            contactIdToCasesMap: auraMap,
            subject: component.get('v.EmailSubject'),
            body: component.get('v.EmailBody'),
        });
        action.setCallback(this, function (response) {
            if (response.getState() !== 'SUCCESS') {
                helper.fireToast('Error', helper.buildErrorMessage(response.getError()), 'error');
                event.getSource().set('v.disabled', false);
                return;
            }

            helper.fireToast('', 'Email message(s) sent.', 'success');
            component.set('v.EmailSubject', '');
            component.set('v.EmailBody', '');
            component.set('v.FormError', '');
            helper.toggleEmailModal(component);
            event.getSource().set('v.disabled', false);
        });
        $A.enqueueAction(action);
    },
});
