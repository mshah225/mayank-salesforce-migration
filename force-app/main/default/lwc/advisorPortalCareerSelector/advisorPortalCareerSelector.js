/* eslint-disable no-console */
import {LightningElement} from 'lwc';

export default class AdvisorPortalCareerSelector extends LightningElement {
    options = [
        {label: 'Undergraduate', value: 'UGRD'},
        {label: 'Graduate', value: 'GRD'},
    ];
    value = 'UGRD';

    updateViewCasesFor(event) {
        console.log(this.value);
        this.value = event.detail.value;
        console.log(this.value);
    }
}
