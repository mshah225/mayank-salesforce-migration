/* eslint-disable no-alert */
/* eslint-disable no-console */
import {LightningElement, api} from 'lwc';
import getDefaultFilter from '@salesforce/apex/AdvisorPortalFilterSavingService.getDefaultFilter';
import setDefaultFilter from '@salesforce/apex/AdvisorPortalFilterSavingService.setDefaultFilter';
import clearDefaultFilter from '@salesforce/apex/AdvisorPortalFilterSavingService.clearDefaultFilter';

export default class AdvisorPortalSaveFilters extends LightningElement {
    @api currentFilter;
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
                console.error(err);
                this.makeToast('error', 'Error', err.body.message);
            })
            .finally(() => {
                this.decrementProcessingCounter();
            });
    }

    saveFilters() {
        setDefaultFilter({json: JSON.stringify(this.currentFilter)})
            .then(() => {
                this.makeToast('success', 'Success', 'Filters saved as default.');
            })
            .catch((err) => {
                console.error(err);
                this.makeToast('error', 'Error', err.body.message);
            })
            .finally(() => {
                this.template.querySelector('c-lightning-design-modal.save-modal').closeModal();
            });
    }

    resetSavedFilters() {
        this.makeToast('loading', '', '');
        clearDefaultFilter()
            .then(() => {
                this.dispatchEvent(
                    new CustomEvent('clearappliedfilters', {
                        detail: {},
                    })
                );
                this.makeToast('success', 'Success', 'Default filter cleared.');
            })
            .catch((err) => {
                this.makeToast('error', 'Error', err.body.message);
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
                    onClick: () => {
                        this.template.querySelector(modalSelector).closeModal();
                    },
                    classes: 'slds-button slds-button_neutral',
                },
                {
                    label: 'Save my Default Filters',
                    onClick: () => {
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
                    onClick: () => {
                        this.template.querySelector(modalSelector).closeModal();
                    },
                    classes: 'slds-button slds-button_neutral',
                },
                {
                    label: 'Reset my Default Filters',
                    onClick: () => {
                        this.resetSavedFilters();
                    },
                    classes: 'slds-button slds-button_brand',
                },
            ];
        }
        this.template.querySelector(modalSelector).openModal();
    }

    makeToast(type, title, body) {
        this.dispatchEvent(
            new CustomEvent('showtoast', {
                detail: {
                    title: title,
                    message: body,
                    type: type,
                    duration: 5000,
                },
            })
        );
    }

    incrementProcessingCounter() {
        this.dispatchEvent(new CustomEvent('incrementprocessingcounterevent'));
    }
    decrementProcessingCounter() {
        this.dispatchEvent(new CustomEvent('decrementprocessingcounterevent'));
    }
}
