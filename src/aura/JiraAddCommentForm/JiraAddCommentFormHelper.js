({
    submitForm: function (component) {
        var status = component.get('v.status');
        var questionOne = component.get('v.questionOne');
        var questionTwo = component.get('v.questionTwo');
        var questionThree = component.get('v.questionThree');
        var questionFour = component.get('v.questionFour');
        var questionFive = component.get('v.questionFive');
        var questionSix = component.get('v.questionSix');
        var answerOne = component.get('v.answerOne');
        var answerTwo = component.get('v.answerTwo');
        var answerThree = component.get('v.answerThree');
        var answerFour = component.get('v.answerFour');
        var answerFive = component.get('v.answerFive');
        var answerSix = component.get('v.answerSix');
        var jiraKey = component.get('v.ticketKey');

        var ticketComment = '';
        ticketComment += this.addToTicketComment(questionOne, answerOne);
        ticketComment += this.addToTicketComment(questionTwo, answerTwo);
        ticketComment += this.addToTicketComment(questionThree, answerThree);
        ticketComment += this.addToTicketComment(questionFour, answerFour);
        ticketComment += this.addToTicketComment(questionFive, answerFive);
        ticketComment += this.addToTicketComment(questionSix, answerSix);

        var action = component.get('c.submitForm');
        action.setParams({
            ticketComment: ticketComment,
            jiraKey: jiraKey,
            status: status,
        });
        $A.enqueueAction(action);
        var statusChange = component.getEvent('statusChange');
        statusChange.setParams({
            status: status,
            issueKey: jiraKey,
        });
        statusChange.fire();
    },

    addToTicketComment: function (question, answer, comment) {
        if (question != undefined && answer != undefined) {
            return question + '\\n' + answer.replace(/[\r\n]/g, '\\r').replace(new RegExp('"', 'g'), '\\"') + '\\n';
        } else {
            return '';
        }
    },

    removeUnusedQuestions: function (component) {
        if (component.get('v.questionOne') == undefined) {
            var question = component.find('questionOne').destroy();
        }
        if (component.get('v.questionTwo') == undefined) {
            var question = component.find('questionTwo').destroy();
        }
        if (component.get('v.questionThree') == undefined) {
            var question = component.find('questionThree').destroy();
        }
        if (component.get('v.questionFour') == undefined) {
            var question = component.find('questionFour').destroy();
        }
        if (component.get('v.questionFive') == undefined) {
            var question = component.find('questionFive').destroy();
        }
        if (component.get('v.questionSix') == undefined) {
            var question = component.find('questionSix').destroy();
        }
    },
});
