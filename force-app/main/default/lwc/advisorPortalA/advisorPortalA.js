import {LightningElement, wire} from 'lwc';
import checkIfAllowedToUse from '@salesforce/apex/AdvisorPortalMassTransferController.checkIfAllowedToUse';
import viewAsOptions from '@salesforce/apex/AdvisorPortalTopLevelFilterController.viewAsOptions';
import getDefaultFilter from '@salesforce/apex/AdvisorPortalFilterSavingService.getDefaultFilter';
import getFilteredCases from '@salesforce/apex/AdvisorPortalFilterSectionController.getFilteredCases';
import {loadScript} from 'lightning/platformResourceLoader';
import integration_v54_js from '@salesforce/resourceUrl/integration_v54_js';

export default class AdvisorPortalA extends LightningElement {
    allUsers = [];
    myQueueId = null;
    selectedUsers = [];

    currentFilter = null;

    allResults = [];
    selectedResults = [];

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

    allowedToUseMassTransfer;
    @wire(checkIfAllowedToUse, {})
    checkedIfAllowedToUse(result) {
        let {data, error} = result;
        if (data != null) {
            this.allowedToUseMassTransfer = data;
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error(error);
        }
        this.loadLess();
    }

    // Retrieve all user options
    get gradToggleSelected() {
        return this.currentFilter != null && this.currentFilter.career != null && this.currentFilter.career === 'GRD';
    }
    @wire(viewAsOptions, {gradOnly: gradToggleSelected})
    gotViewAsOptions(result) {
        let {data, error} = result;
        if (data != null) {
            let firstSelectionFound = false;
            let allUsers = [];

            const viewAsOptions = JSON.parse(data);

            for (let i = 0; i < viewAsOptions.length; i++) {
                const opt = viewAsOptions[i];
                const label = opt.label;
                const value = opt.value;

                let option = {label, value, isHeader: false, isSelected: false};

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
            this.loadLess();
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error(error);
            this.loadLess();
        }
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
        }

        this.loadLess();
    }

    // One loading for each wire
    connectedCallback() {
        this.loadMore(); // loadMore for retrieving user options
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
    }

    // getViewAsOptions() {
    //     this.loadMore();
    //     this.getViewAsOptions({filterJSON: JSON.stringify(this.currentFilter)})
    //         .then((val) => {})
    //         .catch((err) => {
    //             // eslint-disable-next-line no-console
    //             console.error(err);
    //         })
    //         .finally(() => {
    //             this.loadLess();
    //         });
    // }

    updateFilter(e) {
        this.currentFilter[e.detail.name] = e.detail.value;
        this.triggerCurrentFilterChanges();
    }

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

    changeSelectedUsers(e) {
        this.selectedUsers = [...e.detail];
    }

    updateSelectedResults(e) {
        this.selectedResults = [...e.detail];
    }

    triggerCurrentFilterChanges() {
        this.currentFilter = {...this.currentFilter};
    }

    filterVisibility = true;
    toggleFilterVisibility() {
        if (this.filterVisibility) {
            this.filterVisibility = false;
        } else {
            this.filterVisibility = true;
        }

        const elem = this.template.querySelector('.filterSectionWrapper');
        if (this.filterVisibility) {
            elem.classList.remove('d-none');
        } else {
            elem.classList.add('d-none');
        }
    }

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

    reloadContacts() {
        this.getCases();
    }

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
