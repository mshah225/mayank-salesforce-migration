@isTest
public with sharing class StudentProfileAcademicIntegritySortableTest {
    @isTest
    private static void testSortBySession() {
        String sortBy = 'Session';

        StudentProfileAcademicIntegritySortable eq1 = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'SP201'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable eq2 = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'SP201'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable lesser = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'FA201'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable greater = new StudentProfileAcademicIntegritySortable(
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

        StudentProfileAcademicIntegritySortable eq1 = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(CLASS_NBR__c = 'CSE454'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable eq2 = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(CLASS_NBR__c = 'CSE454'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable lesser = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(CLASS_NBR__c = 'ASU101'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable greater = new StudentProfileAcademicIntegritySortable(
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

        StudentProfileAcademicIntegritySortable eq1 = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(SUBJECT__c = 'CSE', CATALOG_NBR__c = '454'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable eq2 = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(SUBJECT__c = 'CSE', CATALOG_NBR__c = '454'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable lesser = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(SUBJECT__c = 'ASU', CATALOG_NBR__c = '101'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable greater = new StudentProfileAcademicIntegritySortable(
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

        StudentProfileAcademicIntegritySortable eq1 = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(CLASS_DESCR__c = 'First-Year Composition'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable eq2 = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(CLASS_DESCR__c = 'First-Year Composition'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable lesser = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(CLASS_DESCR__c = 'Arizona History'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable greater = new StudentProfileAcademicIntegritySortable(
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

        StudentProfileAcademicIntegritySortable eq1 = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(SSR_CLSTOPIC_DESCR__c = 'SP201'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable eq2 = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(SSR_CLSTOPIC_DESCR__c = 'SP201'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable lesser = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(SSR_CLSTOPIC_DESCR__c = 'FA201'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable greater = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(SSR_CLSTOPIC_DESCR__c = 'SP202'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable nulled = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(),
            sortBy
        );

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assert(0 < nulled.compareTo(lesser));
        System.assert(0 > lesser.compareTo(nulled));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByUnits() {
        String sortBy = 'Units';

        StudentProfileAcademicIntegritySortable eq1 = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(UNT_TAKEN__c = 48),
            sortBy
        );
        StudentProfileAcademicIntegritySortable eq2 = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(UNT_TAKEN__c = 48),
            sortBy
        );
        StudentProfileAcademicIntegritySortable lesser = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(UNT_TAKEN__c = 68),
            sortBy
        );
        StudentProfileAcademicIntegritySortable greater = new StudentProfileAcademicIntegritySortable(
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

        StudentProfileAcademicIntegritySortable eq1 = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(FT_FULL_NAME__c = 'Roberts'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable eq2 = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(FT_FULL_NAME__c = 'Roberts'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable lesser = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(FT_FULL_NAME__c = 'Addams'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable greater = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(FT_FULL_NAME__c = 'Johnsmith'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable nulled = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(),
            sortBy
        );

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assert(0 < nulled.compareTo(lesser));
        System.assert(0 > lesser.compareTo(nulled));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByDays() {
        String sortBy = 'Days';

        StudentProfileAcademicIntegritySortable eq1 = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(SCH_HTML_DAY1__c = 'M,W,F'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable eq2 = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(SCH_HTML_DAY1__c = 'M,W,F'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable lesser = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(SCH_HTML_DAY1__c = 'M'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable greater = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(SCH_HTML_DAY1__c = 'W'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable nulled = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(),
            sortBy
        );

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assert(0 < nulled.compareTo(lesser));
        System.assert(0 > lesser.compareTo(nulled));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByTimes() {
        String sortBy = 'Times';

        StudentProfileAcademicIntegritySortable eq1 = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(SCH_DAILY_TIME__c = '9:00-11:00'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable eq2 = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(SCH_DAILY_TIME__c = '9:00-11:00'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable lesser = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(SCH_DAILY_TIME__c = '12:00-14:00'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable greater = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(SCH_DAILY_TIME__c = '13:30-15:00'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable nulled = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(),
            sortBy
        );

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assert(0 < nulled.compareTo(lesser));
        System.assert(0 > lesser.compareTo(nulled));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByDates() {
        String sortBy = 'Dates';

        StudentProfileAcademicIntegritySortable eq1 = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(ASU_SCH_DATES__c = 'Summer Semester'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable eq2 = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(ASU_SCH_DATES__c = 'Summer Semester'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable lesser = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(ASU_SCH_DATES__c = 'Fall Semester'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable greater = new StudentProfileAcademicIntegritySortable(
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

        StudentProfileAcademicIntegritySortable eq1 = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(SSR_MTG_LOC_LONG__c = 'Tempe'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable eq2 = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(SSR_MTG_LOC_LONG__c = 'Tempe'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable lesser = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(SSR_MTG_LOC_LONG__c = 'Downtown'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable greater = new StudentProfileAcademicIntegritySortable(
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

        StudentProfileAcademicIntegritySortable eq1 = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(CRSE_GRADE_OFF__c = 'B-'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable eq2 = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(CRSE_GRADE_OFF__c = 'B-'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable lesser = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(CRSE_GRADE_OFF__c = 'A+'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable greater = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(CRSE_GRADE_OFF__c = 'C+'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable nulled = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(),
            sortBy
        );

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assert(0 < nulled.compareTo(lesser));
        System.assert(0 > lesser.compareTo(nulled));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByInvalidType() {
        String sortBy = 'INVALID';

        StudentProfileAcademicIntegritySortable eq1 = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'SP201'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable eq2 = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'SP201'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable lesser = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'FA201'),
            sortBy
        );
        StudentProfileAcademicIntegritySortable greater = new StudentProfileAcademicIntegritySortable(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'SP202'),
            sortBy
        );

        System.assertEquals(0, lesser.compareTo(greater));
        System.assertEquals(0, greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }
}