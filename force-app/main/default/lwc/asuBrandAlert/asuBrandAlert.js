import {LightningElement, api, track} from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader';
import bootstrap4_asu from '@salesforce/resourceUrl/bootstrap_4_asu';
import font_awesome from '@salesforce/resourceUrl/Font_Awesome_4_7_0';

export default class AsuBrandAlert extends LightningElement {
    @api singleAlertSeverity = null;
    @api singleAlertTitle = null;
    @api singleAlertMessage = null;
    @api singleAlertLink = null;

    counter = 0;
    @track alertList = [];

    connectedCallback() {
        if (this.singleAlertSeverity != null) {
            this.addAlert(
                this.singleAlertSeverity,
                this.singleAlertTitle,
                this.singleAlertMessage,
                this.singleAlertLink
            );
        }
    }

    renderedCallback() {
        loadStyle(this, bootstrap4_asu + '/dist/css/bootstrap-asu.min.css');
        loadStyle(this, font_awesome + '/Font_Awesome_4_7_0/css/font-awesome.min.css');
    }

    @api
    addTest() {
        this.addAlert(
            'WARNING',
            '',
            'Have a Financial Aid question? Before you contact us, get quick answers to the most common questions students are asking right now.',
            'https://students.asu.edu/contact/financialaid'
        );
    }

    closeAlert(event) {
        let keyToRemove;
        let checkForKey = event.target;
        let limitCheck = 10;

        while (keyToRemove === undefined && limitCheck-- > 0) {
            keyToRemove = checkForKey.dataset.key;
            checkForKey = checkForKey.parentNode;
        }

        for (let i = 0; i < this.alertList.length; i++) {
            if (this.alertList[i].id === keyToRemove) {
                this.alertList.splice(i, 1);
                break;
            }
        }
    }

    @api
    addAlert(severity, title, message, link) {
        let newAlert = {
            id: '',
            title: title,
            message: message,
            severity: severity,
            icon: 'fa fa-icon fa-2x',
            iconTitle: '',
            classList: 'alert',
            link: link,
            linkNotNull: link != null,
        };
        newAlert.id = '' + this.counter++;

        if (severity === 'CONFIRM') {
            newAlert.icon += ' fa-check-circle';
            newAlert.iconTitle = 'Success';
            newAlert.classList += ' alert-success';
        } else if (severity === 'INFO') {
            newAlert.icon += ' fa-info-circle';
            newAlert.iconTitle = 'Information';
            newAlert.classList += ' alert-info';
        } else if (severity === 'WARNING') {
            newAlert.icon += ' fa-bell';
            newAlert.iconTitle = 'Alert';
            newAlert.classList += ' alert-warning';
        } else if (severity === 'FATAL') {
            newAlert.icon += ' fa-exclamation-triangle';
            newAlert.iconTitle = 'Error';
            newAlert.classList = ' alert-danger';
        } else {
            newAlert.icon += ' fa-question-circle';
            newAlert.iconTitle = title;
            newAlert.classList = ' alert-question';
        }

        this.alertList.push(newAlert);
    }
}
