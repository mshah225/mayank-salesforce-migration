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
        const [passedObjectName, fieldName] = fieldReference.split('.');
        const {apiName, fields} = data;

        if (apiName !== passedObjectName) {
            throw new Error(`Invalid object name: Passed ${passedObjectName}, and data is of ${apiName}.`);
        }

        const fieldValue = fields[fieldName]?.value || null;
        return fieldValue;

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
