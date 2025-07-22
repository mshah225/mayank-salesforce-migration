/* eslint-disable no-undef */
import {createElement} from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import Toast from 'lightning/toast';
import getUserSearchCustomMetadata from '@salesforce/apex/UserMatcherController.getUserSearchCustomMetadata';
import getUserSearchRoleCustomMetadata from '@salesforce/apex/UserMatcherController.getUserSearchRoleCustomMetadata';
import startAudit from '@salesforce/apex/UserMatcherController.startAudit';
import checkStatus from '@salesforce/apex/UserMatcherController.checkStatus';
import getDownloadLink from '@salesforce/apex/UserMatcherController.getDownloadLink';
import getFileContents from '@salesforce/apex/UserMatcherController.getFileContents';
import {UserCSVMatcherTest} from 'c/userCSVMatcher';
import {flushPromises} from 'c/helperTestFunctions';

const csvStrings = require('./data/csvStrings.json');
const pageRef = require('./data/pageRef.json');
const fieldsList = require('./data/fieldsList.json');
const fieldsListEmpty = require('./data/fieldsListEmpty.json');
const rolesList = require('./data/rolesList.json');
const rolesListEmpty = require('./data/rolesListEmpty.json');

// Mock all Apex functions (these allow us to mock the data)
jest.mock(
    '@salesforce/apex/UserMatcherController.getUserSearchCustomMetadata',
    () => {
        const {createApexTestWireAdapter} = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    {virtual: true}
);
jest.mock(
    '@salesforce/apex/UserMatcherController.getUserSearchRoleCustomMetadata',
    () => {
        const {createApexTestWireAdapter} = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn()),
        };
    },
    {virtual: true}
);
jest.mock(
    '@salesforce/apex/UserMatcherController.startAudit',
    () => {
        return {
            default: jest.fn(),
        };
    },
    {virtual: true}
);
jest.mock(
    '@salesforce/apex/UserMatcherController.checkStatus',
    () => {
        return {
            default: jest.fn(),
        };
    },
    {virtual: true}
);
jest.mock(
    '@salesforce/apex/UserMatcherController.getDownloadLink',
    () => {
        return {
            default: jest.fn(),
        };
    },
    {virtual: true}
);
jest.mock(
    '@salesforce/apex/UserMatcherController.getFileContents',
    () => {
        return {
            default: jest.fn(),
        };
    },
    {virtual: true}
);

describe('c-tagging-component', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Clear mocks
        jest.clearAllMocks();
    });

    test('Loads roles', async () => {
        const element = createElement('c-user-c-s-v-matcher', {
            is: UserCSVMatcherTest,
        });
        document.body.appendChild(element);
        getUserSearchRoleCustomMetadata.emit(rolesList);

        // Wait for wire to complete
        await flushPromises();

        // Loaded results
        expect(element.userSearchRolesList).toHaveLength(2);
        expect(element.userSearchRolesList).toMatchObject(rolesList);
    });

    test('Loads columns from fields', async () => {
        const element = createElement('c-user-c-s-v-matcher', {
            is: UserCSVMatcherTest,
        });
        document.body.appendChild(element);
        getUserSearchCustomMetadata.emit(fieldsList);

        // Wait for wire to complete
        await flushPromises();

        // Loaded results
        expect(element.csvTable).toEqual(fieldsList.map((v) => `"${v.label}"`).join(',') + '\n');
    });

    test('Loading icon until metadata is done loading', async () => {
        const element = createElement('c-user-c-s-v-matcher', {
            is: UserCSVMatcherTest,
        });
        document.body.appendChild(element);

        // Starts as loading
        expect(element.metaLoading).toEqual(true);

        getUserSearchRoleCustomMetadata.emit(rolesList);
        getUserSearchCustomMetadata.emit(fieldsList);

        // Wait for wires to complete
        await flushPromises();

        // Done loading
        expect(element.metaLoading).toEqual(false);
    });

    test('Start audit successfully', async () => {
        const element = createElement('c-user-c-s-v-matcher', {
            is: UserCSVMatcherTest,
        });
        document.body.appendChild(element);
        getUserSearchRoleCustomMetadata.emit(rolesList);
        getUserSearchCustomMetadata.emit(fieldsList);
        await flushPromises();
        // Simulate uploading file
        element.shadowRoot.querySelector('lightning-input').dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    files: [
                        {
                            name: 'asuriteList.csv',
                            text: () => {
                                return new Promise((resolve, reject) => {
                                    resolve(csvStrings.asuriteList);
                                });
                            },
                        },
                    ],
                },
            })
        );
        // Simulate selecting role
        element.shadowRoot.querySelector('lightning-combobox').dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    value: rolesList[0].value,
                },
            })
        );
        await flushPromises(); // await events finishing

        // Mock implementation for creating job
        startAudit.mockImplementation(() => Promise.resolve('001'));

        // Simulate button press
        element.shadowRoot.querySelector('lightning-button').dispatchEvent(new Event('click'), {bubbles: true});

        // Wait for event to be processed
        await flushPromises();

        // File extracted and ready to upload
        expect(startAudit).toHaveBeenCalledWith({
            identifiers: csvStrings.asuriteList.split(/[\r\n]+/).filter((v) => !!v),
            auditRole: rolesList[0].value,
        });
    });

    test('Check audit status while queued', async () => {
        const element = createElement('c-user-c-s-v-matcher', {
            is: UserCSVMatcherTest,
        });
        document.body.appendChild(element);
        CurrentPageReference.emit(pageRef);
        getUserSearchRoleCustomMetadata.emit(rolesList);
        getUserSearchCustomMetadata.emit(fieldsList);
        await flushPromises();
        element.shadowRoot.querySelector('lightning-input').dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    files: [
                        {
                            name: 'asuriteList.csv',
                            text: () => {
                                return new Promise((resolve, reject) => {
                                    resolve(csvStrings.asuriteList);
                                });
                            },
                        },
                    ],
                },
            })
        );
        element.shadowRoot.querySelector('lightning-combobox').dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    value: rolesList[0].value,
                },
            })
        );
        await flushPromises();
        startAudit.mockImplementation(() => Promise.resolve('001'));
        checkStatus.mockImplementation(() => Promise.resolve('Queued'));
        element.shadowRoot.querySelector('lightning-button').dispatchEvent(new Event('click'), {bubbles: true});
        await flushPromises();

        // File extracted and ready to upload
        expect(checkStatus).toHaveBeenCalledWith({
            auditLogId: '001',
        });
        expect(getDownloadLink).not.toHaveBeenCalled();
        expect(getFileContents).not.toHaveBeenCalled();
    });

    test('Get download URL and file once complete', async () => {
        const element = createElement('c-user-c-s-v-matcher', {
            is: UserCSVMatcherTest,
        });
        document.body.appendChild(element);
        CurrentPageReference.emit(pageRef);
        getUserSearchRoleCustomMetadata.emit(rolesList);
        getUserSearchCustomMetadata.emit(fieldsList);
        await flushPromises();
        element.shadowRoot.querySelector('lightning-input').dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    files: [
                        {
                            name: 'asuriteList.csv',
                            text: () => {
                                return new Promise((resolve, reject) => {
                                    resolve(csvStrings.asuriteList);
                                });
                            },
                        },
                    ],
                },
            })
        );
        element.shadowRoot.querySelector('lightning-combobox').dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    value: rolesList[0].value,
                },
            })
        );
        await flushPromises();
        startAudit.mockImplementation(() => Promise.resolve('001'));
        checkStatus.mockImplementation(() =>
            Promise.resolve({
                done: true,
                percent: 1,
            })
        );
        getDownloadLink.mockImplementation(() => Promise.resolve('DOWNLOAD_URL'));
        getFileContents.mockImplementation(() => Promise.resolve(csvStrings.expectedCSV));
        element.shadowRoot.querySelector('lightning-button').dispatchEvent(new Event('click'), {bubbles: true});
        await flushPromises();

        // File extracted and ready to upload
        expect(getDownloadLink).toHaveBeenCalledWith({auditLogId: '001'});
        expect(element.downloadLink).toEqual('DOWNLOAD_URL');
        expect(getFileContents).toHaveBeenCalledWith({auditLogId: '001'});
        expect(element.csvTable).toEqual(csvStrings.expectedCSV);
    });

    test('Error - no roles', async () => {
        const element = createElement('c-user-c-s-v-matcher', {
            is: UserCSVMatcherTest,
        });
        document.body.appendChild(element);
        getUserSearchRoleCustomMetadata.emit(rolesListEmpty);

        // Wait for wire to complete
        await flushPromises();

        // Loaded results
        expect(element.hasError).toEqual(true);
        expect(element.errorMessage).toContain('No roles configured for auditing');
    });

    test('Error - no audit fields', async () => {
        const element = createElement('c-user-c-s-v-matcher', {
            is: UserCSVMatcherTest,
        });
        document.body.appendChild(element);
        getUserSearchCustomMetadata.emit(fieldsListEmpty);

        // Wait for wire to complete
        await flushPromises();

        // Loaded results
        expect(element.hasError).toEqual(true);
        expect(element.errorMessage).toContain('No columns configured for auditing');
    });

    test('Error - start audit without uploading file', async () => {
        const element = createElement('c-user-c-s-v-matcher', {
            is: UserCSVMatcherTest,
        });
        document.body.appendChild(element);
        getUserSearchRoleCustomMetadata.emit(rolesList);
        getUserSearchCustomMetadata.emit(fieldsList);
        await flushPromises();
        element.shadowRoot.querySelector('lightning-combobox').dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    value: rolesList[0].value,
                },
            })
        );
        await flushPromises();

        // Simulate button press
        element.shadowRoot.querySelector('lightning-button').dispatchEvent(new Event('click'), {bubbles: true});

        // Wait for event to be processed
        await flushPromises();

        // Error toast
        expect(Toast.show).toHaveBeenCalledWith({
            label: 'Cannot start audit',
            message: 'Must select a non-empty file to upload first',
            variant: 'warning',
        });
    });

    test('Error - start audit without selecting role', async () => {
        const element = createElement('c-user-c-s-v-matcher', {
            is: UserCSVMatcherTest,
        });
        document.body.appendChild(element);
        getUserSearchRoleCustomMetadata.emit(rolesList);
        getUserSearchCustomMetadata.emit(fieldsList);
        await flushPromises();
        element.shadowRoot.querySelector('lightning-input').dispatchEvent(
            new CustomEvent('change', {
                detail: {
                    files: [
                        {
                            name: 'asuriteList.csv',
                            text: () => {
                                return new Promise((resolve, reject) => {
                                    resolve(csvStrings.asuriteList);
                                });
                            },
                        },
                    ],
                },
            })
        );
        await flushPromises();

        // Simulate button press
        element.shadowRoot.querySelector('lightning-button').dispatchEvent(new Event('click'), {bubbles: true});

        // Wait for event to be processed
        await flushPromises();

        // Error toast
        expect(Toast.show).toHaveBeenCalledWith({
            label: 'Cannot start audit',
            message: 'Must select an audit role first',
            variant: 'warning',
        });
    });
});
