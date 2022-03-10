({
    openPrimaryAndSubTab: function (
        primaryTabId,
        primaryTabName,
        primaryTabURL,
        subTabId,
        subTabName,
        subTabURL,
        openPrimary
    ) {
        if (sforce.console.isInConsole()) {
            sforce.console.focusPrimaryTabByName(primaryTabId, function (focusPrimaryTabResponse) {
                if (!focusPrimaryTabResponse.success) {
                    sforce.console.openPrimaryTab(
                        null,
                        primaryTabURL,
                        true,
                        primaryTabName,
                        function (openPrimaryTabResponse) {
                            sforce.console.openSubtab(
                                openPrimaryTabResponse.id,
                                subTabURL,
                                true,
                                subTabName,
                                null,
                                function (openSubTabResponse) {
                                    if (!openSubTabResponse.success) {
                                        sforce.console.focusSubTabByNameAndPrimaryTabId(
                                            subTabId,
                                            openSubTabResponse.id
                                        );
                                    }
                                },
                                subTabId
                            );
                        },
                        primaryTabId
                    );
                } else {
                    sforce.console.getFocusedPrimaryTabId(function (primaryFocusResponse) {
                        sforce.console.focusSubtabByNameAndPrimaryTabId(
                            subTabId,
                            primaryFocusResponse.id,
                            function (focusSubTabResponse) {
                                if (!focusSubTabResponse.success) {
                                    sforce.console.openSubtab(
                                        primaryFocusResponse.id,
                                        subTabURL,
                                        true,
                                        subTabName,
                                        null,
                                        function (openSubTabResponse) {
                                            if (!openSubTabResponse.success) {
                                                sforce.console.focusSubTabByNameAndPrimaryTabId(
                                                    subTabId,
                                                    openSubTabResponse.id
                                                );
                                            }
                                        },
                                        subTabId
                                    );
                                }
                            }
                        );
                    });
                }
            });
        } else if (!openPrimary) {
            window.open(subTabURL, '_blank');
        } else {
            window.open(primaryTabURL, '_blank');
        }
    },
});
