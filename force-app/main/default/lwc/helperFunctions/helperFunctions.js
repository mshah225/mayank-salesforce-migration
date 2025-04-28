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
 * @param {Object} config Optional param that can set various optional configs
 *                  {
 *                      alphabetize: {Boolean} true if should sort labels in alphabetical order - default is false
 *                  }
 * @returns label-value array
 */
export function buildPicklistOptionsArray(optionsMap, config) {
    let optionsList = [];

    if (config == null) config = {};

    Object.keys(optionsMap).forEach(function (key) {
        optionsList.push({label: key, value: optionsMap[key]});
    });

    // Sort by alphabetical ordering labels
    if (config?.alphabetize === true) {
        optionsList.sort((a, b) => a.label.toLocaleLowerCase().localeCompare(b.label.toLocaleLowerCase()));
    }

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
    if (obj === null) return null;
    if (obj === undefined) return undefined;
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
 * One case where this can happen is with modals launched by a record action.
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

export const UNEXPECTED_ERROR_MSG_PREFIX =
    'An unexpected error has occurred and we have failed to surface any relevant error text. Please view the error object in the Javascript console. Please reach out to Salesforce support: ';
/**
 * Extract a list of human readable error messages from an error object or list or error objects
 * @param {Object|List<Object>} errors
 * @returns String[]
 */
export function extractErrorMessages(errors) {
    // Make errors into an array (with one item) if it isn't an array already (which it might be depending on error source)
    if (!Array.isArray(errors)) {
        errors = [errors];
    }

    return (
        errors
            // Remove null/undefined items
            .filter((error) => !!error)
            // Extract an error message
            .map((error) => {
                // Errors that aren't wrapped in an Error object (maybe from JS throw command)
                if (typeof error === 'string') {
                    return error; // just the message
                }

                // The vast majority of error messages are proper objects - so try to detect object shape to extract error messages
                else if (typeof error === 'object') {
                    /**
                     * If the error is because a failed flow, an issue in a trigger, a missing required field, or a
                     * duplicate unique field (basically arises from DML and is record-wide rather the field-specific)
                     * This can also come from Mixed DML errors.
                     * {
                     *   "body": {
                     *     "pageErrors": [
                     *       {
                     *         "message": String
                     *       }, ...
                     *     ]
                     *   }
                     * }
                     */
                    if (
                        error.body != null &&
                        typeof error.body === 'object' &&
                        error.body.pageErrors != null &&
                        Array.isArray(error.body.pageErrors) &&
                        error.body.pageErrors.length > 0 &&
                        error.body.pageErrors[0] != null &&
                        typeof error.body.pageErrors[0] === 'object' &&
                        error.body.pageErrors[0].message != null &&
                        typeof error.body.pageErrors[0].message === 'string'
                    ) {
                        return error.body.pageErrors.map((v) => v.message); // a list of messages
                    }

                    /**
                     * If the error is DML based but because of a specific field, then the object uses fieldErrors
                     * rather than pageErrors.  This can be because of a failed validation rule, using the wrong type
                     * in a lookup field, or other sources that are tied to a specific field
                     * {
                     *   "body": {
                     *     "fieldErrors": {
                     *       <FIELD_NAME>: [
                     *         {
                     *           "message": String
                     *         }
                     *       ]
                     *     }
                     *   }
                     * }
                     */
                    if (
                        error.body != null &&
                        typeof error.body === 'object' &&
                        error.body.fieldErrors != null &&
                        typeof error.body.fieldErrors === 'object' &&
                        Object.keys(error.body.fieldErrors).length > 0 &&
                        error.body.fieldErrors[Object.keys(error.body.fieldErrors)[0]] != null &&
                        Array.isArray(error.body.fieldErrors[Object.keys(error.body.fieldErrors)[0]]) &&
                        error.body.fieldErrors[Object.keys(error.body.fieldErrors)[0]].length > 0 &&
                        error.body.fieldErrors[Object.keys(error.body.fieldErrors)[0]][0] != null &&
                        typeof error.body.fieldErrors[Object.keys(error.body.fieldErrors)[0]][0] === 'object' &&
                        error.body.fieldErrors[Object.keys(error.body.fieldErrors)[0]][0].message != null &&
                        typeof error.body.fieldErrors[Object.keys(error.body.fieldErrors)[0]][0].message === 'string'
                    ) {
                        let messages = [];
                        for (const fieldName of Object.keys(error.body.fieldErrors)) {
                            error.body.fieldErrors[fieldName].forEach((v) => {
                                messages.push(v.message);
                            });
                        }
                        return messages; // a list of messages
                    }

                    /**
                     * The UI API uses error.message as well as a second more detailed error message deeper in
                     * this is basically the equilvalent to pageErrors from DML sourced exceptions
                     * {
                     *   "body": {
                     *     "message": String (basic),
                     *     "output": {
                     *       "errors": [
                     *         {
                     *           "message": String (additional detail)
                     *         }
                     *       ]
                     *     }
                     *   }
                     * }
                     */
                    if (
                        error.body != null &&
                        typeof error.body === 'object' &&
                        error.body.output != null &&
                        typeof error.body.output === 'object' &&
                        error.body.output.errors != null &&
                        Array.isArray(error.body.output.errors) &&
                        error.body.output.errors.length > 0 &&
                        error.body.output.errors[0] != null &&
                        typeof error.body.output.errors[0] === 'object' &&
                        error.body.output.errors[0].message != null &&
                        typeof error.body.output.errors[0].message === 'string'
                    ) {
                        return error.body.output.errors.map(
                            (e) => (error.body?.message != null ? `${error.body.message}\\n` : '') + e.message
                        ); // a list of messages
                    }

                    /**
                     * Like when there are DML related errors, errors from the UI API can be field specific,
                     * in which case it uses the fieldErrors attribute rather than errors
                     * {
                     *   "body": {
                     *     "message": String (basic),
                     *     "output": {
                     *       "fieldErrors": {
                     *         <FIELD_NAME>: [
                     *           {
                     *             "message": String
                     *           }
                     *         ]
                     *       }
                     *     }
                     *   }
                     * }
                     */
                    if (
                        error.body != null &&
                        typeof error.body === 'object' &&
                        error.body.output != null &&
                        typeof error.body.output === 'object' &&
                        error.body.output.fieldErrors != null &&
                        typeof error.body.output.fieldErrors === 'object' &&
                        Object.keys(error.body.output.fieldErrors).length > 0 &&
                        error.body.output.fieldErrors[Object.keys(error.body.output.fieldErrors)[0]] != null &&
                        Array.isArray(error.body.output.fieldErrors[Object.keys(error.body.output.fieldErrors)[0]]) &&
                        error.body.output.fieldErrors[Object.keys(error.body.output.fieldErrors)[0]].length > 0 &&
                        error.body.output.fieldErrors[Object.keys(error.body.output.fieldErrors)[0]][0] != null &&
                        typeof error.body.output.fieldErrors[Object.keys(error.body.output.fieldErrors)[0]][0] ===
                            'object' &&
                        error.body.output.fieldErrors[Object.keys(error.body.output.fieldErrors)[0]][0].message !=
                            null &&
                        typeof error.body.output.fieldErrors[Object.keys(error.body.output.fieldErrors)[0]][0]
                            .message === 'string'
                    ) {
                        let messages = [];
                        for (const fieldName of Object.keys(error.body.output.fieldErrors)) {
                            error.body.output.fieldErrors[fieldName].forEach((v) => {
                                messages.push(
                                    (error.body?.message != null ? `${error.body.message}\\n` : '') + v.message
                                );
                            });
                        }
                        return messages; // a list of messages
                    }

                    /**
                     * If this error comes from the GraphQL API, then KEEP IN MIND the the wire returns an object
                     * with {errors: Array, data: Object}, rather than the standard {error, data}. So make sure
                     * to unwrap and check for errors, rather the error.
                     *
                     * Since we convert all single errors into arrays at an earlier step, we don't need to worry
                     * about this distinction at this step.
                     *
                     * Each item in the errors array is structued like so
                     * {
                     *   "error": [
                     *     {
                     *       "message": String
                     *     }
                     *   ]
                     * }
                     *
                     */
                    if (
                        error.error != null &&
                        Array.isArray(error.error) &&
                        error.error.length > 0 &&
                        error.error[0] != null &&
                        typeof error.error[0] === 'object' &&
                        error.error[0].message != null &&
                        typeof error.error[0].message === 'string'
                    ) {
                        return error.error.map((v) => v.message); // a list of messages
                    }

                    /**
                     * If the error was caught and the developer threw a nice standard AuraHandledException, then
                     * the error format is standardized.  Several other sources give errors in this format, including
                     * missing cacheable=true errors, most other Apex errors, Governor Limit errors, etc
                     *
                     * Basically, any errors propogating from Apex should look like this, except for DML-related errors
                     * (though you can catch DML related errors and raise AuraHandledException to format them nicely
                     * like this)
                     *
                     * {
                     *   "body": {
                     *      "message": String
                     *   }
                     * }
                     */
                    if (typeof error.body === 'object' && typeof error.body.message === 'string') {
                        return error.body.message;
                    }

                    /**
                     * Standard JS Error objects just have an attribute called message which is a string
                     * {
                     *   "message": String
                     * }
                     */
                    if (typeof error.message === 'string') {
                        return error.message;
                    }
                }

                console.debug('Unexpected Error Format Found:', error);

                // Unknown error shape so report this to user and hope they reach out so we can improve this code
                return UNEXPECTED_ERROR_MSG_PREFIX + (error.statusText || '[UNKNOWN STATUS TEXT]');
            })
            // Flatten - each mapped item might return a list, so this converts: [[String] | String] -> [String]
            .reduce((prev, curr) => prev.concat(curr), [])
            // Remove empty strings
            .filter((message) => !!message)
            // Remove leading and trailing spaces for each message
            .map((message) => message.trim())
            // Convert any \\n into proper \n
            .map((v) => {
                return v.replace('\\n', '\n');
            })
    );
}
