({
    doInit: function (component, event, helper) {
        helper.getIssues(component);
        helper.getWatchedIssues(component);
    },

    openTest: function (component, event, helper) {
        $A.createComponent(
            'c:JiraAddCommentForm',
            {
                'aura:id': 'findableAuraId',
                'ticketKey': event.target.getAttribute('name'),
                'questionOne': 'What environment will be used for testing?',
                'questionTwo': 'Test plan (including test cases):',
                'questionThree': 'Tester(s):',
                'questionFour': 'What configuration changes need to be made?',
                'status': 'In Testing',
                'modalHeader': 'Testing Form for ' + event.target.getAttribute('name'),
            },
            function (newModal, status, errorMessage) {
                if (status === 'SUCCESS') {
                    var body = component.get('v.body');
                    body.push(newModal);
                    component.set('v.body', body);
                } else if (status === 'INCOMPLETE') {
                    console.log('No response from server or client is offline.');
                } else if (status === 'ERROR') {
                    console.log('Error: ' + errorMessage);
                }
            }
        );
    },

    openSecondTech: function (component, event, helper) {
        $A.createComponent(
            'c:JiraAddCommentForm',
            {
                'aura:id': 'findableAuraId',
                'ticketKey': event.target.getAttribute('name'),
                'questionOne': 'Brief summary of the changes:',
                'questionTwo': 'What were the test cases?',
                'questionThree': 'Name of admin who tested and signed off:',
                'questionFour': 'Name of stakeholder representative who signed off:',
                'questionFive': 'What metadata needs to be migrated?',
                'questionSix': 'What configuration and security changes need to be made before or after deploy?',
                'status': 'Technical Review',
                'modalHeader': 'Tech Form for ' + event.target.getAttribute('name'),
            },
            function (newModal, status, errorMessage) {
                if (status === 'SUCCESS') {
                    var body = component.get('v.body');
                    body.push(newModal);
                    component.set('v.body', body);
                } else if (status === 'INCOMPLETE') {
                    console.log('No response from server or client is offline.');
                } else if (status === 'ERROR') {
                    console.log('Error: ' + errorMessage);
                }
            }
        );
    },

    handleStatusChange: function (component, event, helper) {
        helper.handleStatusChange(component, event);
    },
});
