import {LightningElement, api} from 'lwc';
import LightningCaseTransferModal from 'c/lightningCaseTransferModal';

export default class LightningCaseTransferModalConsole extends LightningElement {
    @api caseIds = [];

    firstRender = true;

    connectedCallback() {
        // LightningCaseTransferModal.open({
        //     size: 'medium',
        //     description: 'Transfer Case',
        //     massTransfer: false,
        //     caseIds: this.caseIds,
        //     loadingCb: (e) => {
        //         console.debug('loadingDb', e);
        //         this.handleLoading(e);
        //     },
        //     toastCb: (e) => {
        //         console.debug('toastCb', e);
        //         this.handleToast(e);
        //     },
        // });
    }

    renderedCallback() {
        if (this.firstRender) {
            console.log(this.firstRender);
            this.firstRender = false;
            this.template.querySelector('c-lightning-case-transfer-modal-custom').open({
                massTransfer: false,
                caseIds: this.caseIds,
                loadingCb: (e) => {
                    console.debug('loadingDb', e);
                    this.handleLoading(e);
                },
                toastCb: (e) => {
                    console.debug('toastCb', e);
                    this.handleToast(e);
                },
            });
        }
    }

    handleLoading(e) {}

    handleToast(e) {}
}
