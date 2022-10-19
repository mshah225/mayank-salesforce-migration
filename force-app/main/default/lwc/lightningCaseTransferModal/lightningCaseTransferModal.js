import {api} from 'lwc';
import LightningModal from 'lightning/modal';
import {parseBoolean} from 'c/helperFunctions';

export default class LightningCaseTransferModal extends LightningModal {
    // Callbacks for things that would be events if it were not a modal
    @api loadingCb;
    @api toastCb;

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

    closeModal() {
        this.close();
    }

    transferCases() {
        const viewElem = this.template.querySelector('c-lightning-case-transfer-view');

        this.sendLoadingEvent(true);
        viewElem
            .transferCases()
            .then(() => {
                this.closeModal();
                this.sendToast('Success', 'Case transferred!', 'success');
            })
            .catch((err) => {
                this.closeModal();
                this.sendToast('Failure', 'Could not transfer case!', 'error');
                // eslint-disable-next-line no-console
                console.error(err);
            })
            .finally(() => {
                this.sendLoadingEvent(false);
                this.disabled = false;
            });
    }

    renderedCallback() {
        console.log('renderedCallaback', document);
    }

    addAllowOverflowCSSRule() {
        // slds-modal__content
    }

    sendLoadingEvent(loadMore) {
        if (this.loadingCb != null) this.loadingCb(new CustomEvent('loading', {detail: loadMore}));
    }

    // Call the toastCb
    sendToast(title, body, type) {
        if (this.toastCb != null)
            this.toastCb(
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
}
