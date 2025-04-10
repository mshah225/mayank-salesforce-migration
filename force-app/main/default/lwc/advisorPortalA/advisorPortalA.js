import {LightningElement, api, wire} from 'lwc';
import {getRecord, createRecord, updateRecord} from 'lightning/uiRecordApi';
import {gql, graphql} from 'lightning/uiGraphQLApi';
import LightningPrompt from 'lightning/prompt';
import LightningConfirm from 'lightning/confirm';
import ToastContainer from 'lightning/toastContainer';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import GraphqlManager from 'c/graphqlManager';
import FilterSetManager from 'c/filterSetManager';

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
import checkIfCanShareFilterSets from '@salesforce/apex/FilterSetController.checkIfCanShare';

import USER_ID from '@salesforce/user/Id';
import STUDENT_PROGRAM_PLAN_OBJECT from '@salesforce/schema/Student_Program_Plan__c';
import STUDENT_PROGRAM_PLAN_RESIDENCY from '@salesforce/schema/Student_Program_Plan__c.Residency__c';
import USER_NAME_FIELD from '@salesforce/schema/User.Name';
import FILTER_SET_OBJECT from '@salesforce/schema/Filter_Set__c';
import FILTER_SET_ID_FIELD from '@salesforce/schema/Filter_Set__c.Id';
import FILTER_SET_NAME_FIELD from '@salesforce/schema/Filter_Set__c.Name';
import FILTER_SET_VALUE_FIELD from '@salesforce/schema/Filter_Set__c.Value__c';

import FilterSetsModal from 'c/filterSetsModal';
import FilterSetShareModal from 'c/filterSetShareModal';
import FilterSetRemoveModal from 'c/filterSetRemoveModal';
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
        let filter = {
            caseTypeState: this.caseTypeState,
            career: this.career,
            ownerIds: this.ownerIds,
            studentString: this.studentString,
            campus: this.campus,
            academicLevel: this.academicLevel,
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

        // Remove empty fields
        let properties = Object.keys(filter);
        for (let prop of properties) if (filter[prop] == null || filter[prop] === '') delete filter[prop];

        return filter;
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
        return this._caseTypeState ?? '';
    }
    set caseTypeState(v) {
        if (v === this.caseTypeState) return;
        this._caseTypeState = v;
    }
    /** @type {"AllCasesState"|"ProactiveCasesState"|"WatchlistCasesState"} */
    _caseTypeState = 'ProactiveCasesState';

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
        this.persistenceFromDate = v.from || '';
        this.persistenceToDate = v.to || '';
    }

    get persistenceFromDate() {
        return this._persistenceFromDate ?? '';
    }
    set persistenceFromDate(v) {
        if (v === this.persistenceFromDate) return;
        this._persistenceFromDate = v;
    }
    /** @type {String} */
    _persistenceFromDate;

    get persistenceToDate() {
        return this._persistenceToDate ?? '';
    }
    set persistenceToDate(v) {
        if (v === this.persistenceToDate) return;
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

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [USER_NAME_FIELD],
    })
    gotUserDetail({error, data}) {
        if (data !== undefined) {
            this.myname = data.fields.Name.value;
        }
    }
    myname;

    @wire(checkIfCanShareFilterSets, {})
    checkedIfCanShareFilterSets({data, errors}) {
        if (data !== undefined) {
            this.allowedToShareFilterSets = data;
        } else if (errors !== undefined) {
            this.allowedToShareFilterSets = false;
        }
    }
    allowedToShareFilterSets = false;

    /** If there is an applied filter set, get details about it */
    @wire(graphql, {
        query: gql`
            query FilterSetQuery($filterSetId: ID!) {
                uiapi {
                    query {
                        Filter_Set__c(where: {Id: {eq: $filterSetId}}) {
                            edges {
                                node {
                                    Id
                                    Name {
                                        value
                                    }
                                    Owner__c {
                                        value
                                    }
                                    Owner__r {
                                        Name {
                                            value
                                        }
                                        Alias {
                                            value
                                        }
                                    }
                                    Value__c {
                                        value
                                    }
                                    Is_Shared__c {
                                        value
                                    }
                                    CreatedDate {
                                        value
                                    }

                                    Filter_Set_User_Associations__r {
                                        edges {
                                            node {
                                                Id
                                                User__c {
                                                    value
                                                }
                                                User__r {
                                                    Name {
                                                        value
                                                    }
                                                    Alias {
                                                        value
                                                    }
                                                }
                                                Pinned__c {
                                                    value
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        `,
        variables: '$appliedFilterSetGraphQLVars',
    })
    gotAppliedFitlerSetDetails({data, errors}) {
        if (data !== undefined) {
            let graphqlManager = new GraphqlManager(data);
            this.filterSetManager = new FilterSetManager(graphqlManager.unwrap().Filter_Set__c);
            this.appliedFilterSet = this.filterSetManager.getAll()[0];
        } else if (errors !== undefined) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading filter set details',
                    message: extractErrorMessages(errors)[0],
                    variant: 'error',
                })
            );
            this.appliedFilterSet = undefined;
            this.filterSetManager = undefined;
        }
    }
    get appliedFilterSetGraphQLVars() {
        if (this.appliedFilterSetId == null) return undefined;
        return {
            filterSetId: this.appliedFilterSetId,
        };
    }
    filterSetManager;
    appliedFilterSetId;
    appliedFilterSet;

    get filterSetSharedType() {
        return this.appliedFilterSet?.Is_Shared__c
            ? this.userOwnsFilterSet
                ? 'Shared by me'
                : 'Shared with me'
            : 'Private';
    }
    get filterSetName() {
        return this.filterSetNameName || this.appliedFilterSet?.Name || '';
    }
    get userOwnsFilterSet() {
        return this.appliedFilterSet?.Owner__c === USER_ID;
    }
    get filterSetIsPinned() {
        return this.appliedFilterSet?.Pinned__c ?? false;
    }
    get filterSetPinLabel() {
        return this.filterSetIsPinned ? 'Unpin' : 'Pin';
    }
    get userCanShareFilterSet() {
        return this.allowedToShareFilterSets && this.userOwnsFilterSet;
    }
    get cannotEditFilterSetName() {
        return !this.userOwnsFilterSet;
    }

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
        } else if (error !== undefined) {
            this.allUsersAndPodsError = error;
        }
    }
    allUsersAndPods;
    allUsersAndPodsError;
    get usersAndPodsPartialFilter() {
        return JSON.stringify({career: this.career});
    }
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
     **********                 Loading Indicators                **********
     ***********************************************************************/
    set loadingUsersAndPodOptions(v) {
        if (v === this.loadingUsersAndPodOptions) return;
        this._loadingUsersAndPodOptions = v;
        if (this.applyingFilterSet) {
            if (v) this.applyingFilterSetCounter += 1;
            else this.applyingFilterSetCounter -= 1;
        }
    }
    get loadingUsersAndPodOptions() {
        return this._loadingUsersAndPodOptions;
    }
    _loadingUsersAndPodOptions = true;

    set loadingAcadPlanOptions(v) {
        if (v === this.loadingAcadPlanOptions) return;
        this._loadingAcadPlanOptions = v;
        if (this.applyingFilterSet) {
            if (v) this.applyingFilterSetCounter += 1;
            else this.applyingFilterSetCounter -= 1;
        }
    }
    get loadingAcadPlanOptions() {
        return this._loadingAcadPlanOptions;
    }
    _loadingAcadPlanOptions = true;

    set loadingSchoolDepartmentOptions(v) {
        if (v === this.loadingSchoolDepartmentOptions) return;
        this._loadingSchoolDepartmentOptions = v;
        if (this.applyingFilterSet) {
            if (v) this.applyingFilterSetCounter += 1;
            else this.applyingFilterSetCounter -= 1;
        }
    }
    get loadingSchoolDepartmentOptions() {
        return this._loadingSchoolDepartmentOptions;
    }
    _loadingSchoolDepartmentOptions = true;

    set loadingCampusOptions(v) {
        if (v === this.loadingCampusOptions) return;
        this._loadingCampusOptions = v;
        if (this.applyingFilterSet) {
            if (v) this.applyingFilterSetCounter += 1;
            else this.applyingFilterSetCounter -= 1;
        }
    }
    get loadingCampusOptions() {
        return this._loadingCampusOptions;
    }
    _loadingCampusOptions = true;

    set loadingCaseCategoryOptions(v) {
        if (v === this.loadingCaseCategoryOptions) return;
        this._loadingCaseCategoryOptions = v;
        if (this.applyingFilterSet) {
            if (v) this.applyingFilterSetCounter += 1;
            else this.applyingFilterSetCounter -= 1;
        }
    }
    get loadingCaseCategoryOptions() {
        return this._loadingCaseCategoryOptions;
    }
    _loadingCaseCategoryOptions = true;

    set loadingCaseSubCategoryOptions(v) {
        if (v === this.loadingCaseSubCategoryOptions) return;
        this._loadingCaseSubCategoryOptions = v;
        if (this.applyingFilterSet) {
            if (v) this.applyingFilterSetCounter += 1;
            else this.applyingFilterSetCounter -= 1;
        }
    }
    get loadingCaseSubCategoryOptions() {
        return this._loadingCaseSubCategoryOptions;
    }
    _loadingCaseSubCategoryOptions = true;

    set loadingCaseSubjectOptions(v) {
        if (v === this.loadingCaseSubjectOptions) return;
        this._loadingCaseSubjectOptions = v;
        if (this.applyingFilterSet) {
            if (v) this.applyingFilterSetCounter += 1;
            else this.applyingFilterSetCounter -= 1;
        }
    }
    get loadingCaseSubjectOptions() {
        return this._loadingCaseSubjectOptions;
    }
    _loadingCaseSubjectOptions = true;

    // Counter variable used to track when a filter set is being applied so we can ignore change events until all
    // loading has completed
    set applyingFilterSetCounter(v) {
        this._applyingFilterSetCounter = v;
        if (this.applyingFilterSet && v === 0) this.applyingFilterSet = false; // unset apply flag if counter has reached 0
    }
    get applyingFilterSetCounter() {
        return this._applyingFilterSetCounter;
    }
    _applyingFilterSetCounter = 0;

    /***********************************************************************
     **********                 Most functions                    **********
     ***********************************************************************/

    /**
     * Add event listener to detect lightning toasts
     */
    connectedCallback() {
        // Create toast container to show toasts
        this.toastContainer = ToastContainer.instance();
    }

    /**
     * Apply the new user options
     */
    changeSelectedUsers(evnt) {
        // Ignore change event if currently in process of applying a filter set
        if (this.applyingFilterSet) return;

        if (this.ownerIds !== evnt.detail.value) {
            this.ownerIds = evnt.detail.value;
            this.hasChangedFields = true;
        }
    }

    /**
     * User pressed the apply button - commit the changes and reload the filters
     */
    commitSelectedUsers(evnt) {
        // Ignore change event if currently in process of applying a filter set
        if (this.applyingFilterSet) return;

        if (this.ownerIds !== evnt.detail.value) {
            this.ownerIds = evnt.detail.value;
            this.hasChangedFields = true;
        }
        this.applyFilters();
    }

    /**
     * Change handler - all field-specific logic is in the setter function
     */
    changeField(evnt) {
        // Ignore change event if currently in process of applying a filter set
        if (this.applyingFilterSet) return;

        // Custom component all raise field name in event - for standard components grab it from the currentTarget
        const fieldName = evnt.detail?.name || evnt.currentTarget?.dataset?.name;
        const fieldValue = evnt.detail?.value || evnt.currentTarget?.value;

        if (fieldName == null) return;

        const currentValue = this[fieldName];

        if (currentValue !== fieldValue) {
            this[fieldName] = fieldValue;
            this.hasChangedFields = true;
        }

        // Any triggers to immediately apply changes
        if (fieldName === 'career') this.applyFilters();
        else if (fieldName === 'caseTypeState') this.applyFilters();
    }
    hasChangedFields = false;

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
        return this.apply(this.currentFilter);
    }
    reapplyFilters() {
        if (this.appliedFilter != null) this.apply(this.appliedFilter);
    }
    allResults = [];
    isLoading = false;
    apply(filter) {
        this.isLoading = true;
        return getFilteredCases({filterJSON: JSON.stringify(filter)})
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

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: errorStr,
                        variant: 'error',
                        mode: 'sticky',
                    })
                );
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
            forceRefresh: true,
        }).then((result) => {
            if (result?.action != null) {
                if (result?.action?.filterSet?.Value__c == null) {
                    throw new Error('Could not apply filter set, filter set value was empty');
                }

                this.appliedFilterSetId = result.action.filterSetId;
                this.applyingFilterSet = true; // currently applying
                // Set filter from saved filter set
                this.currentFilter = JSON.parse(result.action.filterSet.Value__c);
                this.hasChangedFields = false; // Clear has changed flag

                // Apply filters is apply is true (rather than just viewing filter values)
                if (result?.action?.apply === true) this.applyFilters();
            }
        });
    }
    // When we are applying a filter set, we need to ignore change events until all wires are done loading
    applyingFilterSet;

    /**
     * Rename applied filter set
     */
    handleRenameFilterSet(evnt) {
        this.filterSetManager
            .rename(this.appliedFilterSet.Id, evnt.detail.value)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Filter set renamed',
                        variant: 'success',
                    })
                );
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while renaming filter set',
                        message: extractErrorMessages(error)[0],
                        variant: 'error',
                        mode: 'sticky',
                    })
                );
            });
    }

    /**
     * Pin or unpin applied filter set
     */
    handleTogglePinFilterSet() {
        let newPinValue = !this.filterSetIsPinned;

        this.filterSetManager
            .pin(this.appliedFilterSet.Id, newPinValue)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: newPinValue ? 'Filter set pinned' : 'Filter set unpinned',
                        variant: 'success',
                    })
                );
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: `Error when ${newPinValue ? 'pinning' : 'unpinning'} filter set`,
                        message: extractErrorMessages(error)[0],
                        variant: 'error',
                        mode: 'sticky',
                    })
                );
            });
    }

    /**
     * Share or unshare currently applied filter set
     */
    handleShareFilterSet() {
        FilterSetShareModal.open({
            size: 'medium',
            filterSet: this.appliedFilterSet,
        })
            .then((resp) => {
                if (resp?.userIds != null) {
                    return this.filterSetManager.share(this.appliedFilterSet.Id, resp.userIds).then(() => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Filter set has been shared',
                                message: ' ',
                                variant: 'success',
                            })
                        );
                    });
                }
                // Cancelled out of modal and not applying changes
                return Promise.resolve();
            })
            .catch((e) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: extractErrorMessages(e)[0],
                        variant: 'error',
                    })
                );
            });
    }

    /**
     * Delete currently applied fileer set
     */
    handleDeleteFilterSet() {
        FilterSetRemoveModal.open({
            size: 'small',
            filterSet: this.appliedFilterSet,
        })
            .then((val) => {
                if (val?.delete != null) {
                    return this.filterSetManager.remove(this.appliedFilterSet.Id, val).then(() => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: val.delete
                                    ? 'Filter set has been removed'
                                    : 'Filter set has been unshared with selected users',
                                variant: 'success',
                            })
                        );
                    });
                }
                // Cancelled deletion
                return Promise.resolve();
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error when removing filter set',
                        message: extractErrorMessages(error)[0],
                        variant: 'error',
                        mode: 'sticky',
                    })
                );
            });
    }

    /** Has applied a filter set and is editting it */
    get showEditWarning() {
        return this.appliedFilterSet != null && this.hasChangedFields;
    }

    /** Can save as if no filter set OR filter set and changed fields OR filter set and not owner */
    get disableSaveAsButton() {
        return !(
            this.appliedFilterSet == null ||
            (this.appliedFilterSet != null && this.hasChangedFields) ||
            (this.appliedFilterSet != null && !this.userOwnsFilterSet)
        );
    }
    /** Can overwrite if viewing a filter set, and user owns filter set, and has modified  */
    get disableOverwriteButton() {
        return !(this.appliedFilterSet != null && this.hasChangedFields && this.userOwnsFilterSet);
    }
    /** Can reset if viewing a filter set and has modified */
    get disableResetButton() {
        return !(this.appliedFilterSet != null && this.hasChangedFields);
    }

    /**
     * Save current configuration as a new filter set
     */
    saveFilterSet() {
        LightningPrompt.open({
            label: 'New Filter Set',
            message: 'Give filter set a name',
            defaultValue: this.lastFilterSetName ?? `${this.myname ? this.myname + "'s" : 'My'} filter set`,
        })
            .then((filterSetName) => {
                if (filterSetName != null) {
                    this.lastFilterSetName = filterSetName;
                    const fields = {};
                    fields[FILTER_SET_NAME_FIELD.fieldApiName] = filterSetName;
                    fields[FILTER_SET_VALUE_FIELD.fieldApiName] = JSON.stringify(this.currentFilter);

                    const recordInput = {
                        apiName: FILTER_SET_OBJECT.objectApiName,
                        fields,
                    };

                    return createRecord(recordInput)
                        .then((recordOutput) => {
                            this.appliedFilterSetId = recordOutput.id;
                            this.hasChangedFields = false;
                            this.hideAllToasts(); // close existing to prevent toasts from overlapping
                            this.refs.hasSavedFilterSetToast.show();
                            this.lastFilterSetName = undefined;
                        })
                        .catch((e) => {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Unable to save filter set',
                                    message: extractErrorMessages(e)[0],
                                    variant: 'error',
                                    mode: 'sticky',
                                })
                            );
                            this.saveFilterSet();
                        });
                }
                return Promise.resolve();
            })
            .catch((e) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Unable to save filter set',
                        message: extractErrorMessages(e)[0],
                        variant: 'error',
                        mode: 'sticky',
                    })
                );
            });
    }
    lastFilterSetName;

    /**
     * Overwrite  the filter field for a filter set
     */
    overwriteFilterSet() {
        LightningConfirm.open({
            label: 'Update filter set',
            message: 'This will update the filter set filters for you and any users you have shared it with',
        })
            .then((result) => {
                if (result) {
                    const fields = {};
                    fields[FILTER_SET_ID_FIELD.fieldApiName] = this.appliedFilterSetId;
                    fields[FILTER_SET_VALUE_FIELD.fieldApiName] = JSON.stringify(this.currentFilter);

                    const recordInput = {
                        fields,
                    };

                    return updateRecord(recordInput).then(() => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Filter set has been updated',
                                variant: 'success',
                            })
                        );
                        this.hasChangedFields = false;
                    });
                }
                return Promise.resolve();
            })
            .catch((e) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Unable to overwrite filter set',
                        message: extractErrorMessages(e)[0],
                        variant: 'error',
                        mode: 'sticky',
                    })
                );
            });
    }

    /**
     * Undo any changes and revert to values of the applied filter set
     */
    resetFilterSet() {
        this.currentFilter = JSON.parse(this.appliedFilterSet.Value__c);
        this.hasChangedFields = false;
        this.applyFilters();
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
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success',
                                    message: 'Feedback successfully submitted: ' + v,
                                    variant: 'success',
                                })
                            );
                        });
                    }

                    // In UGRAD mode, just create normal case
                    return submitFeedback({
                        carName: 'Advisor Portal',
                        feedbackText: feedback,
                    }).then(() => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Feedback successfully submitted',
                                variant: 'success',
                            })
                        );
                    });
                }
                return Promise.resolve();
            })
            .catch((e) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Unable to submit feedback',
                        message: extractErrorMessages(e)[0],
                        variant: 'error',
                        mode: 'sticky',
                    })
                );
            });
    }

    /**
     * Reset the page, clearing any applied filters or filter sets
     */
    resetPageHandler() {
        LightningConfirm.open({
            label: 'Reset page',
            message: 'This will clear the page, clearing applied filter and filter sets.',
            variant: 'headerless',
        })
            .then((result) => {
                if (result === true) {
                    this.appliedFilterSetId = undefined;
                    this.appliedFilterSet = undefined;

                    this.currentFilter = {
                        career: this.career,
                        caseTypeState: 'ProactiveCasesState',
                    };
                    this.appliedFilter = undefined;

                    this.allResults = [];
                }
            })
            .catch((e) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Unable to reset page',
                        message: extractErrorMessages(e)[0],
                        variant: 'error',
                        mode: 'sticky',
                    })
                );
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
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'You must select some contacts/cases before using this',
                    variant: 'error',
                })
            );
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
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'You must select some contacts/cases before using this',
                    variant: 'error',
                })
            );
        } else {
            AdvisorPortalModalMassEmail.open({
                size: 'medium',
                description: 'Email all selected contacts/cases',
                selectedContactWrappers: wrappers,
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
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'You must select some contacts/cases before using this',
                    variant: 'error',
                })
            );
        } else {
            AdvisorPortalModalMassClose.open({
                size: 'medium',
                description: 'Close all selected cases',
                selectedContactWrappers: wrappers,
            });
        }
    }

    /**
     * Forcibly close all toasts
     */
    hideAllToasts() {
        this.toastContainer.close();
        this.toastContainer = ToastContainer.instance();
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

export class AdvisorPortalTest extends AdvisorPortalA {
    @api set allUsersAndPods(v) {
        super.allUsersAndPods = v;
    }
    get allUsersAndPods() {
        return super.allUsersAndPods;
    }

    @api set loadingUsersAndPodOptions(v) {
        super.loadingUsersAndPodOptions = v;
    }
    get loadingUsersAndPodOptions() {
        return super.loadingUsersAndPodOptions;
    }

    @api set campusOptions(v) {
        super.campusOptions = v;
    }
    get campusOptions() {
        return super.campusOptions;
    }

    @api set loadingCampusOptions(v) {
        super.loadingCampusOptions = v;
    }
    get loadingCampusOptions() {
        return super.loadingCampusOptions;
    }

    @api set academicProgramOptions(v) {
        super.academicProgramOptions = v;
    }
    get academicProgramOptions() {
        return super.academicProgramOptions;
    }

    @api get loadingAcadProgramOptions() {
        return super.loadingAcadProgramOptions;
    }

    @api set schoolDepartmentOptions(v) {
        super.schoolDepartmentOptions = v;
    }
    get schoolDepartmentOptions() {
        return super.schoolDepartmentOptions;
    }

    @api set loadingSchoolDepartmentOptions(v) {
        super.loadingSchoolDepartmentOptions = v;
    }
    get loadingSchoolDepartmentOptions() {
        return super.loadingSchoolDepartmentOptions;
    }

    @api set academicPlanOptions(v) {
        super.academicPlanOptions = v;
    }
    get academicPlanOptions() {
        return super.academicPlanOptions;
    }

    @api set loadingAcadPlanOptions(v) {
        super.loadingAcadPlanOptions = v;
    }
    get loadingAcadPlanOptions() {
        return super.loadingAcadPlanOptions;
    }

    @api set residencyOptions(v) {
        super.residencyOptions = v;
    }
    get residencyOptions() {
        return super.residencyOptions;
    }

    @api get loadingResidencyOptions() {
        return super.loadingResidencyOptions;
    }

    @api set caseStatusOptions(v) {
        super.caseStatusOptions = v;
    }
    get caseStatusOptions() {
        return super.caseStatusOptions;
    }

    @api get loadingCaseStatusOptions() {
        return super.loadingCaseStatusOptions;
    }

    @api set caseCategoryOptions(v) {
        super.caseCategoryOptions = v;
    }
    get caseCategoryOptions() {
        return super.caseCategoryOptions;
    }

    @api set loadingCaseCategoryOptions(v) {
        super.loadingCaseCategoryOptions = v;
    }
    get loadingCaseCategoryOptions() {
        return super.loadingCaseCategoryOptions;
    }

    @api set caseSubCategoryOptions(v) {
        super.caseSubCategoryOptions = v;
    }
    get caseSubCategoryOptions() {
        return super.caseSubCategoryOptions;
    }

    @api set loadingCaseSubCategoryOptions(v) {
        super.loadingCaseSubCategoryOptions = v;
    }
    get loadingCaseSubCategoryOptions() {
        return super.loadingCaseSubCategoryOptions;
    }

    @api set caseSubjectOptions(v) {
        super.caseSubjectOptions = v;
    }
    get caseSubjectOptions() {
        return super.caseSubjectOptions;
    }

    @api set loadingCaseSubjectOptions(v) {
        super.loadingCaseSubjectOptions = v;
    }
    get loadingCaseSubjectOptions() {
        return super.loadingCaseSubjectOptions;
    }

    @api set currentFilter(v) {
        super.currentFilter = v;
    }
    get currentFilter() {
        return super.currentFilter;
    }

    @api set appliedFilter(v) {
        super.appliedFilter = v;
    }
    get appliedFilter() {
        return super.appliedFilter;
    }

    @api set allowedToShareFilterSets(v) {
        super.allowedToShareFilterSets = v;
    }
    get allowedToShareFilterSets() {
        return super.allowedToShareFilterSets;
    }

    @api set userIsBothGradAndUgrad(v) {
        super.userIsBothGradAndUgrad = v;
    }
    get userIsBothGradAndUgrad() {
        return super.userIsBothGradAndUgrad;
    }

    @api set showAdditionalFilters(v) {
        super.showAdditionalFilters = v;
    }
    get showAdditionalFilters() {
        return super.showAdditionalFilters;
    }

    @api set appliedFilterSetId(v) {
        super.appliedFilterSetId = v;
    }
    get appliedFilterSetId() {
        return super.appliedFilterSetId;
    }

    @api set appliedFilterSet(v) {
        super.appliedFilterSet = v;
    }
    get appliedFilterSet() {
        return super.appliedFilterSet;
    }

    @api get filterSetSharedType() {
        return super.filterSetSharedType;
    }
    @api get filterSetName() {
        return super.filterSetName;
    }

    @api get gradMode() {
        return super.gradMode;
    }

    @api get ugradMode() {
        return super.ugradMode;
    }

    @api get hasError() {
        return super.hasError;
    }

    @api get errorMessage() {
        return super.errorMessage;
    }
}
