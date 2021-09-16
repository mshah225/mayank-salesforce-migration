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
        }
    },

    toggleOption: function (component, event, helper) {
        event.preventDefault();
        const toggleValue = event.currentTarget.getAttribute('data-value').toLowerCase();
        const value = (component.get('v.value') == null ? '' : component.get('v.value')).toLowerCase();

        let splitValues = [];
        if (value.length > 0) {
            splitValues = value.split(';');
        }

        if (toggleValue) {
            if (splitValues.includes(toggleValue)) {
                let indx = splitValues.indexOf(toggleValue);
                if (indx > -1) {
                    splitValues.splice(indx, 1);
                }
            } else {
                splitValues.push(toggleValue);
            }

            component.set('v.value', splitValues.join(';'));
        }
    },

    selectOptionsInValue: function (component, event, helper) {
        const options = component.get('v.options');
        const selectedValues = (component.get('v.value') == null ? '' : component.get('v.value'))
            .toLowerCase()
            .split(';');

        for (let i = 0, len = options.length; i < len && options[0]; i++) {
            if (selectedValues.includes(options[i].value.toLowerCase())) {
                options[i].isSelected = true;
            } else {
                options[i].isSelected = false;
            }
        }

        component.set('v.innerChangeLock', true);
        component.set('v.options', options);
        component.set('v.innerChangeLock', false);
        helper.setCountSelected(component);
    },

    resetOptions: function (component, event, helper) {
        if (!component.get('v.innerChangeLock')) {
            const options = component.get('v.options');
            const selectedValues = (component.get('v.value') == null ? '' : component.get('v.value'))
                .toLowerCase()
                .split(';');
            const newValues = [];

            for (let i = 0, len = options.length; i < len && options[0]; i++) {
                if (selectedValues.includes(options[i].value.toLowerCase())) {
                    options[i].isSelected = true;
                    newValues.push(options[i].value);
                } else {
                    options[i].isSelected = false;
                }
            }

            component.get('v.value', newValues.join(';').toLowerCase());
            helper.setCountSelected(component);
        }
    },

    clearOptions: function (component, event, helper) {
        let options = component.get('v.options');

        for (let i = 0, len = options.length; i < len; i++) {
            options[i].isSelected = false;
        }

        component.set('v.options', options);
        component.set('v.value', '');
        component.set('v.placeholder', '--Select--');
    },
});
