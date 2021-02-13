({
    setVisibleList: function (component, currentPageNumber, numberOfRecordsDisplayed) {
        let allSections = [];
        let pageSize = Number(numberOfRecordsDisplayed);
        let allContacts = component.get('v.Contacts');
        let totalRecords = allContacts.length;
        let recordOffsetRangeTo = Math.min(currentPageNumber * pageSize, totalRecords);
        let recordOffsetRangeFrom = Math.ceil(pageSize * (currentPageNumber - 1));

        // Set pagination info
        component.set('v.Total', totalRecords);
        component.set('v.Page', currentPageNumber);
        component.set('v.RecordOffsetRangeFrom', Math.ceil(pageSize * (currentPageNumber - 1)) + 1);
        component.set('v.TotalPages', Math.ceil(totalRecords / pageSize));
        component.set('v.RecordOffsetRangeTo', recordOffsetRangeTo);
        component.set('v.ContactsDisplayed', allContacts.slice(recordOffsetRangeFrom, recordOffsetRangeTo));

        // Reset expanded sections
        component.set('v.OpenSections', []);
        component
            .get('v.ContactsDisplayed')
            .forEach((contactWrapper) => allSections.push(contactWrapper.portalContact.Name));
        component.set('v.AllSections', allSections);
        if (component.get('v.SectionsOpenState')) {
            component.set('v.OpenSections', allSections);
        }
    },

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
