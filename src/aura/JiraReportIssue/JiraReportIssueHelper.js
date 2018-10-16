({
    submitIssueForm : function (component) {
        var title = component.get("v.title");
        var questionOne = component.get("v.questionOne");
        var questionTwo = component.get("v.questionTwo");
        var questionThree = component.get("v.questionThree");
        var answerOne = component.get("v.answerOne").replace("\n", "\\n");
        var answerTwo = component.get("v.answerTwo").replace("\n", "\\n");
        var answerThree = component.get("v.answerThree").replace("\n", "\\n");
        var watchers = component.get("v.watchers");
        var type = component.get("v.type");
        
        var problemDescription = questionOne + '\\n' + answerOne + '\\n'
        					+ questionTwo + '\\n' + answerTwo + '\\n'
        					+ questionThree + '\\n' + answerThree + '\\n';
        
       	var action= component.get('c.callout');
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
        } else {
            component.set("v.message","Jira Issue could not be created!");
        }
      });
      $A.enqueueAction(action);
	}
})