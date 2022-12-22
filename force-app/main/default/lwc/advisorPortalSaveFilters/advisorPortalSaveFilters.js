/* eslint-disable no-alert */
/* eslint-disable no-console */
import {LightningElement, api} from 'lwc';
import setDefaultFilter from '@salesforce/apex/AdvisorPortalFilterSavingService.setDefaultFilter';
import clearDefaultFilter from '@salesforce/apex/AdvisorPortalFilterSavingService.clearDefaultFilter';
import LightningQuestionAnswerModal from 'c/lightningQuestionAnswerModal';

export default class AdvisorPortalSaveFilters extends LightningElement {
    @api currentFilter;
    saveButtons = [];
    resetButtons = [];

    saveQuestions = [
        {
            key: 'A',
            question: 'Save your current selection as your default filters?',
            type: 'label',
            subtype: 'center',
        },
    ];
    resetQuestions = [
        {
            key: 'B',
            question: 'Reset my default filters?',
            type: 'label',
            subtype: 'center',
        },
    ];

    openSaveModal() {
        LightningQuestionAnswerModal.open({
            size: 'small',
            description: 'Do you want to save your filters?',
            title: 'Save Filters?',
            questions: this.saveQuestions,
            buttonDescription: {
                okButtonLabel: 'Save my Default Filters',
                cancelButtonLabel: 'Cancel',
                awaitBeforeClosing: (resp) => {
                    if (resp.state === 'success') {
                        this.makeToast('loading', '', '');

                        return setDefaultFilter({json: JSON.stringify(this.currentFilter)})
                            .then(() => {
                                this.makeToast('success', 'Success', 'Filters saved as default.');
                            })
                            .catch((err) => {
                                console.error(err);
                                this.makeToast('error', 'Error', err.body.message);
                            });
                    } else {
                        return Promise.resolve();
                    }
                },
            },
        });
    }

    openResetModal() {
        LightningQuestionAnswerModal.open({
            size: 'small',
            description: 'Do you want to clear your saved filters??',
            title: 'Delete Saved Filters?',
            questions: this.resetQuestions,
            buttonDescription: {
                okButtonLabel: 'Reset my Default Filters',
                cancelButtonLabel: 'Cancel',
                awaitBeforeClosing: (resp) => {
                    if (resp.state === 'success') {
                        this.makeToast('loading', '', '');

                        return clearDefaultFilter()
                            .then(() => {
                                this.dispatchEvent(
                                    new CustomEvent('clearappliedfilters', {
                                        detail: {},
                                    })
                                );
                                this.makeToast('success', 'Success', 'Default filter cleared.');
                            })
                            .catch((err) => {
                                console.error(err);
                                this.makeToast('error', 'Error', err.body.message);
                            });
                    } else {
                        return Promise.resolve();
                    }
                },
            },
        });
    }

    makeToast(type, title, body) {
        this.dispatchEvent(
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

    sendLoadingEvent(loadMore) {
        this.dispatchEvent(new CustomEvent('loading', {detail: loadMore}));
    }
}
