import {LightningElement, api, wire} from 'lwc';
import {refreshApex} from '@salesforce/apex';
import getPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getPicklistValues';
import getCampusValuesX from '@salesforce/apex/AdvisorPortalFilterSectionController.getCampusValuesX';
import getCaseStatusSettings from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseStatusSettings';
import getCaseSubjectPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseSubjectPicklistValues';
import getCaseClassificationPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseClassificationPicklistValues';
import getFilteredCasesX from '@salesforce/apex/AdvisorPortalFilterSectionController.getFilteredCasesX';

export default class AdvisorPortalFilters extends LightningElement {
    @api defaultFilter;

    @api set viewAsUsers(val) {
        this.userIdsChanged();

        this._viewAsUsers = [...val];
    }
    get viewAsUsers() {
        return this._viewAsUsers;
    }
    _viewAsUsers = [];

    @api set currentFilter(val) {
        if (val.gradStudentsOnly !== this._currentFilter.gradStudentsOnly) {
            this.gradToggleChanged();
        }

        this._currentFilter = {...val};
    }
    get currentFilter() {
        return this._currentFilter;
    }
    _currentFilter = {};
    get currentFilterJSON() {
        return JSON.stringify(this.currentFilter);
    }

    get isGraduateOnly() {
        if (this.currentFilter == null) return false;
        else if (this.currentFilter.gradStudentsOnly == null) return false;
        return this.currentFilter.gradStudentsOnly;
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

    campusPicklistValues = [];
    getCampusValuesWire;
    @wire(getCampusValuesX, {filterJSON: '$currentFilterJSON'})
    gotCampusValues(result) {
        this.getCampusValuesWire = result;
        let {data, error} = result;
        if (data != null) {
            this.campusPicklistValues = this.buildPicklistOptionsArray(data);
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error(error);
        }
    }

    caseSubjectPicklistValues = [];
    getCaseSubjectPicklistValuesWire;
    @wire(getCaseSubjectPicklistValues, {viewAsOptions: '$viewAsUsers'})
    gotCaseSubjectPicklistValues(result) {
        this.getCaseSubjectPicklistValuesWire = result;
        let {data, error} = result;
        if (data != null) {
            this.caseSubjectPicklistValues = this.buildPicklistOptionsArray(data);
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error(error);
        }
    }

    caseCategoryPicklistValues = [];
    getCaseClassificationPicklistValuesWire;
    @wire(getCaseClassificationPicklistValues, {viewAsOptions: '$viewAsUsers'})
    gotCaseClassificationPicklistValues(result) {
        this.getCaseClassificationPicklistValuesWire = result;
        let {data, error} = result;
        if (data != null) {
            this.caseCategoryPicklistValues = this.buildPicklistOptionsArray(data);
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error(error);
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

    clearFilters() {
        const clearFilter = {};
        clearFilter.caseTypeState = this.currentFilter.caseTypeState;
        clearFilter.gradStudentsOnly = this.currentFilter.gradStudentsOnly;
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
    userIdsChanged() {
        console.log(this.viewAsUsers);
        refreshApex(this.getCaseSubjectPicklistValuesWire);
        refreshApex(this.getCaseClassificationPicklistValuesWire);
    }

    gradToggleChanged() {
        refreshApex(this.getCampusValuesWire)
            .then((val) => {
                console.log(val);
            })
            .catch((err) => {
                console.error(err);
            });
    }

    buildPicklistOptionsArray(optionsMap) {
        let optionsList = [];

        Object.keys(optionsMap).forEach(function (key) {
            optionsList.push({label: key, value: optionsMap[key]});
        });

        return optionsList;
    }
}
