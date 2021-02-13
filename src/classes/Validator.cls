public without sharing class Validator {
    private static String prefix; // Used to minimize describe calls

    /**
     * Validate supplied string is a legitimate email address
     *
     * @param String Email address that needs validation
     * @return Boolean True if the email address is valid, false otherwise
     */
    public static Boolean validateEmail(String emailToValidate) {
        if (emailToValidate != null) {
            String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
            Pattern emaiLPattern = Pattern.compile(emailRegex);
            Matcher emailMatcher = emaiLPattern.matcher(emailToValidate);

            if (emailMatcher.matches()) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    /**
     * Validate supplied string is a legitimate record Id
     *
     * <p>
     * Note: This method may return true incorrectly if no prefix
     * is set.
     * </p>
     *
     * @param String Id that needs validation
     * @return Boolean True if the Id is valid, false otherwise
     */
    public static Boolean validateId(String idToValidate) {
        if (idToValidate != null) {
            idToValidate = String.escapeSingleQuotes(idToValidate);
            Pattern idPattern = Pattern.compile('^[a-zA-Z0-9]*$');
            Matcher idMatcher = idPattern.matcher(idToValidate);

            if (idMatcher.matches() && (idToValidate.length() == 15 || idToValidate.length() == 18)) {
                if (prefix != null) {
                    if (idToValidate.left(3) == prefix) {
                        return true;
                    } else {
                        return false;
                    }
                } else {
                    return true;
                }
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    /**
     * Validate supplied string is a legitimate record Id for the given SObject.
     *
     * <p>
     * Provides a shortHand way of passing an ID and a type without needing to call
     * setPrefix seperately. Useful for quick validations. Should be avoid if repeated
     * validations are needed.
     * </p>
     *
     * @param String Id that needs validation
     * @param SObject an SObject of the desired type
     * @return Boolean True if the Id is valid, false otherwise
     */
    public static Boolean validateId(String idToValidate, Type t) {
        if (idToValidate != null && t != null) {
            setPrefix(t);

            return validateId(idToValidate);
        } else {
            return false;
        }
    }

    /**
     * Validate supplied string is a legitimate empl ID
     */
    public static Boolean validateEMPLId(String idToValidate) {
        if (idToValidate != null) {
            idToValidate = String.escapeSingleQuotes(idToValidate);
            Pattern idPattern = Pattern.compile('^\\d{10}$');
            Matcher idMatcher = idPattern.matcher(idToValidate);

            return idMatcher.matches();
        } else {
            return false;
        }
    }

    /**
     * Sets the expected prefix of any ids passed to the validator.
     *
     * @param String the 3 letter key prefix
     */
    public static void setPrefix(String s) {
        if (s.length() == 3) {
            prefix = s;
        }
    }

    /**
     * Sets the expected prefix of any ids passed to the validator.
     *
     * @param SObject An instance of the type of SObject that the ID should
     * be compared to. Use this in triggers where you have an existing object to pass
     */
    public static void setPrefix(SObject s) {
        setPrefix(ObjectService.getKeyPrefix(s.getSObjectType()));
    }

    /**
     * Sets the expected prefix of any ids passed to the validator
     *
     * @param Type a generic type of an SObject (Case.class). Use this when you do not
     * have an existing instance of the object. For example, when validating URL parameters.
     */
    public static void setPrefix(Type t) {
        setPrefix((SObject) t.newInstance());
    }
}
