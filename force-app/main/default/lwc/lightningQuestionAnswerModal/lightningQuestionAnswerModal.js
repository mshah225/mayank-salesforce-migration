import {LightningElement, api} from 'lwc';

export default class LightningQuestionAnswerModal extends LightningElement {
    @api title = '';

    @api set questions(val) {
        this._questions = JSON.parse(JSON.stringify(val));
    }
    get questions() {
        return this._questions;
    }
    _questions = [];

    @api buttons = [
        {
            key: 'negativeButton-1',
            ariaLabel: 'Cancel',
            label: 'Cancel',
            onClick: () => {
                this.closeModal();
            },
            classes: 'slds-button slds-button_neutral',
        },
        {
            key: 'positiveButton-1',
            ariaLabel: 'Save',
            label: 'Save',
            onClick: () => {
                this.submitModal();
                this.closeModal();
            },
            classes: 'slds-button slds-button_brand',
        },
    ];

    @api returnFocusTo = null;
    @api noEscape = false;

    showModal = false;

    // Need to set focus into modal when it opens
    needToSetFocus = true;
    renderedCallback() {
        if (this.showModal && this.needToSetFocus) {
            this.focus();
            this.needToSetFocus = false;
        }
    }

    @api openModal() {
        this.showModal = true;
    }
    @api closeModal() {
        this.showModal = false;
        this.needToSetFocus = true;
        if (this.returnFocusTo != null) this.returnFocusTo.focus();
    }

    @api focus() {
        this.template.querySelector('.slds-modal').focus();
    }

    currentlyFocusedElement;
    setFocusHere(e) {
        this.currentlyFocusedElement = e.target;
    }

    killTabKeyPressEvent(e) {
        if (e.which === 9) {
            e.stopPropogation();
        }
    }

    handleKeyPress(e) {
        if (e.which === 27) {
            // Pressed escape - must close modal
            if (!this.noEscape) this.closeModal();
        } else if (e.which === 9) {
            // Pressed tab - must keep within modal
            const allFocusableInModal = this.template.querySelectorAll('button, lightning-button-icon');
            const firstFocusableInModal = allFocusableInModal[0];
            const finalFocusableInModal = allFocusableInModal[allFocusableInModal.length - 1];

            if (this.currentlyFocusedElement != null) {
                if (this.currentlyFocusedElement.isEqualNode(finalFocusableInModal) && !e.shiftKey) {
                    firstFocusableInModal.focus();
                    e.preventDefault();
                } else if (this.currentlyFocusedElement.isEqualNode(firstFocusableInModal) && e.shiftKey) {
                    finalFocusableInModal.focus();
                    e.preventDefault();
                }
            }
        }
    }

    changeAnswer(e) {
        const key = e.detail.key;
        const ans = e.detail.answer;
        for (let i = 0; i < this.questions.length; i++) {
            const q = this.questions[i];
            if (q.key === key) {
                q.answer = ans;
            }
        }
        console.log(this.questions);
    }

    @api reportValidity() {
        const qaSection = this.template.querySelector('c-lightning-question-answer-section');
        return qaSection.reportValidity();
    }

    submitModal() {
        if (!this.reportValidity()) {
            return; // Cannot complete if required fields aren't filled in
        }

        // Fill in empty strings for all optional questions
        for (let i = 0; i < this.questions.length; i++) {
            const q = this.questions[i];
            if (q.answer == null && q.type != null) {
                q.answer = '';
            }
        }

        this.dispatchEvent(new CustomEvent('complete', {detail: JSON.stringify(this.questions)}));
    }
}
