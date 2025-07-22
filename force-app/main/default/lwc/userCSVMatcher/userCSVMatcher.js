import {LightningElement, wire, api} from 'lwc';
import {EnclosingTabId, setTabLabel, setTabIcon} from 'lightning/platformWorkspaceApi';
import {CurrentPageReference, NavigationMixin} from 'lightning/navigation';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {notifyRecordUpdateAvailable} from 'lightning/uiRecordApi';
import Toast from 'lightning/toast';
import getUserSearchCustomMetadata from '@salesforce/apex/UserMatcherController.getUserSearchCustomMetadata';
import getUserSearchRoleCustomMetadata from '@salesforce/apex/UserMatcherController.getUserSearchRoleCustomMetadata';
import startAudit from '@salesforce/apex/UserMatcherController.startAudit';
import checkStatus from '@salesforce/apex/UserMatcherController.checkStatus';
import getDownloadLink from '@salesforce/apex/UserMatcherController.getDownloadLink';
import getFileContents from '@salesforce/apex/UserMatcherController.getFileContents';
import {extractErrorMessages} from 'c/helperFunctions';

import MATCHED_COUNT_FIELD from '@salesforce/schema/User_Audit_Log__c.Matched_Count__c';
import SKIPPED_COUNT_FIELD from '@salesforce/schema/User_Audit_Log__c.Skipped_Count__c';

export default class UserCSVMatcher extends NavigationMixin(LightningElement) {
    /**
     * Set tab name and icon
     */
    @wire(EnclosingTabId)
    gotEnclosingTabId(enclosingTabId) {
        if (enclosingTabId != null) {
            setTabLabel(enclosingTabId, 'User Audit Matcher');
            setTabIcon(enclosingTabId, 'standard:process');
        }
    }

    /**
     * Read audit log ID from URL and start checks
     */
    @wire(CurrentPageReference)
    gotPageReference(currentPageReference) {
        if (currentPageReference != null) {
            // store current page ref
            this.currentPageReference = currentPageReference;
            // get coordinator id from url
            this.auditLogId = currentPageReference.state.c__auditLogId || undefined;
            if (this.auditLogId != null) this.awaitCompletion();
        }
    }
    currentPageReference = undefined;

    // State tracking
    isProcessing = false;
    isUploading = false;
    isRunning = false;
    auditLogId = undefined;
    donePercent = 0;

    // Disabled during job running and whenever file is being processed
    get submitButtonDisabled() {
        return this.isProcessing || this.isUploading || this.isRunning;
    }

    // Primary inputs
    uploadedFile = null;
    auditRole = null;

    // While running
    get loadingReason() {
        if (this.isProcessing) return 'Processing file';
        else if (this.isUploading) return 'Uploading file';
        else if (this.isRunning) return 'Running';
        return null;
    }

    // When complete
    downloadLink = null;
    resultCsv = null;
    get csvTable() {
        if (this.resultCsv != null) {
            // Once results are done, show those
            return this.resultCsv;
        } else if (this.userSearchFieldsList != null) {
            // Until results are ready, just show headers
            return this.userSearchFieldsList.map((v) => `"${v.label}"`).join(',') + '\n';
        }
        return null;
    }

    get fileUploadLabel() {
        let label = 'Upload CSV file';
        if (this.uploadedFile != null) {
            label = this.uploadedFile.filename;
        }
        return label;
    }

    /**
     * Get the fields that are being retrieved (from custom metadata)
     */
    @wire(getUserSearchCustomMetadata)
    gotUserSearchCustomMetadata({error, data}) {
        if (data !== undefined) {
            this.userSearchFieldsList = data;
            this.userSearchFieldsError = undefined;

            // If none are configured show an error
            if (this.userSearchFieldsList.length === 0) {
                this.userSearchFieldsList = undefined;
                this.userSearchFieldsError = new Error(
                    'No columns configured for auditing - please contact a Salesforce Admin'
                );
            }
        }
        if (error !== undefined) {
            this.userSearchFieldsList = undefined;
            this.userSearchFieldsError = error;
        }
    }
    userSearchFieldsList;
    userSearchFieldsError;

    /**
     * Get all the roles that the user can perform an audit on behalf of
     */
    @wire(getUserSearchRoleCustomMetadata)
    gotUserSearchRoleCustomMetadata({error, data}) {
        if (data !== undefined) {
            this.userSearchRolesList = data;
            this.userSearchRolesError = undefined;

            // If none are configured show an error
            if (this.userSearchRolesList.length === 0) {
                this.userSearchRolesList = undefined;
                this.userSearchRolesError = new Error(
                    'No roles configured for auditing - please contact a Salesforce Admin'
                );
            }
        }
        if (error !== undefined) {
            this.userSearchRolesList = undefined;
            this.userSearchRolesError = error;
        }
    }
    userSearchRolesList;
    userSearchRolesError;

    @wire(getRecord, {
        recordId: '$auditLogId',
        fields: [MATCHED_COUNT_FIELD, SKIPPED_COUNT_FIELD],
    })
    gotUserAuditLog({error, data}) {
        if (data !== undefined) {
            this.userAuditLog = data;
        }
        if (error !== undefined) {
            this.userAuditLog = undefined;
            Toast.show({
                label: 'Error loading audit log',
                message: 'Cannot load total matched/skipped counts',
                variant: 'error',
            });
        }
    }
    userAuditLog;

    get matchedCount() {
        return this.userAuditLog ? getFieldValue(this.userAuditLog, MATCHED_COUNT_FIELD) : 0;
    }
    get skippedCount() {
        return this.userAuditLog ? getFieldValue(this.userAuditLog, SKIPPED_COUNT_FIELD) : 0;
    }

    get showSummaryFields() {
        return this.userAuditLog != null && !this.isProcessing && !this.isUploading && !this.isRunning;
    }

    /**
     * The user has uploaded a CSV file
     * @param {ChangeEvent} event
     */
    changeFile(event) {
        // Changing file
        this.isProcessing = true;

        // Validate
        if (event.detail.files.length > 1) {
            Toast.show({
                label: 'Error Uploading File',
                message: 'You can only upload one file at a time',
                variant: 'error',
            });
            this.isProcessing = false;
            return;
        } else if (event.detail.files < 1) {
            this.isProcessing = false;
            return;
        }

        let filename = event.detail.files[0].name;

        // Get file contents
        event.detail.files[0]
            .text()
            .then((v) => {
                let identifiers = v.split(/[\r\n]+/).filter((v2) => !!v2); // remove empty lines
                this.uploadedFile = {
                    filename: filename,
                    identifiers: identifiers,
                };
            })
            .catch((e) => {
                Toast.show({
                    label: 'Error Uploading File',
                    message: extractErrorMessages(e)[0],
                    variant: 'error',
                });
            })
            .finally(() => {
                this.isProcessing = false;
            });
    }

    /**
     * Select which role to run the audit on behalf of
     */
    setAuditRole(event) {
        this.auditRole = event.detail.value;
    }

    /**
     * Submit and upload the CSV file.  This will trigger the UserMatcher batch class and cause us to wait until the process is complete
     */
    submitFile() {
        if (this.uploadedFile == null) {
            Toast.show({
                label: 'Cannot start audit',
                message: 'Must select a non-empty file to upload first',
                variant: 'warning',
                mode: 'dismissible',
            });
            return; // don't continue if no fileData
        }
        if (this.auditRole == null) {
            Toast.show({
                label: 'Cannot start audit',
                message: 'Must select an audit role first',
                variant: 'warning',
                mode: 'dismissible',
            });
            return; // don't continue if no audit role
        }

        this.isUploading = true;
        this.isRunning = false;
        this.resultCsv = null;
        this.downloadLink = null;
        this.auditLogId = null;
        this.userAuditLog = null;

        Toast.show({
            label: 'Uploading',
            message: 'Uploading file...',
            variant: 'info',
            mode: 'dismissible',
        });

        startAudit({
            identifiers: this.uploadedFile.identifiers,
            auditRole: this.auditRole,
        })
            .then((val) => {
                this.auditLogId = val;
                Toast.show({
                    label: 'File uploaded!',
                    message: 'Batch job starting',
                    variant: 'info',
                    mode: 'dismissible',
                });
                this.setUrlParam({c__auditLogId: this.auditLogId}); // this will trigger the gotPageReference wire which will start the await complete loop
            })
            .catch((error) => {
                const exError = extractErrorMessages(error).reduce((prev, curr) => prev.concat(curr + '\n'), '');
                Toast.show({
                    label: 'Error uploading file',
                    message: exError,
                    variant: 'error',
                });
            })
            .finally(() => {
                this.isUploading = false;
            });
    }

    /**
     * Wait for the batch jobs to complete
     * Loops until complete - updating the toast on either success or failure.
     * Upon success, download the User search results
     */
    awaitCompletion() {
        this.isRunning = true;
        checkStatus({auditLogId: this.auditLogId})
            .then((v) => {
                if (v.done) {
                    this.loadResults();
                } else {
                    this.donePercent = Number(v.percent * 100).toPrecision(3);
                    // Check again in 3 seconds
                    setTimeout(() => {
                        this.awaitCompletion();
                    }, 3000);
                }
            })
            .catch((error) => {
                const exError = extractErrorMessages(error).reduce((prev, curr) => prev.concat(curr + '\n'), '');
                Toast.show({
                    label: 'Error!',
                    message: exError,
                    variant: 'error',
                });
                this.isRunning = false;
            })
            .finally(() => {});
    }

    /**
     * Retrieve the contents of the file to display in table
     */
    loadResults() {
        notifyRecordUpdateAvailable([{recordId: this.auditLogId}]).catch(() => {
            // This is just for updating the matched/skipped counts, so it is OK if it fails hence no catch logic
        });

        Promise.all([
            getDownloadLink({auditLogId: this.auditLogId}).then((val) => {
                this.downloadLink = val;
            }),
            getFileContents({auditLogId: this.auditLogId}).then((val) => {
                this.resultCsv = val;
            }),
        ])
            .then(() => {
                Toast.show({
                    label: 'Success',
                    message: 'Audit complete',
                    variant: 'success',
                    mode: 'dismissible',
                });
            })
            .catch((error) => {
                const exError = extractErrorMessages(error).reduce((prev, curr) => prev.concat(curr + '\n'), '');
                Toast.show({
                    label: 'Error!',
                    message: exError,
                    variant: 'error',
                });
            })
            .finally(() => {
                this.isRunning = false;
            });
    }

    /**
     * Navigate to the audit log record
     */
    goToAuditLog() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.auditLogId,
                actionName: 'view',
            },
        });
    }

    /**
     * Set URL parameters without reloading the page
     * @param {Object} params Parameters to set in URL
     */
    setUrlParam(params) {
        // eslint-disable-next-line compat/compat
        const newPageRef = Object.assign({}, this.currentPageReference, {
            // eslint-disable-next-line compat/compat
            state: Object.assign({}, this.currentPageReference.state, params),
        });
        this[NavigationMixin.Navigate](newPageRef, true);
    }

    /**
     * Indicates whether the page is done loading pre-reqs
     */
    get metaLoading() {
        return this.userSearchFieldsList === undefined || this.userSearchRolesList === undefined;
    }

    /**
     * Errors that prevent component from loading correctly?
     */
    get errorMessage() {
        if (this.userSearchFieldsError !== undefined) return extractErrorMessages(this.userSearchFieldsError)[0];
        else if (this.userSearchRolesError !== undefined) return extractErrorMessages(this.userSearchRolesError)[0];
        return '';
    }
    get hasError() {
        return this.userSearchFieldsError !== undefined || this.userSearchRolesError !== undefined;
    }
}

export class UserCSVMatcherTest extends UserCSVMatcher {
    @api
    get userSearchRolesList() {
        return super.userSearchRolesList;
    }
    set userSearchRolesList(v) {
        super.userSearchRolesList = v;
    }

    @api
    get downloadLink() {
        return super.downloadLink;
    }
    set downloadLink(v) {
        super.downloadLink = v;
    }

    @api
    get csvTable() {
        return super.csvTable;
    }

    @api
    get metaLoading() {
        return super.metaLoading;
    }

    @api
    get errorMessage() {
        return super.errorMessage;
    }

    @api
    get hasError() {
        return super.hasError;
    }
}
