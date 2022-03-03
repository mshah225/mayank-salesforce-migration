import {LightningElement, api} from 'lwc';

export default class LightningQuestionAnswerSection extends LightningElement {
    /**
     * Expected format for each q:
     * {
     *   key: 'A unique key to identify this question'
     *   question: 'The question',
     *   type: 'text'|'textarea'|'combobox'
     *   options: [{label, value}, ...]  only allowed if type is combobox
     *   subnote: 'note to go under the input field',
     *   required: true|false,
     * }
     */
    @api set questions(val) {
        let newQuestions = [];
        for (let i = 0; i < val.length; i++) {
            let q = {...val[i]};
            q.isTextArea = q.type === 'textarea';
            q.isComboBox = q.type === 'combobox';
            q.hasSubnote = q.subnote != null && q.subnote !== '';
            if (q.required == null) q.required = false;
            if (q.answer == null) q.answer = '';
            newQuestions.push(q);
        }
        this._questions = newQuestions;
    }
    get questions() {
        return this._questions;
    }
    _questions = [];

    @api reportValidity() {
        let allInputs = this.template.querySelectorAll('lightning-input, lightning-textarea, lightning-combobox');
        let valid = true;
        for (let i = 0; i < allInputs.length; i++) {
            valid &= allInputs[i].reportValidity();
        }
        return valid;
    }

    @api
    clearAll() {
        let allInputs = this.template.querySelectorAll('lightning-input, lightning-textarea, lightning-combobox');
        for (let i = 0; i < allInputs.length; i++) {
            allInputs[i].value = '';
        }
        for (let i = 0; i < this.questions.length; i++) {
            const q = this.questions[i];
            q.answer = '';
        }
    }

    changeAnswer(e) {
        const key = e.originalTarget.name;
        const ans = e.detail.value;
        this.dispatchEvent(
            new CustomEvent('change', {
                detail: {key: key, answer: ans},
            })
        );
        e.stopPropagation();
    }

    @api focus() {
        let firstInput = this.template.querySelector('lightning-input, lightning-textarea, lightning-combobox');
        firstInput.focus();
    }
}
