@isTest
public class AttachmentFactory {
    public class DefaultAttachment extends TestFactory {
        public DefaultAttachment() {
            super(new Attachment(Name = 'Test Attachment', Body = Blob.valueOf('Test Body')));
            this.addToFieldsToIncrement('Name');
        }
    }
}
