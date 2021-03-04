({
    closeDropdown: function (component, event, helper) {
        window.setTimeout(
            $A.getCallback(function () {
                $A.util.removeClass(component.find('combobox-drop').getElement(), 'slds-is-open');
            }),
            150
        );
    },

    toggleDropdown: function (component, event, helper) {
        $A.util.toggleClass(component.find('combobox-drop').getElement(), 'slds-is-open');

        if (!$A.util.hasClass(component.find('combobox-drop').getElement(), 'slds-is-open')) {
            helper.setCountSelected(component);
        } else {
            component.set('v.value', '');
        }
    },

    toggleOption: function (component, event, helper) {
        event.preventDefault();
        let selectedId = event.currentTarget.getAttribute('data-optionId');

        if (selectedId) {
            let options = component.get('v.options');
            let selectedOptions = [];

            for (let i = 0, len = options.length; i < len; i++) {
                if (options[i].label + ';' + options[i].value === selectedId) {
                    options[i].isSelected = !options[i].isSelected;
                }

                if (options[i].isSelected) {
                    selectedOptions.push(options[i].value.toLowerCase());
                }
            }

            component.set('v.options', options);
            component.set('v.value', selectedOptions.join(';'));
            component.set('v.selectedOptions', selectedOptions);
            helper.setCountSelected(component);
        }
    },

    resetOptions: function (component, event, helper) {
        component.set('v.selectedOptions', []);
        helper.setCountSelected(component);
    },

    clearOptions: function (component, event, helper) {
        let options = component.get('v.options');

        for (let i = 0, len = options.length; i < len; i++) {
            options[i].isSelected = false;
        }

        component.set('v.options', options);
        component.set('v.value', '');
        component.set('v.placeholder', '--Select--');
        component.set('v.selectedOptions', []);
    },
});
