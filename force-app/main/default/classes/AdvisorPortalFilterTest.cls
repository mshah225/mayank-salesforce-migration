@IsTest
public class AdvisorPortalFilterTest {
    // Starting at v1, test all fields that have changed from one version to the next to make sure they upgrade successfully
    @IsTest
    private static void testUpgradingToMostRecentVersion() {
        List<String> subjects = new List<String>{ 'eat', 'spiky hair....' };
        List<String> categories = new List<String>{ 'Academic Standing', 'Not Enrolled' };
        List<String> subcategories = new List<String>{
            'Low GPA',
            'Return to Good Standing',
            'Not Enrolled in Next Term'
        };

        AdvisorPortalFilter filter = new AdvisorPortalFilter();
        filter.version = 'v1';
        filter.caseSubject = String.join(subjects, ';');
        filter.caseCategory = String.join(categories, ';');
        filter.caseSubCategory = String.join(subcategories, ';');

        filter.upgradeToMostRecentVersion();

        // Subjects: v1 -> v2 began base64 encoding values
        System.assertEquals(AdvisorPortalFilter.mostRecentVersion, filter.version);
        System.assertEquals(subjects.size(), filter.getCaseSubjects().size());
        for (String expectedSubject : subjects) {
            System.assert(
                filter.getCaseSubjects().contains(expectedSubject),
                'Expected "' + expectedSubject + '" in array ' + filter.getCaseSubjects() + ', but did not find it.'
            );
        }

        // Categories: v1 -> v2 began base64 encoding values
        System.assertEquals(categories.size(), filter.getCaseCategories().size());
        for (String expectedCategory : categories) {
            System.assert(
                filter.getCaseCategories().contains(expectedCategory),
                'Expected "' + expectedCategory + '" in array ' + filter.getCaseCategories() + ', but did not find it.'
            );
        }

        // Subcategories: v1 -> v2 began base64 encoding values
        System.assertEquals(subcategories.size(), filter.getCaseSubCategories().size());
        for (String expectedSubcat : subcategories) {
            System.assert(
                filter.getCaseSubCategories().contains(expectedSubcat),
                'Expected "' + expectedSubcat + '" in array ' + filter.getCaseSubCategories() + ', but did not find it.'
            );
        }
    }

    @IsTest
    private static void testDeserializer() {
        AdvisorPortalFilter filter1 = AdvisorPortalFilter.deserialize(null);
        AdvisorPortalFilter filter2 = AdvisorPortalFilter.deserialize('');
        AdvisorPortalFilter filter3 = AdvisorPortalFilter.deserialize('{}');
        AdvisorPortalFilter filter4 = AdvisorPortalFilter.deserialize('{"version": "v2", "career":"GRD"}');

        System.assertEquals(null, filter1);
        System.assertEquals(null, filter2);
        System.assertEquals(null, filter3);
        System.assertEquals('GRD', filter4.getCareer());
    }

    @IsTest
    private static void testGetCaseState() {
        String filterStr = '{"version":"v3","caseTypeState":"AllCasesState"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        System.assertEquals('AllCasesState', filter.getCaseTypeState());
    }

    @IsTest
    private static void testGetCareer() {
        String filterStr = '{"version":"v3","career":"GRD"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        System.assertEquals('GRD', filter.getCareer());
    }

    @IsTest
    private static void testGetStudentString() {
        String filterStr = '{"version":"v3","studentString":"rnordman"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        System.assertEquals('rnordman', filter.getStudentString());
    }

    @IsTest
    private static void testGetCampus() {
        String filterStr = '{"version":"v3","campus":"CAMP1;CAMP2"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        System.assertEquals('CAMP1;CAMP2', String.join(filter.getCampuses(), ';'));
    }

    @IsTest
    private static void testGetAcademicLevel() {
        String filterStr = '{"version":"v3","academicLevel":"Freshman;Sophmore"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        System.assertEquals('Freshman;Sophmore', String.join(filter.getAcademicLevels(), ';'));
    }

    @IsTest
    private static void testGetStudentGroupCode() {
        String filterStr = '{"version":"v3","studentGroupCode":"AZ330"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        System.assertEquals('AZ330', filter.getStudentGroupCode());
    }

    @IsTest
    private static void testGetMajor() {
        String filterStr = '{"version":"v3","major":"TVFILM"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        System.assertEquals('TVFILM', filter.getMajor());
    }

    @IsTest
    private static void testGetDegreeLevel() {
        String filterStr = '{"version":"v3","degreeLevel":"master;doctorate"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        System.assertEquals('master;doctorate', String.join(filter.getDegreeLevels(), ';'));
    }

    @IsTest
    private static void testGetAcademicProgram() {
        String filterStr = '{"version":"v3","academicProgram":"TVFILM;CRONKITE;ENG"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        System.assertEquals('TVFILM;CRONKITE;ENG', String.join(filter.getAcademicPrograms(), ';'));
    }

    @IsTest
    private static void testGetSchoolDepartment() {
        String filterStr = '{"version":"v3","schoolDepartment":"TECH;LIB"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        System.assertEquals('TECH;LIB', String.join(filter.getSchoolDepartments(), ';'));
    }

    @IsTest
    private static void testGetAcademicPlan() {
        String filterStr = '{"version":"v3","academicPlan":"SF;BA;PM"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        System.assertEquals('SF;BA;PM', String.join(filter.getAcademicPlans(), ';'));
    }

    @IsTest
    private static void testGetAdmitTermFrom() {
        String filterStr = '{"version":"v3","admitTermFrom":"2201"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        System.assertEquals('2201', filter.getAdmitTermFrom());
    }

    @IsTest
    private static void testGetAdmitTermTo() {
        String filterStr = '{"version":"v3","admitTermTo":"2207"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        System.assertEquals('2207', filter.getAdmitTermTo());
    }

    @IsTest
    private static void testGetResidency() {
        String filterStr = '{"version":"v3","residency":"international;resident"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        System.assertEquals('international;resident', String.join(filter.getResidencies(), ';'));
    }

    @IsTest
    private static void testGetCaseStatus() {
        String filterStr = '{"version":"v3","caseStatus":"busy signal"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        System.assertEquals('busy signal', String.join(filter.getCaseStatuses(), ';'));
    }

    @IsTest
    private static void testGetCaseCategory() {
        List<String> categories = new List<String>{ 'CAT-0', 'CAT-33' };
        List<String> b64Categories = new List<String>();
        for (String cat : categories)
            b64Categories.add(EncodingUtil.base64Encode(Blob.valueOf(cat)));

        String filterStr = '{"version":"v3","caseCategory":"' + String.join(b64Categories, ';') + '"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        System.assertEquals(String.join(categories, ';'), String.join(filter.getCaseCategories(), ';'));
    }

    @IsTest
    private static void testGetCaseSubCategory() {
        List<String> subcategories = new List<String>{ 'SUBCAT-0', 'SUBCAT-33' };
        List<String> b64SubCategories = new List<String>();
        for (String subcat : subcategories)
            b64SubCategories.add(EncodingUtil.base64Encode(Blob.valueOf(subcat)));

        String filterStr = '{"version":"v3","caseSubCategory":"' + String.join(b64SubCategories, ';') + '"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        System.assertEquals(String.join(subcategories, ';'), String.join(filter.getCaseSubCategories(), ';'));
    }

    @IsTest
    private static void testGetCaseSubject() {
        List<String> subjects = new List<String>{ 'eat', 'spiky; or....' };
        List<String> b64Subjects = new List<String>();
        for (String subj : subjects)
            b64Subjects.add(EncodingUtil.base64Encode(Blob.valueOf(subj)));

        String filterStr = '{"version":"v3","caseSubject":"' + String.join(b64Subjects, ';') + '"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        System.assertEquals(String.join(subjects, ';'), String.join(filter.getCaseSubjects(), ';'));
    }

    @IsTest
    private static void testGetSpecialPopulation() {
        String filterStr = '{"version":"v3","specialPopulation":"graduating"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        System.assertEquals('graduating', String.join(filter.getSpecialPopulations(), ';'));
    }

    @IsTest
    private static void testGetOutlookScores() {
        String filterStr = '{"version":"v3","outlookScore":"very low;high"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        List<Decimal> v2OutlookScoreList = filter.getOutlookScores();

        System.assertEquals(5, v2OutlookScoreList.size());
        System.assert(v2OutlookScoreList.contains(Decimal.valueOf(0)));
        System.assert(v2OutlookScoreList.contains(Decimal.valueOf(1)));
        System.assert(v2OutlookScoreList.contains(Decimal.valueOf(2)));
        System.assert(v2OutlookScoreList.contains(Decimal.valueOf(3)));
        System.assert(v2OutlookScoreList.contains(Decimal.valueOf(7)));
    }

    @IsTest
    private static void testGetOutlookChange() {
        String filterStr = '{"version":"v3","outlookChange":"up;no change"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        List<Decimal> v2OutlookChangeList = filter.getOutlookChanges();

        System.assertEquals(2, v2OutlookChangeList.size());
        System.assert(v2OutlookChangeList.contains(Decimal.valueOf(1)));
        System.assert(v2OutlookChangeList.contains(Decimal.valueOf(-1)));
    }

    @IsTest
    private static void testGetCreatedFromDate() {
        String filterStr = '{"version":"v3","createdFromDate":"2022-01-02"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        System.assertEquals(
            Datetime.valueOf('2022-01-02 00:00:00').formatGmt('yyyy-MM-dd\'T\'HH:mm:ssZ'),
            filter.getCreatedFromDate().formatGmt('yyyy-MM-dd\'T\'HH:mm:ssZ')
        );
    }

    @IsTest
    private static void testGetCreatedToDate() {
        String filterStr = '{"version":"v3","createdToDate":"2022-01-02"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        System.assertEquals(
            Datetime.valueOf('2022-01-02 23:59:59').formatGmt('yyyy-MM-dd\'T\'HH:mm:ssZ'),
            filter.getCreatedToDate().formatGmt('yyyy-MM-dd\'T\'HH:mm:ssZ')
        );
    }

    @IsTest
    private static void testGetFollowUpFromDate() {
        String filterStr = '{"version":"v3","followUpFromDate":"2022-01-02"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        System.assertEquals(2022, filter.getFollowUpFromDate().year());
        System.assertEquals(1, filter.getFollowUpFromDate().month());
        System.assertEquals(2, filter.getFollowUpFromDate().day());
    }

    @IsTest
    private static void testGetFollowUpToDate() {
        String filterStr = '{"version":"v3","followUpToDate":"2022-01-02"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        System.assertEquals(2022, filter.getFollowUpToDate().year());
        System.assertEquals(1, filter.getFollowUpToDate().month());
        System.assertEquals(2, filter.getFollowUpToDate().day());
    }

    @IsTest
    private static void testGetPersistenceFromDate() {
        String filterStr = '{"version":"v3","persistenceFromDate":"2022-01-02"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        System.assertEquals(2022, filter.getPersistenceFromDate().year());
        System.assertEquals(1, filter.getPersistenceFromDate().month());
        System.assertEquals(2, filter.getPersistenceFromDate().day());
    }

    @IsTest
    private static void testGetPersistenceToDate() {
        String filterStr = '{"version":"v3","persistenceToDate":"2022-01-02"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        System.assertEquals(2022, filter.getPersistenceToDate().year());
        System.assertEquals(1, filter.getPersistenceToDate().month());
        System.assertEquals(2, filter.getPersistenceToDate().day());
    }

    @IsTest
    private static void testGetOwnerIds() {
        String filterStr = '{"version":"v3","ownerIds":"USER-1;USER-2;USER-3"}';

        AdvisorPortalFilter filter = AdvisorPortalFilter.deserialize(filterStr);

        System.assertEquals('USER-1;USER-2;USER-3', String.join(filter.getOwnerIds(), ';'));
    }
}