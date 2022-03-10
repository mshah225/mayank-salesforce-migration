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
        this.refreshCaseSubjectPicklistValues();
        this.refreshCaseClassificationPicklistValues();
    }
    get viewAsUsers() {
        return this._viewAsUsers;
    }
    _viewAsUsers = [];

    @api set currentFilter(val) {
        if (this.filterIsDifferent(this.currentFilter, val)) {
            this.copyChanges(this.currentFilter, val);

            if (this.isGraduateOnly !== (this.currentFilter.career === 'GRD')) {
                this.sendLoadingEvent(true);
                // take the grad toggle change back a rendering cycle to ensure parent LWC can re-render and show loading circle while this completes
                // since this might take a bit if "Academic Plan" is rendering all options (700-ish)
                this.throwBackARenderCycle(() => {
                    this.isGraduateOnly = this.currentFilter.career === 'GRD';
                    this.sendLoadingEvent(false);
                });
                this.refreshCampusValues();
            }
        }
    }
    get currentFilter() {
        if (this._currentFilter == null) this._currentFilter = this.getEmptyFilter();
        return this._currentFilter;
    }
    _currentFilter;

    isGraduateOnly = false;

    // Imperative rather than wire to gain more precise control over when this triggers
    residencyPicklistValues = [];
    refreshResidencyPicklistValues() {
        this.sendLoadingEvent(true);
        getPicklistValues({objectName: 'Student_Program_Plan__c', fieldName: 'Residency__c'})
            .then((val) => {
                this.residencyPicklistValues = this.buildPicklistOptionsArray(val);
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('refreshResidencyPicklistValues', err);
            })
            .finally(() => {
                this.sendLoadingEvent(false);
            });
    }

    // Imperative rather than wire to gain more precise control over when this triggers
    caseStatusPicklistValues = [];
    refreshCaseStatusSettings() {
        this.sendLoadingEvent(true);
        getCaseStatusSettings()
            .then((val) => {
                this.caseStatusPicklistValues = this.buildPicklistOptionsArray(val);
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('refreshCaseStatusSettings', err);
            })
            .finally(() => {
                this.sendLoadingEvent(false);
            });
    }

    // Imperative rather than wire to gain more precise control over when this triggers
    campusPicklistValues = [];
    refreshCampusValues() {
        this.sendLoadingEvent(true);
        const filterJSON = JSON.stringify(this.currentFilter);
        getCampusValues({filterJSON})
            .then((val) => {
                this.campusPicklistValues = this.buildPicklistOptionsArray(val);
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('refreshCampusValues', err);
            })
            .finally(() => {
                this.sendLoadingEvent(false);
            });
    }

    // Imperative rather than wire to gain more precise control over when this triggers
    caseSubjectPicklistValues = [];
    refreshCaseSubjectPicklistValues() {
        this.sendLoadingEvent(true);
        getCaseSubjectPicklistValues({viewAsOptions: this.viewAsUsers})
            .then((val) => {
                this.caseSubjectPicklistValues = this.buildPicklistOptionsArray(val);
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('refreshCaseSubjectPicklistValues', err);
            })
            .finally(() => {
                this.sendLoadingEvent(false);
            });
    }

    // Imperative rather than wire to gain more precise control over when this triggers
    caseCategoryPicklistValues = [];
    refreshCaseClassificationPicklistValues() {
        this.sendLoadingEvent(true);
        getCaseClassificationPicklistValues({viewAsOptions: this.viewAsUsers})
            .then((val) => {
                this.caseCategoryPicklistValues = this.buildPicklistOptionsArray(val);
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('refreshCaseClassificationPicklistValues', err);
            })
            .finally(() => {
                this.sendLoadingEvent(false);
            });
    }

    // Imperative rather than wire to gain more precise control over when this triggers
    academicProgramOptions = [];
    refreshAcademicProgramPicklistValues() {
        this.sendLoadingEvent(true);
        getAcademicProgramPicklistValues()
            .then((val) => {
                const newAcademicProgramOptions = [{label: '--None--', value: ''}];
                const allOtherOptions = this.buildPicklistOptionsArray(val);
                for (let i = 0; i < allOtherOptions.length; i++) {
                    newAcademicProgramOptions.push(allOtherOptions[i]);
                }
                this.academicProgramOptions = newAcademicProgramOptions;
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('refreshAcademicProgramPicklistValues', err);
            })
            .finally(() => {
                this.sendLoadingEvent(false);
            });
    }

    // Imperative rather than wire to gain more precise control over when this triggers
    schoolDepartmentOptions = [];
    refreshSchoolDepartmentPicklistVaues() {
        this.sendLoadingEvent(true);
        const filterJSON = JSON.stringify(this.currentFilter);
        getSchoolDepartmentPicklistVaues({filterJSON})
            .then((val) => {
                const newSchoolDepartmentOptions = [{label: '--None--', value: ''}];
                const allOtherOptions = this.buildPicklistOptionsArray(val);
                for (let i = 0; i < allOtherOptions.length; i++) {
                    newSchoolDepartmentOptions.push(allOtherOptions[i]);
                }
                this.schoolDepartmentOptions = newSchoolDepartmentOptions;
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('refreshSchoolDepartmentPicklistVaues', err);
            })
            .finally(() => {
                this.sendLoadingEvent(false);
            });
    }

    // Imperative rather than wire to gain more precise control over when this triggers
    academicPlanOptions = [];
    refreshAcademicPlanPicklistValues() {
        this.sendLoadingEvent(true);
        const filterJSON = JSON.stringify(this.currentFilter);
        getAcademicPlanPicklistValues({filterJSON})
            .then((val) => {
                const newAcademicPlanOptions = [{label: '--None--', value: ''}];
                const allOtherOptions = this.buildPicklistOptionsArray(val);
                for (let i = 0; i < allOtherOptions.length; i++) {
                    newAcademicPlanOptions.push(allOtherOptions[i]);
                }
                this.academicPlanOptions = newAcademicPlanOptions;
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('gotAcademicPlanPicklistValues', err);
            })
            .finally(() => {
                this.sendLoadingEvent(false);
            });
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

    connectedCallback() {
        this.refreshResidencyPicklistValues();
        this.refreshCaseStatusSettings();
        this.refreshCampusValues();
        this.refreshCaseSubjectPicklistValues();
        this.refreshCaseClassificationPicklistValues();
        this.refreshAcademicProgramPicklistValues();
        this.refreshSchoolDepartmentPicklistVaues();
        this.refreshAcademicPlanPicklistValues();
    }

    changeField(event) {
        const fieldChanged = event.originalTarget.name;
        const newValue = event.detail.value;
        this.currentFilter[fieldChanged] = newValue;

        this.updateConditionalFields(fieldChanged);

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

    // Update any filter fields where the options are dependent on the selection in some other picklist
    updateConditionalFields(changedField) {
        if (changedField === 'degreeLevel') {
            this.refreshAcademicPlanPicklistValues();
        } else if (changedField === 'academicProgram') {
            this.refreshSchoolDepartmentPicklistVaues();
            this.refreshAcademicPlanPicklistValues();
        } else if (changedField === 'schoolDepartment') {
            this.refreshAcademicPlanPicklistValues();
        }
    }

    // Can throw a section of code outside the current rendering cycle - useful if we want to allow our parent LWC to complete a rendering cycle before
    // running this code (we primarily use this to ensure the parent either begins/stops the loading circle during otherwise blocking operations)
    throwBackARenderCycle(fn) {
        setTimeout(fn, 1);
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
