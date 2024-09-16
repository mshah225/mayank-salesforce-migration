/* eslint-disable no-console */
import {LightningElement, api, wire} from 'lwc';
import {cloneObj} from 'c/helperFunctions';

import hasUgradAccess from '@salesforce/apex/AdvisorPortalFilterSectionController.hasUgradAccess';
import hasGradAccess from '@salesforce/apex/AdvisorPortalFilterSectionController.hasGradAccess';

export default class AdvisorPortalFilterSelectCareer extends LightningElement {
    @api
    get currentFilter() {
        return this._currentFilter;
    }
    set currentFilter(val) {
        this._currentFilter = cloneObj(val);
        if (val != null && val.career != null && val.career !== '') {
            this.quietSelect(val.career);
        }
    }
    _currentFilter = null;

    options = [
        {label: 'Undergraduate', value: 'UGRD'},
        {label: 'Graduate', value: 'GRD'},
    ];

    hasUndergradAdvisorPermission = false;
    @wire(hasUgradAccess, {})
    checkedIfUserIsUndergradAdvisor(result) {
        const {data, error} = result;

        if (data !== undefined) {
            this.hasUndergradAdvisorPermission = data;
        }

        if (error !== undefined) {
            console.error('Could not determine if user is undergrad advisor', error);
        }
    }

    hasGradAdvisorPermission = false;
    @wire(hasGradAccess, {})
    checkedIfUserIsGradAdvisor(result) {
        const {data, error} = result;

        if (data !== undefined) {
            this.hasGradAdvisorPermission = data;
        }

        if (error !== undefined) {
            console.error('Could not determine if user is grad advisor', error);
        }
    }

    get isFilterDisabled() {
        const hasBothPerms = this.hasGradAdvisorPermission && this.hasUndergradAdvisorPermission;
        return !hasBothPerms;
    }

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
