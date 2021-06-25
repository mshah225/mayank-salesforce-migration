@isTest
private class Test_OWEAService {
    @isTest
    static void testGetOWEAs() {
        OrgWideEmailAddress expectedAddress = [SELECT Address FROM OrgWideEmailAddress LIMIT 1];

        Test.startTest();
        OrgWideEmailAddress testAddress = OrgWideEmailAddressService.getOrgWideEmailAddress(expectedAddress.Address);
        Test.stopTest();

        System.assertEquals(
            expectedAddress.Id,
            testAddress.Id,
            'OrgWideEmailAddressService did not return the expected address'
        );
    }

    @isTest
    static void testBadOWEA() {
        try {
            Test.startTest();
            OrgWideEmailAddressService.getOrgWideEmailAddress('test@test.com');
        } catch (OrgWideEmailAddressService.OrgWideEmailAddressServiceException e) {
            Test.stopTest();
            System.assert(true);
        } catch (Exception e) {
            Test.stopTest();
            System.assert(false, 'An unknown exception was thrown by the OrgWideEmailAddressService');
        }
    }
}
