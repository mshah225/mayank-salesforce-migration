({
    handleNavigate: function (component, event, helper) {
        const detail = event.getParams('detail');

        const location = detail.location;
        let contactId, contactName, caseId, caseNumber, profileURL;

        switch (location) {
            case 'viewcase':
                contactId = detail.params.contactId;
                contactName = detail.params.contactName;
                caseId = detail.params.caseId;
                caseNumber = detail.params.caseNumber;
                helper.openPrimaryAndSubTab(
                    contactId,
                    contactName,
                    '/' + contactId,
                    caseId,
                    caseNumber,
                    '/' + caseId,
                    false
                );
                break;
            case 'studentprofile':
                contactId = detail.params.contactId;
                contactName = detail.params.contactName;
                profileURL = '/apex/StudentProfile?contactId=' + contactId;
                helper.openPrimaryAndSubTab(
                    contactId,
                    contactName,
                    '/' + contactId,
                    profileURL,
                    contactName + "'s Profile",
                    profileURL,
                    false
                );
                break;
            default:
                console.log('navagation location unsupported', event);
                break;
        }
    },
});
