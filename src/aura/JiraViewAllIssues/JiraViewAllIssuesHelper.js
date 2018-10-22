({
	getIssues : function(component) {
        var action = component.get("c.getIssuesForUser");
        var self = this;
        action.setCallback(this, function(actionResult) {
            component.set("v.myIssues", actionResult.getReturnValue());
        });
        $A.enqueueAction(action);   
    },
    
    getWatchedIssues : function(component) {
        var action = component.get("c.getWatchedIssuesForUser");
        var self = this;
        action.setCallback(this, function(actionResult) {
            component.set("v.myWatchedIssues", actionResult.getReturnValue());
        });
        $A.enqueueAction(action);   
    }
})