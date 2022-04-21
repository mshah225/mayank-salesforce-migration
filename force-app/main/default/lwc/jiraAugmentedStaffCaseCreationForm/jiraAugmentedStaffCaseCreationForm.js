import {LightningElement, wire} from 'lwc';
import checkIfCurrentUserHasPermissions from '@salesforce/apex/AugmentedStaffCaseController.doesUserHavePermission';
import verifyStudentId from '@salesforce/apex/AugmentedStaffCaseController.verifyStudentId';
import getCategoriesIdToName from '@salesforce/apex/AugmentedStaffCaseController.getCategoriesIdToName';
import getSubCategoriesIdToName from '@salesforce/apex/AugmentedStaffCaseController.getSubCategoriesIdToName';
import createTheCase from '@salesforce/apex/AugmentedStaffCaseController.createTheCase';

export default class JiraAugmentedStaffCaseCreationForm extends LightningElement {
    alert;
    get showAlert() {
        return this.alert != null && this.alert !== '';
    }
    alertHref;
    get showAlertLink() {
        return this.alertHref != null && this.alertHref !== '';
    }

    hasPermission;
    @wire(checkIfCurrentUserHasPermissions)
    checkedIfCurrentUserHasPermissions(result) {
        let {data, error} = result;
        if (data != null) {
            this.hasPermission = data;
        } else {
            // eslint-disable-next-line no-console
            console.error(err);
        }
    }

    @wire(getCategoriesIdToName)
    gotCategoriesIdToName(result) {
        let {data, err} = result;
        if (data) {
            const keys = Object.keys(data);
            const newOptions = [];
            // eslint-disable-next-line guard-for-in
            for (let i = 0; i < keys.length; i++) {
                const value = keys[i];
                const label = data[value];
                newOptions.push({label, value});
            }
            this.getQAFor('caseCategory').options = newOptions;
        } else {
            // eslint-disable-next-line no-console
            console.error(err);
        }
    }

    getSubCategories(category) {
        const subCategoriesQA = this.getQAFor('caseSubCategory');
        getSubCategoriesIdToName({category: category})
            .then((val) => {
                const keys = Object.keys(val);
                const newOptions = [];
                // eslint-disable-next-line guard-for-in
                for (let i = 0; i < keys.length; i++) {
                    const value = keys[i];
                    const label = val[value];
                    newOptions.push({label, value});
                }
                subCategoriesQA.options = newOptions;
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error(err);
                subCategoriesQA.options = [];
            })
            .finally(() => {
                // Either select none or select first
                if (subCategoriesQA.options.length === 0) {
                    subCategoriesQA.answer = '';
                } else {
                    subCategoriesQA.answer = subCategoriesQA.options[0].value;
                }
                // Copy to trigger render
                this.questions = [...this.questions];
            });
    }

    showFoundStatus = false;
    foundStudent = false;
    verifyId(studentId) {
        verifyStudentId({studentId: studentId})
            .then((val) => {
                this.showFoundStatus = true;
                this.foundStudent = val;
            })
            .catch((err) => {
                // eslint-disable-next-line no-console
                console.error(err);
                this.foundStudent = false;
            })
            .finally(() => {});
    }

    changeAnswers(e) {
        const eventKey = e.detail.key;
        const eventAnswer = e.detail.answer;
        for (let i = 0; i < this.questions.length; i++) {
            const q = this.questions[i];
            if (eventKey === q.key) {
                q.answer = eventAnswer;
                if (eventKey === 'emplid') {
                    this.verifyId(eventAnswer);
                } else if (eventKey === 'caseCategory') {
                    this.getSubCategories(eventAnswer);
                }
            }
        }
    }

    questions = [
        {
            key: 'emplid',
            question: "Caller's EMPLID/ASURITE",
            answer: '',
            type: 'text',
            required: true,
        },
        {
            key: 'phoneNumber',
            question: 'Best Phone Number',
            answer: '',
            type: 'text',
        },
        {
            key: 'caseCategory',
            question: 'Case Category',
            answer: '',
            type: 'combobox',
            options: [],
            required: true,
        },
        {
            key: 'caseSubCategory',
            question: 'Case Sub-Category',
            answer: '',
            type: 'combobox',
            options: [],
            required: true,
        },
        {
            key: 'caseDescr',
            question: 'Case Description',
            answer: '',
            type: 'textarea',
            subnote: 'FIELD LIMIT: This field must be less than 3000 characters.',
            required: true,
        },
    ];
    getQAFor(key) {
        for (let i = 0; i < this.questions.length; i++) {
            if (this.questions[i].key === key) {
                return this.questions[i];
            }
        }
        return null;
    }

    closeCase = false;
    changeCloseCase(e) {
        this.closeCase = e.originalTarget.checked;
    }

    isValid() {
        let valid = true;
        const qaSection = this.template.querySelector('c-lightning-question-answer-section');
        valid &= qaSection.reportValidity();
        valid &= this.foundStudent;

        if (!valid) {
            this.alert = 'Please ensure that the ASURITE/EMPLID is Valid, and that the required fields are complete.';
        }

        return valid;
    }

    disabledButton = false;
    submitCase() {
        if (this.isValid()) {
            const description = this.getQAFor('caseDescr').answer;
            const category = this.getQAFor('caseCategory').answer;
            const subCategory = this.getQAFor('caseSubCategory').answer;
            const phoneNumber = this.getQAFor('phoneNumber').answer;
            const studentID = this.getQAFor('emplid').answer;
            const closed = this.closeCase;

            this.disabledButton = true;
            createTheCase({description, category, subCategory, phoneNumber, studentID, closed})
                .then((val) => {
                    if (val === true) {
                        this.alert = 'Case was created successfully!';
                    } else {
                        this.alert = 'There was a problem trying to create the case!';
                    }
                })
                .catch((err) => {
                    // eslint-disable-next-line no-console
                    console.error(err);
                    this.alert = 'There was a problem trying to create the case!';
                })
                .finally(() => {
                    this.disabledButton = false;
                });
        }
    }
}
