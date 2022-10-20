import {LightningElement, api} from 'lwc';
import LightningCaseTransferModal from 'c/lightningCaseTransferModal';

export default class LightningCaseTransferModalConsole extends LightningElement {
    @api caseIds = [];

    firstRender = true;

    connectedCallback() {
        LightningCaseTransferModal.open({
            size: 'medium',
            description: 'Transfer Case',
            massTransfer: false,
            caseIds: this.caseIds,
            loadingCb: (e) => {
                this.handleLoading(e);
            },
            toastCb: (e) => {
                this.handleToast(e);
            },
            navCb: (e) => {
                this.navigate(e);
            },
        });
    }

    handleLoading(e) {}

    handleToast(e) {}

    navigate(e) {
        const detail = e.detail;

        const navLocation = detail.location;

        switch (navLocation) {
            case '%reload%':
                location.reload(); // reload the page to update the record owner
                break;
            default:
                // eslint-disable-next-line no-console
                console.error('navagation location unsupported', event);
                break;
        }
    }
}
