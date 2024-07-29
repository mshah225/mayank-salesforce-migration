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
import getCaseSubClassificationPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getCaseSubClassificationPicklistValues';
import getAcademicProgramPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getAcademicProgramPicklistValues';
import getSchoolDepartmentPicklistVaues from '@salesforce/apex/AdvisorPortalFilterSectionController.getSchoolDepartmentPicklistVaues';
import getAcademicPlanPicklistValues from '@salesforce/apex/AdvisorPortalFilterSectionController.getAcademicPlanPicklistValues';
import {buildPicklistOptionsArray, falseWireRun} from 'c/helperFunctions';
import LightningCaseTransferModal from 'c/lightningCaseTransferModal';
import AdvisorPortalModalMassEmail from 'c/advisorPortalModalMassEmail';
import AdvisorPortalModalMassClose from 'c/advisorPortalModalMassClose';

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
    loadingCaseSubCategory = false;
    residencyPicklistValues = [];
    caseStatusPicklistValues = [];
    campusPicklistValues = [];
    caseSubjectPicklistValues = [];
    caseCategoryPicklistValues = [];
    caseSubCategoryPicklistValues = [];
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
        if (falseWireRun(result)) return; // Sometimes the wire is run with null data and error - this should be considered a fake run and nothing should happen

        let {data, error} = result;

        if (data != null) {
            this.allowedToUseMassTransfer = data;
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error('checkedIfAllowedToUseMassTransfer', error);
        }

        this.loadLess();
    }

    // Retrieve default filter
    @wire(getDefaultFilter, {})
    gotDefaultFilter(result) {
        if (falseWireRun(result)) return; // Sometimes the wire is run with null data and error - this should be considered a fake run and nothing should happen

        let {data, error} = result;
        if (data != null) {
            this.currentFilter = JSON.parse(data);
        } else if (error != null) {
            this.currentFilter = {};
            // eslint-disable-next-line no-console
            console.error('gotDefaultFilter', error);
        }

        if (this.currentFilter != null) {
            // default filter settings if none exists
            if (this.currentFilter.caseTypeState == null) this.currentFilter.caseTypeState = 'ProactiveCasesState';
            if (this.currentFilter.career == null) this.currentFilter.career = 'UGRD';

            this.loadMore(); // for any picklist options that depend on filter being set
            Promise.all([
                this.getViewAsOptions(), // once the default filter is loaded - we can get the view as options
                this.refreshCampusValues(), // depends on career
                this.refreshSchoolDepartmentPicklistVaues(), // depends on acad program
                this.refreshAcademicPlanPicklistValues(), // depends on acad program, school, and degree level
            ]).then(() => {
                this.loadLess();
            });
        }

        this.loadLess();
    }

    // Get the view as options
    getViewAsOptions() {
        this.loadMore();

        return viewAsOptions({
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
                console.error('getViewAsOptions', err);
            })
            .finally(() => {
                this.loadLess();
            });
    }

    // One loading for each wire
    connectedCallback() {
        this.loadMore(); // loadMore for retrieving allowed to use mass transfer
        this.loadMore(); // loadMore for retrieving default filter
        this.loadMore(); // for any picklist options that don't depend on anything

        Promise.all([
            this.refreshResidencyPicklistValues(),
            this.refreshCaseStatusSettings(),
            this.refreshAcademicProgramPicklistValues(),
        ]).then(() => {
            this.loadLess();
        });

        // Listen for all standard toast events so we can toast using custom component (since normal toast events won't work in LWC-embedded on VF page)
        this.template.addEventListener('lightning__showtoast', (evnt) => {
            this.handleToast(evnt);
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
    }

    /**
     * Update any filter fields where the options are dependent on the selection in some other picklist
     * @param {String} changedField
     */
    updateConditionalFields(changedField) {
        let prm = Promise.resolve();

        if (changedField === 'career') {
            this.loadingCampusValues = true;
            prm = Promise.all([
                this.refreshCampusValues().then(() => {
                    this.loadingCampusValues = false;
                }),
                this.getViewAsOptions(),
            ]);
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
        } else if (changedField === 'caseCategory') {
            this.loadingCaseSubCategory = true;
            prm = this.refreshCaseSubClassificationPicklistValues().then(() => {
                this.loadingCaseSubCategory = false;
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
        return getCaseSubjectPicklistValues({filterJSON, viewAsOptions: this.selectedUsers})
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
        return getCaseClassificationPicklistValues({filterJSON, viewAsOptions: this.selectedUsers})
            .then((val) => {
                this.caseCategoryPicklistValues = buildPicklistOptionsArray(val);
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('refreshCaseClassificationPicklistValues', err);
            });
    }
    refreshCaseSubClassificationPicklistValues() {
        const filterJSON = JSON.stringify(this.currentFilter);
        return getCaseSubClassificationPicklistValues({filterJSON, viewAsOptions: this.selectedUsers})
            .then((val) => {
                this.caseSubCategoryPicklistValues = buildPicklistOptionsArray(val);
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('refreshCaseSubClassificationPicklistValues', err);
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
                this.showToast(
                    'Error',
                    'Unexpected error while retrieving cases - more details can be found in the JS console.  You should open a bug ticket with the Salesforce team.',
                    'error',
                    5000
                );
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
        this.loadingCaseSubCategory = true;
        this.loadMore();
        Promise.all([
            this.refreshCaseSubjectPicklistValues().then(() => {
                this.loadingCaseStatus = false;
            }),
            this.refreshCaseClassificationPicklistValues().then(() => {
                this.loadingCaseCategory = false;
            }),
            this.refreshCaseSubClassificationPicklistValues().then(() => {
                this.loadingCaseSubCategory = false;
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
                this.reloadContacts(); // refresh the shown contacts
                break;
            default:
                // eslint-disable-next-line no-console
                console.error('navagation location unsupported', event);
                break;
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
            AdvisorPortalModalMassEmail.open({
                size: 'medium',
                description: 'Email all selected contacts/cases',
                selectedContactWrappers: this.selectedResults,
                loadingCb: (e) => {
                    this.handleLoading(e);
                },
                toastCb: (e) => {
                    this.handleToast(e);
                },
                navCb: (e) => {
                    this.navigate(e);
                },
            });
        }
    }
    openModalMassTransfer() {
        if (this.selectedResults.length === 0) {
            this.showToast('Error', 'You must select some contacts/cases before using this', 'error', 5000);
        } else {
            // Get all case ids
            const caseIds = [];
            for (let i = 0; i < this.selectedResults.length; i++) {
                const contact = this.selectedResults[i];

                for (let j = 0; j < contact.cases.length; j++) {
                    const c = contact.cases[j];

                    caseIds.push(c.caseId);
                }
            }

            // Open a modal that is ready to transfer them
            LightningCaseTransferModal.open({
                size: 'medium',
                description: 'Transfer all selected cases',
                massTransfer: true,
                grad: this.currentFilter.career === 'GRD',
                caseIds: caseIds,
                loadingCb: (e) => {
                    this.handleLoading(e);
                },
                toastCb: (e) => {
                    this.handleToast(e);
                },
                navCb: (e) => {
                    this.navigate(e);
                },
            });
        }
    }
    openModalMassClose() {
        if (this.selectedResults.length === 0) {
            this.showToast('Error', 'You must select some contacts/cases before using this', 'error', 5000);
        } else {
            AdvisorPortalModalMassClose.open({
                size: 'medium',
                description: 'Close all selected cases',
                selectedContactWrappers: this.selectedResults,
                loadingCb: (e) => {
                    this.handleLoading(e);
                },
                toastCb: (e) => {
                    this.handleToast(e);
                },
                navCb: (e) => {
                    this.navigate(e);
                },
            });
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
}
