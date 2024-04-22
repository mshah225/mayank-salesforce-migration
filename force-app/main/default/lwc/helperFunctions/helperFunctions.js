/**
 * Can throw a section of code outside the current rendering cycle - useful if we want to allow our parent LWC to complete a rendering cycle before
 * running this code (we primarily use this to ensure the parent either begins/stops the loading circle during otherwise blocking operations)
 * @param {Function} fn
 */
export function throwBackARenderCycle(fn) {
    setTimeout(fn, 1);
}

/**
 * Convert returned picklist map into array of options for comboboxes
 * @param {Map} optionsMap
 * @returns label-value array
 */
export function buildPicklistOptionsArray(optionsMap) {
    let optionsList = [];

    Object.keys(optionsMap).forEach(function (key) {
        optionsList.push({label: key, value: optionsMap[key]});
    });

    return optionsList;
}

/**
 * Perform a deep copy of the specified object
 * @param {Object} obj
 * @returns a deep copy of obj
 * @warning obj cannot be more than one proxy-object deep.  Never let it be a Proxy object of a Proxy object.
 *          More than one layer of Proxies makes JSON.stringify unusably slow
 */
export function cloneObj(obj) {
    return JSON.parse(JSON.stringify(obj));
}

/**
 * Check if this is a real wire run, or a false one.
 * False wire runs occur on page load and have {data:null, error:null}.
 * When this happens - usually we want to do nothing.
 * This function checks if this is a false run
 *
 * @param {*} obj Wire result - is destructured in {data, error}
 * @returns true when this IS a false run
 */
export function falseWireRun(obj) {
    let {data, error} = obj;

    return data == null && error == null;
}

/**
 * Gets the boolean equilvalent of a passed object
 * Useful for any boolean @api params, since we want to allow
 * specifying them in the parent as a string
 *
 * @param {*} obj Parse this JS item as a boolean
 * @returns TRUE when either the obj is a string with value "true" or "TRUE" or when the obj is a boolean with value true
 */
export function parseBoolean(obj) {
    if (typeof obj === 'boolean') return obj;
    else if (typeof obj === 'string') return obj === 'true' || obj === 'TRUE';
    else return false;
}

/**
 * Logging functionality that applies the correct console.log type
 * Can be used along with a toast that way, printing the console as well as exposing it to the user with a toast
 *
 * @param {String} title The title of the message
 * @param {String} message The body of the message
 * @param {"info"|"success"|"warning"|"error"|"loading"} type The type of message this is
 */
export function niceLog(title, message, type) {
    // eslint-disable-next-line no-console
    let loggingFunc = console.log;

    if (type === 'error') {
        // eslint-disable-next-line no-console
        loggingFunc = console.error;
    } else if (type === 'warning') {
        // eslint-disable-next-line no-console
        loggingFunc = console.warn;
    } else if (type === 'info') {
        // eslint-disable-next-line no-console
        loggingFunc = console.info;
    } else if (type === 'loading') {
        title = '↺ ' + title;
    }

    loggingFunc(title, message);
}

let fixedYOffset = null; // state variable for finding y offset
/**
 * Salesforce sometimes does weird stuff which can cause position:fixed;top:0px to not align with the top of the viewport
 * One case where this can happen is with modals launched by a record action.c/advisorPortalA
 *
 * This function returns the offset so that, when using position:fixed, you know how many pixels to subtract from the desired location
 *
 * @param {Node} attachRoot Node where we ca .appendChild and .removeChild for the created element
 * @returns An integer indicating how many pixels from the top of the viewport position:fixed;top:0px is
 */
export function getFixedYOffset(attachRoot) {
    if (fixedYOffset === null) {
        const elem = document.createElement('div');
        elem.style.position = 'fixed';
        elem.style.top = '0px';
        attachRoot.appendChild(elem);
        fixedYOffset = elem.getBoundingClientRect().top;
        attachRoot.removeChild(elem);
    }
    return fixedYOffset;
}

/**
 * Extract a list of human readable error messages from an error object or list or error objects
 * @param {Object|List<Object>} errors
 * @returns String[]
 */
export function extractErrorMessages(errors) {
    if (!Array.isArray(errors)) {
        errors = [errors];
    }

    return (
        errors
            // Remove null/undefined items
            .filter((error) => !!error)
            // Extract an error message
            .map((error) => {
                // Wrrors that aren't wrapped in an Error object (maybe from JS throw command)
                if (typeof error === 'string') {
                    return error;
                }
                // The vast majority of error messages are proper objects - so try to detect object shape to extract error messages
                else if (typeof error === 'object') {
                    // UI API read errors
                    if (Array.isArray(error.body)) {
                        return error.body.map((e) => e.message);
                    }
                    // UI API DML, Apex, missing cacheable=true, network errors
                    else if (error.body && typeof error.body.message === 'string') {
                        return error.body.message;
                    }
                    // DML field errors (such as invalid lookup to wrong object type)
                    // or validation errors can cause this
                    else if (
                        error.body &&
                        typeof error.body.fieldErrors === 'object' &&
                        Object.keys(error.body.fieldErrors).length > 0
                    ) {
                        const keys = Object.keys(error.body.fieldErrors);
                        const allErrors = [];
                        for (let i = 0; i < keys.length; i++) {
                            const key = keys[i];
                            const val = error.body.fieldErrors[key];
                            allErrors.push(val.map((e) => e.message));
                        }
                        return allErrors.reduce((prev, curr) => prev.concat(curr + ' '), '');
                    }
                    // page errors (such as mixed DML error)
                    else if (error.body && Array.isArray(error.body.pageErrors) && error.body.pageErrors.length > 0) {
                        const pageErrors = error.body.pageErrors;
                        const allErrors = [];
                        pageErrors.forEach((e) => {
                            allErrors.push(e.message);
                        });
                        return allErrors.reduce((prev, curr) => prev.concat(curr + ' '), '');
                    }
                    // JS errors
                    else if (typeof error.message === 'string') {
                        return error.message;
                    }
                }
                // Unknown error shape so try HTTP status text
                return error.statusText;
            })
            // Flatten
            .reduce((prev, curr) => prev.concat(curr), [])
            // Remove empty strings
            .filter((message) => !!message)
            .map((message) => message.trim())
    );
}

// Helper function to wait until the microtask queue is empty. This is needed for promise
// timing when calling imperative Apex.
export async function flushPromises() {
    return Promise.resolve();
}
