import {api, wire} from 'lwc';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import LightningModal from 'lightning/modal';
import {falseWireRun} from 'c/helperFunctions';

export default class AdvisorPortalModalMassClose extends LightningModal {
    @api selectedContactWrappers = [];
    @api gradMode = false;

    @api loadingCb;
    @api toastCb;
    @api navCb;

    // Extract case ids from contact wrappers
    get caseIds() {
        let caseIds = [];
        for (const contactWrapper of this.selectedContactWrappers)
            for (const caseWrapper of contactWrapper.cases) caseIds.push(caseWrapper.caseId);
        return caseIds;
    }

    // Get the Advisor Case Record Type Id
    get advisorCaseRecordTypeId() {
        let recordTypeMap = this.caseInfo?.recordTypeInfos ?? {};
        let advisorCaseRecordTypeId = null;

        for (const recTypeId of Object.keys(recordTypeMap)) {
            if (this.gradMode) {
                if (recordTypeMap[recTypeId].name === '(Admin Only) ASU Graduate Advisor Portal')
                    advisorCaseRecordTypeId = recTypeId;
            } else {
                if (recordTypeMap[recTypeId].name === '(Admin Only) ASU Advisor Outreach')
                    advisorCaseRecordTypeId = recTypeId;
            }
        }

        // Either use the type for the proper record type (depending on grad or ugrad mode)
        // Or failing that, use default for the case object
        // Or failing that, use null
        return advisorCaseRecordTypeId ?? this.caseInfo?.defaultRecordTypeId ?? null;
    }

    @wire(getObjectInfo, {objectApiName: CASE_OBJECT})
    gotCaseInfo(result) {
        if (falseWireRun(result)) return;

        let {data, error} = result;
        if (data != null) {
            this.caseInfo = data;
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error(error);
        }
    }
    caseInfo = null;

    isSubmitting = false;

    /**
     * Close the mass close modal
     */
    closeModal() {
        this.close();
    }

    /**
     * Attempt to commit the changes, closing all the cases
     */
    closeCases() {
        this.refs.caseCloseView.commit();
    }

    /**
     * When updates occur we need to react.
     * When the form is submitting we need to prevent repeat submissions.
     * When the form has succesfully submitted, we can close modal.
     * When the form has errored (usually due to missing a required field), we need to allow a new submission attempt
     */
    statusHandler(evnt) {
        if (evnt.detail.type === 'success') {
            this.isSubmitting = false;
            this.closeModal();
        } else if (evnt.detail.type === 'form_error') {
            this.isSubmitting = false;
        } else if (evnt.detail.type === 'submitting') {
            this.isSubmitting = true;
        }
    }

    /**
     * The cases failed to update, unexpectedly
     */
    errorHandler(evnt) {
        this.isSubmitting = false;
        this.makeToast('error', 'Error!', evnt.detail.errors[0] ?? '');
    }

    // Call the loadingCb
    sendLoadingEvent(loadMore) {
        if (this.loadingCb != null) this.loadingCb(new CustomEvent('loading', {detail: loadMore}));
    }

    // Call the toastCb
    makeToast(type, title, body) {
        if (this.toastCb != null)
            this.toastCb(
                new CustomEvent('showtoast', {
                    detail: {
                        title: title,
                        message: body,
                        type: type,
                        duration: 5000,
                    },
                })
            );
    }

    // Call the navCb
    navigate(location, params) {
        if (this.navCb != null) {
            this.navCb(
                new CustomEvent('navigate', {
                    detail: {
                        location: location,
                        params: params,
                    },
                })
            );
        }
    }

    convertToastHandler(evnt) {
        let toastType = evnt?.toastAttributes?.type;
        let toastTitle = evnt?.toastAttributes?.title;
        let toastMessage = evnt?.toastAttributes?.message;

        if (toastType != null && toastTitle != null && toastMessage != null) {
            this.makeToast(toastType, toastTitle, toastMessage);
        } else {
            this.makeToast(
                'warning',
                'Unable to create toast',
                'A toast was raised but could not be parsed and displayed - see JS console for the toast event object'
            );
            console.warn('Un-parsable toast event', evnt);
        }
    }
}
