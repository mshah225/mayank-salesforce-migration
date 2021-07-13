@isTest
public with sharing class VisualstrapTest {
    private static final String htmlIdStr = 'HTML_ID_VALUE';
    @isTest
    private static void testBasicFields() {
        Test.startTest();
        Visualstrap controller = new Visualstrap();
        controller.htmlid = htmlIdStr;
        Test.stopTest();

        System.assertEquals(htmlIdStr, controller.htmlid);
    }
}
