/* eslint-disable no-undef */
import {
    throwBackARenderCycle,
    buildPicklistOptionsArray,
    cloneObj,
    falseWireRun,
    parseBoolean,
    niceLog,
    getFixedYOffset,
} from 'c/helperFunctions';

describe('Test Helper Functions', () => {
    test('Throw Back A Render Cycle', async () => {
        jest.useFakeTimers();
        let x = 0;

        // We will change x in 1ms by using setTimeout.  This causes the change to happen in a different render cycle.
        throwBackARenderCycle(() => {
            x = 1;
        });

        // Should not have changed yet
        expect(x).toBe(0);

        // Wait for 2 ms
        jest.advanceTimersByTime(2);

        // Second render pass should have completed now
        expect(x).toBe(1);
    });

    test('Build Picklist Options Array', () => {
        const mapOfCampusNameToCode = {
            'Downtown Phoenix': 'DTPHX',
            'Online': 'ONLNE',
            'Polytechnic': 'POLY',
            'Tempe': 'TEMPE',
            'West': 'WEST',
        };

        const optionsList = buildPicklistOptionsArray(mapOfCampusNameToCode);

        // Each field should cause a label-value pair
        expect(optionsList.length).toBe(5);
        // Same order, label is attribute name, value is attribute value
        expect(optionsList[0].label).toBe('Downtown Phoenix');
        expect(optionsList[0].value).toBe('DTPHX');
        expect(optionsList[1].label).toBe('Online');
        expect(optionsList[1].value).toBe('ONLNE');
        expect(optionsList[2].label).toBe('Polytechnic');
        expect(optionsList[2].value).toBe('POLY');
        expect(optionsList[3].label).toBe('Tempe');
        expect(optionsList[3].value).toBe('TEMPE');
        expect(optionsList[4].label).toBe('West');
        expect(optionsList[4].value).toBe('WEST');
    });

    test('Object Cloning', () => {
        const originalObj = {
            Name: {
                First: 'Prof',
                Last: 'Strand',
            },
            Email: 'prof.strand@strandinstitute.org',
            IsA: ['Man', 'Skeptic', 'Doctor'],
        };

        const copyObj = cloneObj(originalObj);

        // Should be a different reference
        expect(originalObj).not.toBe(copyObj);
        // But all fields should be the same
        expect(originalObj.Name.First).toBe(copyObj.Name.First);
        expect(originalObj.Name.Last).toBe(copyObj.Name.Last);
        expect(originalObj.Email).toBe(copyObj.Email);
        expect(originalObj.IsA[0]).toBe(copyObj.IsA[0]);
        expect(originalObj.IsA[1]).toBe(copyObj.IsA[1]);
        expect(originalObj.IsA[2]).toBe(copyObj.IsA[2]);
    });

    test('Detect False Wire Run', () => {
        let wireResult = {
            data: null,
            error: null,
        };

        // When data and error are null - then false wire run
        expect(falseWireRun(wireResult)).toBe(true);

        // If data is set, then not false wire run
        wireResult.data = {};
        wireResult.error = null;
        expect(falseWireRun(wireResult)).toBe(false);

        // If error is set, then not false wire run
        wireResult.data = null;
        wireResult.error = {};
        expect(falseWireRun(wireResult)).toBe(false);
    });

    test('Parse Boolean', () => {
        // Parse booleans as booleans
        expect(parseBoolean(true)).toBe(true);
        expect(parseBoolean(false)).toBe(false);
        // Parse strings like booleans
        expect(parseBoolean('true')).toBe(true);
        expect(parseBoolean('false')).toBe(false);
        expect(parseBoolean('TRUE')).toBe(true);
        expect(parseBoolean('FALSE')).toBe(false);
    });

    test('Nice Console Logs', () => {
        const consoleLogMockFn = jest.fn();
        const consoleInfoMockFn = jest.fn();
        const consoleWarnMockFn = jest.fn();
        const consoleErrorMockFn = jest.fn();
        let prevTitle = null;
        let prevBody = null;

        global.console = {
            ...console,
            log: (title, body) => {
                prevTitle = title;
                prevBody = body;
                consoleLogMockFn();
            },
            info: (title, body) => {
                prevTitle = title;
                prevBody = body;
                consoleInfoMockFn();
            },
            warn: (title, body) => {
                prevTitle = title;
                prevBody = body;
                consoleWarnMockFn();
            },
            error: (title, body) => {
                prevTitle = title;
                prevBody = body;
                consoleErrorMockFn();
            },
        };

        // Log info using console.info function
        niceLog('Info Title', 'Info Body', 'info');
        expect(consoleInfoMockFn).toBeCalledTimes(1);
        expect(prevTitle).toBe('Info Title');
        expect(prevBody).toBe('Info Body');

        // Log success using console.log function
        niceLog('Success Title', 'Success Body', 'success');
        expect(consoleLogMockFn).toBeCalledTimes(1);
        expect(prevTitle).toBe('Success Title');
        expect(prevBody).toBe('Success Body');

        // Log warning using console.warn function
        niceLog('Warning Title', 'Warning Body', 'warning');
        expect(consoleWarnMockFn).toBeCalledTimes(1);
        expect(prevTitle).toBe('Warning Title');
        expect(prevBody).toBe('Warning Body');

        // Log error using console.error function
        niceLog('Error Title', 'Error Body', 'error');
        expect(consoleErrorMockFn).toBeCalledTimes(1);
        expect(prevTitle).toBe('Error Title');
        expect(prevBody).toBe('Error Body');

        // Log loading using console.error function
        niceLog('Loading Title', 'Loading Body', 'loading');
        expect(consoleLogMockFn).toBeCalledTimes(2);
        expect(prevTitle).toBe('↺ Loading Title');
        expect(prevBody).toBe('Loading Body');
    });

    test('Get Fixed Y Offsets', () => {
        // Need a document element to attach child to
        const div = document.createElement('div');

        // Mock append/remove child function
        div.appendChild = jest.fn();
        div.removeChild = jest.fn();

        // Usually this is zero
        expect(getFixedYOffset(div)).toBe(0);
        // And the child list should be untouched afterward
        expect(div.childNodes.length).toBe(0);

        // Each function should have been called once
        expect(div.appendChild).toBeCalledTimes(1);
        expect(div.removeChild).toBeCalledTimes(1);

        // Should still be zero
        expect(getFixedYOffset(div)).toBe(0);
        // Doesn't get called again, since it has already been calculated once
        expect(div.appendChild).toBeCalledTimes(1);
        expect(div.removeChild).toBeCalledTimes(1);
    });
});

// Helper function to wait until the microtask queue is empty. This is needed for promise
// timing when calling imperative Apex.
async function flushPromises() {
    return Promise.resolve();
}
