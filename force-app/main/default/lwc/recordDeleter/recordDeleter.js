import {LightningElement, wire} from 'lwc';
import {EnclosingTabId, setTabLabel, setTabIcon} from 'lightning/platformWorkspaceApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {CurrentPageReference, NavigationMixin} from 'lightning/navigation';
import LightningConfirm from 'lightning/confirm';
import {extractErrorMessages} from 'c/helperFunctions';
import {CSVScanner} from 'c/csvReader';
import hasAccess from '@salesforce/apex/RecordDeleterController.hasAccess';
import getObjectName from '@salesforce/apex/RecordDeleterController.getObjectName';
import performMassDelete from '@salesforce/apex/RecordDeleterController.performMassDelete';
import checkStatus from '@salesforce/apex/RecordDeleterController.checkStatus';
import getResults from '@salesforce/apex/RecordDeleterController.getResults';

export default class RecordDeleter extends NavigationMixin(LightningElement) {
    /**
     * Set tab name and icon
     */
    @wire(EnclosingTabId)
    gotEnclosingTabId(enclosingTabId) {
        if (enclosingTabId != null) {
            setTabLabel(enclosingTabId, 'Mass Deleter');
            setTabIcon(enclosingTabId, 'utility:delete');
        }
    }

    /**
     * Read coordinator ID from URL and start cehcks
     */
    @wire(CurrentPageReference)
    gotPageReference(currentPageReference) {
        if (currentPageReference != null) {
            // store current page ref
            this.currentPageReference = currentPageReference;
            // get coordinator id from url
            this.coordinatorId = currentPageReference.state.c__coordinatorId || undefined;
            if (this.coordinatorId != null) this.loopCheck();
        }
    }
    currentPageReference = undefined;

    @wire(hasAccess)
    checkedHasAccess(response) {
        if (response.data !== undefined) {
            this.hasAccess = response.data;
            this.hasAccessError = undefined;
        }
        if (response.error !== undefined) {
            this.hasAccess = undefined;
            this.hasAccessError = response.error;
        }
    }
    hasAccess = undefined;
    hasAccessError = undefined;

    // State tracking
    isProcessing = false;
    isUploading = false;
    isDeleting = false;
    isGeneratingTable = false;
    objectName = undefined;
    deleteRecordIds = [];
    coordinatorId = undefined;
    donePercent = 0;

    get deleteButtonDisabled() {
        return (
            (this.deleteRecordIds ?? []).length === 0 ||
            this.isProcessing ||
            this.isUploading ||
            this.objectName === undefined ||
            this.isDeleting ||
            this.isGeneratingTable
        );
    }

    get loadingReason() {
        if (this.isProcessing) return 'Processing file';
        else if (this.isUploading) return 'Uploading file';
        else if (this.isDeleting) return 'Deletion in Progress';
        else if (this.isGeneratingTable) return 'Generating table';
        return null;
    }

    /**
     * Whenever file is changed, parse it and get list of records to delete
     */
    changeFile(evnt) {
        // Changing file
        this.isProcessing = true;
        this.deleteResults = [];
        this.objectName = undefined;

        // Validate
        if (evnt.detail.files.length > 1) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Uploading File',
                    message: 'You can only upload one file at a time',
                    variant: 'error',
                })
            );
            this.isProcessing = false;
            return;
        } else if (evnt.detail.files < 1) {
            this.isProcessing = false;
            return;
        }

        // Get file contents
        // eslint-disable-next-line compat/compat
        let deleteRecordIds = [];
        evnt.detail.files[0]
            .arrayBuffer()
            .then((v) => {
                // eslint-disable-next-line compat/compat
                const decoder = new TextDecoder('utf-8');
                const contents = decoder.decode(v);

                // List of everything that looks like an id
                deleteRecordIds = contents.split(/[\r\n]+/).filter((row) => {
                    return row.length >= 15 && row.length <= 18;
                });

                // There are ids?
                if (deleteRecordIds.length === 0) {
                    return Promise.reject(new Error('File is empty and contains no record ids'));
                }

                // All have same prefix (same type)
                let firstPrefix = null;
                for (const recordId of deleteRecordIds) {
                    if (firstPrefix == null) firstPrefix = recordId.substring(0, 3);
                    if (recordId.substring(0, 3) !== firstPrefix)
                        return Promise.reject(new Error('File contains mixed object types - cannot process'));
                }

                this.deleteRecordIds = deleteRecordIds;
                return getObjectName({prefix: firstPrefix});
            })
            .then((objectName) => {
                this.objectName = objectName;
            })
            .catch((e) => {
                console.error('Error Uploading File', e);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Uploading File',
                        message: extractErrorMessages(e)[0],
                        variant: 'error',
                    })
                );
            })
            .finally(() => {
                this.isProcessing = false;
            });
    }

    /**
     * Start deletion
     */
    deleteRecords() {
        LightningConfirm.open({
            label: `Delete ${this.deleteRecordIds.length} ${this.objectName}s?`,
            message: `You are about to delete ${this.deleteRecordIds.length} parent ${this.objectName}s  - is that right?`,
            theme: 'success',
        })
            .then((v) => {
                if (v === true) {
                    this.isUploading = true;
                    return performMassDelete({
                        recordIds: this.deleteRecordIds,
                    });
                }
                return Promise.reject(new Error('Deletion aborted'));
            })
            .then((v) => {
                this.coordinatorId = v;
                this.setUrlParam({c__coordinatorId: this.coordinatorId});
                this.loopCheck();
            })
            .catch((e) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Failed to begin deletion',
                        message: extractErrorMessages(e)[0],
                        variant: 'error',
                    })
                );
            })
            .finally(() => {
                this.isUploading = false;
            });
    }

    /**
     * Repeatedly check status until job is complete
     */
    loopCheck() {
        this.isDeleting = true;

        checkStatus({
            coordinatorId: this.coordinatorId,
        })
            .then((v) => {
                if (v.done) {
                    this.loadResults();
                } else {
                    this.donePercent = Number(v.percent * 100).toPrecision(3);
                    // Check again in 3 seconds
                    setTimeout(() => {
                        this.loopCheck();
                    }, 3000);
                }
            })
            .catch((e) => {
                this.isDeleting = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Could not check status of job',
                        message: extractErrorMessages(e)[0],
                        variant: 'error',
                    })
                );
            });
    }

    /**
     * Once job is complete, retrieve results for display
     */
    loadResults() {
        getResults({
            coordinatorId: this.coordinatorId,
        })
            .then((v) => {
                // Store results
                this.isGeneratingTable = true;
                let deleteResults = [];

                const scanner = new CSVScanner(v, ',', '\n');
                while (scanner.hasNextRow()) {
                    const row = scanner.getNextRow();
                    deleteResults.push({
                        recordId: row['Record Id'],
                        success: row.Status === 'TRUE' ? true : row.Status === 'FALSE' ? false : null,
                        errorMessage: row.Error,
                    });
                }
                this.deleteResults = deleteResults;
                this.isGeneratingTable = false;

                // Any failures?
                if (
                    !this.deleteResults.reduce((acc, row) => {
                        return acc && row.success;
                    }, true)
                ) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Some records failed to delete',
                            message: 'View table below to see all failures',
                            variant: 'warning',
                        })
                    );
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success!',
                            message: 'All records deleted successfully',
                            variant: 'success',
                        })
                    );
                }
            })
            .catch((e) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Could not load results',
                        message: extractErrorMessages(e)[0],
                        variant: 'error',
                    })
                );
            })
            .finally(() => {
                this.isDeleting = false;
            });
    }
    deleteResults = [];

    /**
     * Logic for displaying table
     */
    tableColumns = [
        {
            label: 'Record Id',
            fieldName: 'recordId',
            hideDefaultActions: true,
            sortable: true,
            cellAttributes: {
                class: {fieldName: 'class'},
            },
        },
        {
            label: 'Success',
            fieldName: 'success',
            type: 'boolean',
            hideDefaultActions: true,
            sortable: true,
            initialWidth: 120,
            cellAttributes: {
                class: {fieldName: 'class'},
            },
        },
        {
            label: 'Error Message',
            fieldName: 'errorMessage',
            sortable: true,
            cellAttributes: {
                class: {fieldName: 'class'},
            },
            wrapText: true,
        },
    ];
    get tableRows() {
        // Sort based on original order of record ids in uploaded file
        const rows = (this.deleteResults ?? [])
            .map((v) => {
                return {
                    recordId: v.recordId,
                    success: v.success,
                    errorMessage: v.errorMessage,
                    class: v.success ? 'slds-text-color_success' : 'slds-text-color_error',
                };
            })
            .sort((a, b) => {
                let v = 0;
                if (this.sortedBy === 'recordId') {
                    // sort by order of uploaded file
                    v = this.deleteRecordIds.indexOf(b) < this.deleteRecordIds.indexOf(a) ? 1 : -1;
                } else if (this.sortedBy === 'success') {
                    // successes first
                    v = b.success > a.success ? 1 : -1;
                } else if (this.sortedBy === 'errorMessage') {
                    // error messages first
                    v = (b.errorMessage ?? '') < (a.errorMessage ?? '') ? 1 : -1;
                }

                return v * (this.sortDirection === 'asc' ? 1 : -1);
            });

        return rows;
    }
    pageSize = 15;
    sortDirection = 'asc';
    sortedBy = 'recordId';
    onHandleSort = (evnt) => {
        this.sortedBy = evnt.detail.fieldName;
        this.sortDirection = evnt.detail.sortDirection;
    };

    setUrlParam(params) {
        // eslint-disable-next-line compat/compat
        const newPageRef = Object.assign({}, this.currentPageReference, {
            // eslint-disable-next-line compat/compat
            state: Object.assign({}, this.currentPageReference.state, params),
        });
        this[NavigationMixin.Navigate](newPageRef);
    }

    get loading() {
        return (
            this.currentPageReference === undefined ||
            (this.hasAccess === undefined && this.hasAccessError === undefined)
        );
    }

    get errorMessage() {
        if (this.hasAccessError !== undefined) return 'Current user is not allowed to mass delete records';
        return '';
    }
    get hasError() {
        return this.hasAccessError !== undefined;
    }
}
