@isTest
public with sharing class SortableCreditByExamTest {
    @isTest
    private static void testSortByTitle() {
        String sortBy = 'Title';

        SortableCreditByExam eq1 = new SortableCreditByExam(new PS_ASU_SP_TRNSFR_V__x(TITLE__c = 'Literature'), sortBy);
        SortableCreditByExam eq2 = new SortableCreditByExam(new PS_ASU_SP_TRNSFR_V__x(TITLE__c = 'Literature'), sortBy);
        SortableCreditByExam lesser = new SortableCreditByExam(new PS_ASU_SP_TRNSFR_V__x(TITLE__c = 'History'), sortBy);
        SortableCreditByExam greater = new SortableCreditByExam(
            new PS_ASU_SP_TRNSFR_V__x(TITLE__c = 'Politics'),
            sortBy
        );

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByCourseTitle() {
        String sortBy = 'Course Title';

        SortableCreditByExam eq1 = new SortableCreditByExam(
            new PS_ASU_SP_TRNSFR_V__x(COURSE_TITLE__c = 'First-Year Composition'),
            sortBy
        );
        SortableCreditByExam eq2 = new SortableCreditByExam(
            new PS_ASU_SP_TRNSFR_V__x(COURSE_TITLE__c = 'First-Year Composition'),
            sortBy
        );
        SortableCreditByExam lesser = new SortableCreditByExam(
            new PS_ASU_SP_TRNSFR_V__x(COURSE_TITLE__c = 'American History 1870-1940'),
            sortBy
        );
        SortableCreditByExam greater = new SortableCreditByExam(
            new PS_ASU_SP_TRNSFR_V__x(COURSE_TITLE__c = 'Geopolitical Conflicts in the Eastern World'),
            sortBy
        );

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByScore() {
        String sortBy = 'Score';

        SortableCreditByExam eq1 = new SortableCreditByExam(new PS_ASU_SP_TRNSFR_V__x(SCORE__c = 80), sortBy);
        SortableCreditByExam eq2 = new SortableCreditByExam(new PS_ASU_SP_TRNSFR_V__x(SCORE__c = 80), sortBy);
        SortableCreditByExam lesser = new SortableCreditByExam(new PS_ASU_SP_TRNSFR_V__x(SCORE__c = 30), sortBy);
        SortableCreditByExam greater = new SortableCreditByExam(new PS_ASU_SP_TRNSFR_V__x(SCORE__c = 90), sortBy);

        System.assert(0 < lesser.compareTo(greater));
        System.assert(0 > greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByTransfer() {
        String sortBy = 'Transfer';

        SortableCreditByExam eq1 = new SortableCreditByExam(new PS_ASU_SP_TRNSFR_V__x(UNT_TRNSFR__c = 50), sortBy);
        SortableCreditByExam eq2 = new SortableCreditByExam(new PS_ASU_SP_TRNSFR_V__x(UNT_TRNSFR__c = 50), sortBy);
        SortableCreditByExam lesser = new SortableCreditByExam(new PS_ASU_SP_TRNSFR_V__x(UNT_TRNSFR__c = 20), sortBy);
        SortableCreditByExam greater = new SortableCreditByExam(new PS_ASU_SP_TRNSFR_V__x(UNT_TRNSFR__c = 80), sortBy);

        System.assert(0 < lesser.compareTo(greater));
        System.assert(0 > greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByInvalidType() {
        String sortBy = 'INVALID';

        SortableCreditByExam eq1 = new SortableCreditByExam(new PS_ASU_SP_TRNSFR_V__x(UNT_TRNSFR__c = 50), sortBy);
        SortableCreditByExam eq2 = new SortableCreditByExam(new PS_ASU_SP_TRNSFR_V__x(UNT_TRNSFR__c = 50), sortBy);
        SortableCreditByExam lesser = new SortableCreditByExam(new PS_ASU_SP_TRNSFR_V__x(UNT_TRNSFR__c = 20), sortBy);
        SortableCreditByExam greater = new SortableCreditByExam(new PS_ASU_SP_TRNSFR_V__x(UNT_TRNSFR__c = 80), sortBy);

        System.assertEquals(0, lesser.compareTo(greater));
        System.assertEquals(0, greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }
}
