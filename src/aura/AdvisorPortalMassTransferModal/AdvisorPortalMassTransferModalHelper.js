({
    toggleTransferModal: function (component) {
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

        $A.util.toggleClass(component.find('modalBackdrop'), 'slds-backdrop_open');
        $A.util.toggleClass(component.find('massTransferModal'), 'slds-fade-in-open');

        if ($A.util.hasClass(component.find('massTransferModal'), 'slds-fade-in-open')) {
            component.set('v.SelectedOwnerId', '');
            component.set('v.SelectedLabel', '--Select--');
            component.set('v.FormError', '');
            component.get('v.ViewAsOptions');

            let viewAsOptions = component.get('v.ViewAsOptions');
            for (let i = 0, len = viewAsOptions.length; i < len; i++) {
                viewAsOptions[i].isSelected = false;
            }
            component.set('v.ViewAsOptions', viewAsOptions);
        }

        document.getElementById('massTransferBody').scrollTop = 0;
        document.getElementById('transferToDropdownList').scrollTop = 0;
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

    toggleDropdown: function (component) {
        $A.util.toggleClass(component.find('combobox-drop').getElement(), 'slds-is-open');
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
