({
    getFilterPicklists: function (component) {
        component.getEvent('incrementProcessingCounterEvent').fire();
        let residencyAction = component.get('c.getPicklistValues');
        residencyAction.setParams({objectName: 'Student_Program_Plan__c', fieldName: 'Residency__c'});
        residencyAction.setCallback(this, function (response) {
            component.set('v.ResidencyPicklistValues', this.buildPicklistOptionsArray(response.getReturnValue()));
            component.getEvent('decrementProcessingCounterEvent').fire();
        });
        $A.enqueueAction(residencyAction);

        component.getEvent('incrementProcessingCounterEvent').fire();
        let caseStatusAction = component.get('c.getCaseStatusSettings');
        caseStatusAction.setCallback(this, function (response) {
            component.set('v.CaseStatusPicklistValues', this.buildPicklistOptionsArray(response.getReturnValue()));
            component.getEvent('decrementProcessingCounterEvent').fire();
        });
        $A.enqueueAction(caseStatusAction);

        component.getEvent('incrementProcessingCounterEvent').fire();
        let campusOptionsAction = component.get('c.getCampusValues');
        campusOptionsAction.setCallback(this, function (response) {
            component.set('v.CampusPicklistValues', this.buildPicklistOptionsArray(response.getReturnValue()));
            component.getEvent('decrementProcessingCounterEvent').fire();
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

    applyFilters: function (component) {
        if (!this.validateDateFields(component)) {
            return;
        }

        component.getEvent('incrementProcessingCounterEvent').fire();

        const filterAction = component.get('c.getFilteredCases');
        filterAction.setParams({
            viewAsOptions: component.get('v.UserIds'),
            filter: this.buildFilter(component),
        });

        filterAction.setCallback(this, function (response) {
            if (!response.getReturnValue()) {
                component.getEvent('updateCaseContactWrappersEvent').setParams({caseContactWrapperList: []}).fire();
            } else {
                component
                    .getEvent('updateCaseContactWrappersEvent')
                    .setParams({caseContactWrapperList: response.getReturnValue()})
                    .fire();
            }

            component.getEvent('decrementProcessingCounterEvent').fire();
        });
        $A.enqueueAction(filterAction);
    },

    buildFilter: function (component) {
        return {
            sobjectType: 'AdvisorPortalFilter',
            studentString: component.get('v.Student'),
            caseCategory: component.get('v.CaseCategory'),
            caseSubject: component.get('v.CaseSubject'),
            caseStatus: component.get('v.CaseStatus'),
            allCasesState: component.get('v.CaseTypeState') === 'AllCasesState',
            watchlistCasesState: component.get('v.CaseTypeState') === 'WatchlistCasesState',
            proactiveCasesState: component.get('v.CaseTypeState') === 'ProactiveCasesState',
            outlookScore: component.get('v.OutlookScore'),
            outlookChange: component.get('v.OutlookChange'),
            createdFromDate: component.get('v.CreatedFromDate'),
            createdToDate: component.get('v.CreatedToDate'),
            followUpFromDate: component.get('v.FollowUpFromDate'),
            followUpToDate: component.get('v.FollowUpToDate'),
            persistenceFromDate: component.get('v.PersistenceFromDate'),
            persistenceToDate: component.get('v.PersistenceToDate'),
            caseCount: parseInt(component.get('v.CaseCount')),
            studentGroupCode: component.get('v.StudentGroup'),
            academicLevel: component.get('v.AcademicLevel'),
            campus: component.get('v.Campus'),
            residency: component.get('v.Residency'),
            major: component.get('v.Major'),
            gradStudentsOnly: component.get('v.GraduateStudentsOnly'),
        };
    },

    isViewingAllCases: function (component) {
        return component.get('v.CaseTypeState') === 'AllCasesState';
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
