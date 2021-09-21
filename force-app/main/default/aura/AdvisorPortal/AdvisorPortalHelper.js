({
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
    updateViewAsOptions: function (component, event, helper) {
        helper.incrementProcessingCounter(component);
        let selectedOptions;

        if (event.getParam('viewAsUsersList')) {
            selectedOptions = event.getParam('viewAsUsersList');
        } else {
            selectedOptions = component.get('v.AllUserOptions');
        }

        component.set('v.SelectedUserOptions', selectedOptions);

        helper.decrementProcessingCounter(component);
    },
    showToast: function (component, title, body, type, duration) {
        duration = duration == null ? 5000 : duration;
        component.find('lightningToast').fireParams(title, body, type, duration);
    },
});
