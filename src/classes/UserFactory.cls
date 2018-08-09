@isTest
public class UserFactory {
    public class DefaultUser extends TestFactory {
        public DefaultUser() {
            super(new User(FirstName = 'Test',
                    LastName = 'User',
                    Username = 'test.user.Emperor.Of.Byzantium@test.example.com',
                    Email = 'test.user@test.example.com',
                    Alias = 'testuser',
                    CommunityNickname = 'testuserEmperorOfByzantium',
                    TimeZoneSidKey = 'America/Phoenix',
                    LocaleSidKey = 'en_US',
                    EmailEncodingKey = 'ISO-8859-1',
                    LanguageLocaleKey = 'en_US'
                )
            );
            this.addToFieldsToIncrement('LastName');
            this.addToFieldsToIncrement('CommunityNickname');
            this.addToFieldsToIncrement('Email');
            this.addToFieldsToIncrement('UserName');
        }
    }
}