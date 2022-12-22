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

    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    transferCases() {
        this.disabled = true;

        const viewElem = this.template.querySelector('c-lightning-case-transfer-view');

        viewElem
            .transferCases()
            .then(() => {
                this.closeModal();
                this.sendToast('Success', 'Case transferred!', 'success');
                getRecordNotifyChange([{recordId: this.recordId}]); // trigger Lightning Experience tab refresh
            })
            .catch((err) => {
                this.closeModal();
                this.sendToast('Failure', 'Could not transfer case!', 'error');
                // eslint-disable-next-line no-console
                console.error(err);
            })
            .finally(() => {
                this.disabled = false;
            });
    }

    sendToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            })
        );
    }
}
