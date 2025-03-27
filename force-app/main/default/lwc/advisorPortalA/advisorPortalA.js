import {LightningElement, wire} from 'lwc';
import LightningPrompt from 'lightning/prompt';

import getAccessModes from '@salesforce/apex/AdvisorPortalFilterSectionController.getAccessModes';
import getUsersAndPods from '@salesforce/apex/AdvisorPortalFilterSectionController.getUsersAndPods';
import getPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getPicklistValues';
import getCampusValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getCampusValues';
import getAcademicProgramPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getAcademicProgramPicklistValues';
import getSchoolDepartmentPicklistVaues from '@salesforce/apex/AdvisorPortalFilterSectionController.getSchoolDepartmentPicklistVaues';
import getAcademicPlanPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getAcademicPlanPicklistValues';
import getCaseStatusSettings from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseStatusSettings';
import getCaseClassificationPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseClassificationPicklistValues';
import getCaseSubClassificationPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseSubClassificationPicklistValues';
import getCaseSubjectPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseSubjectPicklistValues';
import getFilteredCases from '@salesforce/apex/AdvisorPortalFilterSectionController.getFilteredCases';

import STUDENT_PROGRAM_PLAN_OBJECT from '@salesforce/schema/Student_Program_Plan__c';
import STUDENT_PROGRAM_PLAN_RESIDENCY from '@salesforce/schema/Student_Program_Plan__c.Residency__c';

import FilterSetsModal from 'c/filterSetsModal';
import LightningCaseTransferModal from 'c/lightningCaseTransferModal';
import AdvisorPortalModalMassEmail from 'c/advisorPortalModalMassEmail';
import AdvisorPortalModalMassClose from 'c/advisorPortalModalMassClose';
import submitFeedback from '@salesforce/apex/FeedbackButtonService.submitFeedback';
import createTicket from '@salesforce/apex/JiraCallout.createTicket';

import {extractErrorMessages} from 'c/helperFunctions';

export default class AdvisorPortalA extends LightningElement {
    /**
     * Override filter or get the filter as a single object
     */
    set currentFilter(v) {
        this.caseTypeState = v.caseTypeState || '';
        this.career = v.career || '';
        this.ownerIds = v.ownerIds || '';
        this.studentString = v.studentString || '';
        this.campus = v.campus || '';
        this.academicLevel = v.academicLevel || '';
        this.studentGroupCode = v.studentGroupCode || '';
        this.major = v.major || '';
        this.degreeLevel = v.degreeLevel || '';
        this.academicProgram = v.academicProgram || '';
        this.schoolDepartment = v.schoolDepartment || '';
        this.academicPlan = v.academicPlan || '';
        this.admitTermFrom = v.admitTermFrom || '';
        this.admitTermTo = v.admitTermTo || '';
        this.residency = v.residency || '';
        this.caseStatus = v.caseStatus || '';
        this.caseCategory = v.caseCategory || '';
        this.caseSubCategory = v.caseSubCategory || '';
        this.caseSubject = v.caseSubject || '';
        this.specialPopulation = v.specialPopulation || '';
        this.outlookScore = v.outlookScore || '';
        this.outlookChange = v.outlookChange || '';
        this.caseCount = v.caseCount || '';
        this.createdFromDate = v.createdFromDate || '';
        this.createdToDate = v.createdToDate || '';
        this.followUpFromDate = v.followUpFromDate || '';
        this.followUpToDate = v.followUpToDate || '';
        this.persistenceFromDate = v.persistenceFromDate || '';
        this.persistenceToDate = v.persistenceToDate || '';
    }
    get currentFilter() {
        return {
            caseTypeState: this.caseTypeState,
            career: this.career,
            ownerIds: this.ownerIds,
            studentString: this.studentString,
            campus: this.campus,
            studentGroupCode: this.studentGroupCode,
            major: this.major,
            degreeLevel: this.degreeLevel,
            academicProgram: this.academicProgram,
            schoolDepartment: this.schoolDepartment,
            academicPlan: this.academicPlan,
            admitTermFrom: this.admitTermFrom,
            admitTermTo: this.admitTermTo,
            residency: this.residency,
            caseStatus: this.caseStatus,
            caseCategory: this.caseCategory,
            caseSubCategory: this.caseSubCategory,
            caseSubject: this.caseSubject,
            specialPopulation: this.specialPopulation,
            outlookScore: this.outlookScore,
            outlookChange: this.outlookChange,
            caseCount: this.caseCount,
            createdFromDate: this.createdFromDate,
            createdToDate: this.createdToDate,
            followUpFromDate: this.followUpFromDate,
            followUpToDate: this.followUpToDate,
            persistenceFromDate: this.persistenceFromDate,
            persistenceToDate: this.persistenceToDate,
        };
    }
    appliedFilter;

    /***********************************************************************
     **********                  Get/Set filters                  **********
     ***********************************************************************/
    get gradMode() {
        return this.career === 'GRD';
    }
    get ugradMode() {
        return this.career === 'UGRD';
    }

    get career() {
        return this._career ?? '';
    }
    set career(v) {
        if (v === this.career) return;
        this._career = v;

        this.loadingUsersAndPodOptions = true;
        this.loadingCampusOptions = true;
        this.loadingCaseCategoryOptions = true;
        this.loadingCaseSubCategoryOptions = true;
        this.loadingCaseSubjectOptions = true;
    }
    /** @type {"GRD"|"UGRD"} */
    _career;

    get ownerIds() {
        return this._ownerIds ?? '';
    }
    set ownerIds(v) {
        if (v === this.ownerIds) return;
        this._ownerIds = v;

        this.loadingCaseCategoryOptions = true;
        this.loadingCaseSubCategoryOptions = true;
        this.loadingCaseSubjectOptions = true;
    }
    _ownerIds;

    get caseTypeState() {
        return this._caseTypeState ?? 'ProactiveCasesState';
    }
    set caseTypeState(v) {
        if (v === this.caseTypeState) return;
        this._caseTypeState = v;
    }
    /** @type {"AllCasesState"|"ProactiveCasesState"|"WatchlistCasesState"} */
    _caseTypeState;

    get studentString() {
        return this._studentString ?? '';
    }
    set studentString(v) {
        if (v === this.studentString) return;
        this._studentString = v;
    }
    /** @type {String} */
    _studentString;

    get campus() {
        return this._campus ?? '';
    }
    set campus(v) {
        if (v === this.campus) return;
        this._campus = v;
    }
    /** @type {String} */
    _campus;

    get degreeLevel() {
        return this._degreeLevel ?? '';
    }
    set degreeLevel(v) {
        if (v === this.degreeLevel) return;
        this._degreeLevel = v;

        this.loadingAcadPlanOptions = true;
    }
    /** @type {String} */
    _degreeLevel;

    get academicProgram() {
        return this._academicProgram ?? '';
    }
    set academicProgram(v) {
        if (v === this.academicProgram) return;
        this._academicProgram = v;

        this.loadingSchoolDepartmentOptions = true;
        this.loadingAcadPlanOptions = true;
    }
    /** @type {String} */
    _academicProgram;

    get schoolDepartment() {
        return this._schoolDepartment ?? '';
    }
    set schoolDepartment(v) {
        if (v === this.schoolDepartment) return;
        this._schoolDepartment = v;

        this.loadingAcadPlanOptions = true;
    }
    /** @type {String} */
    _schoolDepartment;

    get academicPlan() {
        return this._academicPlan ?? '';
    }
    set academicPlan(v) {
        if (v === this.academicPlan) return;
        this._academicPlan = v;
    }
    /** @type {String} */
    _academicPlan;

    get admitTermFrom() {
        return this._admitTermFrom ?? '';
    }
    set admitTermFrom(v) {
        if (v === this.admitTermFrom) return;
        this._admitTermFrom = v;
    }
    /** @type {String} */
    _admitTermFrom;

    get admitTermTo() {
        return this._admitTermTo ?? '';
    }
    set admitTermTo(v) {
        if (v === this.admitTermTo) return;
        this._admitTermTo = v;
    }
    /** @type {String} */
    _admitTermTo;

    get academicLevel() {
        return this._academicLevel ?? '';
    }
    set academicLevel(v) {
        if (v === this.academicLevel) return;
        this._academicLevel = v;
    }
    /** @type {String} */
    _academicLevel;

    get studentGroupCode() {
        return this._studentGroupCode ?? '';
    }
    set studentGroupCode(v) {
        if (v === this.studentGroupCode) return;
        this._studentGroupCode = v;
    }
    /** @type {String} */
    _studentGroupCode;

    get major() {
        return this._major ?? '';
    }
    set major(v) {
        if (v === this.major) return;
        this._major = v;
    }
    /** @type {String} */
    _major;

    get residency() {
        return this._residency ?? '';
    }
    set residency(v) {
        if (v === this.residency) return;
        this._residency = v;
    }
    /** @type {String} */
    _residency;

    get caseStatus() {
        return this._caseStatus ?? '';
    }
    set caseStatus(v) {
        if (v === this.caseStatus) return;
        this._caseStatus = v;
    }
    /** @type {String} */
    _caseStatus;

    get caseCategory() {
        return this._caseCategory ?? '';
    }
    set caseCategory(v) {
        if (v === this.caseCategory) return;
        this._caseCategory = v;

        this.loadingCaseSubCategoryOptions = true;
    }
    /** @type {String} */
    _caseCategory;

    get caseSubCategory() {
        return this._caseSubCategory ?? '';
    }
    set caseSubCategory(v) {
        if (v === this.caseSubCategory) return;
        this._caseSubCategory = v;
    }
    /** @type {String} */
    _caseSubCategory;

    get specialPopulation() {
        return this._specialPopulation ?? '';
    }
    set specialPopulation(v) {
        if (v === this.specialPopulation) return;
        this._specialPopulation = v;
    }
    /** @type {String} */
    _specialPopulation;

    get caseSubject() {
        return this._caseSubject ?? '';
    }
    set caseSubject(v) {
        if (v === this.caseSubject) return;
        this._caseSubject = v;
    }
    /** @type {String} */
    _caseSubject;

    get outlookScore() {
        return this._outlookScore ?? '';
    }
    set outlookScore(v) {
        if (v === this.outlookScore) return;
        this._outlookScore = v;
    }
    /** @type {String} */
    _outlookScore;

    get outlookChange() {
        return this._outlookChange ?? '';
    }
    set outlookChange(v) {
        if (v === this.outlookChange) return;
        this._outlookChange = v;
    }
    /** @type {String} */
    _outlookChange;

    get caseCount() {
        return this._caseCount ?? '';
    }
    set caseCount(v) {
        if (v === this.caseCount) return;
        this._caseCount = v;
    }
    /** @type {String} */
    _caseCount;

    set createdDateRange(v) {
        this.createdFromDate = v.from || '';
        this.createdToDate = v.to || '';
    }

    get createdFromDate() {
        return this._createdFromDate ?? '';
    }
    set createdFromDate(v) {
        if (v === this.createdFromDate) return;
        this._createdFromDate = v;
    }
    /** @type {String} */
    _createdFromDate;

    get createdToDate() {
        return this._createdToDate ?? '';
    }
    set createdToDate(v) {
        if (v === this.createdToDate) return;
        this._createdToDate = v;
    }
    /** @type {String} */
    _createdToDate;

    set followUpDateRange(v) {
        this.followUpFromDate = v.from || '';
        this.followUpToDate = v.to || '';
    }

    get followUpFromDate() {
        return this._followUpFromDate ?? '';
    }
    set followUpFromDate(v) {
        if (v === this.followUpFromDate) return;
        this._followUpFromDate = v;
    }
    /** @type {String} */
    _followUpFromDate;

    get followUpToDate() {
        return this._followUpToDate ?? '';
    }
    set followUpToDate(v) {
        if (v === this.followUpToDate) return;
        this._followUpToDate = v;
    }
    /** @type {String} */
    _followUpToDate;

    set persistenceChangeDateRange(v) {
        this.persistenceChangeFromDate = v.from || '';
        this.persistenceChangeToDate = v.to || '';
    }

    get persistenceChangeFromDate() {
        return this._persistenceChangeFromDate ?? '';
    }
    set persistenceChangeFromDate(v) {
        if (v === this.persistenceChangeFromDate) return;
        this._persistenceChangeFromDate = v;
    }
    /** @type {String} */
    _persistenceChangeFromDate;

    get persistenceChangeToDate() {
        return this._persistenceToDate ?? '';
    }
    set persistenceChangeToDate(v) {
        if (v === this.persistenceChangeToDate) return;
        this._persistenceToDate = v;
    }
    /** @type {String} */
    _persistenceToDate;

    /***********************************************************************
     **********               Global wires for user               **********
     ***********************************************************************/

    /**
     * Check if the user has access to undergraduate or graduate advisor portal
     * Or, if they have access to neither, display an error
     */
    @wire(getAccessModes, {})
    gotAccessModes({data, error}) {
        if (data !== undefined) {
            if (data.length === 0) {
                this.accessModeError = new Error('User does not have access to the Advisor Portal');
            } else {
                this.accessModeError = undefined;
                this.career = data[0];

                if (data.length > 1) {
                    this.userIsBothGradAndUgrad = true;
                }
            }
        } else if (error !== undefined) {
            this.accessModeError = error;
        }
    }
    accessModeError;
    userIsBothGradAndUgrad = false;

    /***********************************************************************
     **********                 Dropdown options                  **********
     ***********************************************************************/

    /**
     * Career options are hardcoded
     */
    careerOptions = [
        {label: 'Undergraduate', value: 'UGRD'},
        {label: 'Graduate', value: 'GRD'},
    ];

    /**
     * Get options for the user/pods dropdown
     * This depends on the career
     */
    @wire(getUsersAndPods, {
        filterJSON: '$usersAndPodsPartialFilter',
    })
    gotUsersAndPods({data, error}) {
        if (data !== undefined) {
            this.loadingUsersAndPodOptions = false;
            this.allUsersAndPods = data.map((opt) => {
                let isLabel = opt.label.includes('--');
                return {
                    label: isLabel ? opt.label.replaceAll('--', '') : opt.label,
                    value: opt.value,
                    isLabel: isLabel,
                };
            });
            this.ownerIds = this.myQueueId;
        } else if (error !== undefined) {
            this.allUsersAndPodsError = error;
        }
    }
    allUsersAndPods;
    allUsersAndPodsError;
    get usersAndPodsPartialFilter() {
        return JSON.stringify({career: this.career});
    }
    loadingUsersAndPodOptions = true;
    /** @type {String} This users queue id */
    get myQueueId() {
        for (let option of this.allUsersAndPods ?? []) if (!option.isLabel) return option.value;
        return '';
    }

    /**
     * View cases or students?
     */
    caseTypeStateOptions = [
        {label: 'All Students', value: 'AllCasesState'},
        {label: 'Proactive Cases', value: 'ProactiveCasesState'},
        {label: 'Watchlist Cases', value: 'WatchlistCasesState'},
    ];

    /**
     * Get options for the campus dropdown
     * This depends on the career
     */
    @wire(getCampusValues, {
        filterJSON: '$campusPartialFilter',
    })
    gotCampusValues({data, error}) {
        if (data !== undefined) {
            this.loadingCampusOptions = false;
            this.campusOptions = data;
        } else if (error !== undefined) {
            this.campusError = error;
        }
    }
    campusOptions;
    campusError;
    get campusPartialFilter() {
        return JSON.stringify({career: this.career});
    }
    loadingCampusOptions = true;

    /**
     * Degree Levels are hardcoded
     */
    degreeLevelOptions = [
        {label: 'Certificate', value: 'certificate'},
        {label: 'Doctorate', value: 'doctorate'},
        {label: 'Masters', value: 'masters'},
        {label: 'Non-degree', value: 'non-degree'},
    ];

    /**
     * Academic Program options
     */
    @wire(getAcademicProgramPicklistValues, {})
    gotAcademicProgramPicklistValues({data, error}) {
        if (data !== undefined) {
            this.academicProgramOptions = data;
        } else if (error !== undefined) {
            this.academicProgramError = error;
        }
    }
    academicProgramOptions;
    academicProgramError;
    get loadingAcadProgramOptions() {
        return this.academicProgramOptions == null;
    }

    /**
     * Get options for school/department dropdown
     * This depends on the selected academic programs
     */
    @wire(getSchoolDepartmentPicklistVaues, {
        filterJSON: '$schoolDepartmentPartialFilter',
    })
    gotSchoolDepartmentPicklistVaues({data, error}) {
        if (data !== undefined) {
            this.loadingSchoolDepartmentOptions = false;
            this.schoolDepartmentOptions = data;
        } else if (error !== undefined) {
            this.schoolDepartmentError = error;
        }
    }
    schoolDepartmentOptions;
    schoolDepartmentError;
    get schoolDepartmentPartialFilter() {
        return JSON.stringify({academicProgram: this.academicProgram});
    }
    loadingSchoolDepartmentOptions = true;

    /**
     * Get options for academic plan dropdown
     * This depends on the degree level, academic program, and college/school department
     */
    @wire(getAcademicPlanPicklistValues, {
        filterJSON: '$academicPlanPartialFilter',
    })
    gotAcademicPlanPicklistValues({data, error}) {
        if (data !== undefined) {
            this.loadingAcadPlanOptions = false;
            this.academicPlanOptions = data;
        } else if (error !== undefined) {
            this.academicPlanError = error;
        }
    }
    academicPlanOptions;
    academicPlanError;
    get academicPlanPartialFilter() {
        return JSON.stringify({
            degreeLevel: this.degreeLevel,
            academicProgram: this.academicProgram,
            schoolDepartment: this.schoolDepartment,
        });
    }
    loadingAcadPlanOptions = true;

    /**
     * Academic Levels are hardcoded
     */
    academicLevelOptions = [
        {label: 'Freshman', value: 'Freshman'},
        {label: 'Sophomore', value: 'Sophomore'},
        {label: 'Junior', value: 'Junior'},
        {label: 'Senior', value: 'Senior'},
        {label: 'Graduate', value: 'Graduate'},
    ];

    /**
     * Get the options for residency
     */
    @wire(getPicklistValues, {
        objectName: STUDENT_PROGRAM_PLAN_OBJECT.objectApiName,
        fieldName: STUDENT_PROGRAM_PLAN_RESIDENCY.fieldApiName,
    })
    gotResidencyOptions({data, error}) {
        if (data !== undefined) {
            this.residencyOptions = data;
        } else if (error !== undefined) {
            this.residencyError = error;
        }
    }
    residencyOptions;
    residencyError;
    get loadingResidencyOptions() {
        return this.residencyOptions == null;
    }

    /**
     * Get case status options
     */
    @wire(getCaseStatusSettings, {})
    gotCaseStatusSettings({data, error}) {
        if (data !== undefined) {
            this.caseStatusOptions = data;
        } else if (error !== undefined) {
            this.caseStatusError = error;
        }
    }
    caseStatusOptions;
    caseStatusError;
    get loadingCaseStatusOptions() {
        return this.caseStatusOptions == null;
    }

    /**
     * Get options for case category dropdown
     * This depends on the career and ownerIds
     */
    @wire(getCaseClassificationPicklistValues, {
        filterJSON: '$caseCategoryPartialFilter',
    })
    gotCaseClassificationPicklistValues({data, error}) {
        if (data !== undefined) {
            this.loadingCaseCategoryOptions = false;
            this.caseCategoryOptions = data;
        } else if (error !== undefined) {
            this.caseCategoryError = error;
        }
    }
    caseCategoryOptions;
    caseCategoryError;
    get caseCategoryPartialFilter() {
        return JSON.stringify({
            career: this.career,
            ownerIds: this.ownerIds,
        });
    }
    loadingCaseCategoryOptions = true;

    /**
     * Get options for case subcategory dropdown
     * This depends on the career, ownerIds, and case category
     */
    @wire(getCaseSubClassificationPicklistValues, {
        filterJSON: '$caseSubCategoryPartialFilter',
    })
    gotCaseSubClassificationPicklistValues({data, error}) {
        if (data !== undefined) {
            this.loadingCaseSubCategoryOptions = false;
            this.caseSubCategoryOptions = data;
        } else if (error !== undefined) {
            this.caseSubCategoryError = error;
        }
    }
    caseSubCategoryOptions;
    caseSubCategoryError;
    get caseSubCategoryPartialFilter() {
        return JSON.stringify({
            career: this.career,
            ownerIds: this.ownerIds,
            caseCategory: this.caseCategory,
        });
    }
    loadingCaseSubCategoryOptions = true;

    /**
     * Special Population options are hardcoded
     */
    specialPopulationOptions = [
        {label: 'Accelerated Masters', value: 'accelerated 4+1 degrees'},
        {label: 'Active Students with Registation Hold', value: 'active students with registation hold'},
        {label: 'Applied to Graduate', value: 'applied to graduate'},
        {label: 'Cintana Students', value: 'cintana students'},
        {label: 'Concurrent Enrollment', value: 'concurrent enrollment'},
        {label: 'Format Students', value: 'format students'},
        {label: 'Personalized Graduate Admissions', value: 'personalized graduate admissions'},
        {label: 'Mayo Students', value: 'mayo students'},
        {label: 'Provisional Admits, not met yet', value: 'provivisional admits, not met yet'},
        {label: 'Research Assistants', value: 'research assistants'},
        {label: 'Teaching Assistants', value: 'teaching assistants'},
        {label: 'Veterans', value: 'veterans'},
    ];

    /**
     * Get options for case subcategory dropdown
     * This depends on the career, and ownerIds
     */
    @wire(getCaseSubjectPicklistValues, {
        filterJSON: '$caseSubjectPartialFilter',
    })
    gotCaseSubjectPicklistValues({data, error}) {
        if (data !== undefined) {
            this.loadingCaseSubjectOptions = false;
            this.caseSubjectOptions = data;
        } else if (error !== undefined) {
            this.caseSubjectError = error;
        }
    }
    caseSubjectOptions;
    caseSubjectError;
    get caseSubjectPartialFilter() {
        return JSON.stringify({
            career: this.career,
            ownerIds: this.ownerIds,
        });
    }
    loadingCaseSubjectOptions = true;

    /**
     * Outlook Score options are hardcoded
     */
    outlookScoreOptions = [
        {label: 'Very Low', value: 'very low'},
        {label: 'Low', value: 'low'},
        {label: 'Moderate', value: 'moderate'},
        {label: 'High', value: 'high'},
        {label: 'Very High', value: 'very high'},
    ];

    /**
     * Outlook Change options are hardcoded
     */
    outlookChangeOptions = [
        {label: 'Up', value: 'up'},
        {label: 'No change', value: 'no change'},
        {label: 'Down', value: 'down'},
    ];

    /***********************************************************************
     **********                 Most functions                    **********
     ***********************************************************************/

    /**
     * Add event listener to detect lightning toasts
     */
    connectedCallback() {
        // Listen for all standard toast events so we can toast using custom component (since normal toast events won't work in LWC-embedded on VF page)
        this.template.addEventListener('lightning__showtoast', (evnt) => {
            this.handleToast(evnt);
        });
    }

    /**
     * Apply the new user options
     */
    changeSelectedUsers(evnt) {
        this.ownerIds = evnt.detail.value;
        this.applyFilters();
    }

    /**
     * Change handler - all field-specific logic is in the setter function
     */
    changeField(evnt) {
        // Custom component all raise field name in event - for standard components grab it from the currentTarget
        const fieldName = evnt.detail?.name || evnt.currentTarget?.dataset?.name;
        const fieldValue = evnt.detail?.value || evnt.currentTarget?.value;

        if (fieldName != null) {
            this[fieldName] = fieldValue;
        }
    }

    /**
     * Reset all filters to empty
     */
    clearFilters() {
        this.currentFilter = {
            ownerIds: this.ownerIds,
            career: this.career,
            caseTypeState: 'ProactiveCasesState',
        };
        this.applyFilters();
    }

    /**
     * Apply filters and get contacts/cases
     */
    applyFilters() {
        this.appliedFilter = {...this.currentFilter};
        this.apply(this.currentFilter);
    }
    reapplyFilters() {
        if (this.appliedFilter != null) this.apply(this.appliedFilter);
    }
    allResults = [];
    isLoading = false;
    apply(filter) {
        this.isLoading = true;
        getFilteredCases({filterJSON: JSON.stringify(filter)})
            .then((val) => {
                this.allResults = val;
            })
            .catch((err) => {
                let errorStr = 'ERROR';
                try {
                    errorStr =
                        'Unexpected error while retrieving cases. ' +
                        extractErrorMessages(err)[0] +
                        '. More details can be found in the JS console.  You should open a bug ticket with the Salesforce team.';
                } catch (e) {
                    errorStr +=
                        'Unexpected error while retrieving cases. We could not extract a human readable error message. More details can be found in the JS console.  You should open a bug ticket with the Salesforce team.';
                }

                this.showToast('Error', errorStr, 'error', 60000);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    /**
     * Open the saved filter sets modal
     */
    viewFilterSets() {
        FilterSetsModal.open({
            size: 'large',
            onlightning__showtoast: (evnt) => {
                this.handleToast(evnt);
            },
        });
    }

    /**
     * Handle when the user presses the feedback button
     * Either create the case in Salesforce or a ticket in JIRA
     */
    feedbackHandler() {
        LightningPrompt.open({
            label: 'Feedback',
            message:
                'We value your feedback. Do you have a question, issue, or idea to impove the Advisor Portal? Submit it below.',
        })
            .then((feedback) => {
                if (feedback != null) {
                    // In grad mode create ticket in JIRA
                    if (this.gradMode) {
                        return createTicket({
                            jiraProjectMetadataRecordName: 'Graduate College',
                            summary: 'Graduate Advisor Portal Feedback Inquiry',
                            description: feedback,
                            type: 'Improvement',
                            componentNames: 'Salesforce',
                        }).then((v) => {
                            this.showToast('Success', 'Feedback successfully submitted: ' + v, 'success', 5000);
                        });
                    }

                    // In UGRAD mode, just create normal case
                    return submitFeedback({
                        carName: 'Advisor Portal',
                        feedbackText: feedback,
                    }).then(() => {
                        this.showToast('Success', 'Feedback successfully submitted', 'success', 5000);
                    });
                }
                return Promise.resolve();
            })
            .catch((e) => {
                this.showToast('Unable to submit feedback', extractErrorMessages(e)[0], 'error', 60000);
            });
    }

    /**
     * Toggle if majority of filters are shown or not
     */
    toggleAdditionalFilters() {
        this.showAdditionalFilters = !this.showAdditionalFilters;
    }
    showAdditionalFilters = false;
    get toggleAdditionalFiltersLabel() {
        return this.showAdditionalFilters ? 'Hide additional filters' : 'Show additional filters';
    }
    get toggleAdditionalFiltersIcon() {
        return this.showAdditionalFilters ? 'utility:up' : 'utility:down';
    }

    /**
     * Open the mass transfer modal
     */
    openMassTransferModal(evnt) {
        const wrappers = evnt?.detail?.value ?? [];
        if (wrappers.length === 0) {
            this.showToast('Error', 'You must select some contacts/cases before using this', 'error', 5000);
        } else {
            const caseIds = wrappers
                .map((conWrap) => {
                    return conWrap.cases.map((caseWrap) => caseWrap.caseId);
                })
                .flat();

            // Open a modal to transfer cases
            LightningCaseTransferModal.open({
                size: 'medium',
                description: 'Transfer all selected cases',
                massTransfer: true,
                grad: this.career === 'GRD',
                caseIds: caseIds,
                onlightning__showtoast: (e) => {
                    this.handleToast(e);
                },
                onloading: (e) => {
                    if (e.detail === true) this.isLoading = true;
                    else this.isLoading = false;
                },
                onnavigate: (e) => {
                    this.navigate(e);
                },
            });
        }
    }
    /**
     * Open the mass email modal
     */
    openMassEmailModal(evnt) {
        const wrappers = evnt?.detail?.value ?? [];

        if (wrappers.length === 0) {
            this.showToast('Error', 'You must select some contacts/cases before using this', 'error', 5000);
        } else {
            AdvisorPortalModalMassEmail.open({
                size: 'medium',
                description: 'Email all selected contacts/cases',
                selectedContactWrappers: wrappers,
                onlightning__showtoast: (e) => {
                    this.handleToast(e);
                },
                onloading: (e) => {
                    if (e.detail === true) this.isLoading = true;
                    else this.isLoading = false;
                },
            });
        }
    }
    /**
     * Open the mass close modal
     */
    openMassCloseModal(evnt) {
        const wrappers = evnt?.detail?.value ?? [];

        if (wrappers.length === 0) {
            this.showToast('Error', 'You must select some contacts/cases before using this', 'error', 5000);
        } else {
            AdvisorPortalModalMassClose.open({
                size: 'medium',
                description: 'Close all selected cases',
                selectedContactWrappers: wrappers,
                onlightning__showtoast: (e) => {
                    this.handleToast(e);
                },
            });
        }
    }

    /**
     * Handle navigation events
     */
    navigate(e) {
        const detail = e.detail;

        const location = detail.location;

        switch (location) {
            case 'viewcase':
            case 'studentprofile':
                // Raise these events to VF event handler (since wrapper layers prevent direct usage of workspace api)
                // And we need the layering to support Advisor Portal in SF classic
                this.dispatchEvent(
                    new CustomEvent('navigate', {
                        detail: {
                            location: location,
                            params: detail.params,
                        },
                    })
                );
                break;
            case '%reload%':
                this.reapplyFilters(); // refresh the shown contacts
                break;
            default:
                // eslint-disable-next-line no-console
                console.error('navagation location unsupported', event);
                break;
        }
    }

    /**
     * This should be attached on keydown to any field that has a tooltip.
     * It will detect <ESCAPE> presses and add a class to the tooltip to force it to close
     *
     * @param {KeyboardEvent} e keydown event
     */
    closeTooltipOnEscape(evnt) {
        if (evnt.key === 'Escape') {
            const target = evnt.currentTarget;
            const targetParent = target.parentElement;
            const tooltip = targetParent.querySelector('.tooltip');
            tooltip.classList.add('tooltip-escaped');
        }
    }
    /**
     * This should be attached onblur to any field that has a tooltip.
     * It will detect blur and remove the forcefully closed class (re-enabling the tooltip if <ESCAPE> was pressed)
     *
     * @param {BlurEvent} e onblur event
     */
    resetTooltipState(evnt) {
        const target = evnt.currentTarget;
        const targetParent = target.parentElement;
        const tooltip = targetParent.querySelector('.tooltip');
        tooltip.classList.remove('tooltip-escaped');
    }

    // Toast handlers
    handleToast(e) {
        let title = '',
            message = '',
            type = '',
            duration = 5000;

        if (e.type === 'lightning__showtoast') {
            // If this is a standard toast event - use toastAttributes
            // @recommended
            title = e?.toastAttributes?.title ?? title;
            message = e?.toastAttributes?.message ?? message;
            type = e?.toastAttributes?.type ?? type;
            duration = e?.toastAttributes?.duration ?? duration;
        } else {
            // If it is a custom event, grab from details
            // @deprecated
            title = e?.detail?.title ?? title;
            message = e?.detail?.message ?? message;
            type = e?.detail?.type ?? type;
            duration = e?.duration ?? duration;
        }

        this.showToast(title, message, type, duration);
    }
    showToast(title, message, type, duration) {
        const toastLWC = this.template.querySelector('c-lightning-design-toast');
        toastLWC.fireParams(title, message, type, duration);
    }

    // Error state
    get hasError() {
        return (
            this.accessModeError !== undefined ||
            this.allUsersAndPodsError !== undefined ||
            this.academicProgramError !== undefined ||
            this.schoolDepartmentError !== undefined ||
            this.academicPlanError !== undefined ||
            this.residencyError !== undefined ||
            this.caseStatusError !== undefined ||
            this.caseCategoryError !== undefined ||
            this.caseSubCategoryError !== undefined ||
            this.caseSubjectError !== undefined
        );
    }
    get errorMessage() {
        if (this.accessModeError !== undefined) return extractErrorMessages(this.accessModeError)[0];
        if (this.allUsersAndPodsError !== undefined) return extractErrorMessages(this.allUsersAndPodsError)[0];
        if (this.academicProgramError !== undefined) return extractErrorMessages(this.academicProgramError)[0];
        if (this.schoolDepartmentError !== undefined) return extractErrorMessages(this.schoolDepartmentError)[0];
        if (this.academicPlanError !== undefined) return extractErrorMessages(this.academicPlanError)[0];
        if (this.residencyError !== undefined) return extractErrorMessages(this.residencyError)[0];
        if (this.caseStatusError !== undefined) return extractErrorMessages(this.caseStatusError)[0];
        if (this.caseCategoryError !== undefined) return extractErrorMessages(this.caseCategoryError)[0];
        if (this.caseSubCategoryError !== undefined) return extractErrorMessages(this.caseSubCategoryError)[0];
        if (this.caseSubjectError !== undefined) return extractErrorMessages(this.caseSubjectError)[0];
        return '';
    }
}
