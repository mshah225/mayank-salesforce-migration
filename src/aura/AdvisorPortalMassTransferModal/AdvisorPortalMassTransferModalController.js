({
    toggleMassTransferModal: function (component, event, helper) {
        helper.toggleTransferModal(component);
    },

    handleViewAsOptions: function (component, event, helper) {
        component.set('v.ViewAsOptions', event.getParam('viewAsOptions'));
    },

    massTransfer: function (component, event, helper) {
        let casesToTransfer = [];
        component.set('v.FormError', '');
        let contacts = component.get('v.Contacts');
        event.getSource().set('v.disabled', true);

        if (!component.get('v.SelectedOwnerId')) {
            component.set('v.FormError', 'Please select a new Owner.');
            event.getSource().set('v.disabled', false);
            return;
        }

        for (let i = 0; i < contacts.length; i++) {
            if (contacts[i].isSelected) {
                for (let j = 0; j < contacts[i].cases.length; j++) {
                    if (contacts[i].cases[j].isSelected) {
                        casesToTransfer.push(contacts[i].cases[j].portalCase);
                    }
                }
            }
        }

        let action = component.get('c.transferCases');
        action.setParams({
            portalCases: casesToTransfer,
            ownerId: component.get('v.SelectedOwnerId').split(';').pop(),
        });
        action.setCallback(this, function (response) {
            if (response.getState() !== 'SUCCESS') {
                helper.fireToast('Error', helper.buildErrorMessage(response.getError()), 'error');
                event.getSource().set('v.disabled', false);
                return;
            }

            helper.fireToast('', 'Case(s) Successfully Transferred.', 'success');
            component.set('v.SelectedOwnerId', '');
            component.set('v.FormError', '');
            helper.toggleTransferModal(component);
            event.getSource().set('v.disabled', false);
            $A.get('e.c:RefreshAdvisorPortalContacts').fire();
        });
        $A.enqueueAction(action);
    },

    toggleDropdown: function (component, event, helper) {
        helper.toggleDropdown(component);
    },

    hideDropdown: function (component) {
        window.setTimeout(
            $A.getCallback(function () {
                $A.util.removeClass(component.find('combobox-drop').getElement(), 'slds-is-open');
            }),
            150
        );
    },

    toggleOption: function (component, event, helper) {
        let selectedId = event.currentTarget.getAttribute('data-optionId');

        if (selectedId) {
            let viewAsOptions = component.get('v.ViewAsOptions');

            for (let i = 0, len = viewAsOptions.length; i < len; i++) {
                if (viewAsOptions[i].label + ';' + viewAsOptions[i].value === selectedId) {
                    viewAsOptions[i].isSelected = true;
                    component.set('v.SelectedLabel', viewAsOptions[i].label);
                    component.set('v.SelectedOwnerId', viewAsOptions[i].value);
                } else if (viewAsOptions[i].isSelected) {
                    viewAsOptions[i].isSelected = false;
                }
            }

            component.set('v.ViewAsOptions', viewAsOptions);
            helper.toggleDropdown(component);
        }
    },
});
