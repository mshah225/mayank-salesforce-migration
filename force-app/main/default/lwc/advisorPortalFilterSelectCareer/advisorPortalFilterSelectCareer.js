import {LightningElement, api} from 'lwc';

export default class AdvisorPortalFilterSelectCareer extends LightningElement {
    @api
    get defaultFilter() {
        return null; // no getting needed
    }
    set defaultFilter(val) {
        if (val != null && val.career != null && val.career !== '') {
            this.quietSelect(val.career);
        }
    }

    options = [
        {label: 'Undergraduate', value: 'UGRD'},
        {label: 'Graduate', value: 'GRD'},
    ];
    value = 'UGRD';

    @api
    quietSelect(val) {
        this.value = val;
    }

    @api
    loudSelect(val) {
        this.value = val;
        this.sendEvent();
    }

    updateViewCasesFor(event) {
        event.stopPropagation();
        event.stopImmediatePropagation();
        event.preventDefault();

        this.value = event.detail.value;
        this.sendEvent();
    }

    sendEvent() {
        this.dispatchEvent(
            new CustomEvent('change', {
                detail: {name: 'career', value: this.value},
            })
        );
    }
}
