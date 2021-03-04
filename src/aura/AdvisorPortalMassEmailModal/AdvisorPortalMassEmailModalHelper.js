({
    toggleEmailModal: function (component) {
        let contacts = component.get('v.Contacts');

        let hasSomethingSelected = false;
        for (let i = 0; i < contacts.length; i++) {
            if (hasSomethingSelected) {
                break;
            }

            hasSomethingSelected = contacts[i].isSelected;

            for (let j = 0; j < contacts[i].cases.length; j++) {
                if (contacts[i].cases[j].isSelected) {
                    hasSomethingSelected = true;
                    break;
                }
            }
        }

        if (!hasSomethingSelected) {
            this.fireToast('Error', 'Please select a case or contact first.', 'error');
            return;
        }

        $A.util.toggleClass(component.find('modalBackdrop'), 'slds-backdrop_open');
        $A.util.toggleClass(component.find('massEmailModal'), 'slds-fade-in-open');

        if ($A.util.hasClass(component.find('massEmailModal'), 'slds-fade-in-open')) {
            component.set('v.EmailSubject', '');
            component.set('v.EmailBody', '');
            component.set('v.FormError', '');
        }

        document.getElementById('massEmailBody').scrollTop = 0;
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
});
