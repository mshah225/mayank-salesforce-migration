@isTest
public class StringRegexHelperTest {
    @isTest
    private static void testNoEscapesNeeded() {
        Assert.areEqual('ghost', StringRegexHelper.escapeCharsForPattern('ghost'));
    }

    @isTest
    private static void testDontEscape() {
        // Various characters that might accidentally get escaped, but which we shouldn't escape
        // Single quotes aren't reserved in Regex
        Assert.areEqual('ghost\'s pet spider', StringRegexHelper.escapeCharsForPattern('ghost\'s pet spider'));
        // Double quotes aren't reserved in Regex
        Assert.areEqual('ghost said "fly"', StringRegexHelper.escapeCharsForPattern('ghost said "fly"'));
    }

    @isTest
    private static void testControlCharacters() {
        // Newline is \n in Regex (need to escape backslash for regex engine)
        Assert.areEqual('today\\ntomorrow', StringRegexHelper.escapeCharsForPattern('today\ntomorrow'));
        // Tab is \t in Regex (need to escape backslash for regex engine)
        Assert.areEqual('today\\ttomorrow', StringRegexHelper.escapeCharsForPattern('today\ttomorrow'));
        // Carriage return \r in Regex (need to escape backslash for regex engine)
        Assert.areEqual('today\\rtomorrow', StringRegexHelper.escapeCharsForPattern('today\rtomorrow'));
    }

    @isTest
    private static void testBoundaries() {
        // $ is used in Regex to indicate the beginning of a line
        Assert.areEqual('\\$20', StringRegexHelper.escapeCharsForPattern('$20'));
        // ^ is used in Regex to indicate the end of a line
        Assert.areEqual('2\\^3', StringRegexHelper.escapeCharsForPattern('2^3'));
    }

    @isTest
    private static void testQuantifiers() {
        // ? is used in Regex on quantifier to indicate "once or not at all"
        Assert.areEqual('when\\?', StringRegexHelper.escapeCharsForPattern('when?'));
        // * is used in Regex on quantifier to indicate "zero or more times"
        Assert.areEqual('when\\*', StringRegexHelper.escapeCharsForPattern('when*'));
        // + is used in Regex on quantifier to indicate "one or more time"
        Assert.areEqual('when\\+', StringRegexHelper.escapeCharsForPattern('when+'));
    }

    @isTest
    private static void testLogicalOperators() {
        // Pipes are used in Regex as the OR operator
        Assert.areEqual('cat\\|dog', StringRegexHelper.escapeCharsForPattern('cat|dog'));
    }

    @isTest
    private static void testContainers() {
        // Parentheses are used in Regex to wrap groups
        Assert.areEqual('\\(ghost\\)', StringRegexHelper.escapeCharsForPattern('(ghost)'));
        // Brackets are used in Regex to wrap character classes
        Assert.areEqual('\\[ghost\\]', StringRegexHelper.escapeCharsForPattern('[ghost]'));
        // Curly Braces are used in Regex to wrap quantifier counts and in various named character classes
        Assert.areEqual('\\{ghost\\}', StringRegexHelper.escapeCharsForPattern('{ghost}'));
    }

    @isTest
    private static void testSpecialConstructs() {
        // Colons are used in Regex for some special constructs
        Assert.areEqual('Inheritance\\: Eragon', StringRegexHelper.escapeCharsForPattern('Inheritance: Eragon'));
        // Triangle brackets are used in Regex for some special constructs
        Assert.areEqual('\\<naptime\\>', StringRegexHelper.escapeCharsForPattern('<naptime>'));
        // Equals are used in Regex for some special constructs
        Assert.areEqual('3 \\= 3', StringRegexHelper.escapeCharsForPattern('3 = 3'));
        // ! are used in Regex for some special constructs
        Assert.areEqual('Hello World\\!', StringRegexHelper.escapeCharsForPattern('Hello World!'));
        // ? are used in Regex for some special constructs
        Assert.areEqual('when\\?', StringRegexHelper.escapeCharsForPattern('when?'));
    }

    @isTest
    private static void testMisc() {
        // Backslashes are used in Regex for character classes
        Assert.areEqual('C\\:\\\\Windows\\\\System32', StringRegexHelper.escapeCharsForPattern('C:\\Windows\\System32'));
        // Commas are used in Regex for quantifier counts
        Assert.areEqual('cat\\, dog\\, and frog', StringRegexHelper.escapeCharsForPattern('cat, dog, and frog'));
        // Dashes are used in Regex for some character classes, e.g. "a-z"
        Assert.areEqual('Spring 2020 \\- Fall 2023', StringRegexHelper.escapeCharsForPattern('Spring 2020 - Fall 2023'));
        // Dots are used in Regex to indicate "any character"
        Assert.areEqual('1999\\.12\\.18', StringRegexHelper.escapeCharsForPattern('1999.12.18'));
        // Ampersands are used in Regex for class intersectiosn
        Assert.areEqual('Cats \\& Coffee', StringRegexHelper.escapeCharsForPattern('Cats & Coffee'));
        // ^ are used in Regex to indicate negated character classes
        Assert.areEqual('Rubix\\^3', StringRegexHelper.escapeCharsForPattern('Rubix^3'));
        // Ensure that non newline is escaped properly
        Assert.areEqual('today\\\\ntomorrow', StringRegexHelper.escapeCharsForPattern('today\\ntomorrow'));
    }
}
