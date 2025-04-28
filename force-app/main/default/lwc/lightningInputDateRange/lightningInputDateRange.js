import {LightningElement, api} from 'lwc';

export default class LightningInputDateRange extends LightningElement {
    @api name;
    @api label;

    @api fromValue;
    @api toValue;

    changeLowerBound(evnt) {
        evnt.stopPropagation();
        evnt.stopImmediatePropagation();
        evnt.preventDefault();

        this.fromValue = evnt.detail.value;

        this.sendChangeEvent();
    }

    changeUpperBound(evnt) {
        evnt.stopPropagation();
        evnt.stopImmediatePropagation();
        evnt.preventDefault();

        this.toValue = evnt.detail.value;

        this.sendChangeEvent();
    }

    sendChangeEvent() {
        this.dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    name: this.name,
                    value: {
                        from: this.fromValue,
                        to: this.toValue,
                    },
                },
            })
        );
    }
}
