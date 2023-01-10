public class JSONObject {
    private Map<String, Object> mp;

    public JSONObject() {
        mp = new Map<String, Object>();
    }
    public JSONObject(Map<String, Object> existingMp) {
        mp = existingMp;
    }
    public JSONObject(String jsonStr) {
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

            // Create JSONObject for next level down and call .put recursively
            JSONObject nextLevelObj = new JSONObject(nextLevelMp);
            nextLevelObj.put(removeFirstStep(path), obj);
        } else {
            // Final step

            String step = path;

            if (stepIsArray(step)) {
                // This step is an array, so we we to move into the array at the right index
                String stepKey = extractKeyFromStep(step);
                Integer stepIndx = extractIndxFromStep(step);

                List<Object> stepArray = (List<Object>) (mp.get(stepKey));
                padList(stepArray, stepIndx); // pad list if needed to ensure specified index exist

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
                // Create JSONObject for next level down and call .get recursively
                JSONObject nextLevelObj = new JSONObject(nextLevelMp);
                obj = nextLevelObj.get(removeFirstStep(path));
            }
        } else {
            // Final step

            String step = path;

            if (stepIsArray(step)) {
                // This step is an array, so we we to move into the array at the right index
                String stepKey = extractKeyFromStep(step);
                Integer stepIndx = extractIndxFromStep(step);
                List<Object> stepArray;

                if (!mp.containsKey(stepKey)) {
                    obj = null;
                } else {
                    stepArray = (List<Object>) (mp.get(stepKey));
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

    private static void padList(List<Object> ls, Integer indx) {
        if (indx >= ls.size()) {
            ls.add(null);
        }
    }
    private static Boolean hasDepth(String path) {
        return path.contains('.');
    }
    private static String extractFirstStep(String path) {
        return path.split('\\.')[0];
    }
    private static String removeFirstStep(String path) {
        List<String> pathArr = path.split('\\.');
        pathArr.remove(0);
        return String.join(pathArr, '.');
    }
    private static Boolean stepIsArray(String step) {
        return step.contains('[') && step.contains('[') && step.indexOf('[') < step.indexOf(']');
    }
    private static Integer extractIndxFromStep(String step) {
        return stepIsArray(step) ? Integer.valueOf(step.substringBetween('[', ']')) : null;
    }
    private static String extractKeyFromStep(String step) {
        return step.substringBefore('[');
    }

    public class JSONTypeException extends Exception {
    }
}