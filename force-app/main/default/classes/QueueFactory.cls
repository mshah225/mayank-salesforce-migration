@isTest
public class QueueFactory {
    public class DefaultCaseQueue extends TestFactory {
        public DefaultCaseQueue() {
            super(new QueueSobject(QueueId = UserInfo.getUserId(), SobjectType = 'Case'));
        }
    }

    public class DefaultSuccessPodQueue extends TestFactory {
        public DefaultSuccessPodQueue() {
            super(new QueueSobject(QueueId = UserInfo.getUserId(), SobjectType = 'Success_Pod__c'));
        }
    }

    public class RelatedGroupCaseQueue extends TestFactory {
        public RelatedGroupCaseQueue(Id groupId) {
            super(new QueueSobject(QueueId = groupId, SobjectType = 'Case'));
        }
    }

    public class RelatedGroupSuccessPodQueue extends TestFactory {
        public RelatedGroupSuccessPodQueue(Id groupId) {
            super(new QueueSobject(QueueId = groupId, SobjectType = 'Success_Pod__c'));
        }
    }
}
