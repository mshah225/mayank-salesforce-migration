import {LightningElement, api} from 'lwc';

export default class LightningQuestionAnswerSection extends LightningElement {
    /**
     * Expected format for each q:
     * {
     *   key: 'A unique key to identify this question'
     *   question: 'The question',
     *   type: 'text'|'textarea'|'combobox'|'dual-listbox'|'label'
     *   subtype:  should specify sub type of type if multiple are possible
     *   options: [{label, value}, ...]  only allowed if type is combobox, or dual-listbox
     *   sourceLabel: the source label (only allowed for dual-listboxes)
     *   selectedLabel: the selected label (only allowed for dual-listboxes)
     *   href: the link the url should go to (inly allowed for label's with subtype link)
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
     *              'link'
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
            if (q.isLabel) q.isLink = q.subtype === 'link';
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

    // inject styles for anything that .css can't modify
    firstRender = true;
    renderedCallback() {
        if (this.firstRender) {
            this.firstRender = false;

            const styleElem = document.createElement('style');
            styleElem.innerText =
                '.slds-input.slds-combobox__input.slds-input_faux label {font-weight:normal; font-size:1em; margin-bottom:0px;}' +
                this.template.querySelector('.styleWrapper').appendChild(styleElem);
        }
    }

    allInputTypes = 'lightning-input, lightning-textarea, c-lightning-combo-box, lightning-dual-listbox';
}
