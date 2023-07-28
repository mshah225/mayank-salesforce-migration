@isTest
private class CsvManagerTest {
    @isTest
    private static void addRowSuccess() {
        Test.setMock(HttpCalloutMock.class, new BulkAPICalloutMock());
        CsvManager manager = new CsvManager('Id\n', 10, ObjectScrambleService.objectTypes.CONTACT);
        System.assertEquals('Id\n', manager.getCsvFile());

        Test.startTest();
        manager.addRow('003M0000012A8X5');
        Test.stopTest();

        System.assertEquals(1, manager.getCurrentBatchSize());
        System.assert(
            manager.getCsvFile().contains('003M0000012A8X5'),
            'Row data was not successfully added. Does not contain Contact Id. ' + manager.getCsvFile()
        );
    }

    @isTest
    private static void addRowAtMaxSizeSuccess() {
        Test.setMock(HttpCalloutMock.class, new BulkAPICalloutMock());
        CsvManager manager = new CsvManager('Id\n', 1, ObjectScrambleService.objectTypes.CONTACT);
        System.assertEquals('Id\n', manager.getCsvFile());

        Test.startTest();
        manager.addRow('003M0000012A8X5');

        System.assertEquals(1, manager.getCurrentBatchSize());

        manager.addRow('003M0000012A8X6');
        Test.stopTest();

        System.assertEquals(1, manager.getCurrentBatchSize());
    }
}
