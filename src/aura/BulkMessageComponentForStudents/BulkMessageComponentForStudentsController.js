({
    processRecords: function (component, event, helper) {
        var studentList = component.find('studentListId').getSelectedRows();
        var idList = [];

        if (!studentList.length > 0) {
            alert('Please select atleast 1 student.');
        } else {
            for (var i = 0; i < studentList.length; i++) {
                idList[i] = studentList[i].Id;
            }
            component.set('v.idList', '[' + idList.join() + ']');
            var ids = component.get('v.idList');
            /*
             * Code to be used for lightning component. removed when embedded in VF page
             */
            var evt = $A.get('e.force:navigateToComponent');
            var urlEvent = $A.get('e.force:navigateToURL');
            var sanitizedUrl = '/apex/BulkSMSEnterprise_Contact?selected=' + ids + '&objectName=Contact';

            if (evt) {
                evt.setParams({
                    componentDef: 'smagicinteract:BulkSMSComponent',
                    componentAttributes: {
                        IdList: ids,
                        objectName: 'Contact',
                    },
                });
                evt.fire();
            } else if (urlEvent) {
                urlEvent.setParams({
                    url: sanitizedUrl,
                    target: '_blank',
                });
                urlEvent.fire();
            } else if (typeof sforce != 'undefined' && sforce.one) {
                sforce.one.navigateToURL(sanitizedUrl);
            } else {
                var console = component.get('v.console');
                history.pushState({}, window.title, window.location.href);

                var win = window.open(sanitizedUrl, '_blank');
                win.focus();
            }
        }
    },

    doInit: function (component, event, helper) {
        helper.fetchData(component);
    },

    onPicklistChange: function (component, event, helper) {
        if (component && component.get('v.selectedCoach')) {
            helper.fetchData(component, component.get('v.selectedCoach'));
        } else {
            helper.fetchData(component);
        }
    },
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');

        if (action.name == 'Show_Details') {
            sforce.console.openPrimaryTab(null, '/' + row.Id, true, row.FirstName, openSuccess, row.Id);
            var openSuccess = function openSuccess(result) {
                //Report whether opening the new tab was successful
                if (result.success == true) {
                    console.log('Tab open success');
                } else {
                    console.log('Tab open failed');
                }
            };
        }
    },
});
