({
    omniChannelService: function (component, eventName) {
        var loginStatus = component.get('v.loginStatus');
        var outOfOfficeMessage = component.get('v.outOfOfficeMessage');

        var action = component.get('c.updateOmniChannelInfo');
        action.setParams({
            loginStatus: loginStatus,
            outOfOfficeMessage: outOfOfficeMessage,
        });

        action.setCallback(this, function (response) {
            //No action is required so commenting below code.
            // var state = response.getState();
            // if (state === "SUCCESS") {
            // }
        });
        $A.enqueueAction(action);
    },
});
