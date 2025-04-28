export class KeyboardController {
    /**
     * Is this keycode associated with a down type action (e.g. <down>)
     * @param {int} code
     * @returns {Boolean} true or false
     */
    static isDownKey(code) {
        return code === 40; // down
    }

    /**
     * Is this keycode associated with a up type action (e.g. <up>)
     * @param {int} code
     * @returns {Boolean} true or false
     */
    static isUpKey(code) {
        return code === 38; // up
    }

    /**
     * Is this keycode associated with a select type action (e.g. <enter> or <space>)
     * @param {int} code
     * @returns {Boolean} true or false
     */
    static isSelectionKey(code) {
        return code === 13 /*enter*/ || code === 32 /*space*/;
    }

    /**
     * Is this keycode associated with a closing type action (e.g. <esc>)
     * @param {int} code
     * @returns {Boolean} true or false
     */
    static isCloseKey(code) {
        return code === 27; // esc
    }

    /**
     * Is this keycode associated with tabbing (e.g. <tab>)
     * @param {int} code
     * @returns {Boolean} true or false
     */
    static isTabKey(code) {
        return code === 9; // tab
    }

    /**
     * Is the keycode associated with meta controls
     * @param {int} code
     * @returns {Boolean} true or false
     */
    static isMetaKey(code) {
        return code === 17 /*Control*/ || code === 224 /*Meta*/;
    }

    /**
     * Is the keycode associated with PageUp
     * @param {int} code
     * @returns {Boolean} true or false
     */
    static isPageUpKey(code) {
        return code === 33; /*PageUp*/
    }

    /**
     * Is the keycode associated with PageDown
     * @param {int} code
     * @returns {Boolean} true or false
     */
    static isPageDownKey(code) {
        return code === 34; /*PageDown*/
    }

    /**
     * Is the keycode associated with Home
     * @param {int} code
     * @returns {Boolean} true or false
     */
    static isHomeKey(code) {
        return code === 36; /*Home*/
    }

    /**
     * Is the keycode associated with End
     * @param {int} code
     * @returns {Boolean} true or false
     */
    static isEndKey(code) {
        return code === 35; /*End*/
    }
}
