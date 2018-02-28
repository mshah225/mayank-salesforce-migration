public abstract class TestFactory {
    private static final Boolean USE_NEW_RECORD_ID = false;
    private static final Boolean IS_DEEP_CLONE = true;
    private static final Boolean RESET_TIMESTAMPS = false;
    private static final Boolean USE_NEW_AUTONUMBERS = false;
    private static Integer incrementingCounter;
    private Map<String, List<Sobject>> fieldNameToRelatedObjects;
    private List<String> fieldNamesToIncrement;
    private Sobject newObject;
    protected Sobject template;
    
    public TestFactory(Sobject template) {
        incrementingCounter = 1;
        this.template = template;
        fieldNameToRelatedObjects = new Map<String, List<Sobject>>();
        fieldNamesToIncrement = new List<String>();
    }
    
    public void setRelatedObject(String fieldName, Sobject relatedTo) {
        setRelatedObject(fieldName, new List<Sobject> {relatedTo});
    }
    
    public void setRelatedObject(String fieldName, List<Sobject> relatedTo) {
        fieldNameToRelatedObjects.put(fieldName, relatedTo);
    }
    
    public void addToFieldsToIncrement(String fieldName) {
        addToFieldsToIncrement(new List<String>{fieldName});
    }
    
    public void addToFieldsToIncrement(List<String> fieldNames) {
        fieldNamesToIncrement.addAll(fieldNames);
    }
    
    public List<Sobject> create() {
        return create(1); 
    }
    
    public List<Sobject> create(Integer numberToCreate) {
        List<Sobject> createdTestObjects = new List<Sobject>();
        for (Integer index = 0; index < numberToCreate; index ++) {
            createNewObject(index);
            createdTestObjects.add(newObject);
        }
        return createdTestObjects;
    }
    
    private void createNewObject(Integer currentIndex) {
        createObjectFromTemplate();
        setNewObjectRelatedObjectFields(currentIndex);
        incrementNewObjectFieldsAndCounter();
    }
    
    private void createObjectFromTemplate() {
        newObject = template.clone(USE_NEW_RECORD_ID, IS_DEEP_CLONE, RESET_TIMESTAMPS, USE_NEW_AUTONUMBERS);
    }
    
    private void setNewObjectRelatedObjectFields(Integer currentIndex) {
        for (String fieldName : fieldNameToRelatedObjects.keySet()) {
            List<Sobject> relatedObjects = fieldNameToRelatedObjects.get(fieldName);
            Sobject interleavedRelatedObject = relatedObjects.get(Math.mod(currentIndex, relatedObjects.size()));
            newObject.put(fieldName, interleavedRelatedObject.Id);
        }
    }
    
    private void incrementNewObjectFieldsAndCounter() {
        for (String fieldName : fieldNamesToIncrement) {
            String incrementedField = newObject.get(fieldName) + '' + incrementingCounter;
            newObject.put(fieldName, incrementedField);
        }
        incrementingCounter ++;
    }
}