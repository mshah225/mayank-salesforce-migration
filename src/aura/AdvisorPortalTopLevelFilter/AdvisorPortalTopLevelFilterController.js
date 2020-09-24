/**
 * @File Name          : AdvisorPortalTopLevelFilterController.js
 * @Description        :
 * @Author             :
 * @Group              :
 * @Last Modified By   : thom.clark@sierra-cedar.com
 * @Last Modified On   : 10/18/2019, 5:20:48 PM
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0                                               Initial Version
 * 1.1      10/17/2019  thom.clark@sierra-cedar.com  Added "Apply Selection" button to stop delay of
 *                                                   filter on item selection of top filter.
 *          10/18/2019  thom.clark@sierra-cedar.com  Allowed for top filter to close onblur
 * 			10/30/2019  thom.clark@sierra-cedar.com  Set up spinner when Apply Selection is clicked to
 * 													 let user know processing is happening.
 **/
({
    doInit: function (component, event, helper) {
        let allUserOptionsCount = 0;
        let action = component.get('c.viewAsOptions');
        action.setCallback(this, function (result) {
            let firstSelectionFound = false;
            let allUserOptions = [];
            let viewAsSelectOptions = [];
            let responseMap = result.getReturnValue();

            for (let key in responseMap) {
                if (responseMap.hasOwnProperty(key)) {
                    let option = {label: key, value: responseMap[key], isHeader: false};

                    if (key.includes('--')) {
                        option.label = option.label.replace(/--/g, '');
                        option.isHeader = true;
                    }

                    if (!option.isHeader) {
                        allUserOptionsCount++;

                        if (!firstSelectionFound) {
                            component.set('v.MyQueueId', option.value);
                            option.isSelected = true;
                            firstSelectionFound = true;
                            component.set('v.CurrentSelectedOptions', [option]);
                        }
                    }

                    allUserOptions.push(option);
                    viewAsSelectOptions.push(option);
                }
            }

            $A.get('e.c:UpdateViewAsOptions')
                .setParams({viewAsOptions: component.get('v.CurrentSelectedOptions')})
                .fire();
            component.set('v.AllUserOptions', allUserOptions);
            component.set('v.FilteredUserOptions', allUserOptions);
            component.set('v.AllOptionsCount', allUserOptionsCount);
            component.set('v.PillsDisplayedCount', component.get('v.DefaultPillsDisplayed'));

            helper.setCountSelected(component);
        });
        $A.enqueueAction(action);
    },

    setOwnerIdList: function (component, event, helper) {
        let ownerIdList = [];
        let ownerIdListParsed;
        let ownerIdListProxy = component.get('v.CurrentSelectedOptions');
        let action = component.get('c.setOwnerIdListFromUserSelection');

        if (ownerIdListProxy.length > 0) {
            ownerIdListParsed = JSON.parse(JSON.stringify(ownerIdListProxy));
            for (let i = 0; i < ownerIdListParsed.length; i++) {
                if (ownerIdListParsed[i].isSelected) {
                    ownerIdList.push(ownerIdListParsed[i].value);
                }
            }
        }

        if (ownerIdList != null) {
            action.setParams({ownerIdList: ownerIdList});
        }
        $A.enqueueAction(action);
    },

    selectAll: function (component, event, helper) {
        component.getEvent('incrementProcessingCounterEvent').fire();

        let allUserOpts = component.get('v.AllUserOptions');
        let selectedOptions = [];

        for (let i = 0, len = allUserOpts.length; i < len; i++) {
            if (!allUserOpts[i].isHeader) {
                allUserOpts[i].isSelected = true;
                selectedOptions.push(allUserOpts[i]);
            }
        }

        component.set('v.AllUserOptions', allUserOpts);
        component.set('v.CurrentSelectedOptions', selectedOptions);

        helper.setCountSelected(component);
        component.getEvent('decrementProcessingCounterEvent').fire();
    },

    myQueue: function (component, event, helper) {
        component.getEvent('incrementProcessingCounterEvent').fire();

        let myQueue = [];
        let allUserOpts = component.get('v.AllUserOptions');

        for (let i = 0, len = allUserOpts.length; i < len; i++) {
            if (allUserOpts[i].value === component.get('v.MyQueueId')) {
                allUserOpts[i].isSelected = true;
                myQueue.push(allUserOpts[i]);
            } else {
                allUserOpts[i].isSelected = false;
            }
        }

        component.set('v.AllUserOptions', allUserOpts);
        component.set('v.CurrentSelectedOptions', myQueue);

        helper.setCountSelected(component);
        component.getEvent('decrementProcessingCounterEvent').fire();
    },

    onchangeNameSearch: function (component) {
        let filterString = component.get('v.FilterValue');
        let prevFilterString = component.get('v.PrevFilterValue');

        if (filterString && filterString.length > 0) {
            let filteredOpts = [];
            let allUserOpts = [];

            if (
                prevFilterString &&
                prevFilterString.length > 0 &&
                filterString.toLowerCase().includes(prevFilterString.toLowerCase())
            ) {
                allUserOpts = component.get('v.FilteredUserOptions'); // This search is a subset of the previous search
            } else {
                allUserOpts = component.get('v.AllUserOptions');
            }

            for (let i = 0, len = allUserOpts.length; i < len; i++) {
                if (
                    allUserOpts[i].label &&
                    (allUserOpts[i].isHeader || allUserOpts[i].label.toLowerCase().includes(filterString.toLowerCase()))
                ) {
                    filteredOpts.push(allUserOpts[i]);
                }
            }

            component.set('v.FilteredUserOptions', filteredOpts);
            component.set('v.PrevFilterValue', filterString);

            $A.util.addClass(component.find('combobox-drop').getElement(), 'slds-is-open');
        } else {
            $A.util.removeClass(component.find('combobox-drop').getElement(), 'slds-is-open');

            let allUserOpts = component.get('v.AllUserOptions');
            component.set('v.FilteredUserOptions', allUserOpts);
            component.set('v.PrevFilterValue', '');
        }
    },

    applyChanges: function (component) {
        component.getEvent('incrementProcessingCounterEvent').fire();
        let ownerIdList = [];
        let ownerIdListParsed;
        let ownerIdListProxy = component.get('v.CurrentSelectedOptions');
        let action = component.get('c.setOwnerIdListFromUserSelection');

        if (ownerIdListProxy.length > 0) {
            ownerIdListParsed = JSON.parse(JSON.stringify(ownerIdListProxy));
            for (let i = 0; i < ownerIdListParsed.length; i++) {
                if (ownerIdListParsed[i].isSelected) {
                    ownerIdList.push(ownerIdListParsed[i].value);
                }
            }
        }

        if (ownerIdList != null) {
            action.setParams({ownerIdList: ownerIdList});
        }

        action.setCallback(this, function (result) {
            component.getEvent('decrementProcessingCounterEvent').fire();
            $A.get('e.c:UpdateViewAsOptions')
                .setParams({viewAsOptions: component.get('v.CurrentSelectedOptions')})
                .fire();
        });

        $A.enqueueAction(action);
    },

    toggleDropdown: function (component, event, helper) {
        $A.util.toggleClass(component.find('combobox-drop').getElement(), 'slds-is-open');

        if (!$A.util.hasClass(component.find('combobox-drop').getElement(), 'slds-is-open')) {
            helper.setCountSelected(component);
        } else {
            component.set('v.FilterValue', '');
        }

        let actionToUpdateCheckmarks = component.get('c.onchangeNameSearch');
        $A.enqueueAction(actionToUpdateCheckmarks);
    },
    toggleOption: function (component, event, helper) {
        let detail = event.getParams('detail');
        let selectedId = detail.key;

        if (selectedId) {
            let currentSelections = [];
            let allUserOpts = component.get('v.AllUserOptions');

            for (let i = 0, len = allUserOpts.length; i < len; i++) {
                if (allUserOpts[i].label + ';' + allUserOpts[i].value === selectedId) {
                    if (allUserOpts[i].isSelected) {
                        allUserOpts[i].isSelected = false;
                    } else {
                        allUserOpts[i].isSelected = true;
                        currentSelections.push(allUserOpts[i]);
                    }
                } else if (allUserOpts[i].isSelected) {
                    currentSelections.push(allUserOpts[i]);
                }
            }

            component.set('v.AllUserOptions', allUserOpts);
            component.set('v.CurrentSelectedOptions', currentSelections);
            helper.setCountSelected(component);
        }
    },

    removeOption: function (component, event, helper) {
        let selectedName = event.getSource().get('v.title');
        if (selectedName) {
            let remainingSelections = [];
            let allUserOpts = component.get('v.AllUserOptions');

            for (let i = 0, len = allUserOpts.length; i < len; i++) {
                if (selectedName === allUserOpts[i].label) {
                    allUserOpts[i].isSelected = false;
                }

                if (allUserOpts[i].isSelected) {
                    remainingSelections.push(allUserOpts[i]);
                }
            }

            component.set('v.AllUserOptions', allUserOpts);
            component.set('v.CurrentSelectedOptions', remainingSelections);
            helper.setCountSelected(component);
        }
    },

    expandPillGroup: function (component) {
        component.set('v.PillsDisplayedCount', component.get('v.AllOptionsCount'));
        $A.util.addClass(component.find('more-pills-toggle').getElement(), 'slds-hide');
    },

    collapsePillGroup: function (component) {
        component.set('v.PillsDisplayedCount', component.get('v.DefaultPillsDisplayed'));

        if (component.find('more-pills-toggle')) {
            $A.util.removeClass(component.find('more-pills-toggle').getElement(), 'slds-hide');
        }
    },
});
