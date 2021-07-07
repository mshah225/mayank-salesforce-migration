({
    doInit: function (component, event, helper) {
        component.getEvent('incrementProcessingCounterEvent').fire();
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
            component.getEvent('updateAllUserOptionsEvent').setParams({allUserOptions: allUserOptions}).fire();
            component
                .getEvent('updateViewAsOptionsEvent')
                .setParams({viewAsUsersList: component.get('v.CurrentSelectedOptions')})
                .fire();
            component.set('v.AllUserOptions', allUserOptions);
            component.set('v.FilteredUserOptions', allUserOptions);
            component.set('v.AllOptionsCount', allUserOptionsCount);
            component.set('v.PillsDisplayedCount', component.get('v.DefaultPillsDisplayed'));

            helper.setCountSelected(component);
            component.getEvent('decrementProcessingCounterEvent').fire();
        });
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

    clearAll: function (component, event, helper) {
        component.getEvent('incrementProcessingCounterEvent').fire();

        let allUserOpts = component.get('v.AllUserOptions');
        let selectedOptions = [];

        for (let i = 0, len = allUserOpts.length; i < len; i++) {
            if (!allUserOpts[i].isHeader) {
                allUserOpts[i].isSelected = false;
            }
        }

        component.set('v.AllUserOptions', allUserOpts);
        component.set('v.CurrentSelectedOptions', selectedOptions);

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
        } else {
            let allUserOpts = component.get('v.AllUserOptions');
            component.set('v.FilteredUserOptions', allUserOpts);
            component.set('v.PrevFilterValue', '');
        }
    },

    applyChanges: function (component) {
        component.getEvent('incrementProcessingCounterEvent').fire();
        component
            .getEvent('updateViewAsOptionsEvent')
            .setParams({viewAsUsersList: component.get('v.CurrentSelectedOptions')})
            .fire();
        component.getEvent('decrementProcessingCounterEvent').fire();
    },

    handleClickWithinDropdownSection: function (component, event, helper) {
        event.stopPropagation(); // prevent this from triggering page-wide
    },

    toggleDropdown: function (component, event, helper) {
        if (!component.get('v.OnClickOutListenerSet')) {
            component.set('v.OnClickOutListenerSet', true);

            // close modal and cleanup page-wide listener
            helper.handleClickOutsideDropdownSection = function (e) {
                $A.util.removeClass(component.find('combobox-drop').getElement(), 'slds-is-open');
                document.body.removeEventListener('click', helper.handleClickOutsideDropdownSection);
                component.set('v.OnClickOutListenerSet', false);
            };
            document.body.addEventListener('click', helper.handleClickOutsideDropdownSection);
        }

        $A.util.toggleClass(component.find('combobox-drop').getElement(), 'slds-is-open');

        if (!$A.util.hasClass(component.find('combobox-drop').getElement(), 'slds-is-open')) {
            helper.setCountSelected(component);
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
