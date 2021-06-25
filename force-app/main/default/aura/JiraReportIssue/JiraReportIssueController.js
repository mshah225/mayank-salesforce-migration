({
    submitIssueForm: function (component, event, helper) {
        helper.validateRequiredFieldsAndSubmitForm(component);
    },

    navigateToIssue: function (component, event, helper) {
        helper.navigateToIssue(component);
    },
});
