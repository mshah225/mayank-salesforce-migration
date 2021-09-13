/* eslint-disable no-alert */
/* eslint-disable no-console */
import {LightningElement} from 'lwc';
import getDefaultFilter from '@salesforce/apex/AdvisorPortalFilterSavingService.getDefaultFilter';
import setDefaultFilter from '@salesforce/apex/AdvisorPortalFilterSavingService.setDefaultFilter';
import clearDefaultFilter from '@salesforce/apex/AdvisorPortalFilterSavingService.clearDefaultFilter';

export default class AdvisorPortalSaveFilters extends LightningElement {
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
}
