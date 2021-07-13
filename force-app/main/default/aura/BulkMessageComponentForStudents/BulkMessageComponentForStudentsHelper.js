({
    fetchData: function (component, coachId) {
        var action = component.get('c.studentList');
        action.setParams({
            userId: coachId,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var studentResult = response.getReturnValue();
                if (!action.getParam('userId')) {
                    // settings list of coaches only when the success coach id is not defined.
                    component.set('v.coachList', studentResult.coaches);
                }
                if (studentResult) {
                    component.set('v.studentWrapperResult', studentResult);
                    if (studentResult.students && studentResult.students.length === 0) {
                        component.set('v.errorMessage', 'No Students found');
                    }
                }
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('Error message: ' + errors[0].message);
                    }
                } else {
                    console.log('Unknown error');
                }
            }
        });
        $A.enqueueAction(action);
    },
});
