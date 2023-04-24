import {LightningElement, api} from 'lwc';

export default class JiraAlert extends LightningElement {
    @api message;
    @api url;
}
