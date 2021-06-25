({
    setCountSelected: function (component) {
        let countSelected = component.get('v.selectedOptions').length;

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
