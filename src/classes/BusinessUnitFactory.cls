@isTest
public class BusinessUnitFactory {
    public class DefaultBusinessUnit extends TestFactory {
        public DefaultBusinessUnit() {
            super(
                new et4ae5__Business_Unit__c(
                    Name = 'TestBusinessUnit',
                    et4ae5__Enabled__c = true,
                    et4ae5__Business_Unit_ID__c = 'buId'
                )
            );
            this.addToFieldsToIncrement('et4ae5__Business_Unit_ID__c');
        }
    }
}
