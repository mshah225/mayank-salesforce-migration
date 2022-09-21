/**
 * @File Name          : advisorPortalTopLevelFilterOption.js
 * @Description        :
 * @Author             : thom.clark@sierra-cedar.com
 * @Group              :
 * @Last Modified By   : thom.clark@sierra-cedar.com
 * @Last Modified On   : 10/18/2019, 12:56:31 PM
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    10/9/2019   thom.clark@sierra-cedar.com     Initial Version
 **/
import {LightningElement, api, track} from 'lwc';

export default class AdvisorPortalUserSelectOption extends LightningElement {
    @track isSelected;

    @api
    get option() {
        return this._option;
    }

    set option(option) {
        this._option = option;
        if (option) {
            // protect against option=null which sometimes occurs on the advisor portal phase two page
            this.isSelected = option.isSelected;
        }
    }

    get label() {
        return this.option.label;
    }

    get ariaSelected() {
        return this.isSelected ? 'true' : 'false';
    }

    toggleOption(event) {
        event.preventDefault();
        this.isSelected = !this.isSelected;

        this.dispatchEvent(
            new CustomEvent('toggleoption', {
                detail: {key: this.option.key, isSelected: this.isSelected},
            })
        );
    }
}
