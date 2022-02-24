import {LightningElement, api, wire} from 'lwc';
import getPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getPicklistValues';
import getCampusValuesX from '@salesforce/apex/AdvisorPortalFilterSectionController.getCampusValuesX';
import getCaseStatusSettings from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseStatusSettings';
import getCaseSubjectPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseSubjectPicklistValues';
import getCaseClassificationPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseClassificationPicklistValues';
import getFilteredCasesX from '@salesforce/apex/AdvisorPortalFilterSectionController.getFilteredCasesX';

export default class AdvisorPortalFilters extends LightningElement {
    @api set defaultFilter(val) {
        this._defaultFilter = val;
        this.currentFilter = val;
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
        if (this.filterIsDifferent(this.currentFilter, val)) {
            this.copyChanges(this.currentFilter, val);
            this._currentFilter = {...this._currentFilter};
        }
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
    }

    // Reassigning currentFilterJSON, like in we do it `set currentFilter` will trigger this to re-run
    campusPicklistValues = [];
    @wire(getCampusValuesX, {filterJSON: '$currentFilterJSON'})
    gotCampusValues(result) {
        let {data, error} = result;
        if (data != null) {
            this.campusPicklistValues = this.buildPicklistOptionsArray(data);
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error('gotCampusValues', error);
        }
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

    applyFilters() {
        let viewAsOptions = this.viewAsUsers;
        let filterJSON = JSON.stringify(this.currentFilter);

        console.log('--applyFilters--');
        console.log(viewAsOptions);
        console.log(filterJSON);
        console.log('--applyFilters--');

        getFilteredCasesX({viewAsOptions, filterJSON})
            .then((val) => {
                console.log('--applyFilters then--');
                console.log(val);
                console.log('--applyFilters then--');
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error(err);
            })
            .finally(() => {});
    }

    // Helper functions
    copyChanges(filterA, filterB) {
        for (let i = 0; i < this.filterPropertyList.length; i++) {
            const propertyName = this.filterPropertyList[i];
            if (filterB[propertyName] != null && filterA[propertyName] !== filterB[propertyName])
                filterA[propertyName] = filterB[propertyName];
        }
    }

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

    sendChangeFilterEvent(name, value) {
        this.dispatchEvent(
            new CustomEvent('change', {
                detail: {name, value},
            })
        );
    }
}
