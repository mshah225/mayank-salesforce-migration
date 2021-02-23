import {LightningElement} from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader';
import bootstrap from '@salesforce/resourceUrl/bootstrap_4';

export default class AsuBrandFooter extends LightningElement {
    renderedCallback() {
        this.template.querySelector('.wrapper-footer-innovation').id = 'wrapper-footer-innovation';
        this.template.querySelector('.footer-innovation').id = 'footer-innovation';
        this.template.querySelector('.wrapper-footer-colophon').id = 'wrapper-footer-colophon';
        this.template.querySelector('.footer-colophon').id = 'footer-colophon';

        loadStyle(this, bootstrap);
    }
}
