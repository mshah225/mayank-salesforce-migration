({
    getIssues: function (component) {
        var action = component.get('c.getIssuesForUser');
        var self = this;
        action.setCallback(this, function (actionResult) {
            component.set('v.myIssues', actionResult.getReturnValue());
        });
        $A.enqueueAction(action);
    },

    getWatchedIssues: function (component) {
        var action = component.get('c.getWatchedIssuesForUser');
        var self = this;
        action.setCallback(this, function (actionResult) {
            component.set('v.myWatchedIssues', actionResult.getReturnValue());
        });
        $A.enqueueAction(action);
    },

    handleStatusChange: function (component, event) {
        var issueKey = event.getParam('issueKey');
        var status = event.getParam('status');

        var myIssues = component.get('v.myIssues');
        myIssues.forEach(function (issue) {
            console.log(issue);
            if (issue.issueId == issueKey) {
                console.log(status);
                issue.status = status;
                component.set('v.myIssues', myIssues);
            }
        });

        var myWatchedIssues = component.get('v.myWatchedIssues');
        myWatchedIssues.forEach(function (issue) {
            console.log(issue);
            if (issue.issueId == issueKey) {
                console.log(status);
                issue.status = status;
                component.set('v.myWatchedIssues', myWatchedIssues);
            }
        });
    },
});
