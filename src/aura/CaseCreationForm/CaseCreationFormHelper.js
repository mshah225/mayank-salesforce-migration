({
    validateAndCreateCase: function (component) {
        var submitButton = component.find('submitButton');
        submitButton.set('v.disabled', true);

        var caseSubject;
        var caseDescription;

        var caseCar = component.get('v.caseAssignmentRule');

        var defaultSubject = component.get('v.usingDefaultSubject');
        if (defaultSubject) {
            caseSubject = component.get('v.defaultSubject');
        } else {
            caseSubject = component.get('v.providedSubject');
        }

        var defaultDescription = component.get('v.usingDefaultDescription');
        if (defaultDescription) {
            caseDescription = component.get('v.defaultDescription');
        } else {
            caseDescription = component.get('v.providedDescription');
        }

        var action = component.get('c.createFeedbackCase');
        action.setParams({
            carName: caseCar,
            subject: caseSubject,
            description: caseDescription,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS' && response.getReturnValue() != null) {
                var key = response.getReturnValue();
                this.clearInputs(component);
                component.set('v.message', 'Case was successfully created!');
            } else {
                component.set('v.message', 'Failed to Create the Case.');
            }
            submitButton.set('v.disabled', false);
        });
        $A.enqueueAction(action);
    },

    clearInputs: function (component) {
        component.set('v.providedSubject', '');
        component.set('v.providedDescription', '');
    },
});
