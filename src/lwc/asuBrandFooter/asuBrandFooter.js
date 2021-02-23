import {LightningElement} from 'lwc';

export default class AsuBrandFooter extends LightningElement {
    renderedCallback() {
        this.template.querySelector('.wrapper-footer-innovation').id = 'wrapper-footer-innovation';
        this.template.querySelector('.footer-innovation').id = 'footer-innovation';
        this.template.querySelector('.wrapper-footer-colophon').id = 'wrapper-footer-colophon';
        this.template.querySelector('.footer-colophon').id = 'footer-colophon';

        let styleSheet = document.createElement('link');
        styleSheet.rel = 'stylesheet';
        styleSheet.type = 'text/css';
        styleSheet.href =
            'https://cdn.jsdelivr.net/gh/mgilardi/asu-design-system/bootstrap4-theme/dist/css/bootstrap-asu.min.css';
        document.head.appendChild(styleSheet);
    }
}
