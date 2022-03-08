import {LightningElement, api, wire} from 'lwc';
import getPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getPicklistValues';
import getCampusValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getCampusValues';
import getCaseStatusSettings from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseStatusSettings';
import getCaseSubjectPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseSubjectPicklistValues';
import getCaseClassificationPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseClassificationPicklistValues';
import getAcademicProgramPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getAcademicProgramPicklistValues';
import getSchoolDepartmentPicklistVaues from '@salesforce/apex/AdvisorPortalFilterSectionController.getSchoolDepartmentPicklistVaues';
import getAcademicPlanPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getAcademicPlanPicklistValues';
import getFilteredCases from '@salesforce/apex/AdvisorPortalFilterSectionController.getFilteredCases';
import {refreshApex} from '@salesforce/apex';

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
    residencyPicklistValuesWire;
    @wire(getPicklistValues, {objectName: 'Student_Program_Plan__c', fieldName: 'Residency__c'})
    gotPicklistValues(result) {
        this.residencyPicklistValuesWire = result;
        let {data, error} = this.residencyPicklistValuesWire;
        if (data != null) {
            this.residencyPicklistValues = this.buildPicklistOptionsArray(data);
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error(error);
        }
        this.checkInitialLoadingComplete();
    }

    caseStatusPicklistValues = [];
    caseStatusPicklistValuesWire;
    @wire(getCaseStatusSettings, {})
    gotCaseStatusSettings(result) {
        this.caseStatusPicklistValuesWire = result;
        let {data, error} = this.caseStatusPicklistValuesWire;
        if (data != null) {
            this.caseStatusPicklistValues = this.buildPicklistOptionsArray(data);
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error(error);
        }
        this.checkInitialLoadingComplete();
    }

    // Reassigning currentFilterJSON, like in we do it `set currentFilter` will trigger this to re-run
    campusPicklistValues = [];
    campusPicklistValuesWire;
    @wire(getCampusValues, {filterJSON: '$currentFilterJSON'})
    gotCampusValues(result) {
        this.campusPicklistValuesWire = result;
        let {data, error} = this.campusPicklistValuesWire;
        if (data != null) {
            this.campusPicklistValues = this.buildPicklistOptionsArray(data);
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error('gotCampusValues', error);
        }
        this.checkInitialLoadingComplete();
    }

    // Reassigning viewAsUsers, like in we do it `set viewAsUsers` will trigger this to re-run
    caseSubjectPicklistValues = [];
    caseSubjectPicklistValuesWire;
    @wire(getCaseSubjectPicklistValues, {viewAsOptions: '$viewAsUsers'})
    gotCaseSubjectPicklistValues(result) {
        this.caseSubjectPicklistValuesWire = result;
        let {data, error} = this.caseSubjectPicklistValuesWire;
        if (data != null) {
            this.caseSubjectPicklistValues = this.buildPicklistOptionsArray(data);
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error('gotCaseSubjectPicklistValues', error);
        }
        this.checkInitialLoadingComplete();
    }

    // Reassigning viewAsUsers, like in we do it `set viewAsUsers` will trigger this to re-run
    caseCategoryPicklistValues = [];
    caseCategoryPicklistValuesWire;
    @wire(getCaseClassificationPicklistValues, {viewAsOptions: '$viewAsUsers'})
    gotCaseClassificationPicklistValues(result) {
        this.caseCategoryPicklistValuesWire = result;
        let {data, error} = this.caseCategoryPicklistValuesWire;
        if (data != null) {
            this.caseCategoryPicklistValues = this.buildPicklistOptionsArray(data);
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error('gotCaseClassificationPicklistValues', error);
        }
        this.checkInitialLoadingComplete();
    }

    academicProgramOptions = [];
    academicProgramOptionsWire;
    @wire(getAcademicProgramPicklistValues, {})
    gotAcademicProgramPicklistValues(result) {
        this.academicProgramOptionsWire = result;
        let {data, error} = this.academicProgramOptionsWire;
        if (data != null) {
            const newAcademicProgramOptions = [{label: '--None--', value: ''}];
            const allOtherOptions = this.buildPicklistOptionsArray(data);
            for (let i = 0; i < allOtherOptions.length; i++) {
                newAcademicProgramOptions.push(allOtherOptions[i]);
            }
            this.academicProgramOptions = newAcademicProgramOptions;
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error('gotAcademicProgramPicklistValues', error);
        }
        this.checkInitialLoadingComplete();
    }

    schoolDepartmentOptions = [];
    schoolDepartmentOptionsWire;
    @wire(getSchoolDepartmentPicklistVaues, {filterJSON: '$currentFilterJSON'})
    gotSchoolDepartmentPicklistVaues(result) {
        this.schoolDepartmentOptionsWire = result;
        let {data, error} = this.schoolDepartmentOptionsWire;
        if (data != null) {
            const newSchoolDepartmentOptions = [{label: '--None--', value: ''}];
            const allOtherOptions = this.buildPicklistOptionsArray(data);
            for (let i = 0; i < allOtherOptions.length; i++) {
                newSchoolDepartmentOptions.push(allOtherOptions[i]);
            }
            this.schoolDepartmentOptions = newSchoolDepartmentOptions;
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error('gotSchoolDepartmentPicklistVaues', error);
        }
        this.checkInitialLoadingComplete();
    }

    academicPlanOptions = [];
    academicPlanOptionsWire;
    @wire(getAcademicPlanPicklistValues, {filterJSON: '$currentFilterJSON'})
    gotAcademicPlanPicklistValues(result) {
        this.academicPlanOptionsWire = result;
        let {data, error} = this.academicPlanOptionsWire;
        if (data != null) {
            const newAcademicPlanOptions = [{label: '--None--', value: ''}];
            const allOtherOptions = this.buildPicklistOptionsArray(data);
            for (let i = 0; i < allOtherOptions.length; i++) {
                newAcademicPlanOptions.push(allOtherOptions[i]);
            }
            this.academicPlanOptions = newAcademicPlanOptions;
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error('gotAcademicPlanPicklistValues', error);
        }
        this.checkInitialLoadingComplete();
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
        {label: '--None--', value: ''},
        {label: 'Masters', value: 'masters'},
        {label: 'Doctorate', value: 'doctorate'},
        {label: 'Certificate', value: 'certificate'},
        {label: 'Non-degree', value: 'non-degree'},
    ];
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

    initialLoad = true;
    connectedCallback() {
        // one for initial load
        this.sendLoadingEvent(true);
    }

    changeField(event) {
        const fieldChanged = event.originalTarget.name;
        const newValue = event.detail.value;
        this.currentFilter[fieldChanged] = newValue;

        this.updateConditionalFields();

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
    // Send a loading decrement after all components have loaded
    checkInitialLoadingComplete() {
        if (this.initialLoad) {
            if (
                this.academicPlanOptionsWire != null &&
                this.schoolDepartmentOptionsWire != null &&
                this.academicProgramOptionsWire != null &&
                this.caseCategoryPicklistValuesWire != null &&
                this.caseSubjectPicklistValuesWire != null &&
                this.campusPicklistValuesWire != null &&
                this.caseStatusPicklistValuesWire != null &&
                this.residencyPicklistValuesWire != null
            ) {
                this.initialLoad = false;
                this.sendLoadingEvent(false);
            }
        }
    }

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

    // Update any filter fields where the options are dependent on the selection in some other picklist
    updateConditionalFields() {
        this.sendLoadingEvent(true);
        refreshApex(this.academicPlanOptionsWire)
            .catch((err) => {
                console.error(err);
            })
            .finally(() => {
                this.sendLoadingEvent(false);
            });
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
