/**
 * Utility class for interacting with JSON.  This class automatically adds the needed arrays and object maps as you descend
 * into the JSON object.  So long as you are consistent and don't suddenly treat an array field as an object, it should be
 * A-OK.
 *
 * This should essentially match the built-in JSON.serialize/deserialize and JS's JSON.stringify/parse functionality, with some extra
 * magic on top to automatically build the object as needed.
 *
 * Basically this lets you do stuff like .put('people[0].name.first', 'Robert') where the JSONObject class figures out that the people is an array,
 * and the first element of the array has a field call name, which has a field called first, which is equal to Robert. This saves you from needing
 * to create a map, and then another map, and then a list, and then another map to build up your object before serializing it.
 * Equilvalent JSON: {people:[{name:{first:"Robert"}}]}
 */
public class JSONObject {
    JSONObjectNonRooted mp;
    Boolean rootIsAnArray = false;
    Boolean rootIsAnObject = false;
    Boolean rootIsASimpleValue = false;

    public JSONObject() {
        // New object
        mp = new JSONObjectNonRooted();
    }
    public JSONObject(Map<String, Object> existingMp) {
        // New object
        Map<String, Object> rootChild = new Map<String, Object>();
        rootChild.put('root', existingMp);
        mp = new JSONObjectNonRooted(rootChild);
        // There is an object at the root
        rootIsAnObject = true;
    }
    public JSONObject(String jsonStr) {
        mp = new JSONObjectNonRooted();
        Object jsonObj = JSON.deserializeUntyped(jsonStr);
        mp.put('root', jsonObj);

        // Set flags about what we have an the root
        rootIsAnArray = jsonObj instanceof List<Object>;
        rootIsASimpleValue = isSimpleObject(jsonObj);
        rootIsAnObject = !rootIsAnArray && !rootIsASimpleValue;
    }

    public void put(String path, Object obj) {
        // If the type is still unknown, determine it now
        if (!rootIsAnArray && !rootIsAnObject && !rootIsASimpleValue) {
            if (path.startsWith('['))
                rootIsAnArray = true;
            else if (path == '' || path == null)
                rootIsASimpleValue = true;
            else
                rootIsAnObject = true;
        }

        // Depending on type, effects how to query the element
        if (rootIsAnArray)
            mp.put('root' + path, obj);
        if (rootIsAnObject)
            mp.put('root.' + path, obj);
        if (rootIsASimpleValue)
            mp.put('root', obj);
    }

    public Object get(String path) {
        Object obj = null;
        // Depending on type, effects how to query the element
        if (rootIsAnArray)
            obj = mp.get('root' + path);
        if (rootIsAnObject)
            obj = mp.get('root.' + path);
        if (rootIsASimpleValue)
            obj = mp.get('root');
        return obj;
    }

    public String serialize() {
        return JSON.serialize(mp.get('root'));
    }

    /**
     * The meat of the JSONObject is handled below.  It's primary weakness is that it can't handle non-object items, so JSON
     * where the root is an array or simple object would break it.  So JSONObject wraps around this object and adds a root
     * element that everything else then falls under (thus circumventing this limitation).
     */
    public class JSONObjectNonRooted {
        private Map<String, Object> mp;

        public JSONObjectNonRooted() {
            mp = new Map<String, Object>();
        }
        public JSONObjectNonRooted(Map<String, Object> existingMp) {
            mp = existingMp;
        }
        public JSONObjectNonRooted(String jsonStr) {
            mp = new Map<String, Object>();
            mp = (Map<String, Object>) JSON.deserializeUntyped(jsonStr);
        }

        public void put(String path, Object obj) {
            if (hasDepth(path)) {
                // Not at the deepest level yet, need to traverse down

                String step = extractFirstStep(path);
                Map<String, Object> nextLevelMp;

                if (stepIsArray(step)) {
                    // This step is an array, so we we to move into the array at the right index
                    String stepKey = extractKeyFromStep(step);
                    Integer stepIndx = extractIndxFromStep(step);

                    // Create array if there isn't one already
                    if (!mp.containsKey(stepKey))
                        mp.put(stepKey, new List<Object>());

                    List<Object> stepArray = (List<Object>) (mp.get(stepKey));
                    padList(stepArray, stepIndx); // pad list if needed to ensure specified index exist

                    // Handle layer arrays
                    if (stepIsLayeredArray(step)) {
                        String indicesStr = step.substring(step.indexOf('[') + 1, step.lastIndexOf(']'));
                        List<String> indicesArr = indicesStr.split('\\]\\[');

                        for (Integer i = 0; i < indicesArr.size() - 1; i++) {
                            // -1 bc final layer is the object we are put-ing, don't need to traverse it only need to reach it

                            // If that position in the array is currently null, create the needed object
                            if (stepArray[stepIndx] == null)
                                stepArray[stepIndx] = new List<Object>();

                            stepArray = (List<Object>) stepArray[stepIndx]; // move into next level deep
                            stepIndx = Integer.valueOf(indicesArr[i + 1]); // get the next indice for that level
                            padList(stepArray, stepIndx); // pad list if needed to ensure specified index exist
                        }
                    }

                    // If that position in the array is currently null, create the needed object
                    if (stepArray[stepIndx] == null)
                        stepArray[stepIndx] = new Map<String, Object>();

                    nextLevelMp = (Map<String, Object>) (stepArray[stepIndx]);
                } else {
                    // Get the next level down

                    // Create object if there isn't one already
                    if (!mp.containsKey(step))
                        mp.put(step, new Map<String, Object>());

                    nextLevelMp = (Map<String, Object>) (mp.get(step));
                }

                // Create JSONObjectNonRooted for next level down and call .put recursively
                JSONObjectNonRooted nextLevelObj = new JSONObjectNonRooted(nextLevelMp);
                nextLevelObj.put(removeFirstStep(path), obj);
            } else {
                // Final step

                String step = path;

                if (stepIsArray(step)) {
                    // This step is an array, so we we to move into the array at the right index
                    String stepKey = extractKeyFromStep(step);
                    Integer stepIndx = extractIndxFromStep(step);

                    // Create array if there isn't one already
                    if (!mp.containsKey(stepKey))
                        mp.put(stepKey, new List<Object>());

                    List<Object> stepArray = (List<Object>) (mp.get(stepKey));
                    padList(stepArray, stepIndx); // pad list if needed to ensure specified index exist

                    // Handle layer arrays
                    if (stepIsLayeredArray(step)) {
                        String indicesStr = step.substring(step.indexOf('[') + 1, step.lastIndexOf(']'));
                        List<String> indicesArr = indicesStr.split('\\]\\[');

                        for (Integer i = 0; i < indicesArr.size() - 1; i++) {
                            // -1 bc final layer is the object we are put-ing, don't need to traverse it only need to reach it

                            // If that position in the array is currently null, create the needed object
                            if (stepArray[stepIndx] == null)
                                stepArray[stepIndx] = new List<Object>();

                            stepArray = (List<Object>) stepArray[stepIndx]; // move into next level deep
                            stepIndx = Integer.valueOf(indicesArr[i + 1]); // get the next indice for that level
                            padList(stepArray, stepIndx); // pad list if needed to ensure specified index exist
                        }
                    }

                    stepArray[stepIndx] = obj;
                } else {
                    // This step is an object, so we can just set in the map
                    mp.put(step, obj);
                }
            }
        }

        public Object get(String path) {
            Object obj = null;

            if (hasDepth(path)) {
                // Not at the deepest level yet, need to traverse down

                String step = extractFirstStep(path);
                Map<String, Object> nextLevelMp;

                if (stepIsArray(step)) {
                    // This step is an array, so we we to move into the array at the right index
                    String stepKey = extractKeyFromStep(step);
                    Integer stepIndx = extractIndxFromStep(step);

                    if (!mp.containsKey(stepKey)) {
                        nextLevelMp = null;
                    } else {
                        List<Object> stepArray = (List<Object>) (mp.get(stepKey));

                        // Handle layer arrays
                        if (stepIsLayeredArray(step)) {
                            String indicesStr = step.substring(step.indexOf('[') + 1, step.lastIndexOf(']'));
                            List<String> indicesArr = indicesStr.split('\\]\\[');

                            for (Integer i = 0; i < indicesArr.size() - 1; i++) {
                                // -1 bc final layer is the object we are put-ing, don't need to traverse it only need to reach it

                                // Can't go deep enough into array - sucks, too bad
                                if (stepIndx >= stepArray.size()) {
                                    nextLevelMp = null;
                                    break;
                                }

                                stepArray = (List<Object>) stepArray[stepIndx]; // move into next level deep
                                stepIndx = Integer.valueOf(indicesArr[i + 1]); // get the next indice for that level
                            }
                        }

                        nextLevelMp = stepIndx >= stepArray.size() ? null : (Map<String, Object>) (stepArray[stepIndx]);
                    }
                } else {
                    // Get the next level down
                    nextLevelMp = (Map<String, Object>) (mp.get(step));
                }

                if (nextLevelMp == null) {
                    // The next level doesn't exist
                    obj = null;
                } else {
                    // Create JSONObjectNonRooted for next level down and call .get recursively
                    JSONObjectNonRooted nextLevelObj = new JSONObjectNonRooted(nextLevelMp);
                    obj = nextLevelObj.get(removeFirstStep(path));
                }
            } else {
                // Final step

                String step = path;

                if (stepIsArray(step)) {
                    // This step is an array, so we we to move into the array at the right index
                    String stepKey = extractKeyFromStep(step);
                    Integer stepIndx = extractIndxFromStep(step);

                    if (!mp.containsKey(stepKey)) {
                        obj = null;
                    } else {
                        List<Object> stepArray = (List<Object>) (mp.get(stepKey));

                        // Handle layer arrays
                        if (stepIsLayeredArray(step)) {
                            String indicesStr = step.substring(step.indexOf('[') + 1, step.lastIndexOf(']'));
                            List<String> indicesArr = indicesStr.split('\\]\\[');

                            for (Integer i = 0; i < indicesArr.size() - 1; i++) {
                                // -1 bc final layer is the object we are put-ing, don't need to traverse it only need to reach it

                                // Can't go deep enough into array - sucks, too bad
                                if (stepIndx >= stepArray.size()) {
                                    obj = null;
                                    break;
                                }

                                stepArray = (List<Object>) stepArray[stepIndx]; // move into next level deep
                                stepIndx = Integer.valueOf(indicesArr[i + 1]); // get the next indice for that level
                            }
                        }

                        obj = stepIndx >= stepArray.size() ? null : stepArray[stepIndx];
                    }
                } else {
                    // This step is an object, so we can just get from the map
                    obj = mp.get(step);
                }
            }

            return obj;
        }

        public String serialize() {
            return JSON.serialize(mp);
        }

        private void padList(List<Object> ls, Integer indx) {
            if (indx >= ls.size()) {
                ls.add(null);
            }
        }
        private Boolean hasDepth(String path) {
            return path.contains('.');
        }
        private String extractFirstStep(String path) {
            return path.split('\\.')[0];
        }
        private String removeFirstStep(String path) {
            List<String> pathArr = path.split('\\.');
            pathArr.remove(0);
            return String.join(pathArr, '.');
        }
        private Boolean stepIsArray(String step) {
            return step.contains('[') && step.contains(']') && step.indexOf('[') < step.indexOf(']');
        }
        private Boolean stepIsLayeredArray(String step) {
            return stepIsArray(step) &&
                step.lastIndexOf('[') != step.indexOf('[') &&
                step.lastIndexOf(']') != step.indexOf(']');
        }
        private Integer extractIndxFromStep(String step) {
            return stepIsArray(step) ? Integer.valueOf(step.substringBetween('[', ']')) : null;
        }
        private String extractKeyFromStep(String step) {
            return step.substringBefore('[');
        }
    }

    /**
     * Checks an object to see if it is a simple type as permitted by JSON
     * (i.e. String, Number, Boolean, or null)
     *
     * @param obj The object in question
     *
     * @return True if the object is a simple object
     */
    private static Boolean isSimpleObject(Object obj) {
        return obj instanceof String ||
            obj instanceof Integer ||
            obj instanceof Double ||
            obj instanceof Boolean ||
            obj == null;
    }

    public class JSONTypeException extends Exception {
    }
}