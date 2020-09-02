({
    getFilterPicklists: function (component) {
        let residencyAction = component.get('c.getPicklistValues');
        residencyAction.setParams({objectName: 'Student_Program_Plan__c', fieldName: 'Residency__c'});
        residencyAction.setCallback(this, function (response) {
            component.set('v.ResidencyPicklistValues', this.buildPicklistOptionsArray(response.getReturnValue()));
        });
        $A.enqueueAction(residencyAction);

        let caseStatusAction = component.get('c.getCaseStatusSettings');
        caseStatusAction.setCallback(this, function (response) {
            component.set('v.CaseStatusPicklistValues', this.buildPicklistOptionsArray(response.getReturnValue()));
        });
        $A.enqueueAction(caseStatusAction);

        let campusOptionsAction = component.get('c.getPicklistValues');
        campusOptionsAction.setParams({objectName: 'Case', fieldName: 'Campus__c'});
        campusOptionsAction.setCallback(this, function (response) {
            component.set('v.CampusPicklistValues', this.buildPicklistOptionsArray(response.getReturnValue()));
        });
        $A.enqueueAction(campusOptionsAction);
    },

    buildPicklistOptionsArray: function (optionsMap) {
        let optionsList = [];

        Object.keys(optionsMap).forEach(function (key) {
            optionsList.push({label: key, value: optionsMap[key]});
        });

        return optionsList;
    },

    applyFilters: function (component, toggleButtonFired) {
        if (!this.validateDateFields(component)) {
            return;
        }

        component.set('v.isProcessing', true);

        let filterAction = component.get('c.getContactCaseWrappersWithLessQueries');
        filterAction.setParams({
            viewAsOptions: component.get('v.UserIds'),
            filter: this.buildFilter(component),
        });
        filterAction.setCallback(this, function (response) {
            console.log(response.getError());
            console.log(response.getReturnValue());
            if (!response.getReturnValue()) {
                component.set('v.FilteredContacts', []);
            } else {
                component.set('v.FilteredContacts', response.getReturnValue());
            }

            component.set('v.isProcessing', false);
        });
        $A.enqueueAction(filterAction);
    },

    buildFilter: function (component) {
        return {
            'sobjectType': 'AdvisorPortalFilter',
            'studentString': component.get('v.Student'),
            'caseCategory': component.get('v.CaseCategory'),
            'caseSubject': component.get('v.CaseSubject'),
            'caseStatus': component.get('v.CaseStatus'),
            'allCasesState': component.get('v.AllCasesState'),
            'watchlistCasesState': component.get('v.WatchlistCasesState'),
            'proactiveCasesState': component.get('v.ProactiveCasesState'),
            'outlookScore': component.get('v.OutlookScore'),
            'outlookChange': component.get('v.OutlookChange'),
            'createdFromDate': component.get('v.CreatedFromDate'),
            'createdToDate:': component.get('v.CreatedToDate'),
            'followUpFromDate': component.get('v.FollowUpFromDate'),
            'followUpToDate': component.get('v.FollowUpToDate'),
            'persistenceFromDate': component.get('v.PersistenceFromDate'),
            'persistenceToDate': component.get('v.PersistenceToDate'),
            'caseCount': parseInt(component.get('v.CaseCount')),
            'studentGroupCode': component.get('v.StudentGroup'),
            'academicLevel': component.get('v.AcademicLevel'),
            'campus': component.get('v.Campus'),
            'residency': component.get('v.Residency'),
            'major': component.get('v.Major'),
            'advisor': component.get('v.Advisor'),
        };
    },

    handleToggleFilterButtons: function (component, event, helper, attributeName, elementAuraId) {
        if (elementAuraId !== 'filtersToggle') {
            if (elementAuraId === 'allCasesFilter' && component.get('v.AllCasesState') === false) {
                component.set('v.AllCasesState', true);
                component.find('allCasesFilter').set('v.variant', 'brand');
                component.set('v.ProactiveCasesState', false);
                component.find('proactiveFilter').set('v.variant', 'neutral');
                component.set('v.WatchlistCasesState', false);
                component.find('watchlistFilter').set('v.variant', 'neutral');
            } else if (elementAuraId === 'proactiveFilter' && component.get('v.ProactiveCasesState') === false) {
                component.set('v.AllCasesState', false);
                component.find('allCasesFilter').set('v.variant', 'neutral');
                component.set('v.ProactiveCasesState', true);
                component.find('proactiveFilter').set('v.variant', 'brand');
                component.set('v.WatchlistCasesState', false);
                component.find('watchlistFilter').set('v.variant', 'neutral');
            } else if (elementAuraId === 'watchlistFilter' && component.get('v.WatchlistCasesState') === false) {
                component.set('v.AllCasesState', false);
                component.find('allCasesFilter').set('v.variant', 'neutral');
                component.set('v.ProactiveCasesState', false);
                component.find('proactiveFilter').set('v.variant', 'neutral');
                component.set('v.WatchlistCasesState', true);
                component.find('watchlistFilter').set('v.variant', 'brand');
            }

            this.applyFilters(component, true);
        } else {
            component.set('v.' + attributeName, !component.get('v.' + attributeName));
            component.find(elementAuraId).set('v.variant', component.get('v.' + attributeName) ? 'brand' : 'neutral');
        }
    },

    validateDateFields: function (component) {
        if (!this.checkDateField(component, 'CreatedFromDate', 'CreatedToDate', 'Created From Date')) {
            return false;
        }

        if (!this.checkDateField(component, 'FollowUpFromDate', 'FollowUpToDate', 'Follow Up From Date')) {
            return false;
        }

        if (
            !this.checkDateField(component, 'PersistenceFromDate', 'PersistenceToDate', 'Persistence Change From Date')
        ) {
            return false;
        }

        return true;
    },

    checkDateField: function (component, fromAttribute, toAttribute, fromDateErrorText) {
        if (
            component.get('v.' + fromAttribute) &&
            component.get('v.' + toAttribute) &&
            Date.parse(component.get('v.' + fromAttribute)) > Date.parse(component.get('v.' + toAttribute))
        ) {
            this.fireToast('Error', fromDateErrorText + ' is in the future. It must be before the To Date.', 'error');
            return false;
        } else {
            return true;
        }
    },

    fireToast: function (title, message, type) {
        let lightningToast = $A.get('e.force:showToast');
        if (lightningToast !== undefined) {
            lightningToast.setParams({title: title, message: message, type: type}).fire();
        } else {
            $A.get('e.c:ShowClassicToast').setParams({title: title, message: message, type: type}).fire();
        }
    },
});
