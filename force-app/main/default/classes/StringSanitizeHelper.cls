/**
 * This is a helper class designed to take in a string and help clean it up a bit.
 * Primarily, it is meant to cleanup strings that are constructed in a common format
 * but where some parts of the string are optional.
 *
 * For example, you might want to format an address like so
 *      1065 W. 1st St (Apt 212)
 *      Tempe, AZ-85281, United States
 * and thus when concatenating the components of the address in this way, you need to
 * hardcode the addition of commas, parentehses, etc.
 * but if some values are null, this might result in something like
 *      1065 W. 1st St ()
 *      Tempe, AZ-,
 *
 * It would, of course, be nice if we could cleanup the address without needing to do
 * a dozen null checks.  The StringSanitizeHelper helps with this.
 *
 * By setting the punctuation apirs to include parenthesesm innerPuncuation to include
 * comma and dash, and whitespaceList to include space
 * We can cleanup the input like
 *      1065 W. 1st St
 *      Tempe, AZ
 *
 * You SHOULD NOT use this is the input is meant to contain emotion and expression.
 * This is because of how it trims "unnecessary" punctuation (which would remove
 * stuff like :) or :( ).  You also would lose multi-punctuation marks (e.g.
 * "You did what?!?!" would get trimmed to "You did what?").
 */
public class StringSanitizeHelper {
    private List<String> innerPuncutationList = new List<String>{};
    private List<String> endPuncutationList = new List<String>{};
    private Map<String, String> puncutationPairs = new Map<String, String>{};
    private List<String> whitespaceList = new List<String>{};

    public StringSanitizeHelper() {
    }

    public void setWhitespaceList(List<String> whitespaceList) {
        this.whitespaceList = whitespaceList;
    }
    public void setPuncutationPairs(Map<String, String> puncutationPairs) {
        this.puncutationPairs = puncutationPairs;
    }
    public void setInnerPuncutationList(List<String> innerPuncutationList) {
        this.innerPuncutationList = innerPuncutationList;
    }
    public void setEndPuncutationList(List<String> endPuncutationList) {
        this.endPuncutationList = endPuncutationList;
    }

    /**
     * The primary function of this class, it cleans a string using all cleaning functions.
     */
    public String cleanup(String str) {
        String cleanStr = cleanEmptyPairedPunctuation(str);
        cleanStr = cleanExcessPuncutationsAndWhitespace(cleanStr);
        cleanStr = cleanLeadingAndTrailingPunctuation(cleanStr);
        return cleanStr;
    }

    /**
     * Finds and remove any empty paired punctuation sections in the input string.
     * For example, if you have are formatting names like so $FIRST ($MIDDLE) $LAST
     * and $MIDDLE is empty string, then you might get a string like "Thomas () Nordman"
     * If you pass that to this function, then it returns "Thomas  Nordman" (note the double space)
     *
     * @param str The input string
     * @return A string with any empty parentheses (or other paired punctuations) removed
     */
    public String cleanEmptyPairedPunctuation(String str) {
        String cleanStr = '';
        Pattern emptyRegexPattern = getEmptyRegexPattern();

        // If there are any paired punctuation that are empty, remove them and their contents
        for (Integer i = 0; i < str.length();) {
            String remainingStr = str.substring(i);

            Boolean appendChar = true;

            // Check for empty paired punctuation
            for (String pairStart : puncutationPairs.keySet()) {
                String pairEnd = puncutationPairs.get(pairStart);
                if (remainingStr.startsWith(pairStart)) {
                    Integer depth = 0;
                    Integer closeIndx = -1;
                    // Find index of closing punctuation pair
                    for (Integer j = i + 1; j < str.length(); j++) {
                        String nextStr = str.substring(j);
                        if (nextStr.startsWith(pairStart))
                            depth += 1;
                        else if (nextStr.startsWith(pairEnd))
                            depth -= 1;
                        // found close puncutation
                        if (depth == -1) {
                            closeIndx = j;
                            break;
                        }
                    }
                    if (closeIndx == -1) {
                        break; // could not find end for this punctuation pair, that's fine I guess
                    } else {
                        // We now know the end index of pair punctuation section, check if empty in between
                        String containedString = str.substring(i, closeIndx + 1);
                        // Is this string all empty characters
                        Boolean empty = emptyRegexPattern.matcher(containedString).matches();
                        // contained only empty characters
                        if (empty) {
                            appendChar = false;
                            i = closeIndx + 1;
                            break;
                        }
                    }
                }
            }

            if (appendChar) {
                cleanStr += str.substring(i, i + 1);
                i += 1;
            } else {
                // do nothing, we have already the pointer to wherever it needs to be
            }
        }

        return cleanStr;
    }

    /**
     * Finds and remove excess punctuation marks (and excess whitespace) as well as fixes space-puncuation ordering
     * For example, with an input of "Mr .,Thomas   Nordman" it fixes the excess puncutation of ".,", removes the
     * excess spaces between Thomas and Nordman, and reorders the space and puncuation between Mr and Thoams.
     * The result is "Mr. Thomas Nordman"
     *
     * @param str The input string
     * @return A string with an extra whitespaces trimmed and
     */
    public String cleanExcessPuncutationsAndWhitespace(String str) {
        String cleanStr = '';

        // Need punctuation and whitespace list for checking emptiness
        Set<String> puncAndSpaces = getPunctuationAndWhitespacesSet();
        // Look for excess punctuation
        for (Integer i = 0; i < str.length();) {
            String nextChar = str.substring(i, i + 1);
            Boolean appendChar = true;

            // Looking at punctuation?
            if (puncAndSpaces.contains(nextChar)) {
                Integer puncLength = 1;
                // how many more characters of puncutation after this one?
                for (Integer c : str.substring(i + 1).getChars()) {
                    String nextChar2 = String.fromCharArray(new List<Integer>{ c });
                    if (puncAndSpaces.contains(nextChar2))
                        puncLength += 1;
                    else
                        break;
                }

                if (puncLength > 1) {
                    // always trim this to [PUNCTUATION] [SPACE] or [PUNCTUATION] or [SPACE]
                    String firstPunc = null, firstWhitespace = null;

                    for (Integer c : str.substring(i, i + puncLength).getChars()) {
                        String s = String.fromCharArray(new List<Integer>{ c });
                        if (whitespaceList.contains(s) && firstWhitespace == null)
                            firstWhitespace = s;
                        else if (
                            (innerPuncutationList.contains(s) || endPuncutationList.contains(s)) && firstPunc == null
                        )
                            firstPunc = s;
                        if (firstWhitespace != null && firstPunc != null)
                            break;
                    }

                    // replace with trimmed versions
                    if (firstPunc != null)
                        cleanStr += firstPunc;
                    if (firstWhitespace != null)
                        cleanStr += firstWhitespace;

                    // Move cursor to after replaced contents
                    i += puncLength;
                    appendChar = false;
                } else if (puncLength == 1) {
                    // no need to modify
                }
            }

            if (appendChar) {
                cleanStr += nextChar;
                i += 1;
            }
        }

        return cleanStr;
    }

    /**
     * Removes leading and trailing whitespaces and punctuation marks. The only exception is that leaves in
     * trailing punctuation if it is endPuncutation (usually this excalamation mark, question mark, period, etc)
     *
     * @param str The input string
     * @return A string with trailing an leading punctuation (and whitespace) stripped out
     */
    public String cleanLeadingAndTrailingPunctuation(String str) {
        String cleanStr = str;
        Set<String> puncAndSpaces = getPunctuationAndWhitespacesSet();

        // And cleanup any leading or trailing punctuation
        // ... except for end punctuation, allow those to trail
        Integer indexOfLastNonPunc = null, indexOfFirstNonPunc = null;
        for (Integer i = 0; i < str.length(); i++) {
            String nextChar = str.substring(i, i + 1);

            // move pointers for alphanumeric characters
            if (!puncAndSpaces.contains(nextChar)) {
                indexOfLastNonPunc = i;
                if (indexOfFirstNonPunc == null)
                    indexOfFirstNonPunc = i;
            }
            // also move index for last if it is end punctuation
            if (endPuncutationList.contains(nextChar))
                indexOfLastNonPunc = i;
        }

        // Cut off leading and trialing punctuation
        if (indexOfFirstNonPunc != null && indexOfLastNonPunc != null) {
            cleanStr = cleanStr.substring(indexOfFirstNonPunc, indexOfLastNonPunc + 1);
        } else if (indexOfFirstNonPunc != null) {
            cleanStr = cleanStr.substring(indexOfFirstNonPunc);
        } else if (indexOfLastNonPunc != null) {
            cleanStr = cleanStr.substring(0, indexOfLastNonPunc + 1);
        } else {
            // no leading or trailing to remove
        }

        return cleanStr;
    }

    /**
     * A Regex Pattern object.  This pattern is a pattern containing any amount of "empty"
     * characters (empty as in whitespace and punctuation, all synatx with no semantic meaning).
     */
    private Pattern getEmptyRegexPattern() {
        // All non characters (these can be collapsed to one or none characters)
        Set<String> emptyChars = new Set<String>();
        for (String s : innerPuncutationList)
            emptyChars.add(s);
        for (String s : endPuncutationList)
            emptyChars.add(s);
        for (String s : puncutationPairs.keySet()) {
            emptyChars.add(s);
            emptyChars.add(puncutationPairs.get(s));
        }
        for (String s : whitespaceList)
            emptyChars.add(s);

        String emptyRegexPatternStr = '';
        if (!emptyChars.isEmpty()) {
            emptyRegexPatternStr += '[';
            for (String s : emptyChars)
                emptyRegexPatternStr += StringRegexHelper.escapeCharsForPattern(s);
            emptyRegexPatternStr += ']*';
        }

        return Pattern.compile(emptyRegexPatternStr);
    }

    /**
     * The Set for all the non paired punctuation marks and whitepsace
     */
    private Set<String> getPunctuationAndWhitespacesSet() {
        Set<String> puncAndSpaces = new Set<String>();
        for (String s : innerPuncutationList)
            puncAndSpaces.add(s);
        for (String s : endPuncutationList)
            puncAndSpaces.add(s);
        for (String s : whitespaceList)
            puncAndSpaces.add(s);
        return puncAndSpaces;
    }
}
