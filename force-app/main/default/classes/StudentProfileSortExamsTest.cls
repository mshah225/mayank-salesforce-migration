@isTest
public with sharing class StudentProfileSortExamsTest {
    @isTest
    private static void testSortByTitle() {
        String sortBy = 'Title';

        StudentProfileSortExams eq1 = new StudentProfileSortExams(
            new PS_ASU_SP_TRNSFR_V__x(TITLE__c = 'Literature'),
            sortBy
        );
        StudentProfileSortExams eq2 = new StudentProfileSortExams(
            new PS_ASU_SP_TRNSFR_V__x(TITLE__c = 'Literature'),
            sortBy
        );
        StudentProfileSortExams lesser = new StudentProfileSortExams(
            new PS_ASU_SP_TRNSFR_V__x(TITLE__c = 'History'),
            sortBy
        );
        StudentProfileSortExams greater = new StudentProfileSortExams(
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

        StudentProfileSortExams eq1 = new StudentProfileSortExams(
            new PS_ASU_SP_TRNSFR_V__x(COURSE_TITLE__c = 'First-Year Composition'),
            sortBy
        );
        StudentProfileSortExams eq2 = new StudentProfileSortExams(
            new PS_ASU_SP_TRNSFR_V__x(COURSE_TITLE__c = 'First-Year Composition'),
            sortBy
        );
        StudentProfileSortExams lesser = new StudentProfileSortExams(
            new PS_ASU_SP_TRNSFR_V__x(COURSE_TITLE__c = 'American History 1870-1940'),
            sortBy
        );
        StudentProfileSortExams greater = new StudentProfileSortExams(
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

        StudentProfileSortExams eq1 = new StudentProfileSortExams(new PS_ASU_SP_TRNSFR_V__x(SCORE__c = 80), sortBy);
        StudentProfileSortExams eq2 = new StudentProfileSortExams(new PS_ASU_SP_TRNSFR_V__x(SCORE__c = 80), sortBy);
        StudentProfileSortExams lesser = new StudentProfileSortExams(new PS_ASU_SP_TRNSFR_V__x(SCORE__c = 30), sortBy);
        StudentProfileSortExams greater = new StudentProfileSortExams(new PS_ASU_SP_TRNSFR_V__x(SCORE__c = 90), sortBy);

        System.assert(0 < lesser.compareTo(greater));
        System.assert(0 > greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByTransfer() {
        String sortBy = 'Transfer';

        StudentProfileSortExams eq1 = new StudentProfileSortExams(
            new PS_ASU_SP_TRNSFR_V__x(UNT_TRNSFR__c = 50),
            sortBy
        );
        StudentProfileSortExams eq2 = new StudentProfileSortExams(
            new PS_ASU_SP_TRNSFR_V__x(UNT_TRNSFR__c = 50),
            sortBy
        );
        StudentProfileSortExams lesser = new StudentProfileSortExams(
            new PS_ASU_SP_TRNSFR_V__x(UNT_TRNSFR__c = 20),
            sortBy
        );
        StudentProfileSortExams greater = new StudentProfileSortExams(
            new PS_ASU_SP_TRNSFR_V__x(UNT_TRNSFR__c = 80),
            sortBy
        );

        System.assert(0 < lesser.compareTo(greater));
        System.assert(0 > greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByInvalidType() {
        String sortBy = 'INVALID';

        StudentProfileSortExams eq1 = new StudentProfileSortExams(
            new PS_ASU_SP_TRNSFR_V__x(UNT_TRNSFR__c = 50),
            sortBy
        );
        StudentProfileSortExams eq2 = new StudentProfileSortExams(
            new PS_ASU_SP_TRNSFR_V__x(UNT_TRNSFR__c = 50),
            sortBy
        );
        StudentProfileSortExams lesser = new StudentProfileSortExams(
            new PS_ASU_SP_TRNSFR_V__x(UNT_TRNSFR__c = 20),
            sortBy
        );
        StudentProfileSortExams greater = new StudentProfileSortExams(
            new PS_ASU_SP_TRNSFR_V__x(UNT_TRNSFR__c = 80),
            sortBy
        );

        System.assertEquals(0, lesser.compareTo(greater));
        System.assertEquals(0, greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }
}