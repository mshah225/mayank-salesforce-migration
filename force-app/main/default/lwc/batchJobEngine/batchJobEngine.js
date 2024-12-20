import {LightningElement, track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getAllBatchClassNames from '@salesforce/apex/BatchJobEngineController.getAllBatchClassNames';
import engineHasAccessToBatchClass from '@salesforce/apex/BatchJobEngineController.engineHasAccessToBatchClass';
import executeBatch from '@salesforce/apex/BatchJobEngineController.executeBatch';
import getJobDetails from '@salesforce/apex/BatchJobEngineController.getJobDetails';

export default class BatchJobEngine extends LightningElement {
    @track batchClassOptions = [];
    selectedBatchClass = '';
    engineHasAccess = false;
    minBatchSize = 1;
    maxBatchSize = 40;
    batchSize = 20; // Default batch size
    batchJobId = '';
    progress = 0;
    executedBatch = 0;
    totalBatch = 0;
    numberOfErrors = 0;
    isModalOpen = false;
    isBatchCompleted = false;
    isRunning = false;

    connectedCallback() {
        this.template.querySelector('c-lightning-design-toast');
        getAllBatchClassNames()
            .then((data) => {
                this.batchClassOptions = data.map((name) => ({label: name, value: name}));
            })
            .catch((error) => {
                console.error('Error fetching batch classes:', error);
            });
    }

    handleOpenModal() {
        this.isModalOpen = true;
    }
    handleCloseModal() {
        this.isModalOpen = false;
    }

    handleBatchClassChange(event) {
        this.selectedBatchClass = event.detail.value;

        engineHasAccessToBatchClass({className: this.selectedBatchClass})
            .then((data) => {
                this.engineHasAccess = data;

                if (!this.engineHasAccess) {
                    this.isRunning = false;
                    this.selectedBatchClass = '';
                    this.showErrorToast();
                }
            })
            .catch((error) => {
                console.error('Error retrieving engine access to batch class:', error);
                this.engineHasAccess = false;
                this.isRunning = false;
                this.selectedBatchClass = '';
            });
    }

    showErrorToast() {
        const evt = new ShowToastEvent({
            title: 'Access Denied',
            message:
                'Batch Job Engine does not have permission to run this batch class. See Batch_Job_Engine_Setting__mdt to define access.',
            variant: 'error',
            mode: 'dismissable',
        });
        this.dispatchEvent(evt);
    }

    handleBatchSizeChange(event) {
        this.batchSize = parseInt(event.target.value, 10);
    }

    handleExecuteBatch() {
        this.isModalOpen = false;
        this.isRunning = true;
        this.batchJobId = ''; // Reset previous job ID

        if (this.engineHasAccess) {
            executeBatch({className: this.selectedBatchClass, chunkSize: this.batchSize})
                .then((jobId) => {
                    this.batchJobId = jobId;
                    // this.getBatchStatus(); // Start polling job status
                })
                .catch((error) => {
                    console.error('Error executing batch:', error);
                    this.isRunning = false;
                });
        } else {
            this.isRunning = false;
            this.showErrorToast();
        }
    }

    getBatchStatus() {
        getJobDetails({jobId: this.batchJobId})
            .then((res) => {
                const job = res[0];
                if (job) {
                    this.totalBatch = job.TotalJobItems;
                    this.executedBatch = job.JobItemsProcessed;
                    this.numberOfErrors = job.NumberOfErrors;
                    this.progress = ((this.executedBatch / this.totalBatch) * 100).toFixed(2);

                    this.isBatchCompleted = job.Status === 'Completed';

                    if (!this.isBatchCompleted) {
                        setTimeout(() => this.getBatchStatus(), 3000); // Poll every 3 seconds
                    } else {
                        this.isRunning = false;
                    }
                }
            })
            .catch((error) => {
                console.error('Error fetching batch status:', error);
                this.isRunning = false;
            });
    }

    get sliderLabel() {
        return `Enter Batch Size (${this.minBatchSize}-${this.maxBatchSize})`;
    }

    get disableExecuteButton() {
        return !this.selectedBatchClass || this.isRunning;
    }

    get progressLabel() {
        return this.isRunning ? 'Batch Job In Progress' : 'Start Batch Job';
    }

    get batchPercentageExecuted() {
        return `${this.progress}%`;
    }

    get batchExecutionStatus() {
        return `Batch Executed ${this.executedBatch} of ${this.totalBatch}`;
    }
}
