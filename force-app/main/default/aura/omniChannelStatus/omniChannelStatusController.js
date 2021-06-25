({
    /*doInit: function (component, event, helper) {
        console.log('doinit of omnistatus');
		var workspaceAPI = component.find("workspace");
		workspaceAPI.getFocusedTabInfo().then(function (response) {
			if (!response)
				return;
			component.set('v.selectedTabId', response.tabId);
		})
			.catch(function (error) {
				console.log(error);
			});
	}, */
    onLogout: function (component, event, helper) {
        component.set('v.loginStatus', false);
        helper.omniChannelService(component, 'logOutEvent');
        var utilityAPI = cmp.find('utilitybar');
        utilityAPI.setUtilityHighlighted({highlighted: true});
    },
    onLoginSuccess: function (component, event, helper) {
        component.set('v.loginStatus', true);
        helper.omniChannelService(component, 'logInEvent');
        var utilityAPI = cmp.find('utilitybar');
        utilityAPI.setUtilityHighlighted({highlighted: false});
    },
    onAccept: function (component, event, helper) {
        var loginStatus = component.get('v.loginStatus');
        var primaryTabName = 'Contact';
        if (loginStatus) {
            sforce.console.focusPrimaryTabByName(primaryTabName, focusSuccess);
        }
        var focusSuccess = function focusSuccess(result) {
            //Report whether going to the primary tab was successful
            if (result.success == true) {
                alert('Going to the primary tab was successful');
            } else {
                alert('Going to the Primary tab was not successful');
            }
        };
    },
});
