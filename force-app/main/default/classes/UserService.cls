public class UserService {
    public static User createTestUser() {
        User testUser = new User();
        testUser.FirstName = 'Test';
        testUser.LastName = 'User';
        testUser.Username = 'test.user.emperor.of.Byzantium@test.example.com';
        testUser.Email = 'test.user@test.example.com';
        testUser.Alias = 'testuser';
        testUser.CommunityNickname = 'testuserCom';
        testUser.TimeZoneSidKey = 'America/Phoenix';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';

        return testUser;
    }

    public static List<User> createMultipleTestUsers(Integer numUsers) {
        List<User> userList = new List<User>();

        for (Integer i = 0; i < numUsers; i++) {
            User tUser = createTestUser();
            tUser.FirstName = 'Test' + i;
            tUser.LastName = 'User' + i;
            tUser.Username = 'test.user.emperor.of.Byzantium' + i + '@test.example.com';
            tUser.Email = 'test.user' + i + '@test.example.com';
            tUser.Alias = 'test' + i;
            tUser.CommunityNickname = 'testuser' + i;
            userList.add(tUser);
        }
        return userList;
    }
}
