({
    submitIssueForm: function (component) {
        var submitButton = component.find('submitButton');
        submitButton.set('v.disabled', true);

        var title = component.get('v.title').replace(/\n/g, ' ').replace(new RegExp('"', 'g'), '\\"');
        var questionOne = component.get('v.questionOne');
        var questionTwo = component.get('v.questionTwo');
        var questionThree = component.get('v.questionThree');
        var answerOne = component.get('v.answerOne').replace(/\n/g, '\\n').replace(new RegExp('"', 'g'), '\\"');
        var answerTwo = component.get('v.answerTwo').replace(/\n/g, '\\n').replace(new RegExp('"', 'g'), '\\"');
        var answerThree = component.get('v.answerThree').replace(/\n/g, '\\n').replace(new RegExp('"', 'g'), '\\"');
        var watchers = component.get('v.watchers');
        var requestForm = component.get('v.requestForm');
        var type = component.get('v.type');

        var problemDescription =
            '*' + questionOne + '*' +
            '\\n' +
            answerOne +
            '\\n\\n' +
            '*' + questionTwo + '*' +
            '\\n' +
            answerTwo +
            '\\n\\n' +
            '*' + questionThree + '*' +
            '\\n' +
            answerThree +
            '\\n\\n';

        if (requestForm != undefined) {
            problemDescription += 'Request Form: ' + '\\n' + requestForm + '\\n';
        }

        var action = component.get('c.callout');
        action.setParams({
            title: title,
            description: problemDescription,
            watchers: watchers,
            type: type,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS' && response.getReturnValue() != null) {
                var key = response.getReturnValue();
                component.set('v.message', 'Jira Issue Successfully Created');
                var link = 'https://asudev.jira.com/browse/' + key;
                component.set('v.link', link);
                component.set('v.displayLink', true);
                this.clearInputs(component);
            } else {
                component.set(
                    'v.message',
                    'Cannot create JIRA ticket, please email your request to salesforce.development@asu.edu'
                );
            }
            submitButton.set('v.disabled', false);
        });
        $A.enqueueAction(action);
    },

    clearInputs: function (component) {
        component.set('v.title', '');
        component.set('v.answerOne', '');
        component.set('v.answerTwo', '');
        component.set('v.answerThree', '');
        component.set('v.watchers', '');
        component.set('v.requestForm', '');
    },

    navigateToIssue: function (component) {
        var navigate = $A.get('e.force:navigateToURL');
        navigate.setParams({url: component.get('v.link')});
        navigate.fire();
    },

    validateRequiredFieldsAndSubmitForm: function (component) {
        var questionOneValue = component.find('questionOneResponse').get('v.value');
        var questionTwoValue = component.find('questionTwoResponse').get('v.value');
        var questionThreeValue = component.find('questionThreeResponse').get('v.value');
        var descriptionValue = component.find('descriptionResponse').get('v.value');
        var errorFound = 0;

        errorFound += this.checkForErrors(component.find('questionOneResponse'));
        errorFound += this.checkForErrors(component.find('questionTwoResponse'));
        errorFound += this.checkForErrors(component.find('questionThreeResponse'));
        errorFound += this.checkForErrors(component.find('descriptionResponse'));

        if (errorFound <= 0) {
            this.submitIssueForm(component);
        } else {
            component.set('v.message', 'Please complete the required forms below!');
        }
    },

    checkForErrors: function (componentName) {
        if (!componentName.get('v.value')) {
            $A.util.addClass(componentName, 'slds-has-error');
            return 1;
        } else {
            $A.util.removeClass(componentName, 'slds-has-error');
            return 0;
        }
    },
});
