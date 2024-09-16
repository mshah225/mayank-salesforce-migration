public class StringRegexHelper {
    // Reserved characters in Regex that need to be escaped
    private static final Set<String> escapeChars = new Set<String>{
        '$',
        '^',
        '?',
        '*',
        '+',
        '|',
        '[',
        ']',
        '(',
        ')',
        '{',
        '}',
        ':',
        '<',
        '>',
        '=',
        '!',
        '\\',
        ',',
        '-',
        '.',
        '&'
    };

    // Single characters in Java that need to be expanded in Regex
    private static final Map<String, String> controlChars = new Map<String, String>{
        '\n' => '\\n',
        '\t' => '\\t',
        '\r' => '\\r'
    };

    /**
     * Takes in a string that is going to be included in a regex pattern string
     * and add backslash escape values if needed to avoid components of it being
     * treated as character classes or other reserved characters.
     *
     * @example "eat (consume\destroy)" -> "eat \(consume\\destroy\)"
     * @param str The string that needs to be escaped
     * @return The escaped string
     */
    public static String escapeCharsForPattern(String str) {
        String newStr = '';

        // Escape literal backslashes to prevent getChars from stripping them out
        str = str.replace('\\', '\\\\');

        for (Integer c : str.getChars()) {
            String s = String.fromCharArray(new List<Integer>{ c });
            if (controlChars.containsKey(s)) {
                newStr += controlChars.get(s);
            } else if (escapeChars.contains(s)) {
                newStr += '\\' + s;
            } else {
                newStr += s;
            }
        }

        return newStr;
    }
}
