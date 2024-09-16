import {createLdsTestWireAdapter} from '@salesforce/wire-service-jest-util';
import GqlParserMock from 'c/gqlParserMock';

export const graphql = createLdsTestWireAdapter(jest.fn());

export const gql = jest.fn((query) => {
    try {
        return new GqlParserMock(query.join('')).object;
    } catch (ex) {
        return {error: ex.message};
    }
});
