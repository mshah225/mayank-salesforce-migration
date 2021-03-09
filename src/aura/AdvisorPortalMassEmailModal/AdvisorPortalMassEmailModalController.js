({
    loadUserDetail: function (component, event, helper) {
        var action = component.get('c.fetchUser');
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var storeResponse = response.getReturnValue();
                component.set('v.userInfo', storeResponse);
            }
        });
        $A.enqueueAction(action);
    },

    toggleMassEmailModal: function (component, event, helper) {
        helper.toggleEmailModal(component);

        // Load all selected cases/contacts into map attribute
        // and count number of emails about to send
        let contacts = component.get('v.Contacts');
        let contactToCaseToEmailMapping = new Map();
        let count = 0;
        for (let i = 0; i < contacts.length; i++) {
            let hasSomethingSelected = contacts[i].isSelected;

            let casesForThisContact = [];
            for (let j = 0; j < contacts[i].cases.length; j++) {
                if (contacts[i].cases[j].isSelected) {
                    casesForThisContact.push(contacts[i].cases[j].portalCase);
                    hasSomethingSelected = true;
                }
            }

            if (hasSomethingSelected) {
                contactToCaseToEmailMapping.set(contacts[i].portalContact.Id, casesForThisContact);
                if (casesForThisContact.length == 0) {
                    count += 1;
                } else {
                    count += casesForThisContact.length;
                }
            }
        }
        component.set('v.SendEmailsToMap', contactToCaseToEmailMapping);
        if (count == 1) {
            component.set('v.sendLabel', 'Send (' + count + ' Email)');
        } else {
            component.set('v.sendLabel', 'Send (' + count + ' Emails)');
        }
    },

    massEmailPreview: function (component, event, helper) {
        let isValid = true;
        component.set('v.FormError', '');
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

        // Only supports one template right now, so hardcode details
        let subject = component.get('v.EmailSubject');

        let body = 'Dear StudentFirstName,\n\n';
        body += component.get('v.EmailBody');
        body += '\n\nSincerely,\n' + component.get('v.userInfo').Name;

        component.set('v.EmailPreviewSubject', subject);
        component.set('v.EmailPreviewBody', body);
    },
    massEmailUnPreview: function (component, event, helper) {
        component.set('v.EmailPreviewSubject', '');
        component.set('v.EmailPreviewBody', '');
    },

    massEmail: function (component, event, helper) {
        let isValid = true;
        component.set('v.FormError', '');
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

        // Tranform to format the Apex expects Maps to be
        let contactToCaseToEmailMapping = component.get('v.SendEmailsToMap');
        let apexMap = {};
        for (var key of contactToCaseToEmailMapping.keys()) {
            apexMap[key] = Object.assign([], contactToCaseToEmailMapping.get(key));
        }

        let action = component.get('c.createPortalEmails');
        action.setParams({
            contactIdToCasesMap: apexMap,
            subject: component.get('v.EmailSubject'),
            body: component.get('v.EmailBody'),
        });
        action.setCallback(this, function (response) {
            if (response.getState() !== 'SUCCESS') {
                helper.fireToast('Error', helper.buildErrorMessage(response.getError()), 'error');
                event.getSource().set('v.disabled', false);
                return;
            }

            helper.fireToast('Success', 'Email message(s) sent.', 'success');
            component.set('v.EmailSubject', '');
            component.set('v.EmailBody', '');
            component.set('v.FormError', '');
            helper.toggleEmailModal(component);
            event.getSource().set('v.disabled', false);
        });
        $A.enqueueAction(action);
    },
});
