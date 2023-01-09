public class JSONObject extends CanSerialize {
    public Map<String, CanSerialize> mp;

    public JSONObject() {
        mp = new Map<String, CanSerialize>();
    }

    public JSONObject getLookup(String key) {
        Object obj = mp.get(key);
        if (!(obj instanceof JSONObject))
            throw new JSONTypeException('Expected ' + key + ' to map to a JSONObject, but it didn\'t.');

        return (JSONObject) obj;
    }
    public String getString(String key) {
        Object obj = mp.get(key);
        if (!(obj instanceof JSONString))
            throw new JSONTypeException('Expected ' + key + ' to map to a JSONString, but it didn\'t.');

        return ((JSONString) obj).val;
    }
    public Integer getInteger(String key) {
        Object obj = mp.get(key);
        if (!(obj instanceof JSONInteger))
            throw new JSONTypeException('Expected ' + key + ' to map to a JSONInteger, but it didn\'t.');

        return ((JSONInteger) obj).val;
    }
    public Double getDouble(String key) {
        Object obj = mp.get(key);
        if (!(obj instanceof JSONDouble))
            throw new JSONTypeException('Expected ' + key + ' to map to a JSONDouble, but it didn\'t.');

        return ((JSONDouble) obj).val;
    }
    public Boolean getBoolean(String key) {
        Object obj = mp.get(key);
        if (!(obj instanceof JSONBoolean))
            throw new JSONTypeException('Expected ' + key + ' to map to a JSONBoolean, but it didn\'t.');

        return ((JSONBoolean) obj).val;
    }
    public JSONList getList(String key) {
        Object obj = mp.get(key);
        if (!(obj instanceof JSONList))
            throw new JSONTypeException('Expected ' + key + ' to map to a JSONList, but it didn\'t.');

        return (JSONList) obj;
    }

    public void put(String path, Object obj) {
        if (path.contains('.')) {
            List<String> pathAndKey = path.split('\\.');
            String key = pathAndKey[pathAndKey.size() - 1]; // key is final item
            pathAndKey.remove(pathAndKey.size() - 1); // remove key from path
            path = String.join(pathAndKey, '.'); // remake path

            setAtPath(path, key, obj);
        } else {
            setAtPath(null, path, obj);
        }
    }

    private void setAtPath(String path, String key, Object obj) {
        JSONObject route = this;

        // Traverse path if specified
        if (path != null && path != '') {
            List<String> steps = path.split('\\.'); // split by . to traverse down key path

            // Traverse path, creating objects where needed
            for (String step : steps) {
                if (!route.hasKey(step))
                    route.set(step, new JSONObject());
                route = route.getLookup(step);
            }
        }

        // At the end of the path, insert at specified key
        if (obj instanceof String)
            route.set(key, (String) obj);
        else if (obj instanceof Integer)
            route.set(key, (Integer) obj);
        else if (obj instanceof Double)
            route.set(key, (Double) obj);
        else if (obj instanceof Boolean)
            route.set(key, (Boolean) obj);
        else if (obj instanceof JSONList)
            route.set(key, (JSONList) obj);
        else if (obj instanceof JSONObject)
            route.set(key, (JSONObject) obj);
        else
            throw new JSONTypeException('This object type is not supported.');
    }

    private void set(String key, JSONObject val) {
        mp.put(key, val);
    }
    private void set(String key, String val) {
        mp.put(key, new JSONString(val));
    }
    private void set(String key, Integer val) {
        mp.put(key, new JSONInteger(val));
    }
    private void set(String key, Boolean val) {
        mp.put(key, new JSONBoolean(val));
    }
    private void set(String key, Double val) {
        mp.put(key, new JSONDouble(val));
    }
    private void set(String key, JSONList val) {
        mp.put(key, val);
    }

    public Boolean hasKey(String key) {
        return mp.containsKey(key);
    }

    public override String serialize() {
        String serialized = '{';

        List<String> serializedAttributes = new List<String>();
        for (String key : mp.keySet()) {
            serializedAttributes.add('"' + key + '":' + mp.get(key).serialize());
        }
        serialized += String.join(serializedAttributes, ',');

        serialized += '}';

        return serialized;
    }

    /**
     * A wrapper class around Strings to provide the .serialize() interface.
     * Should to be used in the JSONObject class whenever the object contains a String value.
     */
    public class JSONString extends CanSerialize {
        public JSONString(String val) {
            this.val = val;
        }
        public override String serialize() {
            return JSON.serialize(val);
        }

        public String val;
    }

    /**
     * A wrapper class around Integers to provide the .serialize() interface.
     * Should to be used in the JSONObject class whenever the object contains a Integer value.
     */
    public class JSONInteger extends CanSerialize {
        public JSONInteger(Integer val) {
            this.val = val;
        }
        public override String serialize() {
            return JSON.serialize(val);
        }

        public Integer val;
    }

    /**
     * A wrapper class around Doubles to provide the .serialize() interface.
     * Should to be used in the JSONObject class whenever the object contains a Double value.
     */
    public class JSONDouble extends CanSerialize {
        public JSONDouble(Double val) {
            this.val = val;
        }
        public override String serialize() {
            return JSON.serialize(val);
        }

        public Double val;
    }

    /**
     * A wrapper class around Booleans to provide the .serialize() interface.
     * Should to be used in the JSONObject class whenever the object contains a Boolean value.
     */
    public class JSONBoolean extends CanSerialize {
        public JSONBoolean(Boolean val) {
            this.val = val;
        }
        public override String serialize() {
            return JSON.serialize(val);
        }

        public Boolean val;
    }

    /**
     * A wrapper class around Lists to provide the .serialize() interface.
     * Should to be used in the JSONObject class whenever the object contains a List value.
     */
    public class JSONList extends CanSerialize {
        public JSONList(List<String> vals) {
            List<JSONString> jsonVals = new List<JSONString>();
            for (String val : vals) {
                jsonVals.add(new JSONString(val));
            }

            this.val = jsonVals;
        }
        public JSONList(List<Integer> vals) {
            List<JSONInteger> jsonVals = new List<JSONInteger>();
            for (Integer val : vals) {
                jsonVals.add(new JSONInteger(val));
            }

            this.val = jsonVals;
        }
        public JSONList(List<Double> vals) {
            List<JSONDouble> jsonVals = new List<JSONDouble>();
            for (Double val : vals) {
                jsonVals.add(new JSONDouble(val));
            }

            this.val = jsonVals;
        }
        public JSONList(List<Boolean> vals) {
            List<JSONBoolean> jsonVals = new List<JSONBoolean>();
            for (Boolean val : vals) {
                jsonVals.add(new JSONBoolean(val));
            }

            this.val = jsonVals;
        }
        public JSONList(List<JSONObject> vals) {
            this.val = vals;
        }
        public override String serialize() {
            String serialized = '[';

            List<String> serializedItems = new List<String>();
            for (CanSerialize item : val) {
                serializedItems.add(item.serialize());
            }
            serialized += String.join(serializedItems, ',');

            serialized += ']';

            return serialized;
        }

        public List<CanSerialize> val;
    }

    /**
     * This can get thrown whenever you ask the JSON object to get a specific type but the expected type is wrong.
     */
    public class JSONTypeException extends Exception {
    }
}