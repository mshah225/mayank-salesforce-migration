import {LightningElement, api} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {CloseActionScreenEvent} from 'lightning/actions';
import {getRecordNotifyChange} from 'lightning/uiRecordApi';

export default class LightningCaseTransferModalLex extends LightningElement {
    @api recordId;

    disabled = false;

    get caseIds() {
        return [this.recordId];
    }

    cancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    transferCases() {
        this.disabled = true;

        const viewElem = this.template.querySelector('c-lightning-case-transfer-view');

        viewElem
            .transferCases()
            .then(() => {
                this.dispatchEvent(new CloseActionScreenEvent());
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Case transferred!',
                        variant: 'success',
                    })
                );
                getRecordNotifyChange([{recordId: this.recordId}]); // trigger Lightning Experience tab refresh
            })
            .catch((err) => {
                this.dispatchEvent(new CloseActionScreenEvent());
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Failure',
                        message: 'Could not transfer case!',
                        variant: 'error',
                    })
                );
                // eslint-disable-next-line no-console
                console.error(err);
            })
            .finally(() => {
                this.disabled = false;
            });
    }
}
