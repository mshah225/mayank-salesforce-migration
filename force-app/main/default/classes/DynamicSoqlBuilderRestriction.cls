/**
 Restriction (filter) types used by the DynamicSoqlBuilder.

 Most often, restrictions are added using the DynamicSoqlBuilder's method which avoid the need for the consumer to directly call
 the constructors in this file - however, in order to support more complex restrictions, they ARE allowed to call the constructors
 directly.

 Too add support for new object types, you must both define how to stringify it (in stringifyValue), as well as add support
 in the constructors that can use that type.

 Currently the is support for Strings, Numbers, Booleans, Lists (of those types), binds (variable binds), keywords 
 (SOQL-specific keywords like TODAY), and subqueries.

 Some times are only valid with certain Restrictions (you cannot mix a list type with the Equal restriction).
 
 */

public abstract class DynamicSoqlBuilderRestriction {
    public DynamicSoqlBuilderRestriction() {
    }

    /**
     * Simple Restrictions is the parent class for all restrictions that are applied to a single field
     */
    public virtual class SimpleRestriction extends DynamicSoqlBuilderRestriction {
        String field;
        Object value;

        public SimpleRestriction(String field, Object value) {
            this.field = field;
            this.value = value;
        }
    }

    /**
     * Complex Restrictions are used once we need to create AND and ORs - or if we need to negate entire clauses.
     */
    public virtual class ComplexRestriction extends DynamicSoqlBuilderRestriction {
        String operation;
        List<DynamicSoqlBuilderRestriction> restrictions;
        public ComplexRestriction(String operation, List<DynamicSoqlBuilderRestriction> restrictions) {
            this.operation = operation;
            this.restrictions = restrictions;
        }

        public Boolean isNotEmpty() {
            return !restrictions.isEmpty();
        }
    }

    /**
     * Take an object and stringify its value for usage by the DynamicSoqlBuilder
     * this is primarily used by the restriction generators in order to convert various
     * object formats into something SOQL will ingest.
     */
    private static String stringifyValue(Object value) {
        String stringVal;
        if (value == null) {
            stringVal = 'NULL';
        } else if (value instanceof Bind) {
            stringVal = ':' + ((Bind) value).toString();
        } else if (value instanceof Keyword) {
            stringVal = ((Keyword) value).toString();
        } else if (value instanceof Subquery) {
            stringVal = '(' + ((Subquery) value).toString() + ')';
        } else if (value instanceof Date) {
            // Date has no equilvalent to .format(format: String)
            // get component values
            Date value_date = (Date) value;
            Integer year = value_date.year();
            Integer month = value_date.month();
            Integer day = value_date.day();
            // pad as needed
            String year_str = String.valueOf(year);
            String month_str = month >= 10 ? String.valueOf(month) : '0' + String.valueOf(month);
            String day_str = day >= 10 ? String.valueOf(day) : '0' + String.valueOf(day);
            // construct string of date
            stringVal = year_str + '-' + month_str + '-' + day_str;
        } else if (value instanceof Datetime) {
            stringVal = ((Datetime) value).formatGmt('yyyy-MM-dd\'T\'HH:mm:ssZ');
        } else if (value instanceof String) {
            stringVal = '\'' + ((String) value).replace('\'', '\\\'') + '\'';
        } else if (value instanceof Decimal) {
            stringVal = ((Decimal) value).toPlainString();
        } else if (value instanceof Boolean) {
            stringVal = ((Boolean) value) ? 'TRUE' : 'FALSE';
        } else if (value instanceof List<Object>) {
            List<String> stringValues = new List<String>();
            for (Object obj : (List<Object>) value)
                stringValues.add(stringifyValue(obj));
            stringVal = '(' + String.join(stringValues, ', ') + ')';
        } else {
            throw new DynamicSoqlBuilderRestrictionException(
                'Invalid value type for Restriction - Supported types: String, Decimal, Boolean, Bind, Keyword, Datetime, Date, (the value null), and lists of those types'
            );
        }
        return stringVal;
    }

    /**
     * The Bind class is used whenever you want to bind a variable in the generated SOQL to a variable by name
     * it results in SOQL that looks like:
     *   SELECT Id FROM Contact WHERE FirstName = :bindVarName
     */
    public class Bind {
        String key;
        public Bind(String key) {
            this.key = key;
        }
        public override String toString() {
            return key;
        }
    }

    /**
     * The Keyword class is used whenever you want to restrict a variable in the generated SOQL to a SOQL-specific keyword
     * it results in SOQL that looks like:
     *   SELECT Id FROM Contact WHERE FirstName = keywordName
     * You might use these to restrict date ranges using keywords like TODAY:
     *   SELECT Id FROM Contact WHERE CreatedDate >= TODAY
     */
    public class Keyword {
        String key;
        public Keyword(String key) {
            this.key = key;
        }
        public override String toString() {
            return key;
        }
    }

    /**
     * The Subquery class is used whenever you want to restrict a field based on the results of a SOQL query.
     * Keep in mind Salesforce has a low governor limit on this type of behavior (2 semi-joins per query),
     * you are responsible for not dynamically generating SOQL queries that exceed this limit
     */
    public class Subquery {
        DynamicSoqlBuilder subquery;

        public Subquery(DynamicSoqlBuilder subquery) {
            this.subquery = subquery;
        }

        public override String toString() {
            return subquery.toString();
        }
    }

    /**
     * Restriction type for filter on the EQUALS (=) operation
     */
    public class EqualRestriction extends SimpleRestriction {
        public EqualRestriction(String field, Bind value) {
            super(field, value);
        }
        public EqualRestriction(String field, Keyword value) {
            super(field, value);
        }
        public EqualRestriction(String field, Datetime value) {
            super(field, value);
        }
        public EqualRestriction(String field, Date value) {
            super(field, value);
        }
        public EqualRestriction(String field, String value) {
            super(field, value);
        }
        public EqualRestriction(String field, Decimal value) {
            super(field, value);
        }
        public EqualRestriction(String field, Boolean value) {
            super(field, value);
        }

        public override String toString() {
            String restrictStr = field + ' = ' + stringifyValue(value);
            return restrictStr;
        }
    }

    /**
     * Restriction type for filter on the NOT EQUALS (!=) operation
     */
    public class NotEqualRestriction extends SimpleRestriction {
        public NotEqualRestriction(String field, Bind value) {
            super(field, value);
        }
        public NotEqualRestriction(String field, Keyword value) {
            super(field, value);
        }
        public NotEqualRestriction(String field, Datetime value) {
            super(field, value);
        }
        public NotEqualRestriction(String field, Date value) {
            super(field, value);
        }
        public NotEqualRestriction(String field, String value) {
            super(field, value);
        }
        public NotEqualRestriction(String field, Decimal value) {
            super(field, value);
        }
        public NotEqualRestriction(String field, Boolean value) {
            super(field, value);
        }

        public override String toString() {
            String restrictStr = field + ' != ' + stringifyValue(value);
            return restrictStr;
        }
    }

    /**
     * Restriction type for filter on the GREATER THAN (>) operation
     */
    public class GreaterThanRestriction extends SimpleRestriction {
        public GreaterThanRestriction(String field, Bind value) {
            super(field, value);
        }
        public GreaterThanRestriction(String field, Keyword value) {
            super(field, value);
        }
        public GreaterThanRestriction(String field, Datetime value) {
            super(field, value);
        }
        public GreaterThanRestriction(String field, Date value) {
            super(field, value);
        }
        public GreaterThanRestriction(String field, String value) {
            super(field, value);
        }
        public GreaterThanRestriction(String field, Decimal value) {
            super(field, value);
        }

        public override String toString() {
            String restrictStr = field + ' > ' + stringifyValue(value);
            return restrictStr;
        }
    }

    /**
     * Restriction type for filter on the GREATER THAN OR EQUAL (>=) operation
     */
    public class GreaterThanOrEqualRestriction extends SimpleRestriction {
        public GreaterThanOrEqualRestriction(String field, Bind value) {
            super(field, value);
        }
        public GreaterThanOrEqualRestriction(String field, Keyword value) {
            super(field, value);
        }
        public GreaterThanOrEqualRestriction(String field, Datetime value) {
            super(field, value);
        }
        public GreaterThanOrEqualRestriction(String field, Date value) {
            super(field, value);
        }
        public GreaterThanOrEqualRestriction(String field, String value) {
            super(field, value);
        }
        public GreaterThanOrEqualRestriction(String field, Decimal value) {
            super(field, value);
        }

        public override String toString() {
            String restrictStr = field + ' >= ' + stringifyValue(value);
            return restrictStr;
        }
    }

    /**
     * Restriction type for filter on the LESS THAN (<) operation
     */
    public class LessThanRestriction extends SimpleRestriction {
        public LessThanRestriction(String field, Bind value) {
            super(field, value);
        }
        public LessThanRestriction(String field, Keyword value) {
            super(field, value);
        }
        public LessThanRestriction(String field, Datetime value) {
            super(field, value);
        }
        public LessThanRestriction(String field, Date value) {
            super(field, value);
        }
        public LessThanRestriction(String field, String value) {
            super(field, value);
        }
        public LessThanRestriction(String field, Decimal value) {
            super(field, value);
        }

        public override String toString() {
            String restrictStr = field + ' < ' + stringifyValue(value);
            return restrictStr;
        }
    }

    /**
     * Restriction type for filter on the LESS THAN OR EQUAL (<=) operation
     */
    public class LessThanOrEqualRestriction extends SimpleRestriction {
        public LessThanOrEqualRestriction(String field, Bind value) {
            super(field, value);
        }
        public LessThanOrEqualRestriction(String field, Keyword value) {
            super(field, value);
        }
        public LessThanOrEqualRestriction(String field, Datetime value) {
            super(field, value);
        }
        public LessThanOrEqualRestriction(String field, Date value) {
            super(field, value);
        }
        public LessThanOrEqualRestriction(String field, String value) {
            super(field, value);
        }
        public LessThanOrEqualRestriction(String field, Decimal value) {
            super(field, value);
        }

        public override String toString() {
            String restrictStr = field + ' <= ' + stringifyValue(value);
            return restrictStr;
        }
    }

    /**
     * Restriction type for filter on the IN operation
     */
    public class InRestriction extends SimpleRestriction {
        public InRestriction(String field, List<Datetime> value) {
            super(field, value);
        }
        public InRestriction(String field, List<Date> value) {
            super(field, value);
        }
        public InRestriction(String field, List<String> value) {
            super(field, value);
        }
        public InRestriction(String field, List<Decimal> value) {
            super(field, value);
        }
        public InRestriction(String field, List<Boolean> value) {
            super(field, value);
        }

        public InRestriction(String field, Bind value) {
            super(field, value);
        }

        public InRestriction(String field, Subquery value) {
            super(field, value);
        }

        public override String toString() {
            String restrictStr;
            String valueList = stringifyValue(value);

            if (valueList == '()')
                restrictStr = field + ' = NULL';
            else
                restrictStr = field + ' IN ' + valueList;

            return restrictStr;
        }
    }

    /**
     * Restriction type for filter on the NOT IN operation
     */
    public class NotInRestriction extends SimpleRestriction {
        public NotInRestriction(String field, List<Datetime> value) {
            super(field, value);
        }
        public NotInRestriction(String field, List<Date> value) {
            super(field, value);
        }
        public NotInRestriction(String field, List<String> value) {
            super(field, value);
        }
        public NotInRestriction(String field, List<Decimal> value) {
            super(field, value);
        }
        public NotInRestriction(String field, List<Boolean> value) {
            super(field, value);
        }

        public NotInRestriction(String field, Bind value) {
            super(field, value);
        }

        public NotInRestriction(String field, Subquery value) {
            super(field, value);
        }

        public override String toString() {
            String restrictStr;
            String valueList = stringifyValue(value);

            if (valueList == '()')
                restrictStr = field + ' != NULL';
            else
                restrictStr = field + ' NOT IN ' + valueList;

            return restrictStr;
        }
    }

    /**
     * Restriction type for filter on the LIKE operation
     */
    public class LikeRestriction extends SimpleRestriction {
        public LikeRestriction(String field, String value) {
            super(field, value);
        }

        public override String toString() {
            String restrictStr = field + ' LIKE ' + stringifyValue(value);
            return restrictStr;
        }
    }

    /**
     * Restriction type for AND-ing mutliple Restrictions together
     */
    public class AndRestriction extends ComplexRestriction {
        public AndRestriction() {
            super('AND', new List<DynamicSoqlBuilderRestriction>());
        }
        public AndRestriction(List<DynamicSoqlBuilderRestriction> restrictions) {
            super('AND', restrictions);
        }

        public AndRestriction add(DynamicSoqlBuilderRestriction restrict) {
            restrictions.add(restrict);
            return this;
        }

        public override String toString() {
            List<String> restrictionStrings = new List<String>();
            for (DynamicSoqlBuilderRestriction restriction : restrictions)
                if (restriction instanceof ComplexRestriction)
                    restrictionStrings.add('(' + restriction.toString() + ')');
                else
                    restrictionStrings.add(restriction.toString());
            return String.join(restrictionStrings, ' ' + operation + ' ');
        }
    }

    /**
     * Restriction type for OR-ing mutliple Restrictions together
     */
    public class OrRestriction extends ComplexRestriction {
        public OrRestriction() {
            super('OR', new List<DynamicSoqlBuilderRestriction>());
        }
        public OrRestriction(List<DynamicSoqlBuilderRestriction> restrictions) {
            super('OR', restrictions);
        }

        public OrRestriction add(DynamicSoqlBuilderRestriction restrict) {
            restrictions.add(restrict);
            return this;
        }

        public override String toString() {
            List<String> restrictionStrings = new List<String>();
            for (DynamicSoqlBuilderRestriction restriction : restrictions)
                if (restriction instanceof ComplexRestriction)
                    restrictionStrings.add('(' + restriction.toString() + ')');
                else
                    restrictionStrings.add(restriction.toString());
            return String.join(restrictionStrings, ' ' + operation + ' ');
        }
    }

    /**
     * Restriction type for negating a restriction using NOT
     */
    public class NotRestriction extends ComplexRestriction {
        public NotRestriction(DynamicSoqlBuilderRestriction restriction) {
            super('NOT', new List<DynamicSoqlBuilderRestriction>{ restriction });
        }

        public override String toString() {
            return operation + '(' + restrictions[0].toString() + ')';
        }
    }

    public class DynamicSoqlBuilderRestrictionException extends Exception {
    }
}
