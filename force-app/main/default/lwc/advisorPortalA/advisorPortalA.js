import {LightningElement, wire} from 'lwc';
import checkIfAllowedToUseMassTransfer from '@salesforce/apex/AdvisorPortalMassTransferController.checkIfAllowedToUse';
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

    showFauxView = true;

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
        }

        this.loadLess();
    }

    // Get the view as options
    getViewAsOptions() {
        this.loadMore();

        console.log('getViewAsOptions 1');

        viewAsOptions({
            gradOnly: this.currentFilter.career === 'GRD',
        })
            .then((val) => {
                console.log('getViewAsOptions 2');
                let firstSelectionFound = false;
                let allUsers = [];
                const viewAsOptions = JSON.parse(val);
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
    }

    updateFilter(e) {
        console.log('updateFilter', e);
        const field = e.detail.name;
        const oldValue = this.currentFilter[field];
        const newValue = e.detail.value;
        if (oldValue === newValue) return;
        this.currentFilter[field] = e.detail.value;
        this.triggerCurrentFilterChanges();

        if (field === 'career') this.getViewAsOptions();
    }

    getCases() {
        console.log('getCases 1');
        this.loadMore();
        getFilteredCases({viewAsOptions: this.selectedUsers, filterJSON: JSON.stringify(this.currentFilter)})
            .then((val) => {
                console.log('getCases 2');
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
        console.log('changeSelectedUsers');
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
        this.filterVisibility = !this.filterVisibility;
    }
    get filterSectionDivClasses() {
        const baseClasses = 'slds-grid slds-wrap slds-gutters_direct-x-small slds-var-m-bottom_x-small';
        let allClasses = baseClasses;
        if (this.filterVisibility == false) allClasses += ' d-none';
        return allClasses;
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
