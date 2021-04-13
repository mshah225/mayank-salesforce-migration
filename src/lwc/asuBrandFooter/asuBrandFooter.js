import {LightningElement} from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader';
import bootstrap4_asu from '@salesforce/resourceUrl/bootstrap_4_asu';

export default class AsuBrandFooter extends LightningElement {
    renderedCallback() {
        const forceSetIds = this.template.querySelectorAll('[data-lwc-force-id]');

        for (let i = 0; i < forceSetIds.length; i++) {
            const element = forceSetIds[i];
            element.id = element.dataset.lwcForceId;
        }

        loadStyle(this, bootstrap4_asu + '/dist/css/bootstrap-asu.min.css');
    }
}
