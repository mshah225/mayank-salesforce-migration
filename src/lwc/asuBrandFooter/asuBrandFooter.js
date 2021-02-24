import {LightningElement} from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader';
import bootstrap from '@salesforce/resourceUrl/bootstrap_4';

export default class AsuBrandFooter extends LightningElement {
    renderedCallback() {
        const forceSetIds = this.template.querySelectorAll('[data-lwc-force-id]');

        for (let i = 0; i < forceSetIds.length; i++) {
            const element = forceSetIds[i];
            element.id = element.dataset.lwcForceId;
        }

        loadStyle(this, bootstrap);
    }
}
