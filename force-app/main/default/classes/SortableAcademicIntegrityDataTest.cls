@isTest
public with sharing class SortableAcademicIntegrityDataTest {
    @isTest
    private static void testSortBySession() {
        String sortBy = 'Session';

        SortableAcademicIntegrityData eq1 = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'SP201'),
            sortBy
        );
        SortableAcademicIntegrityData eq2 = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'SP201'),
            sortBy
        );
        SortableAcademicIntegrityData lesser = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'FA201'),
            sortBy
        );
        SortableAcademicIntegrityData greater = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'SP202'),
            sortBy
        );

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByClass() {
        String sortBy = 'Class';

        SortableAcademicIntegrityData eq1 = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(CLASS_NBR__c = 'CSE454'),
            sortBy
        );
        SortableAcademicIntegrityData eq2 = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(CLASS_NBR__c = 'CSE454'),
            sortBy
        );
        SortableAcademicIntegrityData lesser = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(CLASS_NBR__c = 'ASU101'),
            sortBy
        );
        SortableAcademicIntegrityData greater = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(CLASS_NBR__c = 'GED340'),
            sortBy
        );

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByCourse() {
        String sortBy = 'Course';

        SortableAcademicIntegrityData eq1 = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SUBJECT__c = 'CSE', CATALOG_NBR__c = '454'),
            sortBy
        );
        SortableAcademicIntegrityData eq2 = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SUBJECT__c = 'CSE', CATALOG_NBR__c = '454'),
            sortBy
        );
        SortableAcademicIntegrityData lesser = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SUBJECT__c = 'ASU', CATALOG_NBR__c = '101'),
            sortBy
        );
        SortableAcademicIntegrityData greater = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SUBJECT__c = 'GED', CATALOG_NBR__c = '340'),
            sortBy
        );

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByTitle() {
        String sortBy = 'Title';

        SortableAcademicIntegrityData eq1 = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(CLASS_DESCR__c = 'First-Year Composition'),
            sortBy
        );
        SortableAcademicIntegrityData eq2 = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(CLASS_DESCR__c = 'First-Year Composition'),
            sortBy
        );
        SortableAcademicIntegrityData lesser = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(CLASS_DESCR__c = 'Arizona History'),
            sortBy
        );
        SortableAcademicIntegrityData greater = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(CLASS_DESCR__c = 'Facts or Fiction'),
            sortBy
        );

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByTopic() {
        String sortBy = 'Topic';

        SortableAcademicIntegrityData eq1 = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SSR_CLSTOPIC_DESCR__c = 'SP201'),
            sortBy
        );
        SortableAcademicIntegrityData eq2 = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SSR_CLSTOPIC_DESCR__c = 'SP201'),
            sortBy
        );
        SortableAcademicIntegrityData lesser = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SSR_CLSTOPIC_DESCR__c = 'FA201'),
            sortBy
        );
        SortableAcademicIntegrityData greater = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SSR_CLSTOPIC_DESCR__c = 'SP202'),
            sortBy
        );
        SortableAcademicIntegrityData nulled = new SortableAcademicIntegrityData(new PS_ASU_SP_CLASS_V__x(), sortBy);

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assert(0 < nulled.compareTo(lesser));
        System.assert(0 > lesser.compareTo(nulled));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByUnits() {
        String sortBy = 'Units';

        SortableAcademicIntegrityData eq1 = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(UNT_TAKEN__c = 48),
            sortBy
        );
        SortableAcademicIntegrityData eq2 = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(UNT_TAKEN__c = 48),
            sortBy
        );
        SortableAcademicIntegrityData lesser = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(UNT_TAKEN__c = 68),
            sortBy
        );
        SortableAcademicIntegrityData greater = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(UNT_TAKEN__c = 300),
            sortBy
        );

        System.assert(0 < lesser.compareTo(greater));
        System.assert(0 > greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByInstructor() {
        String sortBy = 'Instructor';

        SortableAcademicIntegrityData eq1 = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(FT_FULL_NAME__c = 'Roberts'),
            sortBy
        );
        SortableAcademicIntegrityData eq2 = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(FT_FULL_NAME__c = 'Roberts'),
            sortBy
        );
        SortableAcademicIntegrityData lesser = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(FT_FULL_NAME__c = 'Addams'),
            sortBy
        );
        SortableAcademicIntegrityData greater = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(FT_FULL_NAME__c = 'Johnsmith'),
            sortBy
        );
        SortableAcademicIntegrityData nulled = new SortableAcademicIntegrityData(new PS_ASU_SP_CLASS_V__x(), sortBy);

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assert(0 < nulled.compareTo(lesser));
        System.assert(0 > lesser.compareTo(nulled));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByDays() {
        String sortBy = 'Days';

        SortableAcademicIntegrityData eq1 = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SCH_HTML_DAY1__c = 'M,W,F'),
            sortBy
        );
        SortableAcademicIntegrityData eq2 = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SCH_HTML_DAY1__c = 'M,W,F'),
            sortBy
        );
        SortableAcademicIntegrityData lesser = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SCH_HTML_DAY1__c = 'M'),
            sortBy
        );
        SortableAcademicIntegrityData greater = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SCH_HTML_DAY1__c = 'W'),
            sortBy
        );
        SortableAcademicIntegrityData nulled = new SortableAcademicIntegrityData(new PS_ASU_SP_CLASS_V__x(), sortBy);

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assert(0 < nulled.compareTo(lesser));
        System.assert(0 > lesser.compareTo(nulled));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByTimes() {
        String sortBy = 'Times';

        SortableAcademicIntegrityData eq1 = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SCH_DAILY_TIME__c = '9:00-11:00'),
            sortBy
        );
        SortableAcademicIntegrityData eq2 = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SCH_DAILY_TIME__c = '9:00-11:00'),
            sortBy
        );
        SortableAcademicIntegrityData lesser = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SCH_DAILY_TIME__c = '12:00-14:00'),
            sortBy
        );
        SortableAcademicIntegrityData greater = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SCH_DAILY_TIME__c = '13:30-15:00'),
            sortBy
        );
        SortableAcademicIntegrityData nulled = new SortableAcademicIntegrityData(new PS_ASU_SP_CLASS_V__x(), sortBy);

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assert(0 < nulled.compareTo(lesser));
        System.assert(0 > lesser.compareTo(nulled));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByDates() {
        String sortBy = 'Dates';

        SortableAcademicIntegrityData eq1 = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(ASU_SCH_DATES__c = 'Summer Semester'),
            sortBy
        );
        SortableAcademicIntegrityData eq2 = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(ASU_SCH_DATES__c = 'Summer Semester'),
            sortBy
        );
        SortableAcademicIntegrityData lesser = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(ASU_SCH_DATES__c = 'Fall Semester'),
            sortBy
        );
        SortableAcademicIntegrityData greater = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(ASU_SCH_DATES__c = 'Spring Semester'),
            sortBy
        );

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByLocation() {
        String sortBy = 'Location';

        SortableAcademicIntegrityData eq1 = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SSR_MTG_LOC_LONG__c = 'Tempe'),
            sortBy
        );
        SortableAcademicIntegrityData eq2 = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SSR_MTG_LOC_LONG__c = 'Tempe'),
            sortBy
        );
        SortableAcademicIntegrityData lesser = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SSR_MTG_LOC_LONG__c = 'Downtown'),
            sortBy
        );
        SortableAcademicIntegrityData greater = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SSR_MTG_LOC_LONG__c = 'Mesa'),
            sortBy
        );

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByGrade() {
        String sortBy = 'Grade';

        SortableAcademicIntegrityData eq1 = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(CRSE_GRADE_OFF__c = 'B-'),
            sortBy
        );
        SortableAcademicIntegrityData eq2 = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(CRSE_GRADE_OFF__c = 'B-'),
            sortBy
        );
        SortableAcademicIntegrityData lesser = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(CRSE_GRADE_OFF__c = 'A+'),
            sortBy
        );
        SortableAcademicIntegrityData greater = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(CRSE_GRADE_OFF__c = 'C+'),
            sortBy
        );
        SortableAcademicIntegrityData nulled = new SortableAcademicIntegrityData(new PS_ASU_SP_CLASS_V__x(), sortBy);

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assert(0 < nulled.compareTo(lesser));
        System.assert(0 > lesser.compareTo(nulled));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByInvalidType() {
        String sortBy = 'INVALID';

        SortableAcademicIntegrityData eq1 = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'SP201'),
            sortBy
        );
        SortableAcademicIntegrityData eq2 = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'SP201'),
            sortBy
        );
        SortableAcademicIntegrityData lesser = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'FA201'),
            sortBy
        );
        SortableAcademicIntegrityData greater = new SortableAcademicIntegrityData(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'SP202'),
            sortBy
        );

        System.assertEquals(0, lesser.compareTo(greater));
        System.assertEquals(0, greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }
}