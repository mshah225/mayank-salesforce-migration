public class OrderedMapStringToString {
    public Map<String, String> mapping = new Map<String, String>();
    public List<String> keyInsertOrder = new List<String>();

    public OrderedMapStringToString() {
    }

    public void clear() {
        mapping.clear();
        keyInsertOrder.clear();
    }

    public Boolean containsKey(String key) {
        return mapping.containsKey(key);
    }

    public Boolean equals(Object arg0) {
        return this === arg0;
    }

    public String get(String key) {
        return mapping.get(key);
    }

    public Integer hashCode() {
        return mapping.hashCode();
    }

    public Boolean isEmpty() {
        return mapping.isEmpty();
    }

    public Set<String> keySet() {
        return mapping.keySet();
    }

    public List<String> keyList() {
        return new List<String>(keyInsertOrder);
    }

    public void put(String key, String val) {
        mapping.put(key, val);
        if (!keyInsertOrder.contains(key))
            keyInsertOrder.add(key);
    }

    public void putAll(Map<String, String> fromMapping) {
        for (String key : fromMapping.keySet()) {
            put(key, fromMapping.get(key));
        }
    }

    public String remove(String key) {
        String removed = mapping.remove(key);
        if (keyInsertOrder.contains(key))
            keyInsertOrder.remove(keyInsertOrder.indexOf(key));

        return removed;
    }

    public Integer size() {
        return mapping.size();
    }

    override public String toString() {
        return mapping.toString();
    }

    public List<String> values() {
        List<String> orderedValues = new List<String>();
        for (String key : keyInsertOrder)
            orderedValues.add(mapping.get(key));
        return orderedValues;
    }

    public List<LabelValue> getOrderedList() {
        List<LabelValue> labelValList = new List<LabelValue>();
        for (String key : keyList()) {
            String val = get(key);
            labelValList.add(new LabelValue(key, val));
        }
        return labelValList;
    }

    public class LabelValue {
        public String label;
        public String value;

        public LabelValue(String lab, String val) {
            label = lab;
            value = val;
        }
    }
}