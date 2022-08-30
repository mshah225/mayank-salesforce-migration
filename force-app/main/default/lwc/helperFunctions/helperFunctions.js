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
