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

    updateViewCasesFor(event) {
        this.value = event.detail.value;

        this.dispatchEvent(
            new CustomEvent('togglegradonly', {
                detail: {gradOnly: this.value === 'GRD'},
            })
        );
    }
}
