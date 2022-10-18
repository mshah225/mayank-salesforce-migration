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
