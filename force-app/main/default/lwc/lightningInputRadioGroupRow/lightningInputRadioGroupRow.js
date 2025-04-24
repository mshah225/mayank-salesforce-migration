import {LightningElement, api} from 'lwc';

export default class LightningInputRadioGroupRow extends LightningElement {
    @api label;
    @api name;

    @api options = [];

    @api
    set value(v) {
        this._value = v;
        if (this.hasRendered) this.updateCheckedAttributes();
    }
    get value() {
        return this._value;
    }
    _value;

    renderedCallback() {
        this.hasRendered = true;
        if (this.value) this.updateCheckedAttributes();
    }
    hasRendered = false;

    updateCheckedAttributes() {
        const allOptions = [...this.template.querySelectorAll('.option')];

        for (const opt of allOptions) {
            if (opt.dataset.value === this.value) {
                opt.querySelector('input').checked = true;
            } else {
                opt.querySelector('input').checked = false;
            }
        }
    }

    changeValue(evnt) {
        // Not changing?
        if (evnt.currentTarget.dataset.value === this.value) return;

        // Actual did change
        this.value = evnt.currentTarget.dataset.value;

        this.dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    name: this.name,
                    value: this.value,
                },
            })
        );
    }
}
