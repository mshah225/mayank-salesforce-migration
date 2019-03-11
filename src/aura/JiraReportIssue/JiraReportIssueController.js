({
    submitIssueForm : function (component, event, helper) {
        helper.validateRequiredFields(component);
	},
    
    navigateToIssue: function(component, event, helper) {
	    helper.navigateToIssue(component);
	}
})
