@isTest
public class BusinessUnitFactory {
    
    public class DefaultBusinessUnit extends TestFactory {
        public DefaultBusinessUnit() {
            super(
                new et4ae5__Business_Unit__c(
                    Name = 'TestBusinessUnit',
                    et4ae5__Enabled__c = TRUE,
                    et4ae5__Business_Unit_ID__c = 'buId'
            ));
            this.addToFieldsToIncrement('et4ae5__Business_Unit_ID__c');
        }
    }
}