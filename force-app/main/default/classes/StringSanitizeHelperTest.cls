@isTest
public class StringSanitizeHelperTest {
    @isTest
    private static void testStringCleanEmptyParentheses() {
        StringSanitizeHelper StringSanitizeHelper = getCommonStringSanitizeHelper();

        // Various locations for empty parentheses
        Assert.areEqual('Hello World', StringSanitizeHelper.cleanup('Hello World()'));
        Assert.areEqual('Hello World', StringSanitizeHelper.cleanup('Hello() World'));
        Assert.areEqual('Hello World', StringSanitizeHelper.cleanup('()Hello World'));

        // Parentheses with only punctuation/whitespace inside
        Assert.areEqual('Hello World', StringSanitizeHelper.cleanup('Hello World(,,)'));
        Assert.areEqual('Hello World', StringSanitizeHelper.cleanup('Hello World(  )'));
        Assert.areEqual('Hello World', StringSanitizeHelper.cleanup('Hello World(, )'));
        Assert.areEqual('Hello World', StringSanitizeHelper.cleanup('Hello World(.,)'));

        // Other types of paided punctuation
        Assert.areEqual('Hello World', StringSanitizeHelper.cleanup('Hello World()'));
        Assert.areEqual('Hello World', StringSanitizeHelper.cleanup('Hello World[]'));
        Assert.areEqual('Hello World', StringSanitizeHelper.cleanup('Hello World{}'));
        Assert.areEqual('Hello World', StringSanitizeHelper.cleanup('Hello World<>'));
    }

    @isTest
    private static void testStringCleanNonEmptyParentheses() {
        StringSanitizeHelper StringSanitizeHelper = getCommonStringSanitizeHelper();

        // non empty parentheses should be untouched
        Assert.areEqual('Hello World(yes)', StringSanitizeHelper.cleanup('Hello World(yes)'));
        Assert.areEqual('Hello World[yes]', StringSanitizeHelper.cleanup('Hello World[yes]'));
        Assert.areEqual('Hello World{yes}', StringSanitizeHelper.cleanup('Hello World{yes}'));
        Assert.areEqual('Hello World<yes>', StringSanitizeHelper.cleanup('Hello World<yes>'));
    }

    @isTest
    private static void testStringCleanExtraWhitespace() {
        StringSanitizeHelper StringSanitizeHelper = getCommonStringSanitizeHelper();

        // Various locations for extra whitespace
        Assert.areEqual('Hello World', StringSanitizeHelper.cleanup('Hello    World'));
        Assert.areEqual('Hello World', StringSanitizeHelper.cleanup('Hello World   '));
        Assert.areEqual('Hello World', StringSanitizeHelper.cleanup('   Hello World'));
        Assert.areEqual('Hello World', StringSanitizeHelper.cleanup('   Hello    World   '));
    }

    @isTest
    private static void testStringCleanExtraPunctuation() {
        StringSanitizeHelper StringSanitizeHelper = getCommonStringSanitizeHelper();

        // Various locations for extra punctation
        Assert.areEqual('Hello,World', StringSanitizeHelper.cleanup('Hello,,World'));
        Assert.areEqual('Hello World', StringSanitizeHelper.cleanup('Hello World,,'));
        Assert.areEqual('Hello World', StringSanitizeHelper.cleanup(',,Hello World'));

        // Trailing end punctuation
        Assert.areEqual('Hello World!', StringSanitizeHelper.cleanup('Hello World!!'));
        Assert.areEqual('Hello World?', StringSanitizeHelper.cleanup('Hello World??'));
        Assert.areEqual('Hello World.', StringSanitizeHelper.cleanup('Hello World..'));
        // Leading end punctuation
        Assert.areEqual('Hello World', StringSanitizeHelper.cleanup('!!Hello World'));
        Assert.areEqual('Hello World', StringSanitizeHelper.cleanup('??Hello World'));
        Assert.areEqual('Hello World', StringSanitizeHelper.cleanup('..Hello World'));

        // Various pairings of extra punctation
        Assert.areEqual('Hello,World', StringSanitizeHelper.cleanup('Hello,,World'));
        Assert.areEqual('Hello,World', StringSanitizeHelper.cleanup('Hello,.World'));
        Assert.areEqual('Hello.World', StringSanitizeHelper.cleanup('Hello..World'));
        Assert.areEqual('Hello.World', StringSanitizeHelper.cleanup('Hello.,World'));
    }

    @isTest
    private static void testStringCleanUnorderedWhitespaceAndPunctation() {
        StringSanitizeHelper StringSanitizeHelper = getCommonStringSanitizeHelper();

        // Various locations for extra punctation
        Assert.areEqual('Hello, World', StringSanitizeHelper.cleanup('Hello ,World'));
        Assert.areEqual('Hello World', StringSanitizeHelper.cleanup(' ,Hello World'));
        Assert.areEqual('Hello World', StringSanitizeHelper.cleanup('Hello World ,'));

        // With end punctuation
        Assert.areEqual('Hello World!', StringSanitizeHelper.cleanup('Hello World !'));
        Assert.areEqual('Hello World?', StringSanitizeHelper.cleanup('Hello World ?'));
    }

    @isTest
    private static void testStringCleanExtraWhitespaceAndPunctuation() {
        StringSanitizeHelper StringSanitizeHelper = getCommonStringSanitizeHelper();

        // Various locations for extra punctation
        Assert.areEqual('Hello, World', StringSanitizeHelper.cleanup('Hello ,  ,,World'));
        Assert.areEqual('Hello, World', StringSanitizeHelper.cleanup('Hello ,  ,.World'));
        Assert.areEqual('Hello. World', StringSanitizeHelper.cleanup('Hello .  ,,World'));
        Assert.areEqual('Hello World', StringSanitizeHelper.cleanup(' ,  ,,Hello World'));
        Assert.areEqual('Hello World', StringSanitizeHelper.cleanup('Hello World ,  ,,'));
    }

    private static final List<String> innerPuncutationList = new List<String>{ ',' };
    private static final List<String> endPunctuationList = new List<String>{ '.', '!', '?' };
    private static final Map<String, String> puncutationPairs = new Map<String, String>{
        '(' => ')',
        '[' => ']',
        '{' => '}',
        '<' => '>'
    };
    private static final List<String> whitespaceList = new List<String>{ ' ' };

    private static StringSanitizeHelper getCommonStringSanitizeHelper() {
        StringSanitizeHelper StringSanitizeHelper = new StringSanitizeHelper();
        StringSanitizeHelper.setInnerPuncutationList(innerPuncutationList);
        StringSanitizeHelper.setEndPuncutationList(endPunctuationList);
        StringSanitizeHelper.setPuncutationPairs(puncutationPairs);
        StringSanitizeHelper.setWhitespaceList(whitespaceList);
        return StringSanitizeHelper;
    }
}
