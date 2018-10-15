({
	submitForm : function(component) {
        var status = component.get("v.status");
        var questionOne = component.get("v.questionOne");
        var questionTwo = component.get("v.questionTwo");
        var questionThree = component.get("v.questionThree");
        var questionFour = component.get("v.questionFour");
        var questionFive = component.get("v.questionFive");
        var questionSix = component.get("v.questionSix");
        var answerOne = component.get("v.answerOne");
        var answerTwo = component.get("v.answerTwo");
        var answerThree = component.get("v.answerThree");
    	var answerFour = component.get("v.answerFour");
        var answerFive = component.get("v.answerFive");
        var answerSix = component.get("v.answerSix");
        var jiraKey = component.get("v.ticketKey");
        var action = component.get('c.submitForm');
        var ticketComment = "";
        
        if (questionOne != undefined && answerOne != undefined) {
            ticketComment += questionOne + '\\n' + answerOne.replace('\n', "\\n") + '\\n';
        }
        if (questionTwo != undefined && answerTwo != undefined) {
            ticketComment += questionTwo + '\\n' + answerTwo.replace('\n', "\\n") + '\\n';
        }
        if (questionThree != undefined && answerThree != undefined) {
            ticketComment += questionThree + '\\n' + answerThree.replace('\n', "\\n") + '\\n';
        }
        if (questionFour != undefined && answerFour != undefined) {
            ticketComment += questionFour + '\\n' + answerFour.replace('\n', "\\n") + '\\n';
        }
        if (questionFive != undefined && !answerFive != undefined) {
            ticketComment += questionFive + '\\n' + answerFive.replace('\n', "\\n") + '\\n';
        }
        if (questionSix != undefined && answerSix != undefined) {
            ticketComment += questionSix + '\\n' + answerSix.replace('\n', "\\n") + '\\n';
        }
        action.setParams({
            'ticketComment': ticketComment,
            'jiraKey' : jiraKey,
            'status' : status
        })
        $A.enqueueAction(action);
    },
    
    removeUnusedQuestions : function (component) {
        if (component.get("v.questionOne") == undefined) {
            var question = component.find("questionOne").destroy();
        }
        if (component.get("v.questionTwo") == undefined) {
            var question = component.find("questionTwo").destroy();
        }
        if (component.get("v.questionThree") == undefined) {
            var question = component.find("questionThree").destroy();
        }
        if (component.get("v.questionFour") == undefined) {
            var question = component.find("questionFour").destroy();
        }
        if (component.get("v.questionFive") == undefined) {
            var question = component.find("questionFive").destroy();
        }
        if (component.get("v.questionSix") == undefined) {
            var question = component.find("questionSix").destroy();
        }
    }
})