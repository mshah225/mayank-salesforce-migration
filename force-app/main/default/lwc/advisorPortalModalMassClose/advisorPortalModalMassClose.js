import {LightningElement, api, wire} from 'lwc';
import populateRecommendedActionOptions from '@salesforce/apex/AdvisorPortalMassUpdateController.populateRecommendedActionOptions';
import populateReturnTermOptions from '@salesforce/apex/AdvisorPortalMassUpdateController.populateReturnTermOptions';
import populateStudentRiskOptions from '@salesforce/apex/AdvisorPortalMassUpdateController.populateStudentRiskOptions';
import populateReasonNotReturningOptions from '@salesforce/apex/AdvisorPortalMassUpdateController.populateReasonNotReturningOptions';
import getCustomMetadata from '@salesforce/apex/AdvisorPortalMassUpdateController.getCustomMetadata';

export default class AdvisorPortalModalMassClose extends LightningElement {
    @api selectedContactWrappers = [];

    recommendedActionOptions;
    @wire(populateRecommendedActionOptions, {})
    populatedRecommendedActionOptions(result) {
        let {data, error} = result;
        if (data != null) {
            this.recommendedActionOptions = this.buildPicklistOptionsArray(data);
            this.intialSetupQuestionOptionsWhenReady();
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error(error);
        }
    }

    returnTermOptions;
    @wire(populateReturnTermOptions, {})
    populatedReturnTermOptions(result) {
        let {data, error} = result;
        if (data != null) {
            this.returnTermOptions = this.buildPicklistOptionsArray(data);
            this.intialSetupQuestionOptionsWhenReady();
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error(error);
        }
    }

    studentRiskOptions;
    @wire(populateStudentRiskOptions, {})
    populatedStudentRiskOptions(result) {
        let {data, error} = result;
        if (data != null) {
            this.studentRiskOptions = this.buildPicklistOptionsArray(data);
            this.intialSetupQuestionOptionsWhenReady();
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error(error);
        }
    }

    reasonNotReturningOptions;
    @wire(populateReasonNotReturningOptions, {})
    populatedReasonNotReturningOptions(result) {
        let {data, error} = result;
        if (data != null) {
            this.reasonNotReturningOptions = this.buildPicklistOptionsArray(data);
            this.intialSetupQuestionOptionsWhenReady();
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error(error);
        }
    }

    caseStatusOptions;
    studentIntentOptions;
    generatedRequirements;
    @wire(getCustomMetadata, {})
    gotCustomMetadata(result) {
        let {data, error} = result;
        if (data != null) {
            const optionsStatus = [];
            const optionsIntent = [];
            const generatedRequirements = {};

            const picklistKeys = Object.keys(data);

            for (let i = 0; i < picklistKeys.length; i++) {
                // which picklist are we looking at?
                const picklistKey = picklistKeys[i];
                // and the mapping for that picklist's conditional requirements?
                const optionToRequirementKeys = Object.keys(data[picklistKey]);

                if (picklistKey === 'caseStatus') {
                    for (let j = 0; j < optionToRequirementKeys.length; j++) {
                        const optionKey = optionToRequirementKeys[j];
                        optionsStatus.push({label: optionKey, value: optionKey});
                    }
                } else if (picklistKey === 'studentIntent') {
                    for (let j = 0; j < optionToRequirementKeys.length; j++) {
                        const optionKey = optionToRequirementKeys[j];
                        optionsIntent.push({label: optionKey, value: optionKey});
                    }
                }

                generatedRequirements[picklistKey] = {};
                for (let j = 0; j < optionToRequirementKeys.length; j++) {
                    const optionToRequirementKey = optionToRequirementKeys[j];
                    generatedRequirements[picklistKey][optionToRequirementKey] =
                        data[picklistKey][optionToRequirementKey];
                }
            }

            this.caseStatusOptions = optionsStatus;
            this.studentIntentOptions = optionsIntent;
            this.generatedRequirements = generatedRequirements;

            this.intialSetupQuestionOptionsWhenReady();
        } else if (error != null) {
            // eslint-disable-next-line no-console
            console.error(error);
        }
    }

    questions = [];

    buttons = [];

    updateDynamicRequirements(e) {
        /* Update value */
        const key = e.detail.key;
        const ans = e.detail.answer;
        const changedQuestion = this.getQuestion(key);
        changedQuestion.answer = ans;
        this.questionBaseMap[key].answer = ans;

        /* Determine if required/not rules have changed */
        let picklistKeyToRequiredStatus = {};

        const requirements = this.generatedRequirements;
        const picklistKeys = Object.keys(requirements);

        for (let i = 0; i < picklistKeys.length; i++) {
            const picklistKey = picklistKeys[i]; // name of picklist
            picklistKeyToRequiredStatus[picklistKey] = false;
        }
        picklistKeyToRequiredStatus.caseStatus = true; // always require case status

        // For each dropdown, in the requirements, check if value changes required fields
        for (let i = 0; i < picklistKeys.length; i++) {
            const picklistKey = picklistKeys[i]; // name of picklist
            const picklistValueToReqMap = requirements[picklistKey]; // map each value to it's required fields

            const picklistOptions = Object.keys(picklistValueToReqMap); // each option in the picklist
            const relatedQuestionObj = this.getQuestion(picklistKey); // the current picklist object

            for (let j = 0; j < picklistOptions.length; j++) {
                const option = picklistOptions[j]; // the possible value of the picklist
                const listOfRequiredFields = picklistValueToReqMap[option]; // the list of required fields

                // checking value depends on question type
                if (relatedQuestionObj.type === 'dual-listbox') {
                    if (relatedQuestionObj.answer != null && relatedQuestionObj.answer.includes(option)) {
                        for (let k = 0; k < listOfRequiredFields.length; k++) {
                            const requiredField = listOfRequiredFields[k];
                            picklistKeyToRequiredStatus[requiredField] = true;
                        }
                    }
                } else {
                    if (option === relatedQuestionObj.answer) {
                        for (let k = 0; k < listOfRequiredFields.length; k++) {
                            const requiredField = listOfRequiredFields[k];
                            picklistKeyToRequiredStatus[requiredField] = true;
                        }
                    }
                }
            }
        }

        const questionKeys = Object.keys(this.questionBaseMap);

        // mark all required as required
        for (let i = 0; i < questionKeys.length; i++) {
            const questionKey = questionKeys[i];
            const relatedQuestionObj = this.questionBaseMap[questionKey];
            relatedQuestionObj.required = picklistKeyToRequiredStatus[questionKey];
        }

        this.updateRequiredStatuses();
    }

    @api openModal() {
        this.template.querySelector('c-lightning-question-answer-modal').openModal();
    }
    @api closeModal() {
        this.template.querySelector('c-lightning-question-answer-modal').closeModal();
    }

    // Send a loading event
    sendLoadingEvent(loadMore) {
        this.dispatchEvent(new CustomEvent('loading', {detail: loadMore}));
    }

    // Raise a toast event
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

    // Update required/not required status for all questions
    updateRequiredStatuses() {
        const intialQuestionSet = [];
        intialQuestionSet.push(this.questionBaseMap.caseStatus);
        if (this.questionBaseMap.reasonsAdminClosed.required) {
            intialQuestionSet.push(this.questionBaseMap.reasonsAdminClosed);
        }
        intialQuestionSet.push(this.questionBaseMap.recommendedActions);
        if (this.questionBaseMap.recommendedActionOther.required) {
            intialQuestionSet.push(this.questionBaseMap.recommendedActionOther);
        }
        intialQuestionSet.push({
            key: 'enrollDetailsLabel',
            question: 'Enrollment Details',
            type: 'label',
            subtype: 'bold',
        });
        intialQuestionSet.push(this.questionBaseMap.studentIntent);
        intialQuestionSet.push(this.questionBaseMap.notReturning);
        if (this.questionBaseMap.notReturningOther.required) {
            intialQuestionSet.push(this.questionBaseMap.notReturningOther);
        }
        if (this.questionBaseMap.returnTerm.required) {
            intialQuestionSet.push(this.questionBaseMap.returnTerm);
        }
        intialQuestionSet.push(this.questionBaseMap.studentRisk);
        if (this.questionBaseMap.studentRiskOther.required) {
            intialQuestionSet.push(this.questionBaseMap.studentRiskOther);
        }
        this.questions = intialQuestionSet;
    }

    // Update the questions with the answer options once all options have been loaded
    intialSetupQuestionOptionsWhenReady() {
        if (
            this.caseStatusOptions != null &&
            this.recommendedActionOptions != null &&
            this.studentIntentOptions != null &&
            this.returnTermOptions != null &&
            this.studentRiskOptions != null &&
            this.reasonNotReturningOptions != null
        ) {
            this.questionBaseMap.caseStatus.options = this.caseStatusOptions;
            this.questionBaseMap.recommendedActions.options = this.recommendedActionOptions;
            this.questionBaseMap.studentIntent.options = this.studentIntentOptions;
            this.questionBaseMap.notReturning.options = this.returnTermOptions;
            this.questionBaseMap.studentRisk.options = this.studentRiskOptions;
            this.questionBaseMap.notReturning.options = this.reasonNotReturningOptions;

            this.updateRequiredStatuses();
        }
    }

    questionBaseMap = {
        caseStatus: {
            key: 'caseStatus',
            question: 'Status',
            required: true,
            type: 'combobox',
            options: [],
        },
        reasonsAdminClosed: {
            key: 'reasonsAdminClosed',
            question: 'Status',
            required: false,
            type: 'text',
        },
        recommendedActions: {
            key: 'recommendedActions',
            question: 'Case Recommended Actions(s)',
            required: false,
            type: 'dual-listbox',
            sourceLabel: 'Action',
            selectedLabel: 'Selected',
            options: [],
        },
        recommendedActionOther: {
            key: 'recommendedActionOther',
            question: 'Case Recommended Action(s) Other',
            required: false,
            type: 'text',
        },
        studentIntent: {
            key: 'studentIntent',
            question: "Student's Intentions",
            required: false,
            type: 'combobox',
            options: [],
        },
        notReturning: {
            key: 'notReturning',
            question: 'Reason(s) Not Returning',
            required: false,
            type: 'dual-listbox',
            sourceLabel: 'Reason',
            selectedLabel: 'Selected',
            options: [],
        },
        notReturningOther: {
            key: 'notReturningOther',
            question: 'Reason(s) Not Returning Other',
            required: false,
            type: 'text',
        },
        returnTerm: {
            key: 'returnTerm',
            question: 'What Term Should the Student Return?',
            required: false,
            type: 'combobox',
            options: [],
        },
        studentRisk: {
            key: 'studentRisk',
            question: 'Student Presented Risk for',
            required: false,
            type: 'combobox',
            options: [],
        },
        studentRiskOther: {
            key: 'studentRiskOther',
            question: 'Student Presented Risk for Other',
            required: false,
            type: 'text',
        },
    };

    // Get element from question array by it's key
    getQuestion(key) {
        for (let i = 0; i < this.questions.length; i++) {
            const q = this.questions[i];
            if (q.key === key) {
                return q;
            }
        }
        return null;
    }

    // Convert returned picklist map into array of options for comboboxes
    buildPicklistOptionsArray(optionsMap) {
        let optionsList = [];

        Object.keys(optionsMap).forEach(function (key) {
            optionsList.push({label: key, value: optionsMap[key]});
        });

        return optionsList;
    }
}
