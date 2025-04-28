/* eslint-disable no-undef */
import GraphqlManager from 'c/graphqlManager';

const inputBasic = require('./data/input/graphqlBasic.json');
const outputBasic = require('./data/output/unwrappedBasic.json');

const inputParentLookups = require('./data/input/graphqlParentLookups.json');
const outputParentLookups = require('./data/output/unwrappedParentLookups.json');

const inputChildRecords = require('./data/input/graphqlChildRecords.json');
const outputChildRecords = require('./data/output/unwrappedChildRecords.json');

const inputEmpty = require('./data/input/graphqlEmpty.json');
const outputEmpty = require('./data/output/unwrappedEmpty.json');

describe('c-graphql-manager', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    test('Test unwrap basic object', () => {
        let manager = new GraphqlManager(inputBasic);
        expect(manager.unwrap()).toMatchObject(outputBasic);
    });

    test('Test unwrap object with lookups', () => {
        let manager = new GraphqlManager(inputParentLookups);
        expect(manager.unwrap()).toMatchObject(outputParentLookups);
    });

    test('Test unwrap object with child records', () => {
        let manager = new GraphqlManager(inputChildRecords);
        expect(manager.unwrap()).toMatchObject(outputChildRecords);
    });

    test('Test empty graphql response', () => {
        let manager = new GraphqlManager(inputEmpty);
        expect(manager.unwrap()).toMatchObject(outputEmpty);
    });
});
