@isTest
public class Test_AdvisorPortalMainPage {
    private static Integer numberOfPods;
    private static Integer numberOfCases;
    private static Integer numberOfStudents;
    private static AdvisorPortalMainPageController apmpc;
    
    /* 
     * Static initialization code to mimize repeat code between test methods
     */
    static {
        numberOfPods = 3;
        numberOfCases = 1;
        numberOfStudents = 10;
        apmpc = new AdvisorPortalMainPageController();
    }
    
    /*
     * testSetup method to create test data.
     * 
     * <p>
     * The AdvisorPortalMainPage generates data based off of the currently
     * logged in user. When creating test data, we need to provide the current userId
     * rather than creating a new user.
     * </p>
     */
    @testSetup
    public static void testSetup() {
        TestDataFactory.makeMeAnAdvisorUser(numberOfPods, numberOfCases, numberOfStudents);
    }
    
    /*
     * Test the controllers ability to return accurate view as options.
     */
    public static testMethod void Test_getViewAsOptions() {
        List<SelectOption> listToTest = apmpc.viewAsOptions;
        
        // Check sizes
        system.assertEquals(3 + numberOfPods, listToTest.size());
        
        // Make sure the current user is the first option on the list
        system.assertEquals(UserInfo.getName(), listToTest[0].getLabel());
        system.assertEquals(UserInfo.getUserId(), listToTest[0].getValue());
        
        // Make sure that the second option is a blank option that is disabled
        system.assertEquals('', listToTest[1].getLabel());
        system.assertEquals('', listToTest[1].getValue());
        system.assert(listToTest[1].getDisabled());
        
        // Make sure the third option is the "My Comittees" heading
        system.assertEquals('--My Committees--', listToTest[2].getLabel());
        system.assertEquals('', listToTest[2].getValue());
        system.assert(listToTest[2].getDisabled());
        
        // Make sure the rest of the options value is a group Id
        validator.setPrefix(group.class);
        
        for (Integer x = 3; x < listToTest.size(); x++) {
            system.assert(Validator.validateId(listToTest[x].getValue()));
        }
    }
    
    /*
     * As of right now the answer to this question should always be true.
     * We need to figure out under what circumstances the view as functionality should
     * be displayed and update the controller method.
     */
    public static testMethod void Test_getHasViewAs() {
        system.assert(true, apmpc.hasViewAs);
    }
    
    /*
     * MimicId has basic getter and setter. We still need to test for code coverate.
     * 
     * <p>
     * This may seem simple and unecessary; however, if the getter/setter changes in the future,
     * this will ensure that the new getter/setter are compatible with existing functionality.
     * </p>
     */
    public static testMethod void Test_getSetMimicId() {
        apmpc.OwnerId = UserInfo.getUserId();
        system.assertEquals(UserInfo.getUserId(), apmpc.OwnerId);
    }
    
    public static testMethod void Test_getAdvisorEmailRTID() {
        system.assertEquals(IDHelper.getRTID('Portal_Email__c', 'Advisor'), apmpc.advisorEmailRTID);
    }
    
    public static testMethod void Test_getAdvisorProactiveCaseRTID() {
        system.assertEquals(IDHelper.getRTID('Case', 'ASU_Advisor_Outreach'), apmpc.AdvisorProactiveCaseRTID);
    }
    
    public static testMethod void Test_getAdvisorReactiveCaseRTID() {
        system.assertEquals(IDHelper.getRTID('Case', 'ASU_Service'), apmpc.AdvisorReactiveCaseRTID);
    }
    
    public static testMethod void Test_getQueries() {
        apmpc.ownerId = UserInfo.getUserId();
        
        system.assert(apmpc.myProactiveQuery.contains((String) apmpc.OwnerId));
        system.assert(apmpc.myWatchlistQuery.contains((String) apmpc.OwnerId));
        system.assert(apmpc.mySummaryListQuery.contains((String) apmpc.OwnerId));
        system.assert(apmpc.myStudentsQuery.contains((String) apmpc.OwnerId));
    }
    
    public static testMethod void Test_getRole(){
        system.assertEquals('User', apmpc.myRole);
    }
}