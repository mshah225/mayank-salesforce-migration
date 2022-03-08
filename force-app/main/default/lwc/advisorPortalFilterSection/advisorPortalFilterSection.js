import {LightningElement, api, wire} from 'lwc';
import getPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getPicklistValues';
import getCampusValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getCampusValues';
import getCaseStatusSettings from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseStatusSettings';
import getCaseSubjectPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseSubjectPicklistValues';
import getCaseClassificationPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseClassificationPicklistValues';
import getFilteredCases from '@salesforce/apex/AdvisorPortalFilterSectionController.getFilteredCases';

export default class AdvisorPortalFilterSection extends LightningElement {
    @api set defaultFilter(val) {
        this._defaultFilter = val;
        this.currentFilter = val;
        this.applyFilters();
    }
    get defaultFilter() {
        return this._defaultFilter;
    }
    _defaultFilter;

    @api set viewAsUsers(val) {
        this._viewAsUsers = [...val];
    }
    get viewAsUsers() {
        return this._viewAsUsers;
    }
    _viewAsUsers = [];

    @api set currentFilter(val) {
        this.sendLoadingEvent(true);
        if (this.filterIsDifferent(this.currentFilter, val)) {
            this.copyChanges(this.currentFilter, val);
            this._currentFilter = {...this._currentFilter};
        }
        this.sendLoadingEvent(false);
    }
    get currentFilter() {
        if (this._currentFilter == null) this._currentFilter = this.getEmptyFilter();
        return this._currentFilter;
    }
    _currentFilter;
    get currentFilterJSON() {
        return JSON.stringify(this.currentFilter);
    }

    get isGraduateOnly() {
        if (this.currentFilter == null) return false;
        else if (this.currentFilter.career == null) return false;
        return this.currentFilter.career === 'GRD';
    }

    residencyPicklistValues = [];
    @wire(getPicklistValues, {objectName: 'Student_Program_Plan__c', fieldName: 'Residency__c'})
    gotPicklistValues(result) {
        let {data, error} = result;
        if (data != null) {
            this.residencyPicklistValues = this.buildPicklistOptionsArray(data);
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error(error);
        }
        this.sendLoadingEvent(false);
    }

    caseStatusPicklistValues = [];
    @wire(getCaseStatusSettings, {})
    gotCaseStatusSettings(result) {
        let {data, error} = result;
        if (data != null) {
            this.caseStatusPicklistValues = this.buildPicklistOptionsArray(data);
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error(error);
        }
        this.sendLoadingEvent(false);
    }

    // Reassigning currentFilterJSON, like in we do it `set currentFilter` will trigger this to re-run
    campusPicklistValues = [];
    @wire(getCampusValues, {filterJSON: '$currentFilterJSON'})
    gotCampusValues(result) {
        let {data, error} = result;
        if (data != null) {
            this.campusPicklistValues = this.buildPicklistOptionsArray(data);
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error('gotCampusValues', error);
        }
        this.sendLoadingEvent(false);
    }

    // Reassigning viewAsUsers, like in we do it `set viewAsUsers` will trigger this to re-run
    caseSubjectPicklistValues = [];
    @wire(getCaseSubjectPicklistValues, {viewAsOptions: '$viewAsUsers'})
    gotCaseSubjectPicklistValues(result) {
        let {data, error} = result;
        if (data != null) {
            this.caseSubjectPicklistValues = this.buildPicklistOptionsArray(data);
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error('gotCaseSubjectPicklistValues', error);
        }
        this.sendLoadingEvent(false);
    }

    // Reassigning viewAsUsers, like in we do it `set viewAsUsers` will trigger this to re-run
    caseCategoryPicklistValues = [];
    @wire(getCaseClassificationPicklistValues, {viewAsOptions: '$viewAsUsers'})
    gotCaseClassificationPicklistValues(result) {
        let {data, error} = result;
        if (data != null) {
            this.caseCategoryPicklistValues = this.buildPicklistOptionsArray(data);
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error('gotCaseClassificationPicklistValues', error);
        }
        this.sendLoadingEvent(false);
    }

    academicLevelPicklistValues = [
        {label: 'Freshman', value: 'Freshman'},
        {label: 'Sophomore', value: 'Sophomore'},
        {label: 'Junior', value: 'Junior'},
        {label: 'Senior', value: 'Senior'},
        {label: 'Graduate', value: 'Graduate'},
    ];
    outlookScoreOptions = [
        {label: 'Very Low', value: 'Very Low'},
        {label: 'Low', value: 'Low'},
        {label: 'Moderate', value: 'Moderate'},
        {label: 'High', value: 'High'},
        {label: 'Very High', value: 'Very High'},
    ];
    outlookChangeOptions = [
        {label: 'Up', value: 'Up'},
        {label: 'Down', value: 'Down'},
        {label: 'No change', value: 'No Change'},
    ];
    degreeLevelOptions = [
        {label: 'Masters', value: 'masters'},
        {label: 'Doctorate', value: 'doctorate'},
        {label: 'Certificate', value: 'certificate'},
        {label: 'Non-degree', value: 'non-degree'},
    ];
    academicProgramOptions = [];
    schoolDepartmentOptions = [];
    academicPlanOptions = [];
    specialPopulationOptions = [
        {label: 'Accelerated 4+1 Degrees', value: 'Accelerated 4+1 Degrees'},
        {label: 'International Accelerated Students', value: 'International Accelerated Students'},
        {label: 'Format Students', value: 'Format Students'},
        {label: 'Provivisional Admits, not met yet', value: 'Provivisional Admits, not met yet'},
        {label: 'Veterans', value: 'Veterans'},
        {label: 'Applied to Graduate', value: 'Applied to Graduate'},
        {label: 'Mayo Students', value: 'Mayo Students'},
        {label: 'Cintana Students', value: 'Cintana Students'},
        {label: 'HS Dual Enrollment Students', value: 'HS Dual Enrollment Students'},
        {label: 'Teach for America Students', value: 'Teach for America Students'},
        {label: 'Research Assistants', value: 'Research Assistants'},
        {label: 'Teaching Assistants', value: 'Teaching Assistants'},
        {label: 'Concurrent Enrollment', value: 'Concurrent Enrollment'},
        {label: 'Active Students with Registation Hold', value: 'Active Students with Registation Hold'},
    ];

    connectedCallback() {
        // one for each wire
        this.sendLoadingEvent(true);
        this.sendLoadingEvent(true);
        this.sendLoadingEvent(true);
        this.sendLoadingEvent(true);
        this.sendLoadingEvent(true);
    }

    changeField(event) {
        const fieldChanged = event.originalTarget.name;
        const newValue = event.detail.value;
        this.currentFilter[fieldChanged] = newValue;

        event.stopPropagation();
        event.stopImmediatePropagation();
        event.preventDefault();

        this.sendChangeFilterEvent(fieldChanged, newValue);
    }

    clearFilters() {
        const clearFilter = {};
        clearFilter.caseTypeState = this.currentFilter.caseTypeState;
        clearFilter.career = this.currentFilter.career;
        this.currentFilter = clearFilter;
        this.applyFilters();
    }

    // don't regenerate the JSON, use whichever JSON more recent request was used with
    cachedFitlerJSON = null;
    @api forceRefresh() {
        if (this.cachedFitlerJSON === null) return;

        let viewAsOptions = this.viewAsUsers;

        this.sendLoadingEvent(true);
        getFilteredCases({viewAsOptions, filterJSON: this.cachedFitlerJSON})
            .then((val) => {
                this.sendChangeResultsEvent(JSON.parse(val));
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error(err);
            })
            .finally(() => {
                this.sendLoadingEvent(false);
            });
    }

    applyFilters() {
        let viewAsOptions = this.viewAsUsers;
        let filterJSON = JSON.stringify(this.currentFilter);
        this.cachedFitlerJSON = filterJSON;

        this.sendLoadingEvent(true);
        getFilteredCases({viewAsOptions, filterJSON})
            .then((val) => {
                this.sendChangeResultsEvent(JSON.parse(val));
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error(err);
            })
            .finally(() => {
                this.sendLoadingEvent(false);
            });
    }

    /**
     * Helper functions
     */
    // Copy only the fields that are different from filterB to filterA
    copyChanges(filterA, filterB) {
        for (let i = 0; i < this.filterPropertyList.length; i++) {
            const propertyName = this.filterPropertyList[i];
            if (filterB[propertyName] != null && filterA[propertyName] !== filterB[propertyName])
                filterA[propertyName] = filterB[propertyName];
        }
    }

    // Check if filterA and filterB disagree
    filterIsDifferent(filterA, filterB) {
        let same = true;

        for (let i = 0; i < this.filterPropertyList.length; i++) {
            const propertyName = this.filterPropertyList[i];
            if (filterA[propertyName] !== filterB[propertyName]) {
                same = false;
                break;
            }
        }

        return !same;
    }

    // Convert returned picklist map into array of options for comboboxes
    buildPicklistOptionsArray(optionsMap) {
        let optionsList = [];

        Object.keys(optionsMap).forEach(function (key) {
            optionsList.push({label: key, value: optionsMap[key]});
        });

        return optionsList;
    }

    // Generate an "empty" filter object, with default values
    getEmptyFilter() {
        const filter = {};
        for (let i = 0; i < this.filterPropertyList.length; i++) {
            const propertyName = this.filterPropertyList[i];
            filter[propertyName] = '';
            if (propertyName === 'career') filter[propertyName] = 'UGRD';
            if (propertyName === 'caseTypeState') filter[propertyName] = 'ProactiveCasesState';
        }
        return filter;
    }

    // All names of properties on filter object should match AdvisorPortalFilter object
    filterPropertyList = [
        'studentString',
        'caseCategory',
        'caseSubject',
        'caseStatus',
        'caseCount',
        'caseTypeState',
        'career',
        'outlookScore',
        'outlookChange',
        'createdFromDate',
        'createdToDate',
        'followUpFromDate',
        'followUpToDate',
        'persistenceFromDate',
        'persistenceToDate',
        'studentGroupCode',
        'academicLevel',
        'campus',
        'major',
        'residency',
        'advisor',
        'degreeLevel',
        'academicProgram',
        'schoolDepartment',
        'academicPlan',
        'admitTermFrom',
        'admitTermTo',
        'specialPopulation',
    ];

    // Send events
    sendChangeFilterEvent(name, value) {
        this.dispatchEvent(
            new CustomEvent('change', {
                detail: {name, value},
            })
        );
    }

    sendChangeResultsEvent(results) {
        this.dispatchEvent(
            new CustomEvent('setresults', {
                detail: results,
            })
        );
    }

    sendLoadingEvent(loadMore) {
        this.dispatchEvent(new CustomEvent('loading', {detail: loadMore}));
    }
}
