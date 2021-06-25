@isTest
public without sharing class SuccessPodFactory {
    public class DefaultSuccessPod extends TestFactory {
        public DefaultSuccessPod() {
            super(
                new Success_Pod__c(
                    OwnerId = UserInfo.getUserId(),
                    RecordTypeId = IdHelper.getRecordTypeId('Success_Resource__c', 'Advisor'),
                    Name = 'Test Pod ',
                    Committee__c = 'tp'
                )
            );
            this.addToFieldsToIncrement('Name');
            this.addToFieldsToIncrement('Committee__c');
        }
    }

    public class RelatedGroupSuccessPod extends TestFactory {
        public RelatedGroupSuccessPod(Id groupId) {
            super(
                new Success_Pod__c(
                    OwnerId = groupId,
                    RecordTypeId = IdHelper.getRTID('Success_Pod__c', 'Advisor'),
                    Name = 'Test Pod ',
                    Committee__c = 'tp'
                )
            );
            this.addToFieldsToIncrement('Name');
            this.addToFieldsToIncrement('Committee__c');
        }
    }

    public List<Success_Pod__c> createRelatedGroupAdvisorPods(Integer numberOfPods) {
        List<Success_Pod__c> advisorPods = new List<Success_Pod__c>();
        List<QueueSobject> queues = new List<QueueSobject>();
        List<Group> groups = new List<Group>();
        GroupFactory.DefaultGroup groupMaker = new GroupFactory.DefaultGroup();
        groups = groupMaker.create(numberOfPods);
        insert groups;

        for (group g : groups) {
            QueueFactory.RelatedGroupCaseQueue relatedGroupCaseQueueMaker = new QueueFactory.RelatedGroupCaseQueue(
                g.Id
            );
            queues.add((QueueSObject) relatedGroupCaseQueueMaker.create(1)[0]);

            QueueFactory.RelatedGroupSuccessPodQueue relatedGroupSuccessPodQueueMaker = new QueueFactory.RelatedGroupSuccessPodQueue(
                g.Id
            );
            queues.add((QueueSObject) relatedGroupSuccessPodQueueMaker.create(1)[0]);
        }

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert queues;
        }

        for (group g : groups) {
            RelatedGroupSuccessPod relatedGroupSuccessPodMaker = new RelatedGroupSuccessPod(g.Id);
            advisorPods.add((Success_Pod__c) relatedGroupSuccessPodMaker.create(1)[0]);
        }

        insert advisorPods;
        return advisorPods;
    }
}
