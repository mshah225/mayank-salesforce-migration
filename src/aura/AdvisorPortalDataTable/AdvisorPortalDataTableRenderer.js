({
    rerender: function (component) {
        this.superRerender();
        window.setTimeout(
            $A.getCallback(function() {
                if (component.get("v.expandSectionsRunning")) {
                    component.set("v.expandSectionsRunning", false);
                    if (component.get("v.SectionsOpenState")) {
                        let allSections = component.get("v.AllSections");
                        component.set("v.OpenSections", allSections);
                    }
                }
            })
        );
    }
});