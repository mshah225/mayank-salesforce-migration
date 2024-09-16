import {LightningElement, api} from 'lwc';
import setDefaultFilter from '@salesforce/apex/AdvisorPortalFilterSavingService.setDefaultFilter';
import clearDefaultFilter from '@salesforce/apex/AdvisorPortalFilterSavingService.clearDefaultFilter';
import LightningConfirm from 'lightning/confirm';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {cloneObj, extractErrorMessages} from 'c/helperFunctions';

export default class AdvisorPortalSaveFilters extends LightningElement {
    @api
    get currentFilter() {
        return this._currentFilter;
    }
    set currentFilter(val) {
        this._currentFilter = cloneObj(val);
    }
    _currentFilter = null;

    openSaveModal() {
        LightningConfirm.open({
            message: 'Do you want to save your filters?',
            label: 'Save Filters',
            theme: 'success',
        })
            .then((v) => {
                // Need to save filter?
                if (v === true) {
                    return setDefaultFilter({json: JSON.stringify(this.currentFilter)}).then(() => {
                        this.makeToast('success', 'Success', 'Filters saved as default.');
                    });
                }
                return Promise.resolve();
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('Error during saving default filter', err);
                this.makeToast('error', 'Error', extractErrorMessages(err)[0]);
            });
    }

    openResetModal() {
        LightningConfirm.open({
            message: 'Do you want to clear your saved filters?',
            label: 'Delete Saved Filters',
            theme: 'warning',
        })
            .then((v) => {
                // Need to save filter?
                if (v === true) {
                    return clearDefaultFilter().then(() => {
                        this.makeToast('success', 'Success', 'Default filter cleared.');
                    });
                }
                return Promise.resolve();
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error('Error during clearing default filter', err);
                this.makeToast('error', 'Error', extractErrorMessages(err)[0]);
            });
    }

    makeToast(type, title, body) {
        const evt = new ShowToastEvent({
            title: title,
            message: body,
            variant: type,
        });
        this.dispatchEvent(evt);
    }
}
