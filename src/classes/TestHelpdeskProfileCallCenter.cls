@isTest
public class TestHelpdeskProfileCallCenter 
{
    private static User createUserWithProfile(String profileId)
    {
        User newUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'thpcc',
            Email = 'thpcc@asu.edu',
            Username = 'thpcc@asu.edu',
            TimeZoneSidKey = 'America/Phoenix',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ReceivesInfoEmails = false,
            ProfileId = profileID
        );
        
        return newUser;
    }
    
    private static String getCallCenterId()
    {
        CallCenter cc = [SELECT Id FROM CallCenter WHERE InternalName = 'inContactCallCenter'];
        return cc.Id;
    }
    
    private static String getHelpdeskProfileId()
    {
        return '00ed00000019z6C';
    }
    
    private static String getNonHelpdeskProfileId()
    {
        return '00ed00000019yKB';
    }
    
    static testmethod void TestInsertHelpdeskProfile()
    {
        String helpDeskProfileId = getHelpdeskProfileId();
        User helpDeskUser = createUserWithProfile(helpDeskProfileId);

        Test.startTest();
        insert helpDeskUser;
        Test.stopTest();
                
        User insertedUser = [SELECT ProfileId, CallCenterId FROM User WHERE Id = :helpDeskUser.Id LIMIT 1];
        System.assert(insertedUser.CallCenterId == getCallCenterId());
    }
    
    static testmethod void TestInsertNonHelpdeskProfile()
    {
        User helpDeskUser = createUserWithProfile(getNonHelpdeskProfileId());

        Test.startTest();
        insert helpDeskUser;
        Test.stopTest();
                
        User insertedUser = [SELECT ProfileId, CallCenterId FROM User WHERE Id = :helpDeskUser.Id LIMIT 1];
        System.assert(insertedUser.CallCenterId != getCallCenterId());
    }
    
    static testmethod void TestUpdateHelpdeskProfile()
    {
        String helpDeskProfileId = getHelpdeskProfileId();
        User helpDeskUser = createUserWithProfile(getNonHelpdeskProfileId());
        insert helpDeskUser;
        User insertedUser = [SELECT ProfileId, CallCenterId FROM User WHERE Id = :helpDeskUser.Id LIMIT 1];
        System.assert(insertedUser.CallCenterId != getCallCenterId());
                
        Test.startTest();
        insertedUser.ProfileId = helpDeskProfileId;
        update insertedUser;
        Test.stopTest();
                
        User updatedUser = [SELECT ProfileId, CallCenterId FROM User WHERE Id = :insertedUser.Id LIMIT 1];
        System.assert(updatedUser.CallCenterId == getCallCenterId());
    }
    
    static testmethod void TestUpdateNonHelpdeskProfile()
    {
        User helpDeskUser = createUserWithProfile(getNonHelpdeskProfileId());
        insert helpDeskUser;
        User insertedUser = [SELECT ProfileId, CallCenterId FROM User WHERE Id = :helpDeskUser.Id LIMIT 1];
        System.assert(insertedUser.CallCenterId != getCallCenterId());
                
        Test.startTest();
        insertedUser.ProfileId = getNonHelpdeskProfileId();
        update insertedUser;
        Test.stopTest();
                
        User updatedUser = [SELECT ProfileId, CallCenterId FROM User WHERE Id = :insertedUser.Id LIMIT 1];
        System.assert(updatedUser.CallCenterId != getCallCenterId());
    }
}