public class UserService
{
  	public static User createTestUser()
  	{
		User testUser = new User();
		testUser.FirstName = 'Test';
		testUser.LastName = 'User';
		testUser.Username = 'test.user@test.example.com';
		testUser.Email = 'test.user@test.example.com';
		testUser.Alias = 'testuser';
		testUser.CommunityNickname = 'testuserCom';
		testUser.TimeZoneSidKey = 'America/Phoenix';
		testUser.LocaleSidKey = 'en_US';
		testUser.EmailEncodingKey = 'ISO-8859-1';
		testUser.LanguageLocaleKey = 'en_US';

		return testUser;
  	}
}