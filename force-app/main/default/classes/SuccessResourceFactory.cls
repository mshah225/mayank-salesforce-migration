@isTest
public class SuccessResourceFactory {
    public class DefaultCoachingResource extends TestFactory {
        public DefaultCoachingResource() {
            super(
                new Success_Resource__c(RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Coach'))
            );
        }
    }

    public class DefaultAdvisorUserResource extends TestFactory {
        public DefaultAdvisorUserResource() {
            super(
                new Success_Resource__c(
                    IsActive__c = true,
                    Role__c = 'User',
                    Resource__c = UserInfo.getUserId(),
                    RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Advisor')
                )
            );
        }
    }

    public class DefaultAdvisorDepartmentManagerResource extends TestFactory {
        public DefaultAdvisorDepartmentManagerResource() {
            super(
                new Success_Resource__c(
                    IsActive__c = true,
                    Role__c = 'Department Manager',
                    Resource__c = UserInfo.getUserId(),
                    RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Advisor')
                )
            );
        }
    }

    public class DefaultAdvisorCollegeManagerResource extends TestFactory {
        public DefaultAdvisorCollegeManagerResource() {
            super(
                new Success_Resource__c(
                    IsActive__c = true,
                    Role__c = 'College Manager',
                    Resource__c = UserInfo.getUserId(),
                    RecordTypeId = RecordIdHelper.getRecordTypeId('Success_Resource__c', 'Advisor')
                )
            );
        }
    }
}
