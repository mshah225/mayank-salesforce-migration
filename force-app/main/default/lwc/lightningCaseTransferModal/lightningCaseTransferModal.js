import {api} from 'lwc';
import LightningModal from 'lightning/modal';
import {parseBoolean} from 'c/helperFunctions';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class LightningCaseTransferModal extends LightningModal {
    // Support both mass transfer mode, and (when false) single transfer mode
    @api set massTransfer(val) {
        this._massTransfer = parseBoolean(val);
    }
    get massTransfer() {
        return this._massTransfer;
    }
    _massTransfer = false;

    // List of cases that need to be transferred
    @api caseIds = [];

    // When in mass transfer mode, treat these as grad or ugrad cases?
    @api set grad(val) {
        this._grad = parseBoolean(val);
    }
    get grad() {
        return this._grad;
    }
    _grad = false;

    get modalHeader() {
        return this.massTransfer ? 'Mass Transfer' : 'Transfer Case';
    }

    isSubmitting = false;

    closeModal() {
        this.close();
    }

    transferCases() {
        const viewElem = this.template.querySelector('c-lightning-case-transfer-view');

        this.sendLoadingEvent(true);
        this.disableClose = true;
        this.isSubmitting = true;
        viewElem
            .transferCases()
            .then(() => {
                this.sendToast('success', 'Success', 'Case transferred!');
                this.navigate('%reload%', {});
            })
            .catch((err) => {
                this.sendToast('error', 'Failure', 'Could not transfer case!');
                // eslint-disable-next-line no-console
                console.error(err);
            })
            .finally(() => {
                this.disableClose = false;
                this.closeModal();
                this.isSubmitting = false;
                this.sendLoadingEvent(false);
            });
    }

    sendLoadingEvent(loadMore) {
        this.dispatchEvent(new CustomEvent('loading', {detail: loadMore}));
    }

    sendToast(type, title, body) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: body,
                variant: type,
            })
        );
    }

    navigate(location, params) {
        this.dispatchEvent(
            new CustomEvent('navigate', {
                detail: {
                    location: location,
                    params: params,
                },
            })
        );
    }
}
