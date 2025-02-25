import {createTestWireAdapter} from '@salesforce/wire-service-jest-util';

export const EnclosingTabId = createTestWireAdapter(jest.fn());

export const setTabLabel = jest.fn();
export const setTabIcon = jest.fn();
