@isTest
public class EmailMessageFactory {
    public class DefaultEmailMessage extends TestFactory {
        public DefaultEmailMessage() {
            super(
                new EmailMessage(
                    FromName = 'Test FromName',
                    FromAddress = 'testFromAddress@test.com',
                    ToAddress = 'testToAddress@test.com',
                    Subject = 'Test Subject'
                )
            );
            this.addToFieldsToIncrement('FromName');
            this.addToFieldsToIncrement('FromAddress');
            this.addToFieldsToIncrement('ToAddress');
            this.addToFieldsToIncrement('Subject');
        }
    }
}
