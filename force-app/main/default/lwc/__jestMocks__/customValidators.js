/**
 * Adds a JEST validator that can look for a specific child element of an HTML node
 */
expect.extend({
    /**
     * Check that the passed element has at least one child matching the selector
     * @param {Element} actual
     * @param {String} selector
     * @returns
     */
    toHaveChildElement(actual, selector) {
        if (actual.querySelectorAll(selector).length > 0) {
            return {
                message: () => `The selector \`${selector}\` should NOT return an element, but it did`,
                pass: true,
            };
        } else {
            return {
                message: () => `The selector \`${selector}\` should return an element, but it didn't`,
                pass: false,
            };
        }
    },
});

/**
 * Adds a JEST validator that matches a list of strings to the textContents for a list of nodes
 */
expect.extend({
    /**
     * Take a list of Nodes, and check that each Node's textContent matches its corresponding
     * value in the expectedTextValues list.
     * @param {List<Element>} elementList
     * @param {List<String>} expectedTextValues
     * @returns
     */
    toMatchTextContents(elementList, expectedTextValues) {
        let failedToMatchIndx = null;
        for (
            let i = 0;
            i < (elementList.length >= expectedTextValues.length ? elementList.length : expectedTextValues.length);
            i++
        ) {
            const nodeText = i < elementList.length ? elementList[i].textContent?.trim() : null;
            const expectedText = i < expectedTextValues.length ? expectedTextValues[i].trim() : null;

            console.debug(nodeText, expectedText, nodeText !== expectedText);
            if (nodeText !== expectedText) {
                failedToMatchIndx = i;
                break;
            }
        }

        if (failedToMatchIndx === null) {
            return {
                message: () =>
                    `Each element in the elementList matched the corresponding text value, but we wanted some to not match!`,
                pass: true,
            };
        } else {
            const nodeText =
                failedToMatchIndx < elementList.length ? elementList[failedToMatchIndx].textContent?.trim() : null;
            const expectedText =
                failedToMatchIndx < expectedTextValues.length ? expectedTextValues[failedToMatchIndx].trim() : null;

            return {
                message: () =>
                    `Element #${failedToMatchIndx} did not match. Expected value was "${expectedText}" but the actual value was "${nodeText}"`,
                pass: false,
            };
        }
    },
});
