import {LightningElement, api} from 'lwc';
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
                this.academicProgramOptions = this.buildPicklistOptionsArray(val);
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
                this.schoolDepartmentOptions = this.buildPicklistOptionsArray(val);
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
                this.academicPlanOptions = this.buildPicklistOptionsArray(val);
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

    /**
     * Handle an change field event - update filter object to contain new value and trigger and conditional fields
     * @param {changeEvent} event
     */
    changeField(event) {
        const fieldChanged = event.originalTarget.name;
        const newValue = event.detail.value;
        this.currentFilter[fieldChanged] = newValue;

        this.updateConditionalFields(fieldChanged);
        this.updateValidityChecks(fieldChanged);

        event.stopPropagation();
        event.stopImmediatePropagation();
        event.preventDefault();

        this.sendChangeFilterEvent(fieldChanged, newValue);
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
            const element = this.template.querySelector('[data-name="' + field + '"]');

            // send clear event for every field
            this.sendChangeFilterEvent(field, '');

            // so long as the field is visibile, clear it visually
            if (element != null) {
                try {
                    element.value = '';
                } catch (err) {
                    console.error(err);
                }
            }
        }

        this.applyFilters();
    }

    /**
     * Reports the validity of all fields
     * @returns validity of all fields
     */
    reportValidity() {
        let valid = true;

        // check that every field is valid
        for (let i = 0; i < this.filterPropertyList.length; i++) {
            const field = this.filterPropertyList[i];
            const element = this.template.querySelector('[data-name="' + field + '"]');
            // so long as the field is visibile, report if valid (if null then it is a disabled field because
            // it is either a grad only field and the user is in undergrad mode, or the other way around)
            if (element != null) {
                valid &= element.reportValidity();
            }
        }

        return valid;
    }

    /**
     * Reload the previously applied filter (don't regenerate the JSON, use whichever JSON more recent request was used with)
     */
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

    /**
     * Apply the current filters
     */
    applyFilters() {
        if (!this.reportValidity()) {
            return; // don't apply if not valid
        }

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
        if (changedField === 'degreeLevel') {
            this.refreshAcademicPlanPicklistValues();
        } else if (changedField === 'academicProgram') {
            this.refreshSchoolDepartmentPicklistVaues();
            this.refreshAcademicPlanPicklistValues();
        } else if (changedField === 'schoolDepartment') {
            this.refreshAcademicPlanPicklistValues();
        }
    }

    /**
     * Can throw a section of code outside the current rendering cycle - useful if we want to allow our parent LWC to complete a rendering cycle before
     * running this code (we primarily use this to ensure the parent either begins/stops the loading circle during otherwise blocking operations)
     * @param {Function} fn
     */
    throwBackARenderCycle(fn) {
        setTimeout(fn, 1);
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
     * @param {String|Integer} value
     */
    sendChangeFilterEvent(name, value) {
        this.dispatchEvent(
            new CustomEvent('change', {
                detail: {name, value},
            })
        );
    }

    /**
     * Raise an event of the matched AdvisorPortalContacts
     * @param {List<AdvisorPortalContact>} results
     */
    sendChangeResultsEvent(results) {
        this.dispatchEvent(
            new CustomEvent('setresults', {
                detail: results,
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
