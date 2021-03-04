({
    handleShowToast: function (component, event, helper) {
        clearTimeout(component.get('v.timer'));
        component.set('v.message', event.getParam('message'));
        component.set('v.type', event.getParam('type'));

        if (event.getParam('title')) {
            component.set('v.title', event.getParam('title'));
        }

        if (event.getParam('duration')) {
            component.set('v.duration', event.getParam('duration'));
        }

        let timer = window.setTimeout(
            $A.getCallback(function () {
                clearTimeout(timer);
                component.set('v.showToast', false);
            }),
            component.get('v.duration')
        );

        component.set('v.showToast', true);
        component.set('v.timer', timer);
    },

    hideToast: function (component) {
        component.set('v.showToast', false);
    },
});
