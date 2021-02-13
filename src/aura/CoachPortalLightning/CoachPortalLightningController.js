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
                // List of valid messages
                if (
                    event.data.includes('/500/e?retURL=%2F0036300000AU5YZ&def_contact_id=') ||
                    event.data.includes('/lightning/r/Case/') ||
                    event.data.includes('/apex/successRecoding')
                ) {
                    messageValid = true;
                }
                if (validOrigin && messageValid) {
                    workspaceAPI.openTab({
                        url: event.data,
                        focus: true,
                    });
                } else {
                    return;
                }
            }),
            false
        );
    },
});
