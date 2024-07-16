@isTest
private class StudentProfileSortAcademicIntegrityTest {
    @isTest
    private static void testSortByClass() {
        String sortBy = 'Class';

        StudentProfileSortAcademicIntegrity eq1 = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(CLASS_NBR__c = 'CSE454'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity eq2 = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(CLASS_NBR__c = 'CSE454'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity lesser = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(CLASS_NBR__c = 'ASU101'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity greater = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(CLASS_NBR__c = 'GED340'),
            sortBy
        );

        System.debug(
            'Comparing Strings: thisValue=' +
                lesser.academicIntegrityDataItem.CLASS_NBR__c +
                ', thatValue=' +
                greater.academicIntegrityDataItem.CLASS_NBR__c
        );
        System.assert(0 > lesser.compareTo(greater), 'Expected lesser to be less than greater');
        System.assert(0 < greater.compareTo(lesser), 'Expected greater to be greater than lesser');
        System.assertEquals(0, eq1.compareTo(eq2), 'Expected equal items to be equal');
    }

    @isTest
    private static void testSortByCourse() {
        String sortBy = 'Course';

        StudentProfileSortAcademicIntegrity eq1 = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SUBJECT__c = 'CSE', CATALOG_NBR__c = '454'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity eq2 = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SUBJECT__c = 'CSE', CATALOG_NBR__c = '454'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity lesser = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SUBJECT__c = 'ASU', CATALOG_NBR__c = '101'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity greater = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SUBJECT__c = 'GED', CATALOG_NBR__c = '340'),
            sortBy
        );

        System.debug(
            'Comparing Strings: thisValue=' +
                lesser.academicIntegrityDataItem.SUBJECT__c +
                lesser.academicIntegrityDataItem.CATALOG_NBR__c +
                ', thatValue=' +
                greater.academicIntegrityDataItem.SUBJECT__c +
                greater.academicIntegrityDataItem.CATALOG_NBR__c
        );
        System.assert(0 > lesser.compareTo(greater), 'Expected lesser to be less than greater');
        System.assert(0 < greater.compareTo(lesser), 'Expected greater to be greater than lesser');
        System.assertEquals(0, eq1.compareTo(eq2), 'Expected equal items to be equal');
    }

    @isTest
    private static void testSortByDates() {
        String sortBy = 'Dates';

        StudentProfileSortAcademicIntegrity eq1 = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(ASU_SCH_DATES__c = 'Summer Semester'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity eq2 = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(ASU_SCH_DATES__c = 'Summer Semester'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity lesser = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(ASU_SCH_DATES__c = 'Fall Semester'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity greater = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(ASU_SCH_DATES__c = 'Spring Semester'),
            sortBy
        );

        System.debug(
            'Comparing Strings: thisValue=' +
                lesser.academicIntegrityDataItem.ASU_SCH_DATES__c +
                ', thatValue=' +
                greater.academicIntegrityDataItem.ASU_SCH_DATES__c
        );
        System.assert(0 > lesser.compareTo(greater), 'Expected lesser to be less than greater');
        System.assert(0 < greater.compareTo(lesser), 'Expected greater to be greater than lesser');
        System.assertEquals(0, eq1.compareTo(eq2), 'Expected equal items to be equal');
    }

    @isTest
    private static void testSortByDays() {
        String sortBy = 'Days';

        StudentProfileSortAcademicIntegrity eq1 = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SCH_HTML_DAY1__c = 'M,W,F'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity eq2 = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SCH_HTML_DAY1__c = 'M,W,F'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity lesser = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SCH_HTML_DAY1__c = 'M'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity greater = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SCH_HTML_DAY1__c = 'W'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity nulled = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(),
            sortBy
        );

        System.debug(
            'Comparing Strings: thisValue=' +
                lesser.academicIntegrityDataItem.SCH_HTML_DAY1__c +
                ', thatValue=' +
                greater.academicIntegrityDataItem.SCH_HTML_DAY1__c
        );
        System.assert(0 > lesser.compareTo(greater), 'Expected lesser to be less than greater');
        System.assert(0 < greater.compareTo(lesser), 'Expected greater to be greater than lesser');
        System.assert(0 > nulled.compareTo(lesser), 'Expected nulled to be less than lesser');
        System.assert(0 < lesser.compareTo(nulled), 'Expected lesser to be greater than nulled');
        System.assertEquals(0, eq1.compareTo(eq2), 'Expected equal items to be equal');
    }

    @isTest
    private static void testSortByGrade() {
        String sortBy = 'Grade';

        StudentProfileSortAcademicIntegrity eq1 = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(CRSE_GRADE_OFF__c = 'B-'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity eq2 = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(CRSE_GRADE_OFF__c = 'B-'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity lesser = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(CRSE_GRADE_OFF__c = 'A+'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity greater = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(CRSE_GRADE_OFF__c = 'C+'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity nulled = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(),
            sortBy
        );

        System.debug(
            'Comparing Strings: thisValue=' +
                lesser.academicIntegrityDataItem.CRSE_GRADE_OFF__c +
                ', thatValue=' +
                greater.academicIntegrityDataItem.CRSE_GRADE_OFF__c
        );
        System.assert(0 > lesser.compareTo(greater), 'Expected lesser to be less than greater');
        System.assert(0 < greater.compareTo(lesser), 'Expected greater to be greater than lesser');
        System.assert(0 > nulled.compareTo(lesser), 'Expected nulled to be less than lesser');
        System.assert(0 < lesser.compareTo(nulled), 'Expected lesser to be greater than nulled');
        System.assertEquals(0, eq1.compareTo(eq2), 'Expected equal items to be equal');
    }

    @isTest
    private static void testSortByInstructor() {
        String sortBy = 'Instructor';

        StudentProfileSortAcademicIntegrity eq1 = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(FT_FULL_NAME__c = 'Roberts'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity eq2 = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(FT_FULL_NAME__c = 'Roberts'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity lesser = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(FT_FULL_NAME__c = 'Addams'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity greater = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(FT_FULL_NAME__c = 'Johnsmith'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity nulled = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(),
            sortBy
        );

        System.debug(
            'Comparing Strings: thisValue=' +
                lesser.academicIntegrityDataItem.FT_FULL_NAME__c +
                ', thatValue=' +
                greater.academicIntegrityDataItem.FT_FULL_NAME__c
        );
        System.assert(0 > lesser.compareTo(greater), 'Expected lesser to be less than greater');
        System.assert(0 < greater.compareTo(lesser), 'Expected greater to be greater than lesser');
        System.assert(0 > nulled.compareTo(lesser), 'Expected nulled to be less than lesser');
        System.assert(0 < lesser.compareTo(nulled), 'Expected lesser to be greater than nulled');
        System.assertEquals(0, eq1.compareTo(eq2), 'Expected equal items to be equal');
    }

    @isTest
    private static void testSortByLocation() {
        String sortBy = 'Location';

        StudentProfileSortAcademicIntegrity eq1 = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SSR_MTG_LOC_LONG__c = 'Tempe'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity eq2 = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SSR_MTG_LOC_LONG__c = 'Tempe'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity lesser = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SSR_MTG_LOC_LONG__c = 'Downtown'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity greater = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SSR_MTG_LOC_LONG__c = 'Mesa'),
            sortBy
        );

        System.debug(
            'Comparing Strings: thisValue=' +
                lesser.academicIntegrityDataItem.SSR_MTG_LOC_LONG__c +
                ', thatValue=' +
                greater.academicIntegrityDataItem.SSR_MTG_LOC_LONG__c
        );
        System.assert(0 > lesser.compareTo(greater), 'Expected lesser to be less than greater');
        System.assert(0 < greater.compareTo(lesser), 'Expected greater to be greater than lesser');
        System.assertEquals(0, eq1.compareTo(eq2), 'Expected equal items to be equal');
    }

    @isTest
    private static void testSortBySession() {
        String sortBy = 'Session';

        StudentProfileSortAcademicIntegrity eq1 = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'SP201'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity eq2 = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'SP201'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity lesser = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'FA201'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity greater = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'SP202'),
            sortBy
        );

        System.debug(
            'Comparing Strings: thisValue=' +
                lesser.academicIntegrityDataItem.SESSION_CODE__c +
                ', thatValue=' +
                greater.academicIntegrityDataItem.SESSION_CODE__c
        );
        System.assert(0 > lesser.compareTo(greater), 'Expected lesser to be less than greater');
        System.assert(0 < greater.compareTo(lesser), 'Expected greater to be greater than lesser');
        System.assertEquals(0, eq1.compareTo(eq2), 'Expected equal items to be equal');
    }

    @isTest
    private static void testSortByTimes() {
        String sortBy = 'Times';

        StudentProfileSortAcademicIntegrity eq1 = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SCH_DAILY_TIME__c = '9:00-11:00'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity eq2 = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SCH_DAILY_TIME__c = '9:00-11:00'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity lesser = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SCH_DAILY_TIME__c = '12:00-14:00'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity greater = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SCH_DAILY_TIME__c = '13:30-15:00'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity nulled = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(),
            sortBy
        );

        System.debug(
            'Comparing Strings: thisValue=' +
                lesser.academicIntegrityDataItem.SCH_DAILY_TIME__c +
                ', thatValue=' +
                greater.academicIntegrityDataItem.SCH_DAILY_TIME__c
        );
        System.assert(0 > lesser.compareTo(greater), 'Expected lesser to be less than greater');
        System.assert(0 < greater.compareTo(lesser), 'Expected greater to be greater than lesser');
        System.assert(0 > nulled.compareTo(lesser), 'Expected nulled to be less than lesser');
        System.assert(0 < lesser.compareTo(nulled), 'Expected lesser to be greater than nulled');
        System.assertEquals(0, eq1.compareTo(eq2), 'Expected equal items to be equal');
    }

    @isTest
    private static void testSortByTitle() {
        String sortBy = 'Title';

        StudentProfileSortAcademicIntegrity eq1 = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(CLASS_DESCR__c = 'First-Year Composition'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity eq2 = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(CLASS_DESCR__c = 'First-Year Composition'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity lesser = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(CLASS_DESCR__c = 'Arizona History'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity greater = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(CLASS_DESCR__c = 'Facts or Fiction'),
            sortBy
        );

        System.debug(
            'Comparing Strings: thisValue=' +
                lesser.academicIntegrityDataItem.CLASS_DESCR__c +
                ', thatValue=' +
                greater.academicIntegrityDataItem.CLASS_DESCR__c
        );
        System.assert(0 > lesser.compareTo(greater), 'Expected lesser to be less than greater');
        System.assert(0 < greater.compareTo(lesser), 'Expected greater to be greater than lesser');
        System.assertEquals(0, eq1.compareTo(eq2), 'Expected equal items to be equal');
    }

    @isTest
    private static void testSortByTopic() {
        String sortBy = 'Topic';

        StudentProfileSortAcademicIntegrity eq1 = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SSR_CLSTOPIC_DESCR__c = 'SP201'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity eq2 = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SSR_CLSTOPIC_DESCR__c = 'SP201'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity lesser = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SSR_CLSTOPIC_DESCR__c = 'FA201'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity greater = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SSR_CLSTOPIC_DESCR__c = 'SP202'),
            sortBy
        );

        System.debug(
            'Comparing Strings: thisValue=' +
                lesser.academicIntegrityDataItem.SSR_CLSTOPIC_DESCR__c +
                ', thatValue=' +
                greater.academicIntegrityDataItem.SSR_CLSTOPIC_DESCR__c
        );
        System.assert(0 > lesser.compareTo(greater), 'Expected lesser to be less than greater');
        System.assert(0 < greater.compareTo(lesser), 'Expected greater to be greater than lesser');
        System.assertEquals(0, eq1.compareTo(eq2), 'Expected equal items to be equal');
    }

    @isTest
    private static void testSortByUnits() {
        String sortBy = 'Units';

        StudentProfileSortAcademicIntegrity eq1 = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(UNT_TAKEN__c = 68.0),
            sortBy
        );
        StudentProfileSortAcademicIntegrity eq2 = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(UNT_TAKEN__c = 68.0),
            sortBy
        );
        StudentProfileSortAcademicIntegrity lesser = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(UNT_TAKEN__c = 68.0),
            sortBy
        );
        StudentProfileSortAcademicIntegrity greater = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(UNT_TAKEN__c = 300.0),
            sortBy
        );
        StudentProfileSortAcademicIntegrity nulled = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(),
            sortBy
        );

        System.debug(
            'Comparing lesser and greater in testSortByUnits: lesser=' +
                lesser.academicIntegrityDataItem.UNT_TAKEN__c +
                ', greater=' +
                greater.academicIntegrityDataItem.UNT_TAKEN__c
        );
        System.assert(0 > lesser.compareTo(greater), 'Expected lesser to be less than greater');
        System.assert(0 < greater.compareTo(lesser), 'Expected greater to be greater than lesser');
        System.assert(0 > nulled.compareTo(lesser), 'Expected nulled to be less than lesser');
        System.assert(0 < lesser.compareTo(nulled), 'Expected lesser to be greater than nulled');
        System.assertEquals(0, eq1.compareTo(eq2), 'Expected equal items to be equal');
    }

    @isTest
    private static void testSortByInvalidType() {
        String sortBy = 'INVALID';

        StudentProfileSortAcademicIntegrity eq1 = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'SP201'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity eq2 = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'SP201'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity lesser = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'FA201'),
            sortBy
        );
        StudentProfileSortAcademicIntegrity greater = new StudentProfileSortAcademicIntegrity(
            new PS_ASU_SP_CLASS_V__x(SESSION_CODE__c = 'SP202'),
            sortBy
        );

        System.assertEquals(
            0,
            lesser.compareTo(greater),
            'Expected lesser to be equal to greater for invalid sort type'
        );
        System.assertEquals(
            0,
            greater.compareTo(lesser),
            'Expected greater to be equal to lesser for invalid sort type'
        );
        System.assertEquals(0, eq1.compareTo(eq2), 'Expected equal items to be equal for invalid sort type');
    }
}