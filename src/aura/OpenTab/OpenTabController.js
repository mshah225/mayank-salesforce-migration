({
    doInit: function (component) {
        var workspaceAPI = component.find("workspace");
        window.addEventListener("message", $A.getCallback(function (event) {
            var validOrigin = false;
            var messageValid = false;
            if (event.origin.substring(0, 11) == "https://asu") {
                validOrigin = true;
            }
            if (event.data.includes("/500/e?retURL=%2F0036300000AU5YZ&def_contact_id=")
                || event.data.includes("/lightning/r/Case/")) {
                messageValid = true;
            }
            if (validOrigin && messageValid) {
                console.log(event.data);
                workspaceAPI.openTab({
                    url: event.data,
                    focus: true
                }).catch(function(error) {
                });
            } else {
                return;
            }
        }), false);
    }
})

