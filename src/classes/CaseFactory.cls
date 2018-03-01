@isTest
public class CaseFactory {
    public class DefaultCase extends TestFactory {
        public DefaultCase() {
            super(new Case(
                Subject = 'Test Subject',
                Description = 'Test Description'
            ));
            this.addToFieldsToIncrement('Subject');
            this.addToFieldsToIncrement('Description');
        }
    }
}