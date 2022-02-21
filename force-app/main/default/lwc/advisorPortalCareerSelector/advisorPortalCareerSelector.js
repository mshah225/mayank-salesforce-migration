/* eslint-disable no-console */
import {LightningElement, api} from 'lwc';

export default class AdvisorPortalCareerSelector extends LightningElement {
    @api
    get defaultFilter() {
        return null; // no getting needed
    }
    set defaultFilter(val) {
        if (val != null && val.gradStudentsOnly != null) {
            this.value = val.gradStudentsOnly ? 'GRD' : 'UGRD';
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
            new CustomEvent('togglegradonly', {
                detail: {gradOnly: this.value === 'GRD'},
            })
        );

        this.dispatchEvent(
            new CustomEvent('change', {
                detail: {value: this.value === 'GRD'},
            })
        );
    }
}
