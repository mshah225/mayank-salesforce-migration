export class KeyboardController {
    /**
     * Is this keycode associated with a down type action (e.g. <down>)
     * @param {int} code
     * @returns {Boolean} true or false
     */
    static isDownKey(code) {
        if (typeof code === 'string') return code === 'ArrowDown';
        return code === 40; // down
    }

    /**
     * Is this keycode associated with a up type action (e.g. <up>)
     * @param {int} code
     * @returns {Boolean} true or false
     */
    static isUpKey(code) {
        if (typeof code === 'string') return code === 'ArrowUp';
        return code === 38; // up
    }

    /**
     * Is this keycode associated with a select type action (e.g. <enter> or <space>)
     * @param {int} code
     * @returns {Boolean} true or false
     */
    static isSelectionKey(code) {
        if (typeof code === 'string') return [' ', 'Enter'].includes(code);
        return code === 13 /*enter*/ || code === 32 /*space*/;
    }

    /**
     * Is this keycode <space>?
     * @param {int} code
     * @returns {Boolean} true or false
     */
    static isSpaceKey(code) {
        if (typeof code === 'string') return code === ' ';
        return code === 32 /*space*/;
    }

    /**
     * Is this keycode associated with a closing type action (e.g. <esc>)
     * @param {int} code
     * @returns {Boolean} true or false
     */
    static isCloseKey(code) {
        if (typeof code === 'string') return code === 'Escape';
        return code === 27; // esc
    }

    /**
     * Is this keycode associated with tabbing (e.g. <tab>)
     * @param {int} code
     * @returns {Boolean} true or false
     */
    static isTabKey(code) {
        if (typeof code === 'string') return code === 'Tab';
        return code === 9; // tab
    }

    /**
     * Is the keycode associated with meta controls
     * @param {int} code
     * @returns {Boolean} true or false
     */
    static isMetaKey(code) {
        if (typeof code === 'string') return ['Control', 'Meta'].includes(code);
        return code === 17 /*Control*/ || code === 224 /*Meta*/;
    }

    /**
     * Is the keycode associated with PageUp
     * @param {int} code
     * @returns {Boolean} true or false
     */
    static isPageUpKey(code) {
        if (typeof code === 'string') return code === 'PageUp';
        return code === 33; /*PageUp*/
    }

    /**
     * Is the keycode associated with PageDown
     * @param {int} code
     * @returns {Boolean} true or false
     */
    static isPageDownKey(code) {
        if (typeof code === 'string') return code === 'PageDown';
        return code === 34; /*PageDown*/
    }

    /**
     * Is the keycode associated with Home
     * @param {int} code
     * @returns {Boolean} true or false
     */
    static isHomeKey(code) {
        if (typeof code === 'string') return code === 'Home';
        return code === 36; /*Home*/
    }

    /**
     * Is the keycode associated with End
     * @param {int} code
     * @returns {Boolean} true or false
     */
    static isEndKey(code) {
        if (typeof code === 'string') return code === 'End';
        return code === 35; /*End*/
    }

    /**
     * Is the keycode something you would expect a user to enter into a search bar? This is basically all the common keycodes on the keyboard
     * @param {int} code
     * @returns {Boolean} true or false
     */
    static isCommon(code) {
        if (typeof code === 'string')
            return [
                'a',
                'b',
                'c',
                'd',
                'e',
                'f',
                'g',
                'h',
                'i',
                'j',
                'k',
                'l',
                'm',
                'n',
                'o',
                'p',
                'q',
                'r',
                's',
                't',
                'u',
                'v',
                'w',
                'x',
                'y',
                'z',
                'A',
                'B',
                'C',
                'D',
                'E',
                'F',
                'G',
                'H',
                'I',
                'J',
                'K',
                'L',
                'M',
                'N',
                'O',
                'P',
                'Q',
                'R',
                'S',
                'T',
                'U',
                'V',
                'W',
                'X',
                'Y',
                'Z',
                '0',
                '1',
                '2',
                '3',
                '4',
                '5',
                '6',
                '7',
                '8',
                '9',
                '!',
                '@',
                '#',
                '$',
                '%',
                '^',
                '&',
                '*',
                '(',
                ')',
                '[',
                ']',
                '{',
                '}',
                '<',
                '>',
                '"',
                "'",
                ':',
                ';',
                ',',
                '.',
                '?',
                '/',
                '-',
                '_',
                '+',
                '=',
                ' ',
            ].includes(code);
        return (
            (code >= 65 && code <= 90) || // a-z A-Z
            (code >= 48 && code <= 57) || // 0-9 )!@#$%^&*(
            code === 219 || // [{
            code === 221 || // ]}
            code === 222 || // ' "
            code === 59 || // : ;
            code === 188 || // , <
            code === 190 || // . >
            code === 191 || // ? /
            code === 173 || // - _
            code === 161 || // + =
            code === 32 // <space>
        );
    }
}
