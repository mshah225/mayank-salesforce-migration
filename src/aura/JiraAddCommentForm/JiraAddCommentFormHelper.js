({
	submitForm : function(component) {
        var status = component.get("v.status");
        var questionOne = component.get("v.questionOne").replace("\n", "\\n");
        var questionTwo = component.get("v.questionTwo").replace("\n", "\\n");
        var questionThree = component.get("v.questionThree").replace("\n", "\\n");
        var questionFour = component.get("v.questionFour").replace("\n", "\\n");
        var answerOne = component.get("v.answerOne").replace("\n", "\\n");
        var answerTwo = component.get("v.answerTwo").replace("\n", "\\n");
        var answerThree = component.get("v.answerThree").replace("\n", "\\n");
    	var answerFour = component.get("v.answerFour").replace("\n", "\\n");
        var jiraKey = component.get("v.ticketKey");
        var action = component.get('c.submitForm');
        
        var ticketComment = questionOne + '\\n' + answerOne + '\\n'
        					+ questionTwo + '\\n' + answerTwo + '\\n'
        					+ questionThree + '\\n' + answerThree + '\\n'
        					+ questionFour + '\\n' + answerFour + '\\n';
        action.setParams({
            'ticketComment': ticketComment,
            'jiraKey' : jiraKey,
            'status' : status
        })
        $A.enqueueAction(action);
    }
})