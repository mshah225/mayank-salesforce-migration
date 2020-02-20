public with sharing class AutoSubscriberService {
    List<sObject> recordsToProcess {get; set;}
    String typeOfObject;
    Map<Auto_Subscriber_Setting__mdt, List<String>> settingToSubscription;

    public AutoSubscriberService(List<sObject> recordsToProcess, String typeOfObject) {
        settingToSubscription = new Map<Auto_Subscriber_Setting__mdt, List<String>>();
        this.recordsToProcess = recordsToProcess;
        this.typeOfObject = typeOfObject;

        createSubscriptionMap();
    }

    private void createSubscriptionMap() {
        List<Auto_Subscriber_Setting__mdt> subscriberSettings = [
            SELECT Subscriptions_To_Add__c, DeveloperName
            FROM Auto_Subscriber_Setting__mdt
            WHERE Active__c = true AND
            Related_Object__r.DeveloperName =: typeOfObject
        ];

        for (Auto_Subscriber_Setting__mdt subSetting : subscriberSettings) {
            List<String> subscriptionIds = new List<String>();

            if (subSetting.Subscriptions_To_Add__c != null) {
                subscriptionIds = subSetting.Subscriptions_To_Add__c.split(',');
            }

            settingToSubscription.put(subSetting, subscriptionIds);
        }
    }

    public void processStudentProgramPlanRecords() {
        List<Student_Program_Plan__c> convertedRecordsToProcess = (List<Student_Program_Plan__c>) recordsToProcess;
        List<Subscriber__c> subsToCreate = new List<Subscriber__c>();

        for (Student_Program_Plan__c programPlan : convertedRecordsToProcess) {
            for (Auto_Subscriber_Setting__mdt subSetting : settingToSubscription.keyset()) {
                if (AutoSubscriberFilterHelper.filterProgramPlan(subSetting.DeveloperName, programPlan)) {
                    subsToCreate.addAll(createSubscriberForProgramPlan(programPlan, settingToSubscription.get(subSetting)));
                }
            }
        }

        if (!subsToCreate.isEmpty()) {
            insert subsToCreate;
        }
    }

    private List<Subscriber__c> createSubscriberForProgramPlan(Student_Program_Plan__c programPlan, List<String> subList) {
        List<Subscriber__c> subsToCreate = new List<Subscriber__c>();

        for (String subscriptionId : subList) {
            Subscriber__c subFromProgramPlan = new Subscriber__c();
            subFromProgramPlan.Subscription__c = subscriptionId;
            subFromProgramPlan.Contact__c = programPlan.Contact__c;
            subFromProgramPlan.Subscriber_Status__c = 'Subscribed';

            subsToCreate.add(subFromProgramPlan);
        }
        
        
        return subsToCreate;
    }
}
