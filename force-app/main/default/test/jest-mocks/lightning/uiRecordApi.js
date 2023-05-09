/* eslint-disable no-console */
import {createLdsTestWireAdapter} from '@salesforce/wire-service-jest-util';
export const getRecord = createLdsTestWireAdapter(jest.fn());
export const getRecords = createLdsTestWireAdapter(jest.fn());
export const getRecordCreateDefaults = createLdsTestWireAdapter(jest.fn());
export const updateRecord = jest.fn().mockResolvedValue({});
export const createRecord = jest.fn().mockResolvedValue({});
export const deleteRecord = jest.fn().mockResolvedValue();
export const generateRecordInputForCreate = jest.fn();
export const generateRecordInputForUpdate = jest.fn();
export const createRecordInputFilteredByEditedFields = jest.fn();
export const refresh = jest.fn().mockResolvedValue();
export const notifyRecordUpdateAvailable = jest.fn().mockResolvedValue();

export const getFieldValue = jest.fn((data, fieldReference) => {
    if (data) {
        const objectName = data.apiName;
        const passedObjectName = fieldReference.split('.')[0];
        if (objectName !== passedObjectName) {
            throw new Error('Invalid object name: Passed ${passedObjectName}, and data is of ${objectName}.');
        }

        const fieldName = fieldReference.split('.')[1];
        const fields = data.fields;
        const fieldValue = fields[fieldName].value;
        if (fieldValue) return fieldValue;
        return null;

        /* -- default code by salesforce
        console.log('data: ', data);
        console.log('field: ', fieldReference);
        // const fields = fieldReference.fieldApiName.split('.');
        if (data.result) {
            const fieldData = fields.reduce((o, i) => o[i], data.result.fields);
            if (fieldData && fieldData.value) {
                return fieldData.value;
            }
        } else {
            const fieldData = fields.reduce((o, i) => o[i], data.fields);
            if (fieldData && fieldData.value) {
                return fieldData.value;
            }
        }
        return null;
        */
    }
});
export const getFieldDisplayValue = jest.fn();
