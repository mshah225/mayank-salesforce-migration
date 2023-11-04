/* eslint-disable no-console */
import {LightningElement, api} from 'lwc';

import currentUserHasPermissionSet from '@salesforce/apex/PermissionsHelper.currentUserHasPermissionSet';

export default class AdvisorPortalFilterSelectCareer extends LightningElement {
    hasUndergradAdvisorPermission;
    hasGradAdvisorPermission;
    isFilterDisabled = false;

    async connectedCallback() {
        // check if the current user has permission to view undergrad cases
        await currentUserHasPermissionSet({permissionSetName: 'Role_Academic_Advisor_Portal_Service_Users'})
            .then((result) => {
                this.hasUndergradAdvisorPermission = result;
            })
            .catch((error) => {
                console.log('Error occurred while checking for undergrad advisor permission');
                console.log(error);
            });
        // check if the current user has permission to view grad cases
        await currentUserHasPermissionSet({permissionSetName: 'Role_Graduate_Academic_Advisor_Portal_Service_Users'})
            .then((result) => {
                this.hasGradAdvisorPermission = result;
            })
            .catch((error) => {
                console.log('Error occurred while checking for grad advisor permission');
                console.log(error);
            });

        // user has permission to change filters when they have both undergrad and grad advisor permissions
        if (!this.hasUndergradAdvisorPermission || !this.hasGradAdvisorPermission) {
            this.isFilterDisabled = true;
        }

        this.value = this.hasUndergradAdvisorPermission ? 'UGRD' : this.hasGradAdvisorPermission ? 'GRD' : 'UGRD';
        this.sendEvent();
    }

    @api
    get currentFilter() {
        return this._currentFilter;
    }
    set currentFilter(val) {
        this._currentFilter = val;
        if (val != null && val.career != null && val.career !== '') {
            this.quietSelect(val.career);
        }
    }
    _currentFilter = null;

    options = [
        {label: 'Undergraduate', value: 'UGRD'},
        {label: 'Graduate', value: 'GRD'},
    ];

    @api
    quietSelect(val) {
        this.value = val;
    }

    @api
    loudSelect(val) {
        this.value = val;
        this.sendEvent();
    }

    updateViewCasesFor(event) {
        event.stopPropagation();
        event.stopImmediatePropagation();
        event.preventDefault();

        this.value = event.detail.value;
        this.sendEvent();
    }

    sendEvent() {
        this.dispatchEvent(
            new CustomEvent('change', {
                detail: {name: 'career', value: this.value},
            })
        );
    }
}
