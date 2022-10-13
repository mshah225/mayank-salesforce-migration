import {LightningElement, api} from 'lwc';
import transferCasesStr from '@salesforce/apex/AdvisorPortalMassTransferController.transferCasesStr';

export default class AdvisorPortalModalMassTransfer extends LightningElement {
    @api set options(val) {
        this._options = [...val];

        this.questions = [
            {
                key: 'transferTo',
                question: 'New Owner',
                options: this.options,
                type: 'combobox',
                subtype: 'single',
                required: true,
            },
        ];
    }
    get options() {
        return this._options;
    }
    @api selectedContactWrappers = [];
    _options = [];

    questions = [];
    buttons = [];

    transferTo = '';

    connectedCallback() {
        this.buttons = [
            {
                key: 'close',
                ariaLabel: 'Cancel',
                label: 'Cancel',
                onClick: () => {
                    this.closeModal();
                },
                classes: 'slds-button slds-button_neutral',
            },
            {
                key: 'submit',
                ariaLabel: 'Transfer',
                label: 'Transfer',
                onClick: () => {
                    this.transferCases();
                },
                classes: 'slds-button slds-button_brand',
            },
        ];
    }

    @api openModal() {
        this.template.querySelector('c-lightning-question-answer-modal').openModal();
    }
    @api closeModal() {
        this.template.querySelector('c-lightning-question-answer-modal').closeModal();
    }
    transferCases() {
        const modal = this.template.querySelector('c-lightning-question-answer-modal');
        if (modal.reportValidity()) {
            const transferToId = modal.questions[0].answer;

            let caseIds = [];

            for (let i = 0; i < this.selectedContactWrappers.length; i++) {
                const contactWrapper = this.selectedContactWrappers[i];
                for (let j = 0; j < contactWrapper.cases.length; j++) {
                    const caseWrapper = contactWrapper.cases[j];
                    caseIds.push(caseWrapper.caseId);
                }
            }

            this.sendLoadingEvent(true);
            transferCasesStr({ownerId: transferToId, portalCaseIds: caseIds})
                .then(() => {
                    this.questions[0].answer = '';
                    this.questions = [...this.questions];
                    this.makeToast('success', 'Success', 'Case(s) Successfully Transferred.');
                })
                .catch((err) => {
                    console.error(err);
                    this.makeToast('error', 'Failure', 'Unable to transfer cases.');
                })
                .finally(() => {
                    this.closeModal();
                    this.sendLoadingEvent(false);
                    this.sendReloadRequestEvent();
                });
        }
    }

    sendLoadingEvent(loadMore) {
        this.dispatchEvent(new CustomEvent('loading', {detail: loadMore}));
    }

    sendReloadRequestEvent() {
        this.dispatchEvent(new CustomEvent('reloadcontacts', {}));
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
}
