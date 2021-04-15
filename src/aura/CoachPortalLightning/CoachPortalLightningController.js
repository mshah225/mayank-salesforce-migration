({
    doInit: function (component) {
        var workspaceAPI = component.find('workspace');
        window.addEventListener(
            'message',
            $A.getCallback(function (event) {
                var validOrigin = false;
                var messageValid = false;
                // Catchall to ensure coming from asu URL
                if (event.origin.substring(0, 11) == 'https://asu') {
                    validOrigin = true;
                }
                // List of valid messages and criteria for message
                if (
                    typeof event.data === 'string' &&
                    event.data.substring(0, 1) != '{' &&
                    (event.data.includes('/500/e?retURL=%2F0036300000AU5YZ&def_contact_id=') ||
                        event.data.includes('/lightning/r/Case/') ||
                        event.data.includes('/apex/successRecoding') ||
                        event.data.includes('/apex/StudentProfile?contactId='))
                ) {
                    messageValid = true;
                }
                if (validOrigin && messageValid) {
                    if (event.data.includes('/apex/StudentProfile?contactId=')) {
                        var contactId = event.data.substring(0, 18);
                        workspaceAPI
                            .openTab({
                                url: '/lightning/r/Contact/' + contactId + '/view',
                                focus: true,
                            })
                            .then(function (response) {
                                workspaceAPI.openSubtab({
                                    parentTabId: response,
                                    url: event.data.substring(18, event.length),
                                    focus: true,
                                });
                            })
                            .catch(function (error) {});
                    } else {
                        workspaceAPI.openTab({
                            url: event.data,
                            focus: true,
                        });
                    }
                } else {
                    return;
                }
            }),
            false
        );
    },
});
