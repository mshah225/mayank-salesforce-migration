import {LightningElement} from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader';
import bootstrap4_asu from '@salesforce/resourceUrl/bootstrap_4_asu';
import ASU_Brand_Footer_Logo_URL from '@salesforce/label/c.ASU_Brand_Footer_Logo_URL';

export default class AsuBrandFooter extends LightningElement {
    label = {
        ASU_Brand_Footer_Logo_URL,
    };

    renderedCallback() {
        const forceSetIds = this.template.querySelectorAll('[data-lwc-force-id]');

        for (let i = 0; i < forceSetIds.length; i++) {
            const element = forceSetIds[i];
            element.id = element.dataset.lwcForceId;
        }

        loadStyle(this, bootstrap4_asu + '/dist/css/bootstrap-asu.min.css');
    }
}
