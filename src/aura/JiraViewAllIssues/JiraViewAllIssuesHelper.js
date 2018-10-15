({
	getIssues : function(component) {
        var action = component.get("c.getIssuesForUser");
        var self = this;
        action.setCallback(this, function(actionResult) {
            component.set("v.myIssues", actionResult.getReturnValue());
        });
        $A.enqueueAction(action);   
    }
})