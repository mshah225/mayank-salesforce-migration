import {LightningElement, api} from 'lwc';

export default class JiraQuestionAnswerSection extends LightningElement {
    /**
     * Expected format for each q:
     * {
     *   key: 'A unique key to identify this question'
     *   body: 'The question',
     *   type: 'text'|'textarea'
     *   subnote: 'note to go under the input field',
     *   required: true|false,
     * }
     */
    @api set questions(val) {
        let newQuestions = [];
        for (let i = 0; i < val.length; i++) {
            let q = {...val[i]};
            q.isTextArea = q.type === 'textarea';
            q.isLink = q.type === 'link';
            q.hasSubnote = q.subnote != null && q.subnote !== '';
            if (q.required == null) q.required = false;
            newQuestions.push(q);
        }
        this._questions = newQuestions;
    }
    get questions() {
        return this._questions;
    }
    _questions = [];

    @api reportValidity() {
        let allInputs = this.template.querySelectorAll('lightning-input, lightning-textarea');
        let valid = true;
        for (let i = 0; i < allInputs.length; i++) {
            valid &= allInputs[i].reportValidity();
        }
        return valid;
    }

    changeAnswer(e) {
        const key = e.originalTarget.name;
        const ans = e.detail.value;
        for (let i = 0; i < this.questions.length; i++) {
            const q = this.questions[i];
            if (q.key === key) {
                q.answer = ans;
            }
        }

        this.dispatchEvent(
            new CustomEvent('change', {
                detail: this.questions,
            })
        );
    }
}
