public with sharing class ExternalObjectQueryController {
    public String numberOfRecords { get; set; }
    public String emplId { get; set; }
    public String exceptionMessage { get; set; }
    public Long elapsedTime { get; set; }
    public String soqlSelect { get; set; }

    public List<selectoption> supportedObject { get; set; }

    //Selected Object
    public String SelectedObject { get; set; }

    //Global describe
    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    Set<String> objectKeys = gd.keySet();
    public List<SelectOption> fieldLableAPI { get; set; }
    public List<String> SelectedFields { get; set; }
    public List<sObject> ObjectList { get; set; }
    public boolean showException { get; set; }

    //Constructor
    public ExternalObjectQueryController() {
        //Initialize
        supportedObject = new List<selectoption>();
        SelectedObject = '';
        fieldLableAPI = new List<SelectOption>();
        SelectedFields = new List<String>();
        ObjectList = new List<sObject>();
        numberOfRecords = '5';
        elapsedTime = 0;
        showException = false;

        //Get only reference to objects
        // for(Schema.SObjectType item : ProcessInstance.TargetObjectId.getDescribe().getReferenceTo())
        List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();

        for (Schema.SObjectType item : gd) {
            //Excluding custom setting objects
            if (item.getDescribe().getName().contains('__x')) {
                //Adding to list
                supportedObject.add(
                    new SelectOption(
                        item.getDescribe().getLocalName().toLowerCase(),
                        item.getDescribe().getName() +
                        ' - ' +
                        item.getDescribe().getLabel()
                    )
                );
            }
        }

        supportedObject.sort();
    }

    //Get fields of selected object
    public void ObjectFields() {
        fieldLableAPI = new List<SelectOption>();

        if (SelectedObject != '--None--') {
            //Creating sObject for dynamic selected object
            Schema.SObjectType systemObjectType = gd.get(SelectedObject);
            //Fetching field results
            Schema.DescribeSObjectResult r = systemObjectType.getDescribe();

            Map<String, Schema.SObjectField> M = r.fields.getMap();
            //Creating picklist of fields
            for (Schema.SObjectField fieldAPI : M.values()) {
                fieldLableAPI.add(
                    new SelectOption(fieldAPI.getDescribe().getName(), fieldAPI.getDescribe().getLabel())
                );
            }
        }
    }

    public void ShowTable() {
        //Creating dynamic query with selected field
        exceptionMessage = '';
        soqlSelect = 'Select Id ';
        ObjectList = new List<sObject>();
        showException = false;

        for (String field : SelectedFields) {
            if (field.toLowerCase() != 'id' && field.toLowerCase() != '--none--')
                soqlSelect += ',' + field + ' ';
        }

        soqlSelect += ' from ' + SelectedObject;

        if (!String.isBlank(emplId))
            soqlSelect += ' WHERE EMPLID__c = \'' + emplId + '\' ';

        if (!String.isBlank(numberOfRecords) && numberOfRecords.isNumeric())
            soqlSelect += ' LIMIT ' + numberOfRecords;

        DateTime timeStart = DateTime.now();
        //Executing the query and fetching results
        try {
            ObjectList = Database.query(soqlSelect);
        } catch (Exception e) {
            exceptionMessage = e.getMessage();
            showException = true;
        } finally {
            elapsedTime = Datetime.now().getTime() - timeStart.getTime();
        }
    }
}
