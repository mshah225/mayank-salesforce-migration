import {LightningElement, api} from 'lwc';
import getPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getPicklistValues';
import getCampusValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getCampusValues';
import getCaseStatusSettings from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseStatusSettings';
import getCaseSubjectPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseSubjectPicklistValues';
import getCaseClassificationPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseClassificationPicklistValues';
import getAcademicProgramPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getAcademicProgramPicklistValues';
import getSchoolDepartmentPicklistVaues from '@salesforce/apex/AdvisorPortalFilterSectionController.getSchoolDepartmentPicklistVaues';
import getAcademicPlanPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getAcademicPlanPicklistValues';

export default class AdvisorPortalFiltersSection extends LightningElement {
    // only load the default filter once
    @api set currentFilter(val) {
        if (val != null) {
            const newFilter = JSON.parse(JSON.stringify(val));
            if (!this.hasDoneInitialAsyncLoad) {
                // if first time
                this._currentFilter = newFilter;
                this.loadAfterAsyncComponents();
            } else {
                // subsequent times
                const oldCareer = this.currentFilter.career;
                const oldStateType = this.currentFilter.caseTypeState;
                const newCareer = newFilter.career;
                const newStateType = newFilter.caseTypeState;

                this._currentFilter = newFilter;

                if (oldCareer !== newCareer) {
                    // Mostly just need to update visuals.
                    // Whenever career is changed it'll trigger the UserSelect component to raise a changeusers event,
                    // which will, in turn set our viewAsUsers, cause us to reapply the filters
                    this.isGraduateOnly = newCareer === 'GRD';
                    this.updateConditionalFields('career');
                } else if (oldStateType !== newStateType) {
                    this.applyFilters();
                }
            }
        }
    }
    get currentFilter() {
        return this._currentFilter;
    }
    _currentFilter = null;

    @api set viewAsUsers(val) {
        this._viewAsUsers = JSON.parse(JSON.stringify(val));
        if (!this.hasDoneInitialAsyncLoad) {
            // if first time
            this.loadAfterAsyncComponents();
        } else {
            // subsequent times
            this.loadingCaseStatus = true;
            this.loadingCaseCategory = true;

            Promise.all([
                this.refreshCaseSubjectPicklistValues().then(() => {
                    this.loadingCaseStatus = false;
                }),
                this.refreshCaseClassificationPicklistValues().then(() => {
                    this.loadingCaseCategory = false;
                }),
            ]).then(() => {
                this.applyFilters();
            });
        }
    }
    get viewAsUsers() {
        return this._viewAsUsers;
    }
    _viewAsUsers = null;

    // will run once all async components are loaded in
    hasDoneInitialAsyncLoad = false;
    loadAfterAsyncComponents() {
        if (this.hasDoneInitialAsyncLoad) return;
        if (this.viewAsUsers === null) return;
        if (this.currentFilter === null) return;
        // Set filter as the default
        this.isGraduateOnly = this.currentFilter.career === 'GRD';

        this.sendLoadingEvent(true);
        this.sendLoadingEvent(true);
        this.sendLoadingEvent(true);
        this.sendLoadingEvent(true);
        this.sendLoadingEvent(true);
        this.sendLoadingEvent(true);
        this.sendLoadingEvent(true);
        this.sendLoadingEvent(true);
        Promise.all([
            this.refreshResidencyPicklistValues().then(() => {
                this.sendLoadingEvent(false);
            }),
            this.refreshCaseStatusSettings().then(() => {
                this.sendLoadingEvent(false);
            }),
            this.refreshCampusValues().then(() => {
                this.sendLoadingEvent(false);
            }),
            this.refreshCaseSubjectPicklistValues().then(() => {
                this.sendLoadingEvent(false);
            }),
            this.refreshCaseClassificationPicklistValues().then(() => {
                this.sendLoadingEvent(false);
            }),
            this.refreshAcademicProgramPicklistValues().then(() => {
                this.sendLoadingEvent(false);
            }),
            this.refreshSchoolDepartmentPicklistVaues().then(() => {
                this.sendLoadingEvent(false);
            }),
            this.refreshAcademicPlanPicklistValues().then(() => {
                this.sendLoadingEvent(false);
            }),
        ]).then(() => {
            this.hasDoneInitialAsyncLoad = true;
            this.applyFilters();
        });
    }

    isGraduateOnly = false;

    loadingCampusValues = false;
    loadingSchoolDepartment = false;
    loadingAcadPlan = false;
    loadingCaseStatus = false;
    loadingCaseCategory = false;

    // Imperative rather than wire to gain more precise control over when this triggers
    residencyPicklistValues = [];
    refreshResidencyPicklistValues() {
        return getPicklistValues({objectName: 'Student_Program_Plan__c', fieldName: 'Residency__c'})
            .then((val) => {
                this.residencyPicklistValues = this.buildPicklistOptionsArray(val);
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('refreshResidencyPicklistValues', err);
            });
    }

    // Imperative rather than wire to gain more precise control over when this triggers
    caseStatusPicklistValues = [];
    refreshCaseStatusSettings() {
        return getCaseStatusSettings()
            .then((val) => {
                this.caseStatusPicklistValues = this.buildPicklistOptionsArray(val);
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('refreshCaseStatusSettings', err);
            });
    }

    // Imperative rather than wire to gain more precise control over when this triggers
    campusPicklistValues = [];
    refreshCampusValues() {
        const filterJSON = JSON.stringify(this.currentFilter);
        return getCampusValues({filterJSON})
            .then((val) => {
                this.campusPicklistValues = this.buildPicklistOptionsArray(val);
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('refreshCampusValues', err);
            });
    }

    // Imperative rather than wire to gain more precise control over when this triggers
    caseSubjectPicklistValues = [];
    refreshCaseSubjectPicklistValues() {
        const filterJSON = JSON.stringify(this.currentFilter);
        return getCaseSubjectPicklistValues({filterJSON, viewAsOptions: this.viewAsUsers})
            .then((val) => {
                this.caseSubjectPicklistValues = this.buildPicklistOptionsArray(val);
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('refreshCaseSubjectPicklistValues', err);
            });
    }

    // Imperative rather than wire to gain more precise control over when this triggers
    caseCategoryPicklistValues = [];
    refreshCaseClassificationPicklistValues() {
        const filterJSON = JSON.stringify(this.currentFilter);
        return getCaseClassificationPicklistValues({filterJSON, viewAsOptions: this.viewAsUsers})
            .then((val) => {
                this.caseCategoryPicklistValues = this.buildPicklistOptionsArray(val);
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('refreshCaseClassificationPicklistValues', err);
            });
    }

    // Imperative rather than wire to gain more precise control over when this triggers
    academicProgramOptions = [];
    refreshAcademicProgramPicklistValues() {
        return getAcademicProgramPicklistValues()
            .then((val) => {
                this.academicProgramOptions = this.buildPicklistOptionsArray(val);
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('refreshAcademicProgramPicklistValues', err);
            });
    }

    // Imperative rather than wire to gain more precise control over when this triggers
    schoolDepartmentOptions = [];
    refreshSchoolDepartmentPicklistVaues() {
        const filterJSON = JSON.stringify(this.currentFilter);
        return getSchoolDepartmentPicklistVaues({filterJSON})
            .then((val) => {
                this.schoolDepartmentOptions = this.buildPicklistOptionsArray(val);
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('refreshSchoolDepartmentPicklistVaues', err);
            });
    }

    // Imperative rather than wire to gain more precise control over when this triggers
    academicPlanOptions = [];
    refreshAcademicPlanPicklistValues() {
        const filterJSON = JSON.stringify(this.currentFilter);
        return getAcademicPlanPicklistValues({filterJSON})
            .then((val) => {
                this.academicPlanOptions = this.buildPicklistOptionsArray(val);
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('gotAcademicPlanPicklistValues', err);
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
        {label: 'Masters', value: 'masters'},
        {label: 'Doctorate', value: 'doctorate'},
        {label: 'Certificate', value: 'certificate'},
        {label: 'Non-degree', value: 'non-degree'},
    ];
    specialPopulationOptions = [
        {label: 'Accelerated 4+1 Degrees', value: 'accelerated 4+1 degrees'},
        {label: 'Format Students', value: 'format students'},
        {label: 'Provivisional Admits, not met yet', value: 'provivisional admits, not met yet'},
        {label: 'Veterans', value: 'veterans'},
        {label: 'Applied to Graduate', value: 'applied to graduate'},
        {label: 'Mayo Students', value: 'mayo students'},
        {label: 'Cintana Students', value: 'cintana students'},
        {label: 'Concurrent Enrollment', value: 'concurrent enrollment'},
        {label: 'Active Students with Registation Hold', value: 'active students with registation hold'},
    ];

    /**
     * Handle an change field event - update filter object to contain new value and trigger and conditional fields
     * @param {changeEvent} event
     */
    changeField(event) {
        const fieldChanged = event.currentTarget.dataset.name;
        const newValue = event.currentTarget.value;
        const oldValue = this.currentFilter[fieldChanged];
        if (oldValue !== newValue) {
            this.currentFilter[fieldChanged] = newValue;
            this.updateConditionalFields(fieldChanged);
            this.updateValidityChecks(fieldChanged);
            this.sendChangeFilterEvent(fieldChanged, newValue);
        }

        this.stopEvent(event);
    }

    stopEvent(e) {
        e.stopPropagation();
        e.stopImmediatePropagation();
        e.preventDefault();
    }

    /**
     * Clear all filters
     */
    clearFilters() {
        const clearFilter = this.getEmptyFilter();
        clearFilter.caseTypeState = this.currentFilter.caseTypeState;
        clearFilter.career = this.currentFilter.career;
        this._currentFilter = clearFilter;

        // visually clear every field
        for (let i = 0; i < this.filterPropertyList.length; i++) {
            const field = this.filterPropertyList[i];

            // don't reset these two fields
            if (field === 'caseTypeState' || field === 'career') continue;

            // send clear event for every field
            this.sendChangeFilterEvent(field, '');
        }

        // Visually clear all the fields
        const lightningInputs = this.template.querySelectorAll('lightning-input, c-lightning-combo-box');
        for (let i = 0; i < lightningInputs.length; i++) {
            lightningInputs[i].value = '';
        }

        this.applyFilters();
    }

    /**
     * Reports the validity of all fields
     * @returns validity of all fields
     */
    reportValidity() {
        let valid = true;

        // check that every input field is valid (only really verifying ranges, and those are all lightning-inputs)
        const lightningInputs = this.template.querySelectorAll('lightning-input');
        for (let i = 0; i < lightningInputs.length; i++) {
            const element = lightningInputs[i];
            valid &= element.reportValidity();
        }

        return valid;
    }

    applyFilters() {
        this.dispatchEvent(new CustomEvent('submit', {detail: {}}));
    }

    /**
     * Helper functions
     */
    admitTermFromPattern = '[0-2][0-9]{2}[1,4,7]';
    admitTermFromPatternMismatchError = 'Should be a valid Peoplesoft term code.';
    admitTermToPattern = '[0-2][0-9]{2}[1,4,7]';
    admitTermToPatternMismatchError = 'Should be a valid Peoplesoft term code.';

    /**
     * Copy only the fields that are different from filterB to filterA
     * @param {AdvisorPortalFilter} filterA
     * @param {AdvisorPortalFilter} filterB
     */
    copyChanges(filterA, filterB) {
        for (let i = 0; i < this.filterPropertyList.length; i++) {
            const propertyName = this.filterPropertyList[i];
            if (filterB[propertyName] != null && filterA[propertyName] !== filterB[propertyName])
                filterA[propertyName] = filterB[propertyName];
        }
    }

    /**
     * Check if filterA and filterB disagree
     * @param {AdvisorPortalFilter} filterA
     * @param {AdvisorPortalFilter} filterB
     * @returns true if different
     */
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

    /**
     * Update an interdependent fields (such as dates being before/after as appropriate)
     * @param {String} changedField
     */
    updateValidityChecks(changedField) {
        if (changedField === 'admitTermFrom' || changedField === 'admitTermTo') {
            const fromTerm = this.currentFilter.admitTermFrom;
            const toTerm = this.currentFilter.admitTermTo;
            const fromTermComponent = this.template.querySelector('[data-name="admitTermFrom"]');
            const toTermComponent = this.template.querySelector('[data-name="admitTermTo"]');

            if (
                fromTerm != null &&
                fromTerm !== '' &&
                toTerm != null &&
                toTerm !== '' &&
                fromTerm.length === 4 &&
                toTerm.length === 4
            ) {
                try {
                    if (parseInt(toTerm, 10) < parseInt(fromTerm, 10)) {
                        toTermComponent.setCustomValidity('To term should be after the From term');
                        fromTermComponent.setCustomValidity('From term should be before the To term');
                    } else {
                        toTermComponent.setCustomValidity('');
                        fromTermComponent.setCustomValidity('');
                    }
                } catch (err) {
                    // eslint-disable-next-line no-console
                    console.error(err);
                }
            } else {
                toTermComponent.setCustomValidity('');
                fromTermComponent.setCustomValidity('');
            }
        } else if (changedField === 'createdFromDate' || changedField === 'createdToDate') {
            const fromDate = this.currentFilter.createdFromDate;
            const toDate = this.currentFilter.createdToDate;
            this.createdFromDateForRangeCheck = fromDate;
            this.createdToDateForRangeCheck = toDate;
        } else if (changedField === 'followUpFromDate' || changedField === 'followUpToDate') {
            const fromDate = this.currentFilter.followUpFromDate;
            const toDate = this.currentFilter.followUpToDate;
            this.followUpFromDateForRangeCheck = fromDate;
            this.followUptoDateForRangeCheck = toDate;
        } else if (changedField === 'persistenceFromDate' || changedField === 'persistenceToDate') {
            const fromDate = this.currentFilter.persistenceFromDate;
            const toDate = this.currentFilter.persistenceToDate;
            this.persistenceFromDateForRangeCheck = fromDate;
            this.persistenceToDateForRangeCheck = toDate;
        }
    }
    // Use these to verify date ranges are valid - enables us to trigger the re-render without replacing the filter object
    createdToDateForRangeCheck;
    createdFromDateForRangeCheck;
    followUpFromDateForRangeCheck;
    followUptoDateForRangeCheck;
    persistenceFromDateForRangeCheck;
    persistenceToDateForRangeCheck;

    /**
     * Update any filter fields where the options are dependent on the selection in some other picklist
     * @param {String} changedField
     */
    updateConditionalFields(changedField) {
        if (changedField === 'career') {
            this.loadingCampusValues = true;
            this.refreshCampusValues().then(() => {
                this.loadingCampusValues = false;
            });
        } else if (changedField === 'degreeLevel') {
            this.loadingAcadPlan = true;
            this.refreshAcademicPlanPicklistValues().then(() => {
                this.loadingAcadPlan = false;
            });
        } else if (changedField === 'academicProgram') {
            this.loadingSchoolDepartment = true;
            this.refreshSchoolDepartmentPicklistVaues().then(() => {
                this.loadingSchoolDepartment = false;
            });

            this.loadingAcadPlan = true;
            this.refreshAcademicPlanPicklistValues().then(() => {
                this.loadingAcadPlan = false;
            });
        } else if (changedField === 'schoolDepartment') {
            this.loadingAcadPlan = true;
            this.refreshAcademicPlanPicklistValues().then(() => {
                this.loadingAcadPlan = false;
            });
        }
    }

    /**
     * Convert returned picklist map into array of options for comboboxes
     * @param {Map} optionsMap
     * @returns label-value array
     */
    buildPicklistOptionsArray(optionsMap) {
        let optionsList = [];

        Object.keys(optionsMap).forEach(function (key) {
            optionsList.push({label: key, value: optionsMap[key]});
        });

        return optionsList;
    }

    /**
     * Generate an "empty" filter object, with default values
     * @returns an AdvisorPortalFilter that is as empty as permitted
     */
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

    /**
     * Raise an event to change the filter in the parent
     * @param {String} name
     * @param {String} value
     */
    sendChangeFilterEvent(name, value) {
        this.dispatchEvent(
            new CustomEvent('change', {
                detail: {name, value},
            })
        );
    }

    /**
     * Raise an event to increase or decrease the loading counter
     * @param {Boolean} loadMore
     */
    sendLoadingEvent(loadMore) {
        this.dispatchEvent(new CustomEvent('loading', {detail: loadMore}));
    }
}
