/* eslint-disable no-console */
import {LightningElement} from 'lwc';

export default class AdvisorPortalCareerSelector extends LightningElement {
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
