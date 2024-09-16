/**
 This class is a tool for building dynamic SOQL queries.
 Often when writing dyanmic SOQL one of the main challenges is making sure to keep everything in the proper order,
 to escape the correct characters, to handle typing.  This only gets more challenging once you start introducting
 binds or if you want to convert lists to their string equilvalent.

 This class helps abstract away some of those complexities, offering an easy interface for writing dyanmic SOQL
 queries.

 The basic usage is the you specify the sobject type, a list of fields to return, and then a list of Restrictions 
 to apply (filters).  Then by calling the .query() function, the class converts you instructions into the proper SOQL
 query, runs it with the specified permissions, and returns the records requested.

 This class supports returning fields (Name), lookup subfields (Owner.Name), as well as running subqueries (SELECT Cases ...)

 As for restrictions, all restriction types defined in the DynamicSoqlBuilderRestriction class are available. You can either
 add restrictions using the retrictEqual, restrictIn, restrictLessThan, etc. functions, which add a list of restrictions which
 are then AND-ed together to generate the SOQL query.  Or if, you need to create complex restrictions, you can use the restrict
 function and create Restrictions directly by calling the relevant DynamicSoqlBuilderRestriction constructors.

 Some examples of restriction types supported include:
    = :var
    = TRUE
    LIKE '%'++'%'
    IN :var
    IN ('o1', 'o2')
    IN (3, 4, 5)
    IN (SELECT Id FROM Contact WHERE...)
    > TODAY
    <= LAST_WEEK

 * keep in mind that binds (which start with colon :), as well as keywords like TODAY or LAST_WEEK, require the use of their
 respective DynamicSoqlBuilderRestriction.Bind and DynamicSoqlBuilderRestriction.Keyword classes - as any strings are assumed
 to be simple strings that need to be properly escaped in the generated SOQL.

 */

public inherited sharing class DynamicSoqlBuilder {
    String objectType;
    List<DynamicSoqlBuilderField> fields = new List<DynamicSoqlBuilderField>();
    Map<String, Object> bindMap = new Map<String, Object>();
    List<DynamicSoqlBuilderRestriction> restrictions = new List<DynamicSoqlBuilderRestriction>();
    Integer queryLimit = null;
    Integer queryOffset = null;
    String queryOrderBy = null;
    String queryGroupBy = null;
    List<String> queryHaving = new List<String>();
    Boolean pluralizeObjectType = false;

    public DynamicSoqlBuilder(String objectType) {
        this.objectType = objectType;
    }
    public DynamicSoqlBuilder(Schema.DescribeSObjectResult objectType) {
        this.objectType = objectType.getName();
    }

    public DynamicSoqlBuilder returnField(String fieldName) {
        fields.add(new DynamicSoqlBuilderField.SimpleField(fieldName));
        return this;
    }
    public DynamicSoqlBuilder returnField(Schema.DescribeFieldResult field) {
        return returnField(field.getName());
    }
    public DynamicSoqlBuilder returnField(DynamicSoqlBuilder subquery) {
        subquery.pluralize(true);
        // if this subquery is returned as a field, then it needs to be pluralized
        // rather than "SELECT Id FROM Case ..." it will be "SELECT Id FROM Cases"
        // as in "SELECT Id, Name, (SELECT Id FROM Cases) FROM Contact..."
        Map<String, Object> subqueryBindMap = subquery.getBinds();
        for (String key : subqueryBindMap.keySet())
            if (!this.hasBind(key))
                this.bind(key, subqueryBindMap.get(key));
        fields.add(new DynamicSoqlBuilderField.Subquery(subquery));
        return this;
    }

    public DynamicSoqlBuilder restrictEqual(String field, String value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.EqualRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictEqual(Schema.DescribeFieldResult field, String value) {
        return restrictEqual(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictEqual(String field, Boolean value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.EqualRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictEqual(Schema.DescribeFieldResult field, Boolean value) {
        return restrictEqual(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictEqual(String field, Decimal value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.EqualRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictEqual(Schema.DescribeFieldResult field, Decimal value) {
        return restrictEqual(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictEqual(String field, Datetime value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.EqualRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictEqual(Schema.DescribeFieldResult field, Datetime value) {
        return restrictEqual(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictEqual(String field, Date value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.EqualRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictEqual(Schema.DescribeFieldResult field, Date value) {
        return restrictEqual(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictEqual(String field, DynamicSoqlBuilderRestriction.Bind value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.EqualRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictEqual(
        Schema.DescribeFieldResult field,
        DynamicSoqlBuilderRestriction.Bind value
    ) {
        return restrictEqual(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictEqual(String field, DynamicSoqlBuilderRestriction.Keyword value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.EqualRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictEqual(
        Schema.DescribeFieldResult field,
        DynamicSoqlBuilderRestriction.Keyword value
    ) {
        return restrictEqual(field.getName(), value);
    }

    public DynamicSoqlBuilder restrictNotEqual(String field, String value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.NotEqualRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictNotEqual(Schema.DescribeFieldResult field, String value) {
        return restrictNotEqual(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictNotEqual(String field, Boolean value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.NotEqualRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictNotEqual(Schema.DescribeFieldResult field, Boolean value) {
        return restrictNotEqual(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictNotEqual(String field, Decimal value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.NotEqualRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictNotEqual(Schema.DescribeFieldResult field, Decimal value) {
        return restrictNotEqual(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictNotEqual(String field, Datetime value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.NotEqualRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictNotEqual(Schema.DescribeFieldResult field, Datetime value) {
        return restrictNotEqual(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictNotEqual(String field, Date value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.NotEqualRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictNotEqual(Schema.DescribeFieldResult field, Date value) {
        return restrictNotEqual(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictNotEqual(String field, DynamicSoqlBuilderRestriction.Bind value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.NotEqualRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictNotEqual(
        Schema.DescribeFieldResult field,
        DynamicSoqlBuilderRestriction.Bind value
    ) {
        return restrictNotEqual(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictNotEqual(String field, DynamicSoqlBuilderRestriction.Keyword value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.NotEqualRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictNotEqual(
        Schema.DescribeFieldResult field,
        DynamicSoqlBuilderRestriction.Keyword value
    ) {
        return restrictNotEqual(field.getName(), value);
    }

    public DynamicSoqlBuilder restrictLessThanOrEqual(String field, String value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.LessThanOrEqualRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictLessThanOrEqual(Schema.DescribeFieldResult field, String value) {
        return restrictLessThanOrEqual(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictLessThanOrEqual(String field, Decimal value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.LessThanOrEqualRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictLessThanOrEqual(Schema.DescribeFieldResult field, Decimal value) {
        return restrictLessThanOrEqual(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictLessThanOrEqual(String field, Datetime value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.LessThanOrEqualRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictLessThanOrEqual(Schema.DescribeFieldResult field, Datetime value) {
        return restrictLessThanOrEqual(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictLessThanOrEqual(String field, Date value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.LessThanOrEqualRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictLessThanOrEqual(Schema.DescribeFieldResult field, Date value) {
        return restrictLessThanOrEqual(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictLessThanOrEqual(String field, DynamicSoqlBuilderRestriction.Bind value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.LessThanOrEqualRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictLessThanOrEqual(
        Schema.DescribeFieldResult field,
        DynamicSoqlBuilderRestriction.Bind value
    ) {
        return restrictLessThanOrEqual(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictLessThanOrEqual(String field, DynamicSoqlBuilderRestriction.Keyword value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.LessThanOrEqualRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictLessThanOrEqual(
        Schema.DescribeFieldResult field,
        DynamicSoqlBuilderRestriction.Keyword value
    ) {
        return restrictLessThanOrEqual(field.getName(), value);
    }

    public DynamicSoqlBuilder restrictGreaterThanOrEqual(String field, String value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.GreaterThanOrEqualRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictGreaterThanOrEqual(Schema.DescribeFieldResult field, String value) {
        return restrictGreaterThanOrEqual(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictGreaterThanOrEqual(String field, Decimal value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.GreaterThanOrEqualRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictGreaterThanOrEqual(Schema.DescribeFieldResult field, Decimal value) {
        return restrictGreaterThanOrEqual(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictGreaterThanOrEqual(String field, Datetime value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.GreaterThanOrEqualRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictGreaterThanOrEqual(Schema.DescribeFieldResult field, Datetime value) {
        return restrictGreaterThanOrEqual(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictGreaterThanOrEqual(String field, Date value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.GreaterThanOrEqualRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictGreaterThanOrEqual(Schema.DescribeFieldResult field, Date value) {
        return restrictGreaterThanOrEqual(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictGreaterThanOrEqual(String field, DynamicSoqlBuilderRestriction.Bind value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.GreaterThanOrEqualRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictGreaterThanOrEqual(
        Schema.DescribeFieldResult field,
        DynamicSoqlBuilderRestriction.Bind value
    ) {
        return restrictGreaterThanOrEqual(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictGreaterThanOrEqual(String field, DynamicSoqlBuilderRestriction.Keyword value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.GreaterThanOrEqualRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictGreaterThanOrEqual(
        Schema.DescribeFieldResult field,
        DynamicSoqlBuilderRestriction.Keyword value
    ) {
        return restrictGreaterThanOrEqual(field.getName(), value);
    }

    public DynamicSoqlBuilder restrictLessThan(String field, String value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.LessThanRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictLessThan(Schema.DescribeFieldResult field, String value) {
        return restrictLessThan(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictLessThan(String field, Decimal value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.LessThanRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictLessThan(Schema.DescribeFieldResult field, Decimal value) {
        return restrictLessThan(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictLessThan(String field, Datetime value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.LessThanRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictLessThan(Schema.DescribeFieldResult field, Datetime value) {
        return restrictLessThan(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictLessThan(String field, Date value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.LessThanRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictLessThan(Schema.DescribeFieldResult field, Date value) {
        return restrictLessThan(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictLessThan(String field, DynamicSoqlBuilderRestriction.Bind value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.LessThanRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictLessThan(
        Schema.DescribeFieldResult field,
        DynamicSoqlBuilderRestriction.Bind value
    ) {
        return restrictLessThan(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictLessThan(String field, DynamicSoqlBuilderRestriction.Keyword value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.LessThanRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictLessThan(
        Schema.DescribeFieldResult field,
        DynamicSoqlBuilderRestriction.Keyword value
    ) {
        return restrictLessThan(field.getName(), value);
    }

    public DynamicSoqlBuilder restrictGreaterThan(String field, String value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.GreaterThanRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictGreaterThan(Schema.DescribeFieldResult field, String value) {
        return restrictGreaterThan(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictGreaterThan(String field, Decimal value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.GreaterThanRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictGreaterThan(Schema.DescribeFieldResult field, Decimal value) {
        return restrictGreaterThan(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictGreaterThan(String field, Datetime value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.GreaterThanRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictGreaterThan(Schema.DescribeFieldResult field, Datetime value) {
        return restrictGreaterThan(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictGreaterThan(String field, Date value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.GreaterThanRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictGreaterThan(Schema.DescribeFieldResult field, Date value) {
        return restrictGreaterThan(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictGreaterThan(String field, DynamicSoqlBuilderRestriction.Bind value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.GreaterThanRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictGreaterThan(
        Schema.DescribeFieldResult field,
        DynamicSoqlBuilderRestriction.Bind value
    ) {
        return restrictGreaterThan(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictGreaterThan(String field, DynamicSoqlBuilderRestriction.Keyword value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.GreaterThanRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictGreaterThan(
        Schema.DescribeFieldResult field,
        DynamicSoqlBuilderRestriction.Keyword value
    ) {
        return restrictGreaterThan(field.getName(), value);
    }

    public DynamicSoqlBuilder restrictLike(String field, String value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.LikeRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictLike(Schema.DescribeFieldResult field, String value) {
        return restrictLike(field.getName(), value);
    }

    public DynamicSoqlBuilder restrictIn(String field, List<String> value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.InRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictIn(Schema.DescribeFieldResult field, List<String> value) {
        return restrictIn(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictIn(String field, List<Decimal> value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.InRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictIn(Schema.DescribeFieldResult field, List<Decimal> value) {
        return restrictIn(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictIn(String field, List<Datetime> value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.InRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictIn(Schema.DescribeFieldResult field, List<Datetime> value) {
        return restrictIn(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictIn(String field, List<Date> value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.InRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictIn(Schema.DescribeFieldResult field, List<Date> value) {
        return restrictIn(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictIn(String field, DynamicSoqlBuilderRestriction.Bind value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.InRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictIn(Schema.DescribeFieldResult field, DynamicSoqlBuilderRestriction.Bind value) {
        return restrictIn(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictIn(String field, DynamicSoqlBuilder subquery) {
        Map<String, Object> subqueryBindMap = subquery.getBinds();
        for (String key : subqueryBindMap.keySet())
            if (!this.hasBind(key))
                this.bind(key, subqueryBindMap.get(key));
        restrictions.add(
            new DynamicSoqlBuilderRestriction.InRestriction(field, new DynamicSoqlBuilderRestriction.Subquery(subquery))
        );
        return this;
    }
    public DynamicSoqlBuilder restrictIn(Schema.DescribeFieldResult field, DynamicSoqlBuilder value) {
        return restrictIn(field.getName(), value);
    }

    public DynamicSoqlBuilder restrictNotIn(String field, List<String> value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.NotInRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictNotIn(Schema.DescribeFieldResult field, List<String> value) {
        return restrictNotIn(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictNotIn(String field, List<Decimal> value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.NotInRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictNotIn(Schema.DescribeFieldResult field, List<Decimal> value) {
        return restrictNotIn(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictNotIn(String field, List<Datetime> value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.NotInRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictNotIn(Schema.DescribeFieldResult field, List<Datetime> value) {
        return restrictNotIn(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictNotIn(String field, List<Date> value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.NotInRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictNotIn(Schema.DescribeFieldResult field, List<Date> value) {
        return restrictNotIn(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictNotIn(String field, DynamicSoqlBuilderRestriction.Bind value) {
        restrictions.add(new DynamicSoqlBuilderRestriction.NotInRestriction(field, value));
        return this;
    }
    public DynamicSoqlBuilder restrictNotIn(
        Schema.DescribeFieldResult field,
        DynamicSoqlBuilderRestriction.Bind value
    ) {
        return restrictNotIn(field.getName(), value);
    }
    public DynamicSoqlBuilder restrictNotIn(String field, DynamicSoqlBuilder subquery) {
        Map<String, Object> subqueryBindMap = subquery.getBinds();
        for (String key : subqueryBindMap.keySet())
            if (!this.hasBind(key))
                this.bind(key, subqueryBindMap.get(key));
        restrictions.add(
            new DynamicSoqlBuilderRestriction.NotInRestriction(
                field,
                new DynamicSoqlBuilderRestriction.Subquery(subquery)
            )
        );
        return this;
    }
    public DynamicSoqlBuilder restrictNotIn(Schema.DescribeFieldResult field, DynamicSoqlBuilder value) {
        return restrictNotIn(field.getName(), value);
    }

    public DynamicSoqlBuilder restrict(DynamicSoqlBuilderRestriction restriction) {
        restrictions.add(restriction);
        return this;
    }

    /**
     * Checks if the current query has any restrictions applied
     */
    public Boolean isRestricted() {
        return !restrictions.isEmpty();
    }

    /** Set the generated soql to pluralize the object type
     * this is used to support generating subqueries when looking at child objects
     * i.e.
     * SELECT Id, (Id, Subject FROM Cases) FROM Contact
     * However, pluralization defaults to false, since usually it is not needed
     */
    public DynamicSoqlBuilder pluralize(Boolean pluralize) {
        this.pluralizeObjectType = pluralize;
        return this;
    }

    /**
     * Set a limit on number of records returned by the query
     */
    public DynamicSoqlBuilder setLimit(Integer count) {
        this.queryLimit = count;
        return this;
    }

    /**
     * Set an offset for the query
     */
    public DynamicSoqlBuilder setOffset(Integer count) {
        this.queryOffset = count;
        return this;
    }

    /**
     * Set an order by for the query
     */
    public DynamicSoqlBuilder setOrder(String str) {
        this.queryOrderBy = str;
        return this;
    }

    /**
     * Set a GROUP BY clause by for the query
     */
    public DynamicSoqlBuilder setGroupBy(String str) {
        this.queryGroupBy = str;
        return this;
    }

    /**
     * Add a string based having clause
     */
    public DynamicSoqlBuilder addHaving(String str) {
        this.queryHaving.add(str);
        return this;
    }

    /**
     * Bind a variable to a value for the query
     */
    public DynamicSoqlBuilder bind(String key, Object value) {
        bindMap.put(key, value);
        return this;
    }

    /**
     * Check if a key already has a bind or not
     */
    public Boolean hasBind(String key) {
        return bindMap.containsKey(key);
    }

    /**
     * Get the bind map (usually used to copy key-values from a subquery into a parent query)
     */
    public Map<String, Object> getBinds() {
        return bindMap;
    }

    /**
     * Perform the query
     */
    public List<SObject> query() {
        return query(AccessLevel.SYSTEM_MODE);
    }

    /**
     * Perform the query using a specific access level
     */
    public List<SObject> query(System.AccessLevel accessLevel) {
        LogSuite.logUntuncated('query', 'DynamicSoqlBuilder QUERY STRING');
        LogSuite.logUntuncated('query', toString());
        LogSuite.logUntuncated('query', 'DynamicSoqlBuilder BIND MAP');
        LogSuite.logUntuncated('query', bindMap.toString());
        LogSuite.logUntuncated('query', 'DynamicSoqlBuilder ACCESS LEVEL');
        LogSuite.logUntuncated('query', accessLevel.toString());

        return Database.queryWithBinds(toString(), bindMap, accessLevel);
    }

    /**
     * String representation of the query
     */
    public override String toString() {
        List<String> fieldStrs = new List<String>();
        for (Object fld : fields) {
            fieldStrs.add(fld.toString());
        }

        String queryStr =
            'SELECT ' +
            String.join(fieldStrs, ', ') +
            ' FROM ' +
            objectType +
            (pluralizeObjectType ? 's' : '');

        if (!restrictions.isEmpty()) {
            queryStr += ' WHERE ' + new DynamicSoqlBuilderRestriction.AndRestriction(restrictions).toString();
        }

        if (queryGroupBy != null)
            queryStr += ' GROUP BY ' + queryGroupBy;

        if (!queryHaving.isEmpty()) {
            queryStr += ' HAVING ' + String.join(queryHaving, ' AND ');
        }

        if (queryOrderBy != null)
            queryStr += ' ORDER BY ' + queryOrderBy;
        if (queryLimit != null)
            queryStr += ' LIMIT ' + queryLimit;
        if (queryOffset != null)
            queryStr += ' OFFSET ' + queryOffset;

        return queryStr;
    }

    class DynamicSoqlBuilderException extends Exception {
    }
}
