({
    toggleModal: function (component, event, helper) {
        var modal = component.find('qaModal');
        $A.util.toggleClass(modal, 'hideModal');
    },

    doInit: function (component, event, helper) {
        helper.removeUnusedQuestions(component);
    },

    submitModal: function (component, event, helper) {
        var modal = component.find('qaModal');
        helper.submitForm(component);
        $A.util.toggleClass(modal, 'hideModal');
    },
});
