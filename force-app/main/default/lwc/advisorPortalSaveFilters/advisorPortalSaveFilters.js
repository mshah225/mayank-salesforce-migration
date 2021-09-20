/* eslint-disable no-alert */
/* eslint-disable no-console */
import {LightningElement} from 'lwc';
import getDefaultFilter from '@salesforce/apex/AdvisorPortalFilterSavingService.getDefaultFilter';
import setDefaultFilter from '@salesforce/apex/AdvisorPortalFilterSavingService.setDefaultFilter';
import clearDefaultFilter from '@salesforce/apex/AdvisorPortalFilterSavingService.clearDefaultFilter';

export default class AdvisorPortalSaveFilters extends LightningElement {
    saveButtons = [];
    resetButtons = [];

    connectedCallback() {
        this.incrementProcessingCounter();
        getDefaultFilter()
            .then((val) => {
                this.dispatchEvent(
                    new CustomEvent('setdefaultfilter', {
                        detail: {filter: val},
                    })
                );
            })
            .catch((err) => {
                console.log(err);
            })
            .finally(() => {
                this.decrementProcessingCounter();
            });
    }

    saveFilters() {
        this.dispatchEvent(
            new CustomEvent('requestcurrentfilter', {
                detail: {
                    callback: (json) => {
                        this.makeToast('loading', '', '');
                        setDefaultFilter({json})
                            .then(() => {
                                this.makeToast('success', 'Success', 'Filters saved as default.');
                            })
                            .catch((err) => {
                                console.log(err);
                                this.makeToast('error', 'Error', 'Error when saving filters.');
                            })
                            .finally(() => {
                                this.template.querySelector('c-lightning-design-modal.save-modal').closeModal();
                            });
                    },
                },
            })
        );
    }

    resetSavedFilters() {
        this.makeToast('loading', '', '');
        clearDefaultFilter()
            .then(() => {
                this.makeToast('success', 'Success', 'Default filter cleared.');
            })
            .catch((err) => {
                this.makeToast('error', 'Error', 'Error when clearing filters.');
            })
            .finally(() => {
                this.template.querySelector('c-lightning-design-modal.reset-modal').closeModal();
            });
    }

    openSaveModal() {
        const modalSelector = 'c-lightning-design-modal.save-modal';

        if (this.saveButtons.length === 0) {
            // add buttons for save modal
            this.saveButtons = [
                {
                    label: 'Cancel',
                    callback: () => {
                        this.template.querySelector(modalSelector).closeModal();
                    },
                    classes: 'slds-button slds-button_neutral',
                },
                {
                    label: 'Save my Default Filters',
                    callback: () => {
                        this.saveFilters();
                    },
                    classes: 'slds-button slds-button_brand',
                },
            ];
        }
        this.template.querySelector(modalSelector).openModal();
    }
    openResetModal() {
        const modalSelector = 'c-lightning-design-modal.reset-modal';
        if (this.resetButtons.length === 0) {
            // add buttons for reset modal
            this.resetButtons = [
                {
                    label: 'Cancel',
                    callback: () => {
                        this.template.querySelector(modalSelector).closeModal();
                    },
                    classes: 'slds-button slds-button_neutral',
                },
                {
                    label: 'Reset my Default Filters',
                    callback: () => {
                        this.resetSavedFilters();
                    },
                    classes: 'slds-button slds-button_brand',
                },
            ];
        }
        this.template.querySelector(modalSelector).openModal();
    }

    makeToast(type, title, body) {
        this.template.querySelector('c-lightning-design-toast').fireParams(title, body, type, 5000);
    }

    incrementProcessingCounter() {
        this.dispatchEvent(new CustomEvent('incrementprocessingcounterevent'));
    }
    decrementProcessingCounter() {
        this.dispatchEvent(new CustomEvent('decrementprocessingcounterevent'));
    }
}
