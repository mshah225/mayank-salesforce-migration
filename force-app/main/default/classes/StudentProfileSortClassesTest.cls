@isTest
public with sharing class StudentProfileSortClassesTest {
    @isTest
    private static void testSortBySession() {
        String sortBy = 'Session';

        StudentProfileSortClasses eq1 = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'SP201'),
            sortBy
        );
        StudentProfileSortClasses eq2 = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'SP201'),
            sortBy
        );
        StudentProfileSortClasses lesser = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'FA201'),
            sortBy
        );
        StudentProfileSortClasses greater = new StudentProfileSortClasses(
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

        StudentProfileSortClasses eq1 = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(CLASS_NBR__c = 'CSE454'),
            sortBy
        );
        StudentProfileSortClasses eq2 = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(CLASS_NBR__c = 'CSE454'),
            sortBy
        );
        StudentProfileSortClasses lesser = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(CLASS_NBR__c = 'ASU101'),
            sortBy
        );
        StudentProfileSortClasses greater = new StudentProfileSortClasses(
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

        StudentProfileSortClasses eq1 = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(SUBJECT__c = 'CSE', CATALOG_NBR__c = '454'),
            sortBy
        );
        StudentProfileSortClasses eq2 = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(SUBJECT__c = 'CSE', CATALOG_NBR__c = '454'),
            sortBy
        );
        StudentProfileSortClasses lesser = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(SUBJECT__c = 'ASU', CATALOG_NBR__c = '101'),
            sortBy
        );
        StudentProfileSortClasses greater = new StudentProfileSortClasses(
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

        StudentProfileSortClasses eq1 = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(CLASS_DESCR__c = 'First-Year Composition'),
            sortBy
        );
        StudentProfileSortClasses eq2 = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(CLASS_DESCR__c = 'First-Year Composition'),
            sortBy
        );
        StudentProfileSortClasses lesser = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(CLASS_DESCR__c = 'Arizona History'),
            sortBy
        );
        StudentProfileSortClasses greater = new StudentProfileSortClasses(
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

        StudentProfileSortClasses eq1 = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(SSR_CLSTOPIC_DESCR__c = 'SP201'),
            sortBy
        );
        StudentProfileSortClasses eq2 = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(SSR_CLSTOPIC_DESCR__c = 'SP201'),
            sortBy
        );
        StudentProfileSortClasses lesser = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(SSR_CLSTOPIC_DESCR__c = 'FA201'),
            sortBy
        );
        StudentProfileSortClasses greater = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(SSR_CLSTOPIC_DESCR__c = 'SP202'),
            sortBy
        );
        StudentProfileSortClasses nulled = new StudentProfileSortClasses(new PS_ASU_SP_CLASS_V__x(), sortBy);

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assert(0 < nulled.compareTo(lesser));
        System.assert(0 > lesser.compareTo(nulled));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByUnits() {
        String sortBy = 'Units';

        StudentProfileSortClasses eq1 = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(UNT_TAKEN__c = 48),
            sortBy
        );
        StudentProfileSortClasses eq2 = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(UNT_TAKEN__c = 48),
            sortBy
        );
        StudentProfileSortClasses lesser = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(UNT_TAKEN__c = 68),
            sortBy
        );
        StudentProfileSortClasses greater = new StudentProfileSortClasses(
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

        StudentProfileSortClasses eq1 = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(FT_FULL_NAME__c = 'Roberts'),
            sortBy
        );
        StudentProfileSortClasses eq2 = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(FT_FULL_NAME__c = 'Roberts'),
            sortBy
        );
        StudentProfileSortClasses lesser = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(FT_FULL_NAME__c = 'Addams'),
            sortBy
        );
        StudentProfileSortClasses greater = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(FT_FULL_NAME__c = 'Johnsmith'),
            sortBy
        );
        StudentProfileSortClasses nulled = new StudentProfileSortClasses(new PS_ASU_SP_CLASS_V__x(), sortBy);

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assert(0 < nulled.compareTo(lesser));
        System.assert(0 > lesser.compareTo(nulled));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByDays() {
        String sortBy = 'Days';

        StudentProfileSortClasses eq1 = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(SCH_HTML_DAY1__c = 'M,W,F'),
            sortBy
        );
        StudentProfileSortClasses eq2 = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(SCH_HTML_DAY1__c = 'M,W,F'),
            sortBy
        );
        StudentProfileSortClasses lesser = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(SCH_HTML_DAY1__c = 'M'),
            sortBy
        );
        StudentProfileSortClasses greater = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(SCH_HTML_DAY1__c = 'W'),
            sortBy
        );
        StudentProfileSortClasses nulled = new StudentProfileSortClasses(new PS_ASU_SP_CLASS_V__x(), sortBy);

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assert(0 < nulled.compareTo(lesser));
        System.assert(0 > lesser.compareTo(nulled));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByTimes() {
        String sortBy = 'Times';

        StudentProfileSortClasses eq1 = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(SCH_DAILY_TIME__c = '9:00-11:00'),
            sortBy
        );
        StudentProfileSortClasses eq2 = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(SCH_DAILY_TIME__c = '9:00-11:00'),
            sortBy
        );
        StudentProfileSortClasses lesser = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(SCH_DAILY_TIME__c = '12:00-14:00'),
            sortBy
        );
        StudentProfileSortClasses greater = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(SCH_DAILY_TIME__c = '13:30-15:00'),
            sortBy
        );
        StudentProfileSortClasses nulled = new StudentProfileSortClasses(new PS_ASU_SP_CLASS_V__x(), sortBy);

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assert(0 < nulled.compareTo(lesser));
        System.assert(0 > lesser.compareTo(nulled));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByDates() {
        String sortBy = 'Dates';

        StudentProfileSortClasses eq1 = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(ASU_SCH_DATES__c = 'Summer Semester'),
            sortBy
        );
        StudentProfileSortClasses eq2 = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(ASU_SCH_DATES__c = 'Summer Semester'),
            sortBy
        );
        StudentProfileSortClasses lesser = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(ASU_SCH_DATES__c = 'Fall Semester'),
            sortBy
        );
        StudentProfileSortClasses greater = new StudentProfileSortClasses(
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

        StudentProfileSortClasses eq1 = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(SSR_MTG_LOC_LONG__c = 'Tempe'),
            sortBy
        );
        StudentProfileSortClasses eq2 = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(SSR_MTG_LOC_LONG__c = 'Tempe'),
            sortBy
        );
        StudentProfileSortClasses lesser = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(SSR_MTG_LOC_LONG__c = 'Downtown'),
            sortBy
        );
        StudentProfileSortClasses greater = new StudentProfileSortClasses(
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

        StudentProfileSortClasses eq1 = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(CRSE_GRADE_OFF__c = 'B-'),
            sortBy
        );
        StudentProfileSortClasses eq2 = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(CRSE_GRADE_OFF__c = 'B-'),
            sortBy
        );
        StudentProfileSortClasses lesser = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(CRSE_GRADE_OFF__c = 'A+'),
            sortBy
        );
        StudentProfileSortClasses greater = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(CRSE_GRADE_OFF__c = 'C+'),
            sortBy
        );
        StudentProfileSortClasses nulled = new StudentProfileSortClasses(new PS_ASU_SP_CLASS_V__x(), sortBy);

        System.assert(0 > lesser.compareTo(greater));
        System.assert(0 < greater.compareTo(lesser));
        System.assert(0 < nulled.compareTo(lesser));
        System.assert(0 > lesser.compareTo(nulled));
        System.assertEquals(0, eq1.compareTo(eq2));
    }

    @isTest
    private static void testSortByInvalidType() {
        String sortBy = 'INVALID';

        StudentProfileSortClasses eq1 = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'SP201'),
            sortBy
        );
        StudentProfileSortClasses eq2 = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'SP201'),
            sortBy
        );
        StudentProfileSortClasses lesser = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'FA201'),
            sortBy
        );
        StudentProfileSortClasses greater = new StudentProfileSortClasses(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'SP202'),
            sortBy
        );

        System.assertEquals(0, lesser.compareTo(greater));
        System.assertEquals(0, greater.compareTo(lesser));
        System.assertEquals(0, eq1.compareTo(eq2));
    }
}