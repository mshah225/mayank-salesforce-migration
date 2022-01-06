@isTest
public with sharing class SortableTransferWorkTest {
    @isTest
    private static void testSortByTerm() {
        String sortBy = 'Term';

        SortableTransferWork eq1 = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(TERM__c = '2010'), sortBy);
        SortableTransferWork eq2 = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(TERM__c = '2010'), sortBy);
        SortableTransferWork lesser = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(TERM__c = '2019'), sortBy);
        SortableTransferWork greater = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(TERM__c = '2020'), sortBy);

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByInstitution() {
        String sortBy = 'Institution';

        SortableTransferWork eq1 = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(INSTITUTION__c = 'Poly'), sortBy);
        SortableTransferWork eq2 = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(INSTITUTION__c = 'Poly'), sortBy);
        SortableTransferWork lesser = new SortableTransferWork(
            new JBT_RET_CLASS_XFER__x(INSTITUTION__c = 'Downtown'),
            sortBy
        );
        SortableTransferWork greater = new SortableTransferWork(
            new JBT_RET_CLASS_XFER__x(INSTITUTION__c = 'Tempe'),
            sortBy
        );

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByCourse() {
        String sortBy = 'Course';

        SortableTransferWork eq1 = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(COURSE__c = 'CSE123'), sortBy);
        SortableTransferWork eq2 = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(COURSE__c = 'CSE123'), sortBy);
        SortableTransferWork lesser = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(COURSE__c = 'ASU101'), sortBy);
        SortableTransferWork greater = new SortableTransferWork(
            new JBT_RET_CLASS_XFER__x(COURSE__c = 'SOC505'),
            sortBy
        );

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByTitle() {
        String sortBy = 'Title';

        SortableTransferWork eq1 = new SortableTransferWork(
            new JBT_RET_CLASS_XFER__x(TITLE__c = 'First-Year Composition'),
            sortBy
        );
        SortableTransferWork eq2 = new SortableTransferWork(
            new JBT_RET_CLASS_XFER__x(TITLE__c = 'First-Year Composition'),
            sortBy
        );
        SortableTransferWork lesser = new SortableTransferWork(
            new JBT_RET_CLASS_XFER__x(TITLE__c = 'Arizona History'),
            sortBy
        );
        SortableTransferWork greater = new SortableTransferWork(
            new JBT_RET_CLASS_XFER__x(TITLE__c = 'Facts or Fiction'),
            sortBy
        );

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByTopic() {
        String sortBy = 'Topic';

        SortableTransferWork eq1 = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(TOPIC__c = 'CSE'), sortBy);
        SortableTransferWork eq2 = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(TOPIC__c = 'CSE'), sortBy);
        SortableTransferWork lesser = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(TOPIC__c = 'ASU'), sortBy);
        SortableTransferWork greater = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(TOPIC__c = 'SOC'), sortBy);
        SortableTransferWork nulled = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(), sortBy);

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assert(0 < nulled.compareTo(lesser));
        System.assert(0 > lesser.compareTo(nulled));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByGrade() {
        String sortBy = 'Grade';

        SortableTransferWork eq1 = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(GRADE__c = 'B-'), sortBy);
        SortableTransferWork eq2 = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(GRADE__c = 'B-'), sortBy);
        SortableTransferWork lesser = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(GRADE__c = 'A+'), sortBy);
        SortableTransferWork greater = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(GRADE__c = 'C+'), sortBy);

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByRCredit() {
        String sortBy = 'RCredit';

        SortableTransferWork eq1 = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(RCREDIT__c = 32), sortBy);
        SortableTransferWork eq2 = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(RCREDIT__c = 32), sortBy);
        SortableTransferWork lesser = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(RCREDIT__c = 10), sortBy);
        SortableTransferWork greater = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(RCREDIT__c = 40), sortBy);

        System.assert(0 < lesser.compareTo(greater));
        System.assert(0 > greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByECredit() {
        String sortBy = 'ECredit';

        SortableTransferWork eq1 = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(ECREDIT__c = 32), sortBy);
        SortableTransferWork eq2 = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(ECREDIT__c = 32), sortBy);
        SortableTransferWork lesser = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(ECREDIT__c = 10), sortBy);
        SortableTransferWork greater = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(ECREDIT__c = 40), sortBy);

        System.assert(0 < lesser.compareTo(greater));
        System.assert(0 > greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByHours() {
        String sortBy = 'Hours';

        SortableTransferWork eq1 = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(GPAHRS__c = 80), sortBy);
        SortableTransferWork eq2 = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(GPAHRS__c = 80), sortBy);
        SortableTransferWork lesser = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(GPAHRS__c = 60), sortBy);
        SortableTransferWork greater = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(GPAHRS__c = 120), sortBy);

        System.assert(0 < lesser.compareTo(greater));
        System.assert(0 > greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByPoints() {
        String sortBy = 'Points';

        SortableTransferWork eq1 = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(GPAPTS__c = 1200), sortBy);
        SortableTransferWork eq2 = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(GPAPTS__c = 1200), sortBy);
        SortableTransferWork lesser = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(GPAPTS__c = 600), sortBy);
        SortableTransferWork greater = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(GPAPTS__c = 3600), sortBy);

        System.assert(0 < lesser.compareTo(greater));
        System.assert(0 > greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByInvalidType() {
        String sortBy = 'INVALID';

        SortableTransferWork eq1 = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(GPAPTS__c = 1200), sortBy);
        SortableTransferWork eq2 = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(GPAPTS__c = 1200), sortBy);
        SortableTransferWork lesser = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(GPAPTS__c = 600), sortBy);
        SortableTransferWork greater = new SortableTransferWork(new JBT_RET_CLASS_XFER__x(GPAPTS__c = 3600), sortBy);

        System.assertEquals(0, lesser.compareTo(greater));
        System.assertEquals(0, greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }
}
