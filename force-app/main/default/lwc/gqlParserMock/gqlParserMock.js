class GqlParserMockException extends Error {}

/**
 * This is a rough GraphQL parser
 * It can take in a properly formatted GraphQL query string and separate it into a corresponding JS object
 *
 * The primary purpose of this is to be used as a mock implementation for JEST tests, so that we can write
 * tests that check if the proper fields are being queried or not.
 *
 * Because this is a rather rough parser, DO NOT use it in production code.  It has various issues
 * that are OK for testing but a problem if used in production such as:
 * 1. Poor error messaging
 * 2. Treating all values as strings (no typing for int/bool/etc)
 * 3. Nothing to extract or check defined variables
 * 4. Likely multiple undiscovered bugs
 *
 * At each level of the generated object there are
 * 1. all the child elements by name
 * 2. a child called __attribs containing any attributes for that node (such as filtering clauses)
 */

export default class GqlParserMock {
    object = null; // generated object
    str = null; // input GQL string

    // additional extracted information
    operationName = null;
    variables = null;
    operation = null;

    // Parsing mode
    cursor = 0; // cursor during parsing
    mode = null; // Parsing mode

    constructor(input) {
        if (input == null) {
            this.object = null;
        }

        if (typeof input !== 'string') {
            throw new GqlParserMockException(
                'Invalid type passed to parser. GQL Parser expects a string, but you passed a(n) ' + typeof elem
            );
        }

        if (typeof input === 'string') {
            this.str = input;
            // try {
            this.parse();
            // } catch (ex) {
            //     throw new GqlParserMockException('Could not parse GQL string ' + (ex.message || ''));
            // }
        }
    }

    parse() {
        if (this.tokens[0].value !== 'query') {
            throw new GqlParserMockException(
                `Invalid query, GQL query should start with "query" keyword. But instead found ${this.tokens[0].value} at starting index ${this.tokens[0].at}`
            );
        }

        // If the second token is NOT a open curly brace and NOT a open parenthesis, then we have a named query (and the name is here) - and will use the name at the root of the object
        if (!['{', '('].includes(this.tokens[1].value)) {
            this.cursor = 1;
        }

        let rootName = this.currentTokenValue();

        // We have not written a parser for the names/types of the variables - so just skip until the first curly brace

        this.object = {};
        this.mode = 'PROPERTY';

        this.skipUntilAfterNext('{'); // skip until after opening brace for root component

        this.object[rootName] = this.parseRecursive();

        if (this.nextNonSpaceTokenValue() !== '}') {
            throw new GqlParserMockException(
                'Invalid query, GQL query should end with a close curly brace for the root component but this did not happen. Braces might be unbalanced'
            );
        } else {
            this.skipUntilAfterNext('{');

            while (this.cursor < (this.tokens?.length ?? 0)) {
                if (this.currentTokenValue() !== '\n') {
                    throw new GqlParserMockException('Extra contents found at the end of the query string - error');
                }
                this.cursor += 1;
            }
        }
    }

    parseRecursive() {
        let fragment = null;

        // skip newlines
        if (this.currentTokenValue() === '\n') {
            this.cursor += 1; // move to after the newline
            return this.parseRecursive();
        }

        if (this.mode === 'PROPERTY') {
            let propName = this.currentTokenValue();
            fragment = {};
            fragment[propName] = {};
            this.cursor += 1; // move to after the token we just read

            // Check for attirbutes
            if (this.nextNonSpaceTokenValue() === '(') {
                // swap to reading attributes
                this.mode = 'ATTRIBUTE';

                this.skipUntilAfterNext('('); // move to after that bracket
                fragment[propName].__attribs = this.parseRecursive();
                this.skipUntilAfterNext(')'); // move to after that bracket

                this.mode = 'PROPERTY';
            }

            // Check for child properties
            if (this.nextNonSpaceTokenValue() === '{') {
                // if the next non space item is a open bracket, then this is a branching point
                this.skipUntilAfterNext('{'); // move to after that bracket
                // and until we find the closing bracket, read each branching path
                while (this.nextNonSpaceTokenValue() !== '}') {
                    fragment[propName] = {
                        ...fragment[propName],
                        ...this.parseRecursive(),
                    };
                }
                this.skipUntilAfterNext('}'); // end bracket for this node
            } else {
                fragment[propName] = null; // no child element, at a lead
            }
        } else if (this.mode === 'ATTRIBUTE') {
            fragment = {};
            while (this.nextNonSpaceTokenValue() !== ')') {
                this.skipUntilBeforeNext(this.nextNonSpaceTokenValue());
                let attribName = this.currentTokenValue();
                this.cursor += 1;

                // need a colon after attirbute name
                if (this.nextNonSpaceTokenValue() !== ':') {
                    throw new GqlParserMockException(
                        `Parsing attributes, but missing colon. Reading token at index ${this.tokens[this.cursor].at}`
                    );
                } else {
                    this.skipUntilAfterNext(':'); // after colon
                }

                if (this.nextNonSpaceTokenValue() === '{') {
                    // attribute is an object of some sort
                    this.skipUntilAfterNext('{');

                    fragment[attribName] = {};

                    fragment[attribName] = {
                        ...fragment[attribName],
                        ...this.parseRecursive(),
                    };

                    // End of this level of tree
                    if (this.nextNonSpaceTokenValue() !== '}') {
                        throw new GqlParserMockException(
                            `Missing close bracket at index ${this.tokens[this.cursor].at}`
                        );
                    } else {
                        this.skipUntilAfterNext('}');
                    }
                } else if (this.nextNonSpaceTokenValue() === '[') {
                    // attribute is an array
                    this.skipUntilAfterNext('[');
                    fragment[attribName] = [];

                    while (this.nextNonSpaceTokenValue() !== ']') {
                        if (this.nextNonSpaceTokenValue() !== '{') {
                            throw new GqlParserMockException(
                                `Parsing array, but missing open curly brace at index ${this.tokens[this.cursor].at}`
                            );
                        }
                        this.skipUntilAfterNext('{');

                        fragment[attribName].push(this.parseRecursive());

                        if (this.nextNonSpaceTokenValue() !== '}') {
                            throw new GqlParserMockException(
                                `Parsing array, but missing open close brace at index ${this.tokens[this.cursor].at}`
                            );
                        }
                        this.skipUntilAfterNext('}');

                        if (this.nextNonSpaceTokenValue() === ',') {
                            // another value in array to read
                            this.skipUntilAfterNext(',');
                        }
                    }
                    this.skipUntilAfterNext(']');
                } else {
                    // simple value
                    this.skipUntilBeforeNext(this.nextNonSpaceTokenValue());
                    fragment[attribName] = this.currentTokenValue();
                    this.cursor += 1;
                }

                if (this.nextNonSpaceTokenValue() === '}') {
                    // no more info at this level of tree - so pop back up
                    break;
                } else if ([','].includes(this.nextNonSpaceTokenValue())) {
                    // Additional information on this level of the tree
                    this.skipUntilAfterNext(this.nextNonSpaceTokenValue());
                }
            }
        }
        return fragment;
    }

    // Checks if the cursor has reached the end of tokens yet
    hasTokensToParse() {
        return this.cursor < this.tokens.length;
    }
    // Get value of the current token
    currentTokenValue() {
        return this.tokens[this.cursor].value;
    }

    /**
     * The value of the next non-newline token
     * @returns The value of the next null spacing token
     */
    nextNonSpaceTokenValue() {
        for (let i = 0; i < this.tokens.length - this.cursor; i++) {
            let token = this.peekN(i);
            if (token == null) return null;
            if (token.value !== '\n') return token.value;
        }
        return null;
    }

    /**
     * Skip the cursor ahead until right before the next specified character
     * @param {String} char Character to move the cursor to before
     */
    skipUntilBeforeNext(char) {
        while (this.hasTokensToParse()) {
            let token = this.currentTokenValue();
            if (token == null) return null;
            if (token === char) {
                break;
            }
            this.cursor += 1;
        }
        return null;
    }
    /**
     * Skip the cursor ahead until after the next specified character
     * @param {String} char Character to move the cursor to after
     */
    skipUntilAfterNext(char) {
        while (this.hasTokensToParse()) {
            let token = this.currentTokenValue();
            if (token == null) return null;
            if (token === char) {
                this.cursor += 1;
                break;
            }
            this.cursor += 1;
        }
    }

    /**
     * Look ahead at the next token
     * @returns The next token, or null if out of bounds
     */
    peek() {
        return this.peekN(1);
    }
    /**
     * Look ahead at the nth next token
     * @param {Integer} n Number of places to look ahead
     * @returns That token, or null if out of bounds
     */
    peekN(n) {
        return this.tokens[this.cursor + n];
    }

    /**
     * Tokens is an array of objects,
     * each object has a `value` (string value of token), and an `at`, integer, the index that element started at in the original string
     */
    _tokens = undefined;
    get tokens() {
        if (this._tokens !== undefined) {
            return this._tokens;
        }

        if (this.str == null) return null;

        let tokens = [];
        let token = '';

        // when you see these push token (these characters never appear in tokens unless in quotes)
        const separatorCharacters = [' '];
        // when you see these, push token and make these their own separate token
        const independentCharacters = ['(', ')', '{', '}', '[', ']', ',', '\n', ':'];
        // Enclosing characters result in themselves and their contents being a single token (usually happens strings)
        const enclosingCharacters = ['"'];
        let enclosed = false;
        let nextIsEscaped = false;

        for (let i = 0; i < this.str.length; i++) {
            const char = this.str[i];

            if (enclosed) {
                token += char;

                if (!nextIsEscaped && enclosingCharacters.includes(char)) {
                    enclosed = false;
                }

                if (char === '\\')
                    if (nextIsEscaped) nextIsEscaped = false;
                    else nextIsEscaped = true;
                else nextIsEscaped = false;

                continue; // move on to next token without checking rest since we are in a closure right now
            }

            if (
                separatorCharacters.includes(char) ||
                independentCharacters.includes(char) ||
                enclosingCharacters.includes(char)
            ) {
                // push token
                if (token !== '') {
                    tokens.push({
                        value: token,
                        at: i - token.length,
                    });
                    token = '';
                }
            }

            if (separatorCharacters.includes(char)) {
                // already pushed token
            } else if (independentCharacters.includes(char)) {
                // push this as its own token
                tokens.push({
                    value: char,
                    at: i,
                });
            } else if (enclosingCharacters.includes(char)) {
                // start enclosure mode and include open enclosure character
                token += this.str[i];
                enclosed = true;
            } else {
                // Character is non whitespace, build token
                token += this.str[i];
            }
        }

        if (enclosed) {
            throw new GqlParserMockException(
                `Parsing error: ended while inside quotes.  You have unbalanced quotes in input. Opening quote was at index ${
                    this.str.length - token.length
                }`
            );
        }

        // Remove leading and trailing newline tokens
        while (tokens[0]?.value === '\n') tokens.splice(0, 1);
        while (tokens[tokens.length - 1]?.value === '\n') tokens.pop();

        this._tokens = tokens;

        return tokens;
    }
}
