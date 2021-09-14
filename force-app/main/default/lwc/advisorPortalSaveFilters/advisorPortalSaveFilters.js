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
        getDefaultFilter()
            .then((val) => {
                this.dispatchEvent(
                    new CustomEvent('setdefaultfilter', {
                        detail: {filter: JSON.stringify(val)},
                    })
                );
            })
            .catch((err) => {
                console.log(err);
            });
    }

    saveFilters() {
        this.dispatchEvent(
            new CustomEvent('requestcurrentfilter', {
                detail: {
                    callback: (filter) => {
                        setDefaultFilter({filter});
                    },
                },
            })
        );
    }

    resetSavedFilters() {
        clearDefaultFilter();
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
                    label: 'Save',
                    callback: () => {
                        this.saveFilters();
                        this.template.querySelector(modalSelector).closeModal();
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
                    label: 'Clear Filters',
                    callback: () => {
                        this.resetSavedFilters();
                        this.template.querySelector(modalSelector).closeModal();
                    },
                    classes: 'slds-button slds-button_brand',
                },
            ];
        }
        this.template.querySelector(modalSelector).openModal();
    }
}
