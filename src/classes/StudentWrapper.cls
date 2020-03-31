public class StudentWrapper {
    @AuraEnabled
    public List<StudentFieldWrapper> fieldDetailsResult {get; set;}
    @AuraEnabled
    public List<Contact> students {get; set;}
    @AuraEnabled
    public Set<User> coaches {get; set;}
    
    private static Map<String, String> fieldDataTypeConversion = new Map<String, String>();
    static {
        fieldDataTypeConversion.put('STRING', 'text');
        fieldDataTypeConversion.put('BOOLEAN', 'boolean');
    }
    
    public void addFieldDetailEntry(String label, String fieldName, String fieldType) {
        if (String.isNotBlank(label) && String.isNotBlank(fieldName) && String.isNotBlank(fieldType)) {
            if (this.fieldDetailsResult == null) {
                this.fieldDetailsResult = new List<StudentFieldWrapper>();
            }
            if (fieldDataTypeConversion.containsKey(fieldType.toUpperCase())) {
                fieldType = fieldDataTypeConversion.get(fieldType.toUpperCase());
            }
            this.fieldDetailsResult.add(new StudentFieldWrapper(label, fieldName, fieldType));
        }
    }
    
    
    public class StudentFieldWrapper{
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String fieldName {get; set;}
        @AuraEnabled
        public String type {get; set;}
        
        public StudentFieldWrapper (String label, String fieldName, String fieldType){
            this.label = label;
            this.fieldName = fieldName;
      	    this.type = fieldType;
        }
    }
}