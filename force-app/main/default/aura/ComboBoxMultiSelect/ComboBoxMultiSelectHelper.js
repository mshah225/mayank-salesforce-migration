({
    setCountSelected: function (component) {
        const value = component.get('v.value') == null ? '' : component.get('v.value');

        let countSelected = 0;
        // count number of semicolons
        if (value.length > 0) {
            countSelected = value.length - value.replaceAll(';', '').length + 1;
        }

        if (countSelected === 1) {
            component.find('multi-select-combobox').set('v.placeholder', countSelected + ' option selected');
        } else if (countSelected > 0) {
            component.find('multi-select-combobox').set('v.placeholder', countSelected + ' options selected');
        } else {
            component.find('multi-select-combobox').set('v.placeholder', '--Select--');
        }

        component.set('v.selectedOptionsCount', countSelected);
    },
});
