import {LightningElement, api} from 'lwc';

export default class LightningQuestionAnswerSection extends LightningElement {
    /**
     * Expected format for each q:
     * {
     *   key: 'A unique key to identify this question'
     *   question: 'The question',
     *     sourceLabel: the source label (only allowed for dual-listboxes)
     *     selectedLabel: the selected label (only allowed for dual-listboxes)
     *   type: 'text'|'textarea'|'combobox'|'dual-listbox'|'label'
     *   subtype:  should specify sub type of type if multiple are possible
     *   options: [{label, value}, ...]  only allowed if type is combobox, or dual-listbox
     *   subnote: 'note to go under the input field',
     *   required: true|false,
     * }
     *
     *
     * types:   'text'
     *          'textarea'
     *          'combobox'
     *              'single' (default)
     *              'multi'
     *          'dual-listbox'
     *          'label'
     *              'bold'
     *              'plain' (default)
     *              'center'
     */
    @api set questions(val) {
        let newQuestions = [];
        for (let i = 0; i < val.length; i++) {
            let q = {...val[i]};
            q.isSpacer = q.type === 'spacer';
            q.isLabel = q.type === 'label';
            if (q.isLabel) q.isBoldLabel = q.subtype === 'bold';
            if (q.isLabel) q.isCenterLabel = q.subtype === 'center';
            if (q.isLabel) q.isPlainLabel = q.subtype === 'plain' || q.subtype == null;
            q.isTextArea = q.type === 'textarea';
            q.isComboBox = q.type === 'combobox';
            if (q.isComboBox) q.isMultiSelect = q.subtype === 'multi';
            q.isDualListbox = q.type === 'dual-listbox';
            q.isInput = !(q.isTextArea || q.isComboBox || q.isLabel || q.isDualListbox || q.isSpacer);
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
        let allInputs = this.template.querySelectorAll(this.allInputTypes);
        let valid = true;
        for (let i = 0; i < allInputs.length; i++) {
            valid &= allInputs[i].reportValidity();
        }
        return valid;
    }

    @api clearAll() {
        let allInputs = this.template.querySelectorAll(this.allInputTypes);
        for (let i = 0; i < allInputs.length; i++) {
            allInputs[i].value = '';
        }
        for (let i = 0; i < this.questions.length; i++) {
            const q = this.questions[i];
            q.answer = '';
        }
    }

    changeAnswer(e) {
        const key = e.currentTarget.name;
        const ans = e.detail.value;
        this.dispatchEvent(
            new CustomEvent('change', {
                detail: {key: key, answer: ans},
            })
        );
        e.stopPropagation();
    }

    @api focus() {
        let firstInput = this.template.querySelector(this.allInputTypes);
        firstInput.focus();
    }

    allInputTypes = 'lightning-input, lightning-textarea, c-lightning-combo-box';
}
