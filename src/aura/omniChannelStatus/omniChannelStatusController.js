({
    onLogout : function(component, event, helper) {
		component.set('v.loginStatus', false);
		helper.omniChannelService(component, 'logOutEvent');
	}, 
	onLoginSuccess : function(component, event, helper) {
		component.set('v.loginStatus', true);
		helper.omniChannelService(component, 'logInEvent');
    }
})