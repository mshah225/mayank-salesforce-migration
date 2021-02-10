public class FYSStudentWrapper {
    @AuraEnabled
    public List<StudentFieldWrapper> fieldDetailsResult { get; set; }
    @AuraEnabled
    public List<Contact> students { get; set; }
    @AuraEnabled
    public Set<User> coaches { get; set; }

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

    public void addFieldDetailEntry() {
        List<List<String>> actionsList = new List<List<String>>();
        List<String> actionDetail = new List<String>();
        actionDetail.add('Show_Details');
        actionDetail.add('Show Detail');
        actionsList.add(actionDetail);

        this.fieldDetailsResult.add(new StudentFieldWrapper(actionsList));
    }

    public class StudentFieldWrapper {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String fieldName { get; set; }
        @AuraEnabled
        public String type { get; set; }
        @AuraEnabled
        public typeAttributes typeAttributes { get; set; }

        public StudentFieldWrapper(List<List<String>> actionsList) {
            this.type = 'action';
            this.typeAttributes = new typeAttributes(actionsList);
        }
        public StudentFieldWrapper(String label, String fieldName, String fieldType) {
            this.label = label;
            this.fieldName = fieldName;
            this.type = fieldType;
        }
    }

    public class TypeAttributes {
        @AuraEnabled
        public List<RowAction> rowActions { get; set; }

        public TypeAttributes(List<List<String>> actionsList) {
            if (actionsList != null) {
                if (!actionsList.isEmpty()) {
                    this.rowActions = new List<RowAction>();
                    for (List<String> actionPair : actionsList) {
                        RowAction actionRec = new RowAction(actionPair[0], actionPair[1]);
                        this.rowActions.add(actionRec);
                    }
                }
            }
        }
    }

    public class RowAction {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String name { get; set; }

        public RowAction(String name, String label) {
            this.label = label;
            this.name = name;
        }
    }
}
