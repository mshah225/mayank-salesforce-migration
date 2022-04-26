import {LightningElement, api, wire} from 'lwc';
import viewAsOptions from '@salesforce/apex/AdvisorPortalTopLevelFilterController.viewAsOptions';
import transferCasesStr from '@salesforce/apex/AdvisorPortalMassTransferController.transferCasesStr';

export default class AdvisorPortalModalMassTransfer extends LightningElement {
    questions = [];
    buttons = [];

    transferTo = '';
    options = [];
    selectedContactWrappers = [];

    @wire(viewAsOptions, {})
    gotViewAsOptions(result) {
        let {data, error} = result;
        if (data != null) {
            let allUserOptions = [];

            const keys = Object.keys(data);

            for (let i = 0; i < keys.length; i++) {
                const key = keys[i];
                let option = {label: key, value: data[key], isLabel: false};

                if (key.includes('--')) {
                    option.label = option.label.replace(/--/g, '');
                    option.isLabel = true;
                }

                allUserOptions.push(option);
            }

            this.options = allUserOptions;

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
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error(error);
        }
    }

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
                    if (caseWrapper.isSelected) {
                        caseIds.push(caseWrapper.portalCase.Id);
                    }
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
