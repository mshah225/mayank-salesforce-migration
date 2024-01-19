import {LightningElement, api, track} from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader';
import bootstrap4_asu from '@salesforce/resourceUrl/bootstrap_4_asu';
import {parseBoolean} from 'c/helperFunctions';

/**
 * ASU-Branded Alert class
 *
 * You should use this class by
 * 1. including it on your page:
 *    <c-asu-brand-alert></c-asu-brand-alert>
 *
 * 2. Calling addAlert to insert alerts onto the DOM automatically
 *    addAlert('FATAL', 'Something went wrong! ', 'Case could not be submitted', null)
 */

export default class AsuBrandAlert extends LightningElement {
    @api singleAlertSeverity = null;
    @api singleAlertTitle = null;
    @api singleAlertMessage = null;
    @api singleAlertLink = null;

    @api set dontLoadASUStyles(val) {
        this._dontLoadASUStyles = parseBoolean(val);
    }
    get dontLoadASUStyles() {
        return this._dontLoadASUStyles;
    }
    _dontLoadASUStyles = false;

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

        if (!this.dontLoadASUStyles) loadStyle(this, bootstrap4_asu + '/dist/css/bootstrap-asu.min.css');
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

    /**
     * Close all alerts. Alternatively, each individual alert can be closed by pressing the close button alongside each alert.
     */
    @api
    clearAlerts() {
        this.alertList = [];
    }

    /**
     * Add an alert to the component.  Along with converting the message to the needed format, this also sets all needed flags on the alert object, including the icon details, ARIA settings,
     * enabling or disabling the link button, and so on.
     *
     * For FATAL and CONFIRM alerts, the alert is given the "alert" ARIA role, grabbing focus from the user.  Other alert types are just given the "status" ARIA role.
     *
     * @param {String} severity The type of alert, this must be either: CONFIRM, WARNING, FATAL, or INFO to use the ASU branded alerts. Other types will result in the base gray minimially styled alert.
     * @param {String} title The title of the alert (shown in bold prior to the main message).
     * @param {String} message The main content of the alert.
     * @param {String} link A link to provide a link to at the end of the alert - usually links to some external content for additional information.  Must set to null if not needed.
     */
    @api
    addAlert(severity, title, message, link) {
        let newAlert = {
            id: '',
            title: title,
            message: message,
            severity: severity,
            icon: 'utility:question_mark',
            iconTitle: '',
            classList: 'alert',
            link: link,
            linkNotNull: link != null && link !== '',
            aria: {
                alertRole: 'status',
                iconDescription: '',
                id: {
                    message: '',
                },
            },
        };
        newAlert.id = '' + this.counter++;
        newAlert.aria.id.message = newAlert.id + '-main-content';

        if (severity === 'CONFIRM') {
            newAlert.icon = 'utility:success';
            newAlert.iconTitle = 'Success';
            newAlert.classList += ' alert-success';
            newAlert.aria.iconDescription = 'Success check mark icon';
            newAlert.aria.alertRole = 'alert';
        } else if (severity === 'INFO') {
            newAlert.icon = 'utility:info';
            newAlert.iconTitle = 'Information';
            newAlert.classList += ' alert-info';
            newAlert.aria.iconDescription = 'Info I-icon';
        } else if (severity === 'WARNING') {
            newAlert.icon = 'utility:notification';
            newAlert.iconTitle = 'Alert';
            newAlert.classList += ' alert-warning';
            newAlert.aria.iconDescription = 'Warning message bell icon';
        } else if (severity === 'FATAL') {
            newAlert.icon = 'utility:warning';
            newAlert.iconTitle = 'Error';
            newAlert.classList += ' alert-danger';
            newAlert.aria.iconDescription = 'Error triangle icon';
            newAlert.aria.alertRole = 'alert';
        } else {
            newAlert.icon = 'utility:question_mark';
            newAlert.iconTitle = title;
            newAlert.aria.iconDescription = 'Question mark icon';
        }

        this.alertList.push(newAlert);
    }
}
