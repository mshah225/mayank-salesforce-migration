import {LightningElement, api} from 'lwc';
import {cloneObj} from 'c/helperFunctions';

export default class AdvisorPortalFiltersSection extends LightningElement {
    // Loaded because default filter - and from career/viewstate that are controlled in other components
    // whenever filter is set, we might need to act depending on what changed
    @api set currentFilter(val) {
        if (val != null) {
            const newFilter = cloneObj(val);
            this._currentFilter = newFilter;
        }
    }
    get currentFilter() {
        return this._currentFilter;
    }
    _currentFilter = null;

    @api set viewAsUsers(val) {
        this._viewAsUsers = cloneObj(val);
    }
    get viewAsUsers() {
        return this._viewAsUsers;
    }
    _viewAsUsers = null;

    get isGraduateOnly() {
        return this.currentFilter != null && this.currentFilter.career === 'GRD';
    }

    // Flags to set the loading circle next to each section
    @api loadingCampusValues = false;
    @api loadingSchoolDepartment = false;
    @api loadingAcadPlan = false;
    @api loadingCaseStatus = false;
    @api loadingCaseCategory = false;

    // For each of the @api specified picklist options we MUST convert the proxy object to a non-proxy object
    // before passing it to the lightningComboBox.  If we don't when the array gets to the lightningComboBox
    // it'll be a Proxy of a Proxy of an array (rather than just a Proxy of an array) which is unuseably slow
    @api set residencyPicklistValues(val) {
        this._residencyPicklistValues = cloneObj(val);
    }
    get residencyPicklistValues() {
        return this._residencyPicklistValues;
    }
    _residencyPicklistValues = [];
    @api set caseStatusPicklistValues(val) {
        this._caseStatusPicklistValues = cloneObj(val);
    }
    get caseStatusPicklistValues() {
        return this._caseStatusPicklistValues;
    }
    _caseStatusPicklistValues = [];
    @api set campusPicklistValues(val) {
        this._campusPicklistValues = cloneObj(val);
    }
    get campusPicklistValues() {
        return this._campusPicklistValues;
    }
    _campusPicklistValues = [];
    @api set caseSubjectPicklistValues(val) {
        this._caseSubjectPicklistValues = cloneObj(val);
    }
    get caseSubjectPicklistValues() {
        return this._caseSubjectPicklistValues;
    }
    _caseSubjectPicklistValues = [];
    @api set caseCategoryPicklistValues(val) {
        this._caseCategoryPicklistValues = cloneObj(val);
    }
    get caseCategoryPicklistValues() {
        return this._caseCategoryPicklistValues;
    }
    _caseCategoryPicklistValues = [];
    @api set academicProgramOptions(val) {
        this._academicProgramOptions = cloneObj(val);
    }
    get academicProgramOptions() {
        return this._academicProgramOptions;
    }
    _academicProgramOptions = [];
    @api set schoolDepartmentOptions(val) {
        this._schoolDepartmentOptions = cloneObj(val);
    }
    get schoolDepartmentOptions() {
        return this._schoolDepartmentOptions;
    }
    _schoolDepartmentOptions = [];
    @api set academicPlanOptions(val) {
        this._academicPlanOptions = cloneObj(val);
    }
    get academicPlanOptions() {
        return this._academicPlanOptions;
    }
    _academicPlanOptions = [];

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
        {label: 'Accelerated Masters', value: 'accelerated 4+1 degrees'},
        {label: 'Format Students', value: 'format students'},
        {label: 'Provisional Admits, not met yet', value: 'provivisional admits, not met yet'},
        {label: 'Veterans', value: 'veterans'},
        {label: 'Applied to Graduate', value: 'applied to graduate'},
        {label: 'Mayo Students', value: 'mayo students'},
        {label: 'Cintana Students', value: 'cintana students'},
        {label: 'Research Assistants', value: 'research assistants'},
        {label: 'Teaching Assistants', value: 'teaching assistants'},
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

    closeTooltipOnEscape(e) {
        if (e.key === 'Escape') {
            const target = e.currentTarget;
            const targetParent = target.parentElement;
            const tooltip = targetParent.querySelector('.tooltip');
            tooltip.classList.add('tooltip-escaped');
        }
    }
    resetTooltipState(e) {
        const target = e.currentTarget;
        const targetParent = target.parentElement;
        const tooltip = targetParent.querySelector('.tooltip');
        tooltip.classList.remove('tooltip-escaped');
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

    /**
     * Raises a "submit" event to apply the current filters
     */
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
