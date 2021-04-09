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
                    typeof event.data === 'string' &&
                    (event.data.includes('/lightning/r/Case/') ||
                        event.data.includes('lightning/r/et4ae5__IndividualEmailResult__c/'))
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
