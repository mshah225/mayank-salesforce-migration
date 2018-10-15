({
    submitIssueForm : function (component, event, helper) {
        var title = component.get("v.title");
        var questionOne = component.get("v.questionOne");
        var questionTwo = component.get("v.questionTwo");
        var questionThree = component.get("v.questionThree");
        var answerOne = component.get("v.answerOne").replace("\n", "\\n");
        var answerTwo = component.get("v.answerTwo").replace("\n", "\\n");
        var answerThree = component.get("v.answerThree").replace("\n", "\\n");
        var watchers = component.get("v.watchers");
        var type = component.get("v.type");
       	var action= component.get('c.callout');
        
        var problemDescription = questionOne + '\\n' + answerOne + '\\n'
        					+ questionTwo + '\\n' + answerTwo + '\\n'
        					+ questionThree + '\\n' + answerThree + '\\n';
        action.setParams({
            'title': title,
            'description': problemDescription,
            'watchers' : watchers,
            'type' : type
        })
        action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            var key = response.getReturnValue();
            component.set("v.message","Jira Issue Successfully Created");
            var link = "Created Issue: https://asudev.jira.com/browse/" + key;
            component.set("v.link", link);
            window.setTimeout(
                $A.getCallback(function() {
                    helper.clearForm(component,event,helper);
            	}), 10000
        	);
        }
      });
      $A.enqueueAction(action);
	}
})