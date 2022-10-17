/**
 * Author: Created by Robert Nordman
 * Date: 10/14/2022
 * Description:
 *   Used to transfer an advisor case.
 */
import {LightningElement, api, wire} from 'lwc';
import getTransferToOptionsForCurrentUserAndStudentStr from '@salesforce/apex/AdvisorCaseTransferService.getTransferToOptionsForCurrentUserAndStudentStr';
import transferSingleCase from '@salesforce/apex/AdvisorCaseTransferService.transferSingleCase';
import {falseWireRun} from 'c/helperFunctions';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class LightningCaseTransfer extends LightningElement {
    @api caseId;
    @api contactId;
    @api grad;

    @api set handleLoadingYourself(val) {
        if (typeof val === 'string') this._handleLoadingYourself = val === 'true';
        else this._handleLoadingYourself = val;
    }
    get handleLoadingYourself() {
        return this._handleLoadingYourself;
    }
    _handleLoadingYourself = false;

    get isLoading() {
        return this.loadingCnt > 0;
    }
    loadingCnt = 0;

    questions = [];
    buttons = [];

    /**
     * When the LWC loads, get transfer-to details for this user/contact/grad combination
     */
    @wire(getTransferToOptionsForCurrentUserAndStudentStr, {
        contactId: '$contactId',
        grad: '$grad',
    })
    gotTransferToOptionsByUserAndStudentStr(result) {
        if (falseWireRun(result)) return; // Sometimes the wire is run with null data and error - this should be considered a fake run and nothing should happen

        let {data, error} = result;

        if (data != null) {
            // Create a list of options
            const options = [];

            const parsedData = JSON.parse(data);
            let firstOption = null;

            for (let i = 0; i < parsedData.length; i++) {
                const opt = parsedData[i];
                let label = opt.label;
                let value = opt.value;

                const isLabel = label.indexOf('--') === 0 && label.lastIndexOf('--') + 2 === label.length; // -- indicates this is a header for a section of the dropdown
                if (isLabel) label = label.substring(2, label.length - 2); // strip off the -- markers

                // The first option is the user themself, it should be autoselected
                if (firstOption == null) firstOption = value;

                // Create an option in the dropdown for each option
                options.push({
                    label: label,
                    value: value,
                    isLabel: isLabel,
                    isSelected: false,
                });
            }

            // Create the questions
            this.questions = [
                {
                    key: 'transferTo',
                    question: 'New Owner',
                    options: options,
                    answer: firstOption, // first option should be autoselected
                    type: 'combobox',
                    subtype: 'single', // only one can be selected
                    required: true,
                },
            ];

            // And open modal if ready
            this.openModalOnceReady();
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error(error);
        }
    }

    connectedCallback() {
        // Setup buttons with callbacks to the close and submit functions
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

        // And open modal if ready
        this.openModalOnceReady();
    }

    /**
     * Once both buttons and questions have been intialized, this will open the modal
     */
    openModalOnceReady() {
        if (this.buttons.length > 0 && this.questions.length > 0) {
            this.openModal();
        }
    }

    /**
     * Transfer cases to owner selected in modal - and then close modal
     */
    transferCases() {
        const modal = this.template.querySelector('c-lightning-question-answer-modal');
        if (modal.reportValidity()) {
            const newOwnerId = modal.questions[0].answer;

            this.sendLoadingEvent(true);
            transferSingleCase({caseId: this.caseId, ownerId: newOwnerId})
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

                    location.reload(); // reload page after transfer is complete
                });
        }
    }

    /**
     * Open the modal
     */
    @api openModal() {
        this.template.querySelector('c-lightning-question-answer-modal').openModal();
    }
    /**
     * Close the modal
     */
    @api closeModal() {
        this.template.querySelector('c-lightning-question-answer-modal').closeModal();
    }

    sendLoadingEvent(loadMore) {
        if (this.handleLoadingYourself) {
            if (loadMore) this.loadingCnt += 1;
            else this.loadingCnt -= 1;
        } else {
            this.dispatchEvent(new CustomEvent('loading', {detail: loadMore}));
        }
    }

    makeToast(type, title, body) {
        let logFunc = console.log;

        if (type == 'error') logFunc = console.error;
        else if (type == 'warning') logFunc = console.warn;
        else if ((type = 'info')) logFunc = console.info;

        logFunc(title, body);

        // And raise an event that can be handled if we are in Lightning Experience
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: body,
                variant: type,
            })
        );
    }
}
