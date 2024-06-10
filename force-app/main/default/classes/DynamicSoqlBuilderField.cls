/**
 A helper class for the two types of fields that the DynamicSoqlBuilder needs support for.

 We have simple relationships, such as direct fields, or the fields of related objects.
 These are simple since they can be treated as strings for the most part.

 And we have more complex fields (subqueries) which look at child records. These require
 the usage of the DynamicSoqlBuilder to build the subquery.

 */

public abstract class DynamicSoqlBuilderField {
    public class SimpleField extends DynamicSoqlBuilderField {
        String field;
        public SimpleField(String field) {
            this.field = field;
        }

        public override String toString() {
            return field;
        }
    }

    public class Subquery extends DynamicSoqlBuilderField {
        DynamicSoqlBuilder subquery;

        public Subquery(DynamicSoqlBuilder subquery) {
            this.subquery = subquery;
        }

        public override String toString() {
            return '(' + subquery.toString() + ')';
        }
    }
}
