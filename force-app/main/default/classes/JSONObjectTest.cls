@isTest
public class JSONObjectTest {
    @isTest
    public static void testIntegerValues() {
        JSONObject jsObj = new JSONObject();
        jsObj.put('finalYear', 2000);
        jsObj.put('currentYear', 2053);
        jsObj.put('currentYear', 1943);

        String expectedJSON = JSON.serialize(JSON.deserializeUntyped('{"finalYear":2000,"currentYear":1943}'));

        System.assertEquals(2000, jsObj.get('finalYear'));
        System.assertEquals(1943, jsObj.get('currentYear'));

        System.assertEquals(expectedJSON, jsObj.serialize());
    }

    @isTest
    public static void testBooleanValues() {
        JSONObject jsObj = new JSONObject();
        jsObj.put('hasDogs', false);
        jsObj.put('hasCats', false);
        jsObj.put('hasCats', true);

        String expectedJSON = JSON.serialize(JSON.deserializeUntyped('{"hasDogs":false,"hasCats":true}'));

        System.assertEquals(false, jsObj.get('hasDogs'));
        System.assertEquals(true, jsObj.get('hasCats'));

        System.assertEquals(expectedJSON, jsObj.serialize());
    }

    @isTest
    public static void testDoubleValues() {
        JSONObject jsObj = new JSONObject();
        jsObj.put('creditLimit', 3000.0);
        jsObj.put('balance', 1200.5);
        jsObj.put('balance', 1830.8);

        String expectedJSON = JSON.serialize(JSON.deserializeUntyped('{"creditLimit":3000.0,"balance":1830.8}'));

        System.assertEquals(3000.0, jsObj.get('creditLimit'));
        System.assertEquals(1830.8, jsObj.get('balance'));

        System.assertEquals(expectedJSON, jsObj.serialize());
    }

    @isTest
    public static void testStringValues() {
        JSONObject jsObj = new JSONObject();
        jsObj.put('firstName', 'Quentin');
        jsObj.put('lastName', 'Quigley');
        jsObj.put('lastName', 'Barlowe');

        String expectedJSON = JSON.serialize(JSON.deserializeUntyped('{"firstName":"Quentin","lastName":"Barlowe"}'));

        System.assertEquals('Quentin', jsObj.get('firstName'));
        System.assertEquals('Barlowe', jsObj.get('lastName'));

        System.assertEquals(expectedJSON, jsObj.serialize());
    }

    @isTest
    public static void testDeeperPaths() {
        JSONObject jsObj = new JSONObject();
        jsObj.put('name.first', 'Quentin');
        jsObj.put('name.last', 'Quigley');
        jsObj.put('name.last', 'Barlowe');

        String expectedJSON = JSON.serialize(JSON.deserializeUntyped('{"name":{"first":"Quentin","last":"Barlowe"}}'));

        System.assertEquals('Quentin', jsObj.get('name.first'));
        System.assertEquals('Barlowe', jsObj.get('name.last'));

        System.assertEquals(expectedJSON, jsObj.serialize());
    }

    @isTest
    public static void testArrays() {
        JSONObject jsObj = new JSONObject();
        jsObj.put('people[0].firstname', 'Anthony');
        jsObj.put('people[0].lastname', 'Partridge');
        jsObj.put('people[1].firstname', 'Sally');
        jsObj.put('people[1].lastname', 'Grissom');
        jsObj.put('people[2].firstname', 'Petra');
        jsObj.put('people[2].lastname', '27');

        String expectedJSON = JSON.serialize(
            JSON.deserializeUntyped(
                '{"people":[{"firstname":"Anthony","lastname":"Partridge"},{"firstname":"Sally","lastname":"Grissom"},{"firstname":"Petra","lastname":"27"}]}'
            )
        );

        System.assertEquals('Anthony', jsObj.get('people[0].firstname'));
        System.assertEquals('Partridge', jsObj.get('people[0].lastname'));
        System.assertEquals('Sally', jsObj.get('people[1].firstname'));
        System.assertEquals('Grissom', jsObj.get('people[1].lastname'));
        System.assertEquals('Petra', jsObj.get('people[2].firstname'));
        System.assertEquals('27', jsObj.get('people[2].lastname'));

        System.assertEquals(expectedJSON, jsObj.serialize());
    }

    @isTest
    public static void testLayeredArrays() {
        JSONObject jsObj = new JSONObject();
        jsObj.put('people[0][0]', 'Anthony');
        jsObj.put('people[0][1]', 'Partridge');
        jsObj.put('people[1][0]', 'Sally');
        jsObj.put('people[1][1]', 'Grissom');
        jsObj.put('people[2][0]', 'Petra');
        jsObj.put('people[2][1]', '27');

        String expectedJSON = JSON.serialize(
            JSON.deserializeUntyped('{"people":[["Anthony","Partridge"],["Sally","Grissom"],["Petra","27"]]}')
        );

        System.assertEquals('Anthony', jsObj.get('people[0][0]'));
        System.assertEquals('Partridge', jsObj.get('people[0][1]'));
        System.assertEquals('Sally', jsObj.get('people[1][0]'));
        System.assertEquals('Grissom', jsObj.get('people[1][1]'));
        System.assertEquals('Petra', jsObj.get('people[2][0]'));
        System.assertEquals('27', jsObj.get('people[2][1]'));

        System.assertEquals(expectedJSON, jsObj.serialize());
    }

    @isTest
    public static void testMixedObjAndArrays() {
        JSONObject jsObj = new JSONObject();
        jsObj.put('people.seasons[0][0].first', 'Anthony');
        jsObj.put('people.seasons[0][0].last', 'Partridge');
        jsObj.put('people.seasons[0][1].first', 'Sally');
        jsObj.put('people.seasons[0][1].last', 'Grissom');
        jsObj.put('people.seasons[1][0].first', 'Anthony');
        jsObj.put('people.seasons[1][0].last', 'Partridge');
        jsObj.put('people.seasons[1][1].first', 'Sally');
        jsObj.put('people.seasons[1][1].last', 'Grissom');
        jsObj.put('people.seasons[2][0].first', 'Anthony');
        jsObj.put('people.seasons[2][0].last', 'Partridge');
        jsObj.put('people.seasons[2][1].first', 'Sally');
        jsObj.put('people.seasons[2][1].last', 'Grissom');
        jsObj.put('people.seasons[2][2].first', 'Petra');
        jsObj.put('people.seasons[2][2].last', '27');

        String expectedJSON = JSON.serialize(
            JSON.deserializeUntyped(
                '{"people":{"seasons":[[{"first":"Anthony","last":"Partridge"},{"first":"Sally","last":"Grissom"}],[{"first":"Anthony","last":"Partridge"},{"first":"Sally","last":"Grissom"}],[{"first":"Anthony","last":"Partridge"},{"first":"Sally","last":"Grissom"},{"first":"Petra","last":"27"}]]}}'
            )
        );

        System.assertEquals('Anthony', jsObj.get('people.seasons[0][0].first'));
        System.assertEquals('Partridge', jsObj.get('people.seasons[0][0].last'));
        System.assertEquals('Sally', jsObj.get('people.seasons[0][1].first'));
        System.assertEquals('Grissom', jsObj.get('people.seasons[0][1].last'));
        System.assertEquals('Anthony', jsObj.get('people.seasons[1][0].first'));
        System.assertEquals('Partridge', jsObj.get('people.seasons[1][0].last'));
        System.assertEquals('Sally', jsObj.get('people.seasons[1][1].first'));
        System.assertEquals('Grissom', jsObj.get('people.seasons[1][1].last'));
        System.assertEquals('Anthony', jsObj.get('people.seasons[2][0].first'));
        System.assertEquals('Partridge', jsObj.get('people.seasons[2][0].last'));
        System.assertEquals('Sally', jsObj.get('people.seasons[2][1].first'));
        System.assertEquals('Grissom', jsObj.get('people.seasons[2][1].last'));
        System.assertEquals('Petra', jsObj.get('people.seasons[2][2].first'));
        System.assertEquals('27', jsObj.get('people.seasons[2][2].last'));

        System.assertEquals(expectedJSON, jsObj.serialize());
    }

    @isTest
    public static void testGettingNonexistant() {
        JSONObject jsObj = new JSONObject();

        String expectedJSON = '{}';

        System.assertEquals(null, jsObj.get('numberOfPeople'));
        System.assertEquals(null, jsObj.get('people'));
        System.assertEquals(null, jsObj.get('people[0]'));
        System.assertEquals(null, jsObj.get('people[1]'));
        System.assertEquals(null, jsObj.get('people[2]'));
        System.assertEquals(null, jsObj.get('people[0].name'));
        System.assertEquals(null, jsObj.get('people[0].name.first'));
        System.assertEquals(null, jsObj.get('people[0].name.last'));
        System.assertEquals(null, jsObj.get('resources[0][1][3].name.last'));

        System.assertEquals(expectedJSON, jsObj.serialize());
    }
}