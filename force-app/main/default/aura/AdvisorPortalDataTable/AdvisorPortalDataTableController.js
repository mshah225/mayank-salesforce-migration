({
    doInit: function (component, event, helper) {
        component.set('v.SectionsOpenState', true);
    },

    resetViews: function (component, event, helper) {
        if (component.get('v.resetCheckboxesDuringViewRefresh')) {
            component.set('v.SelectAll', false);
        }
        helper.setVisibleList(component, 1, component.get('v.PageSize'));

        if (component.get('v.SectionsOpenState')) {
            component.set('v.OpenSections', component.get('v.AllSections'));
        }
    },

    setVisibleList: function (component, event, helper) {
        helper.setVisibleList(component, component.get('v.Page'), component.get('v.PageSize'));
    },

    firstPageNavigation: function (component, event, helper) {
        helper.setVisibleList(component, 1, component.get('v.PageSize'));
    },

    nextPageNavigation: function (component, event, helper) {
        helper.setVisibleList(component, component.get('v.Page') + 1, component.get('v.PageSize'));
    },

    previousPageNavigation: function (component, event, helper) {
        helper.setVisibleList(component, component.get('v.Page') - 1, component.get('v.PageSize'));
    },

    lastPageNavigation: function (component, event, helper) {
        helper.setVisibleList(component, component.get('v.TotalPages'), component.get('v.PageSize'));
    },

    pageSizeChange: function (component, event, helper) {
        let numberOfRecordsDisplayed = component.get('v.PageSize');
        helper.setVisibleList(component, 1, numberOfRecordsDisplayed);
        if (component.get('v.SectionsOpenState')) {
            component.set('v.OpenSections', component.get('v.AllSections'));
        }
    },

    toggleSelectAll: function (component) {
        let currentlyOpenSections = component.find('casesAccordion').get('v.activeSectionName'); // Cache open sections first.
        let checked = component.get('v.SelectAll');
        let contacts = component.get('v.Contacts');

        for (let i = 0; i < contacts.length; i++) {
            contacts[i].isSelected = checked;

            for (let j = 0; j < contacts[i].cases.length; j++) {
                contacts[i].cases[j].isSelected = checked;
            }
        }

        component.set('v.resetCheckboxesDuringViewRefresh', false); // Turn off checkbox reset.
        component.set('v.Contacts', contacts);
        component.set('v.resetCheckboxesDuringViewRefresh', true); // Turn checkbox reset back on.
        component.set('v.OpenSections', currentlyOpenSections);
    },

    toggleRelatedCases: function (component, event) {
        let contactId = event.getSource().get('v.value');
        let contacts = component.get('v.ContactsDisplayed');

        for (let i = 0; i < contacts.length; i++) {
            if (contacts[i].portalContact.Id === contactId) {
                for (let j = 0; j < contacts[i].cases.length; j++) {
                    contacts[i].cases[j].isSelected = contacts[i].isSelected;
                }
            }
        }

        component.set('v.ContactsDisplayed', contacts);
    },

    openCase: function (component, event, helper) {
        let caseId = event.currentTarget.getAttribute('data-caseId');
        let contactId = event.currentTarget.getAttribute('data-contactId');
        helper.openPrimaryAndSubTab(
            contactId,
            event.currentTarget.getAttribute('data-contactName'),
            '/' + contactId,
            caseId,
            event.currentTarget.getAttribute('data-caseNumber'),
            '/' + caseId,
            false
        );
    },

    openStudentProfile: function (component, event, helper) {
        let contactId = event.currentTarget.getAttribute('data-contactId');
        let contactName = event.currentTarget.getAttribute('data-contactName');
        let profileURL = '/apex/StudentProfile?contactId=' + contactId;
        helper.openPrimaryAndSubTab(
            contactId,
            contactName,
            '/' + contactId,
            profileURL,
            contactName + "'s Profile",
            profileURL,
            false
        );
    },

    toggleExpandSections: function (component) {
        if (component.get('v.SectionsOpenState')) {
            component.set('v.OpenSections', component.get('v.AllSections'));
        } else {
            component.set('v.OpenSections', []);
        }
    },

    refreshUsersAndCaseContactWrappers: function (component, event, helper) {
        component.getEvent('refreshAdvisorPortalContacts').fire();
    },
});
