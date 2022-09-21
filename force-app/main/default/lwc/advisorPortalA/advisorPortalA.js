import {LightningElement, wire} from 'lwc';
import checkIfAllowedToUseMassTransfer from '@salesforce/apex/AdvisorPortalMassTransferController.checkIfAllowedToUse';
import viewAsOptions from '@salesforce/apex/AdvisorPortalTopLevelFilterController.viewAsOptions';
import getDefaultFilter from '@salesforce/apex/AdvisorPortalFilterSavingService.getDefaultFilter';
import getFilteredCases from '@salesforce/apex/AdvisorPortalFilterSectionController.getFilteredCases';
import getPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getPicklistValues';
import getCampusValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getCampusValues';
import getCaseStatusSettings from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseStatusSettings';
import getCaseSubjectPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseSubjectPicklistValues';
import getCaseClassificationPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseClassificationPicklistValues';
import getAcademicProgramPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getAcademicProgramPicklistValues';
import getSchoolDepartmentPicklistVaues from '@salesforce/apex/AdvisorPortalFilterSectionController.getSchoolDepartmentPicklistVaues';
import getAcademicPlanPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getAcademicPlanPicklistValues';
import {loadScript} from 'lightning/platformResourceLoader';
import integration_v54_js from '@salesforce/resourceUrl/integration_v54_js';
import {buildPicklistOptionsArray} from 'c/helperFunctions';

export default class AdvisorPortalA extends LightningElement {
    // For the top level user select filter
    allUsers = [];
    myQueueId = null;
    selectedUsers = [];

    // For the main filter section
    currentFilter = null;
    loadingCampusValues = false;
    loadingSchoolDepartment = false;
    loadingAcadPlan = false;
    loadingCaseStatus = false;
    loadingCaseCategory = false;
    residencyPicklistValues = [];
    caseStatusPicklistValues = [];
    campusPicklistValues = [];
    caseSubjectPicklistValues = [];
    caseCategoryPicklistValues = [];
    academicProgramOptions = [];
    schoolDepartmentOptions = [];
    academicPlanOptions = [];

    // For the display section
    allResults = [];
    selectedResults = [];

    // Shared variables for determining what to show
    showFauxView = true;

    loadingCounter = 0;
    sforce = {
        console: {
            isInConsole: function () {
                return false;
            },
        },
    };

    get isLoading() {
        return this.loadingCounter > 0;
    }

    // Check if allowed to use the mass transfer functionality
    allowedToUseMassTransfer;
    @wire(checkIfAllowedToUseMassTransfer, {})
    checkedIfAllowedToUseMassTransfer(result) {
        let {data, error} = result;
        if (data != null) {
            this.allowedToUseMassTransfer = data;
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error(error);
        }
        this.loadLess();
    }

    // Retrieve default filter
    @wire(getDefaultFilter, {})
    gotDefaultFilter(result) {
        let {data, error} = result;
        if (data != null) {
            this.currentFilter = JSON.parse(data);
        } else if (error != null) {
            this.currentFilter = {};
            // eslint-disable-next-line no-console
            console.error(error);
        }

        if (this.currentFilter != null) {
            // default filter settings if none exists
            if (this.currentFilter.caseTypeState == null) this.currentFilter.caseTypeState = 'ProactiveCasesState';
            if (this.currentFilter.career == null) this.currentFilter.career = 'UGRD';

            this.getViewAsOptions(); // once the default filter is loaded - we can get the view as options

            this.loadMore(); // for any picklist options that depend on filter being set
            Promise.all([
                this.refreshCampusValues(),
                this.refreshSchoolDepartmentPicklistVaues(),
                this.refreshAcademicPlanPicklistValues(),
            ]).then(() => {
                this.loadLess();
            });
        }

        this.loadLess();
    }

    // Get the view as options
    getViewAsOptions() {
        this.loadMore();

        viewAsOptions({
            gradOnly: this.currentFilter.career === 'GRD',
        })
            .then((val) => {
                let firstSelectionFound = false;
                let allUsers = [];
                const viewAsOptions = JSON.parse(val);
                for (let i = 0; i < viewAsOptions.length; i++) {
                    const opt = viewAsOptions[i];
                    const label = opt.label;
                    const value = opt.value;
                    const key = label + ';' + value;

                    let option = {label, value, key, isHeader: false, isSelected: false};

                    if (option.label.includes('--')) {
                        option.label = option.label.replace(/--/g, '');
                        option.isHeader = true;
                    }

                    if (!option.isHeader) {
                        if (!firstSelectionFound) {
                            this.myQueueId = option.value;
                            option.isSelected = true;
                            firstSelectionFound = true;
                            this.selectedUsers = [this.myQueueId];
                        }
                    }

                    allUsers.push(option);
                }

                this.allUsers = allUsers;
                if (this.showFauxView) this.showFauxView = false; // the first time this will run will be after all async has loaded in
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error(err);
            })
            .finally(() => {
                this.loadLess();
            });
    }

    // One loading for each wire
    connectedCallback() {
        this.loadMore(); // loadMore for retrieving allowed to use mass transfer
        this.loadMore(); // loadMore for retrieving default filter

        loadScript(this, integration_v54_js)
            .then(() => {
                // eslint-disable-next-line no-undef
                this.sforce = getSforce();
            })
            .catch((err) => {
                console.error(err);
            });

        this.loadMore(); // for any picklist options that don't depend on anything
        Promise.all([
            this.refreshResidencyPicklistValues(),
            this.refreshCaseStatusSettings(),
            this.refreshAcademicProgramPicklistValues(),
        ]).then(() => {
            this.loadLess();
        });
    }

    // The filter has changed
    updateFilter(e) {
        const field = e.detail.name;
        const oldValue = this.currentFilter[field];
        const newValue = e.detail.value;
        if (oldValue === newValue) return;
        this.currentFilter[field] = e.detail.value;
        this.updateConditionalFields(field).then(() => {
            this.triggerCurrentFilterChanges();
        });

        if (field === 'career') this.getViewAsOptions();
    }

    /**
     * Update any filter fields where the options are dependent on the selection in some other picklist
     * @param {String} changedField
     */
    updateConditionalFields(changedField) {
        let prm = Promise.resolve();

        if (changedField === 'career') {
            this.loadingCampusValues = true;
            prm = this.refreshCampusValues().then(() => {
                this.loadingCampusValues = false;
            });
        } else if (changedField === 'degreeLevel') {
            this.loadingAcadPlan = true;
            this.refreshAcademicPlanPicklistValues().then(() => {
                this.loadingAcadPlan = false;
            });
        } else if (changedField === 'academicProgram') {
            this.loadingSchoolDepartment = true;
            this.loadingAcadPlan = true;

            prm = Promise.all([
                this.refreshSchoolDepartmentPicklistVaues().then(() => {
                    this.loadingSchoolDepartment = false;
                }),
                this.refreshAcademicPlanPicklistValues().then(() => {
                    this.loadingAcadPlan = false;
                }),
            ]);
        } else if (changedField === 'schoolDepartment') {
            this.loadingAcadPlan = true;
            prm = this.refreshAcademicPlanPicklistValues().then(() => {
                this.loadingAcadPlan = false;
            });
        }

        return prm;
    }

    // Imperative rather than wire to gain more precise control over when these trigger
    refreshResidencyPicklistValues() {
        return getPicklistValues({objectName: 'Student_Program_Plan__c', fieldName: 'Residency__c'})
            .then((val) => {
                this.residencyPicklistValues = buildPicklistOptionsArray(val);
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('refreshResidencyPicklistValues', err);
            });
    }
    refreshCaseStatusSettings() {
        return getCaseStatusSettings()
            .then((val) => {
                this.caseStatusPicklistValues = buildPicklistOptionsArray(val);
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('refreshCaseStatusSettings', err);
            });
    }
    refreshCampusValues() {
        const filterJSON = JSON.stringify(this.currentFilter);
        return getCampusValues({filterJSON})
            .then((val) => {
                this.campusPicklistValues = buildPicklistOptionsArray(val);
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('refreshCampusValues', err);
            });
    }
    refreshCaseSubjectPicklistValues() {
        const filterJSON = JSON.stringify(this.currentFilter);
        return getCaseSubjectPicklistValues({filterJSON, viewAsOptions: this.viewAsUsers})
            .then((val) => {
                this.caseSubjectPicklistValues = buildPicklistOptionsArray(val);
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('refreshCaseSubjectPicklistValues', err);
            });
    }
    refreshCaseClassificationPicklistValues() {
        const filterJSON = JSON.stringify(this.currentFilter);
        return getCaseClassificationPicklistValues({filterJSON, viewAsOptions: this.viewAsUsers})
            .then((val) => {
                this.caseCategoryPicklistValues = buildPicklistOptionsArray(val);
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('refreshCaseClassificationPicklistValues', err);
            });
    }
    refreshAcademicProgramPicklistValues() {
        return getAcademicProgramPicklistValues()
            .then((val) => {
                this.academicProgramOptions = buildPicklistOptionsArray(val);
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('refreshAcademicProgramPicklistValues', err);
            });
    }
    refreshSchoolDepartmentPicklistVaues() {
        const filterJSON = JSON.stringify(this.currentFilter);
        return getSchoolDepartmentPicklistVaues({filterJSON})
            .then((val) => {
                this.schoolDepartmentOptions = buildPicklistOptionsArray(val);
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('refreshSchoolDepartmentPicklistVaues', err);
            });
    }
    refreshAcademicPlanPicklistValues() {
        const filterJSON = JSON.stringify(this.currentFilter);
        return getAcademicPlanPicklistValues({filterJSON})
            .then((val) => {
                this.academicPlanOptions = buildPicklistOptionsArray(val);
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('gotAcademicPlanPicklistValues', err);
            });
    }

    // Search for cases
    getCases() {
        this.loadMore();
        getFilteredCases({viewAsOptions: this.selectedUsers, filterJSON: JSON.stringify(this.currentFilter)})
            .then((val) => {
                this.allResults = JSON.parse(val);
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error(err);
            })
            .finally(() => {
                this.loadLess();
            });
    }

    // The selected users has changed (now re-search stuff)
    changeSelectedUsers(e) {
        this.selectedUsers = [...e.detail];

        this.loadingCaseStatus = true;
        this.loadingCaseCategory = true;
        this.loadMore();
        Promise.all([
            this.refreshCaseSubjectPicklistValues().then(() => {
                this.loadingCaseStatus = false;
            }),
            this.refreshCaseClassificationPicklistValues().then(() => {
                this.loadingCaseCategory = false;
            }),
        ])
            .then(() => {
                this.getCases();
            })
            .then(() => {
                this.loadLess();
            });
    }

    // Update shown results
    updateSelectedResults(e) {
        this.selectedResults = [...e.detail];
    }

    // Triggers the filter changes to ripple down to child components
    triggerCurrentFilterChanges() {
        this.currentFilter = {...this.currentFilter};
    }

    // Should we show the filter section?
    filterVisibility = true;
    toggleFilterVisibility() {
        this.filterVisibility = !this.filterVisibility;
    }
    get filterSectionDivClasses() {
        const baseClasses = 'slds-grid slds-wrap slds-gutters_direct-x-small slds-var-m-bottom_x-small';
        let allClasses = baseClasses;
        if (this.filterVisibility == false) allClasses += ' d-none';
        return allClasses;
    }

    // Navigate handler to navigate to other sections
    navigate(e) {
        const detail = e.detail;

        const location = detail.location;
        let contactId, contactName, caseId, caseNumber, profileURL;

        switch (location) {
            case 'viewcase':
                contactId = detail.params.contactId;
                contactName = detail.params.contactName;
                caseId = detail.params.caseId;
                caseNumber = detail.params.caseNumber;
                this.openPrimaryAndSubTab(
                    contactId,
                    contactName,
                    '/' + contactId,
                    caseId,
                    caseNumber,
                    '/' + caseId,
                    false
                );
                break;
            case 'studentprofile':
                contactId = detail.params.contactId;
                contactName = detail.params.contactName;
                profileURL = '/apex/StudentProfile?contactId=' + contactId;
                this.openPrimaryAndSubTab(
                    contactId,
                    contactName,
                    '/' + contactId,
                    profileURL,
                    contactName + "'s Profile",
                    profileURL,
                    false
                );
                break;
            default:
                console.error('navagation location unsupported', event);
                break;
        }
    }
    openPrimaryAndSubTab(primaryTabId, primaryTabName, primaryTabURL, subTabId, subTabName, subTabURL, openPrimary) {
        if (this.sforce.console.isInConsole()) {
            this.sforce.console.focusPrimaryTabByName(primaryTabId, (focusPrimaryTabResponse) => {
                if (!focusPrimaryTabResponse.success) {
                    this.sforce.console.openPrimaryTab(
                        null,
                        primaryTabURL,
                        true,
                        primaryTabName,
                        (openPrimaryTabResponse) => {
                            this.sforce.console.openSubtab(
                                openPrimaryTabResponse.id,
                                subTabURL,
                                true,
                                subTabName,
                                null,
                                (openSubTabResponse) => {
                                    if (!openSubTabResponse.success) {
                                        this.sforce.console.focusSubTabByNameAndPrimaryTabId(
                                            subTabId,
                                            openSubTabResponse.id
                                        );
                                    }
                                },
                                subTabId
                            );
                        },
                        primaryTabId
                    );
                } else {
                    this.sforce.console.getFocusedPrimaryTabId((primaryFocusResponse) => {
                        this.sforce.console.focusSubtabByNameAndPrimaryTabId(
                            subTabId,
                            primaryFocusResponse.id,
                            (focusSubTabResponse) => {
                                if (!focusSubTabResponse.success) {
                                    this.sforce.console.openSubtab(
                                        primaryFocusResponse.id,
                                        subTabURL,
                                        true,
                                        subTabName,
                                        null,
                                        (openSubTabResponse) => {
                                            if (!openSubTabResponse.success) {
                                                this.sforce.console.focusSubTabByNameAndPrimaryTabId(
                                                    subTabId,
                                                    openSubTabResponse.id
                                                );
                                            }
                                        },
                                        subTabId
                                    );
                                }
                            }
                        );
                    });
                }
            });
        } else if (!openPrimary) {
            window.open(subTabURL, '_blank');
        } else {
            window.open(primaryTabURL, '_blank');
        }
    }

    // Reload
    reloadContacts() {
        this.getCases();
    }

    // Modal openers
    openModalMassEmail() {
        if (this.selectedResults.length === 0) {
            this.showToast('Error', 'You must select some contacts/cases before using this', 'error', 5000);
        } else {
            this.template.querySelector('c-advisor-portal-modal-mass-email').openModal();
        }
    }
    openModalMassTransfer() {
        if (this.selectedResults.length === 0) {
            this.showToast('Error', 'You must select some contacts/cases before using this', 'error', 5000);
        } else {
            this.template.querySelector('c-advisor-portal-modal-mass-transfer').openModal();
        }
    }
    openModalMassClose() {
        if (this.selectedResults.length === 0) {
            this.showToast('Error', 'You must select some contacts/cases before using this', 'error', 5000);
        } else {
            this.template.querySelector('c-advisor-portal-modal-mass-close').openModal();
        }
    }

    // Loading handlers
    handleLoading(e) {
        const loadMore = e.detail;
        if (loadMore) {
            this.loadMore();
        } else {
            this.loadLess();
        }
    }
    loadMore() {
        this.loadingCounter++;
    }
    loadLess() {
        this.loadingCounter--;
        if (this.loadingCounter < 0) this.loadingCounter = 0;
    }

    // Toast handlers
    handleToast(e) {
        const title = e.detail.title;
        const message = e.detail.message;
        const type = e.detail.type;
        const duration = e.duration ? e.duration : 5000;
        this.showToast(title, message, type, duration);
    }
    showToast(title, message, type, duration) {
        const toastLWC = this.template.querySelector('c-lightning-design-toast');
        toastLWC.fireParams(title, message, type, duration);
    }
}
