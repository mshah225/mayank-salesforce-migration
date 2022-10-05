@IsTest
public class AdvisorPortalFilterTest {
    @IsTest
    private static void testUpgradingToMostRecentVersion() {
        List<String> subjects = new List<String>{ 'eat', 'spiky hair....' };
        List<String> b64Subjects = new List<String>();
        for (String subj : subjects)
            b64Subjects.add(EncodingUtil.base64Encode(Blob.valueOf(subj)));

        String v1FilterStr = '{"version":"v1","caseSubject":"' + String.join(subjects, ';') + '"}';

        AdvisorPortalFilter filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        filter.upgradeToMostRecentVersion();

        System.assertEquals(AdvisorPortalFilter.mostRecentVersion, filter.version);
        System.assertEquals(subjects.size(), filter.getCaseSubjects().size());
        for (String expectedSubject : subjects) {
            System.assert(
                filter.getCaseSubjects().contains(expectedSubject),
                'Expected "' +
                expectedSubject +
                '" in array ' +
                filter.getCaseSubjects() +
                ', but did not find it.'
            );
        }
    }

    @IsTest
    private static void testConvertToFromV1ToMostRecentVersion_caseSubject() {
        String filter_v1_subj = 'TOP-CAT;ORDEAL';
        String filter_vX_subj_expected =
            EncodingUtil.base64Encode(Blob.valueOf('TOP-CAT')) +
            ';' +
            EncodingUtil.base64Encode(Blob.valueOf('ORDEAL'));

        String filter_vX_subj_actual = AdvisorPortalFilter.convStrArrFromRSToRS(
            filter_v1_subj,
            'caseSubject',
            new AdvisorPortalFilter.RuleSet('v1'),
            new AdvisorPortalFilter.RuleSet(AdvisorPortalFilter.mostRecentVersion)
        );

        System.assertEquals(filter_vX_subj_expected, filter_vX_subj_actual);
    }

    @IsTest
    private static void testConvertToFromV1ToMostRecentVersion_caseCategory() {
        String filter_v1_cat = 'BUSTED;RAINING';
        String filter_vX_cat_expected =
            EncodingUtil.base64Encode(Blob.valueOf('BUSTED')) +
            ';' +
            EncodingUtil.base64Encode(Blob.valueOf('RAINING'));

        String filter_vX_cat_actual = AdvisorPortalFilter.convStrArrFromRSToRS(
            filter_v1_cat,
            'caseCategory',
            new AdvisorPortalFilter.RuleSet('v1'),
            new AdvisorPortalFilter.RuleSet(AdvisorPortalFilter.mostRecentVersion)
        );

        System.assertEquals(filter_vX_cat_expected, filter_vX_cat_actual);
    }

    @IsTest
    private static void testConvertToFromV1ToMostRecentVersion_academicPlan() {
        String filter_v1_acadPlan = 'TVFILM;CRONKITE';
        String filter_vX_acadPlan_expected = 'TVFILM;CRONKITE';

        String filter_vX_acadPlan_actual = AdvisorPortalFilter.convStrArrFromRSToRS(
            filter_v1_acadPlan,
            'academicPlan',
            new AdvisorPortalFilter.RuleSet('v1'),
            new AdvisorPortalFilter.RuleSet(AdvisorPortalFilter.mostRecentVersion)
        );

        System.assertEquals(filter_vX_acadPlan_expected, filter_vX_acadPlan_actual);
    }

    @IsTest
    private static void testGetCaseState() {
        String v1FilterStr = '{"version":"v1","caseTypeState":"AllCasesState"}';
        String v2FilterStr = '{"version":"v2","caseTypeState":"AllCasesState"}';

        AdvisorPortalFilter v1Filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        AdvisorPortalFilter v2Filter = (AdvisorPortalFilter) JSON.deserialize(v2FilterStr, AdvisorPortalFilter.class);

        System.assertEquals('AllCasesState', v1Filter.getCaseTypeState());
        System.assertEquals('AllCasesState', v2Filter.getCaseTypeState());
    }

    @IsTest
    private static void testGetCareer() {
        String v1FilterStr = '{"version":"v1","career":"GRD"}';
        String v2FilterStr = '{"version":"v2","career":"GRD"}';

        AdvisorPortalFilter v1Filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        AdvisorPortalFilter v2Filter = (AdvisorPortalFilter) JSON.deserialize(v2FilterStr, AdvisorPortalFilter.class);

        System.assertEquals('GRD', v1Filter.getCareer());
        System.assertEquals('GRD', v2Filter.getCareer());
    }

    @IsTest
    private static void testGetStudentString() {
        String v1FilterStr = '{"version":"v1","studentString":"rnordman"}';
        String v2FilterStr = '{"version":"v2","studentString":"rnordman"}';

        AdvisorPortalFilter v1Filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        AdvisorPortalFilter v2Filter = (AdvisorPortalFilter) JSON.deserialize(v2FilterStr, AdvisorPortalFilter.class);

        System.assertEquals('rnordman', v1Filter.getStudentString());
        System.assertEquals('rnordman', v2Filter.getStudentString());
    }

    @IsTest
    private static void testGetCampus() {
        String v1FilterStr = '{"version":"v1","campus":"CAMP1;CAMP2"}';
        String v2FilterStr = '{"version":"v2","campus":"CAMP1;CAMP2"}';

        AdvisorPortalFilter v1Filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        AdvisorPortalFilter v2Filter = (AdvisorPortalFilter) JSON.deserialize(v2FilterStr, AdvisorPortalFilter.class);

        System.assertEquals('CAMP1;CAMP2', String.join(v1Filter.getCampuses(), ';'));
        System.assertEquals('CAMP1;CAMP2', String.join(v2Filter.getCampuses(), ';'));
    }

    @IsTest
    private static void testGetAcademicLevel() {
        String v1FilterStr = '{"version":"v1","academicLevel":"Freshman;Sophmore"}';
        String v2FilterStr = '{"version":"v2","academicLevel":"Freshman;Sophmore"}';

        AdvisorPortalFilter v1Filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        AdvisorPortalFilter v2Filter = (AdvisorPortalFilter) JSON.deserialize(v2FilterStr, AdvisorPortalFilter.class);

        System.assertEquals('Freshman;Sophmore', String.join(v1Filter.getAcademicLevels(), ';'));
        System.assertEquals('Freshman;Sophmore', String.join(v2Filter.getAcademicLevels(), ';'));
    }

    @IsTest
    private static void testGetStudentGroupCode() {
        String v1FilterStr = '{"version":"v1","studentGroupCode":"AZ330"}';
        String v2FilterStr = '{"version":"v2","studentGroupCode":"AZ330"}';

        AdvisorPortalFilter v1Filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        AdvisorPortalFilter v2Filter = (AdvisorPortalFilter) JSON.deserialize(v2FilterStr, AdvisorPortalFilter.class);

        System.assertEquals('AZ330', v1Filter.getStudentGroupCode());
        System.assertEquals('AZ330', v2Filter.getStudentGroupCode());
    }

    @IsTest
    private static void testGetMajor() {
        String v1FilterStr = '{"version":"v1","major":"TVFILM"}';
        String v2FilterStr = '{"version":"v2","major":"TVFILM"}';

        AdvisorPortalFilter v1Filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        AdvisorPortalFilter v2Filter = (AdvisorPortalFilter) JSON.deserialize(v2FilterStr, AdvisorPortalFilter.class);

        System.assertEquals('TVFILM', v1Filter.getMajor());
        System.assertEquals('TVFILM', v2Filter.getMajor());
    }

    @IsTest
    private static void testGetDegreeLevel() {
        String v1FilterStr = '{"version":"v1","degreeLevel":"master;doctorate"}';
        String v2FilterStr = '{"version":"v2","degreeLevel":"master;doctorate"}';

        AdvisorPortalFilter v1Filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        AdvisorPortalFilter v2Filter = (AdvisorPortalFilter) JSON.deserialize(v2FilterStr, AdvisorPortalFilter.class);

        System.assertEquals('master;doctorate', String.join(v1Filter.getDegreeLevels(), ';'));
        System.assertEquals('master;doctorate', String.join(v2Filter.getDegreeLevels(), ';'));
    }

    @IsTest
    private static void testGetAcademicProgram() {
        String v1FilterStr = '{"version":"v1","academicProgram":"TVFILM;CRONKITE;ENG"}';
        String v2FilterStr = '{"version":"v2","academicProgram":"TVFILM;CRONKITE;ENG"}';

        AdvisorPortalFilter v1Filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        AdvisorPortalFilter v2Filter = (AdvisorPortalFilter) JSON.deserialize(v2FilterStr, AdvisorPortalFilter.class);

        System.assertEquals('TVFILM;CRONKITE;ENG', String.join(v1Filter.getAcademicPrograms(), ';'));
        System.assertEquals('TVFILM;CRONKITE;ENG', String.join(v2Filter.getAcademicPrograms(), ';'));
    }

    @IsTest
    private static void testGetSchoolDepartment() {
        String v1FilterStr = '{"version":"v1","schoolDepartment":"TECH;LIB"}';
        String v2FilterStr = '{"version":"v2","schoolDepartment":"TECH;LIB"}';

        AdvisorPortalFilter v1Filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        AdvisorPortalFilter v2Filter = (AdvisorPortalFilter) JSON.deserialize(v2FilterStr, AdvisorPortalFilter.class);

        System.assertEquals('TECH;LIB', String.join(v1Filter.getSchoolDepartments(), ';'));
        System.assertEquals('TECH;LIB', String.join(v2Filter.getSchoolDepartments(), ';'));
    }

    @IsTest
    private static void testGetAcademicPlan() {
        String v1FilterStr = '{"version":"v1","academicPlan":"SF;BA;PM"}';
        String v2FilterStr = '{"version":"v2","academicPlan":"SF;BA;PM"}';

        AdvisorPortalFilter v1Filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        AdvisorPortalFilter v2Filter = (AdvisorPortalFilter) JSON.deserialize(v2FilterStr, AdvisorPortalFilter.class);

        System.assertEquals('SF;BA;PM', String.join(v1Filter.getAcademicPlans(), ';'));
        System.assertEquals('SF;BA;PM', String.join(v2Filter.getAcademicPlans(), ';'));
    }

    @IsTest
    private static void testGetAdmitTermFrom() {
        String v1FilterStr = '{"version":"v1","admitTermFrom":"2201"}';
        String v2FilterStr = '{"version":"v2","admitTermFrom":"2201"}';

        AdvisorPortalFilter v1Filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        AdvisorPortalFilter v2Filter = (AdvisorPortalFilter) JSON.deserialize(v2FilterStr, AdvisorPortalFilter.class);

        System.assertEquals('2201', v1Filter.getAdmitTermFrom());
        System.assertEquals('2201', v2Filter.getAdmitTermFrom());
    }

    @IsTest
    private static void testGetAdmitTermTo() {
        String v1FilterStr = '{"version":"v1","admitTermTo":"2207"}';
        String v2FilterStr = '{"version":"v2","admitTermTo":"2207"}';

        AdvisorPortalFilter v1Filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        AdvisorPortalFilter v2Filter = (AdvisorPortalFilter) JSON.deserialize(v2FilterStr, AdvisorPortalFilter.class);

        System.assertEquals('2207', v1Filter.getAdmitTermTo());
        System.assertEquals('2207', v2Filter.getAdmitTermTo());
    }

    @IsTest
    private static void testGetResidency() {
        String v1FilterStr = '{"version":"v1","residency":"international;resident"}';
        String v2FilterStr = '{"version":"v2","residency":"international;resident"}';

        AdvisorPortalFilter v1Filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        AdvisorPortalFilter v2Filter = (AdvisorPortalFilter) JSON.deserialize(v2FilterStr, AdvisorPortalFilter.class);

        System.assertEquals('international;resident', String.join(v1Filter.getResidencies(), ';'));
        System.assertEquals('international;resident', String.join(v2Filter.getResidencies(), ';'));
    }

    @IsTest
    private static void testGetCaseStatus() {
        String v1FilterStr = '{"version":"v1","caseStatus":"busy signal"}';
        String v2FilterStr = '{"version":"v2","caseStatus":"busy signal"}';

        AdvisorPortalFilter v1Filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        AdvisorPortalFilter v2Filter = (AdvisorPortalFilter) JSON.deserialize(v2FilterStr, AdvisorPortalFilter.class);

        System.assertEquals('busy signal', String.join(v1Filter.getCaseStatuses(), ';'));
        System.assertEquals('busy signal', String.join(v2Filter.getCaseStatuses(), ';'));
    }

    @IsTest
    private static void testGetCaseCategory() {
        List<String> categories = new List<String>{ 'CAT-0', 'CAT-33' };
        List<String> b64Categories = new List<String>();
        for (String cat : categories)
            b64Categories.add(EncodingUtil.base64Encode(Blob.valueOf(cat)));

        String v1FilterStr = '{"version":"v1","caseCategory":"' + String.join(categories, ';') + '"}';
        String v2FilterStr = '{"version":"v2","caseCategory":"' + String.join(b64Categories, ';') + '"}';

        AdvisorPortalFilter v1Filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        AdvisorPortalFilter v2Filter = (AdvisorPortalFilter) JSON.deserialize(v2FilterStr, AdvisorPortalFilter.class);

        System.assertEquals(String.join(categories, ';'), String.join(v1Filter.getCaseCategories(), ';'));
        System.assertEquals(String.join(categories, ';'), String.join(v2Filter.getCaseCategories(), ';'));
    }

    @IsTest
    private static void testGetCaseSubject() {
        List<String> subjects = new List<String>{ 'eat', 'spiky; or....' };
        List<String> b64Subjects = new List<String>();
        for (String subj : subjects)
            b64Subjects.add(EncodingUtil.base64Encode(Blob.valueOf(subj)));

        String v1FilterStr = '{"version":"v1","caseSubject":"' + String.join(subjects, ';') + '"}';
        String v2FilterStr = '{"version":"v2","caseSubject":"' + String.join(b64Subjects, ';') + '"}';

        AdvisorPortalFilter v1Filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        AdvisorPortalFilter v2Filter = (AdvisorPortalFilter) JSON.deserialize(v2FilterStr, AdvisorPortalFilter.class);

        System.assertEquals(String.join(subjects, ';'), String.join(v1Filter.getCaseSubjects(), ';'));
        System.assertEquals(String.join(subjects, ';'), String.join(v2Filter.getCaseSubjects(), ';'));
    }

    @IsTest
    private static void testGetSpecialPopulation() {
        String v1FilterStr = '{"version":"v1","specialPopulation":"graduating"}';
        String v2FilterStr = '{"version":"v2","specialPopulation":"graduating"}';

        AdvisorPortalFilter v1Filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        AdvisorPortalFilter v2Filter = (AdvisorPortalFilter) JSON.deserialize(v2FilterStr, AdvisorPortalFilter.class);

        System.assertEquals('graduating', String.join(v1Filter.getSpecialPopulations(), ';'));
        System.assertEquals('graduating', String.join(v2Filter.getSpecialPopulations(), ';'));
    }

    @IsTest
    private static void testGetOutlookScores() {
        String v1FilterStr = '{"version":"v1","outlookScore":"very low;high"}';
        String v2FilterStr = '{"version":"v2","outlookScore":"very low;high"}';

        AdvisorPortalFilter v1Filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        AdvisorPortalFilter v2Filter = (AdvisorPortalFilter) JSON.deserialize(v2FilterStr, AdvisorPortalFilter.class);

        List<Decimal> v1OutlookScoreList = v1Filter.getOutlookScores();
        List<Decimal> v2OutlookScoreList = v2Filter.getOutlookScores();

        System.assertEquals(5, v1OutlookScoreList.size());
        System.assert(v1OutlookScoreList.contains(Decimal.valueOf(0)));
        System.assert(v1OutlookScoreList.contains(Decimal.valueOf(1)));
        System.assert(v1OutlookScoreList.contains(Decimal.valueOf(2)));
        System.assert(v1OutlookScoreList.contains(Decimal.valueOf(3)));
        System.assert(v1OutlookScoreList.contains(Decimal.valueOf(7)));

        System.assertEquals(5, v2OutlookScoreList.size());
        System.assert(v2OutlookScoreList.contains(Decimal.valueOf(0)));
        System.assert(v2OutlookScoreList.contains(Decimal.valueOf(1)));
        System.assert(v2OutlookScoreList.contains(Decimal.valueOf(2)));
        System.assert(v2OutlookScoreList.contains(Decimal.valueOf(3)));
        System.assert(v2OutlookScoreList.contains(Decimal.valueOf(7)));
    }

    @IsTest
    private static void testGetOutlookChange() {
        String v1FilterStr = '{"version":"v1","outlookChange":"up;no change"}';
        String v2FilterStr = '{"version":"v2","outlookChange":"up;no change"}';

        AdvisorPortalFilter v1Filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        AdvisorPortalFilter v2Filter = (AdvisorPortalFilter) JSON.deserialize(v2FilterStr, AdvisorPortalFilter.class);

        List<Decimal> v1OutlookChangeList = v1Filter.getOutlookChanges();
        List<Decimal> v2OutlookChangeList = v2Filter.getOutlookChanges();

        System.assertEquals(2, v1OutlookChangeList.size());
        System.assert(v1OutlookChangeList.contains(Decimal.valueOf(1)));
        System.assert(v1OutlookChangeList.contains(Decimal.valueOf(-1)));

        System.assertEquals(2, v2OutlookChangeList.size());
        System.assert(v2OutlookChangeList.contains(Decimal.valueOf(1)));
        System.assert(v2OutlookChangeList.contains(Decimal.valueOf(-1)));
    }

    @IsTest
    private static void testGetCreatedFromDate() {
        String v1FilterStr = '{"version":"v1","createdFromDate":"2022-01-02"}';
        String v2FilterStr = '{"version":"v2","createdFromDate":"2022-01-02"}';

        AdvisorPortalFilter v1Filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        AdvisorPortalFilter v2Filter = (AdvisorPortalFilter) JSON.deserialize(v2FilterStr, AdvisorPortalFilter.class);

        System.assertEquals(
            Datetime.valueOf('2022-01-02 00:00:00').formatGmt('yyyy-MM-dd\'T\'HH:mm:ssZ'),
            v1Filter.getCreatedFromDate()
        );
        System.assertEquals(
            Datetime.valueOf('2022-01-02 00:00:00').formatGmt('yyyy-MM-dd\'T\'HH:mm:ssZ'),
            v2Filter.getCreatedFromDate()
        );
    }

    @IsTest
    private static void testGetCreatedToDate() {
        String v1FilterStr = '{"version":"v1","createdToDate":"2022-01-02"}';
        String v2FilterStr = '{"version":"v2","createdToDate":"2022-01-02"}';

        AdvisorPortalFilter v1Filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        AdvisorPortalFilter v2Filter = (AdvisorPortalFilter) JSON.deserialize(v2FilterStr, AdvisorPortalFilter.class);

        System.assertEquals(
            Datetime.valueOf('2022-01-02 23:59:59').formatGmt('yyyy-MM-dd\'T\'HH:mm:ssZ'),
            v1Filter.getCreatedToDate()
        );
        System.assertEquals(
            Datetime.valueOf('2022-01-02 23:59:59').formatGmt('yyyy-MM-dd\'T\'HH:mm:ssZ'),
            v2Filter.getCreatedToDate()
        );
    }

    @IsTest
    private static void testGetFollowUpFromDate() {
        String v1FilterStr = '{"version":"v1","followUpFromDate":"2022-01-02"}';
        String v2FilterStr = '{"version":"v2","followUpFromDate":"2022-01-02"}';

        AdvisorPortalFilter v1Filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        AdvisorPortalFilter v2Filter = (AdvisorPortalFilter) JSON.deserialize(v2FilterStr, AdvisorPortalFilter.class);

        System.assertEquals('2022-01-02', v1Filter.getFollowUpFromDate());
        System.assertEquals('2022-01-02', v2Filter.getFollowUpFromDate());
    }

    @IsTest
    private static void testGetFollowUpToDate() {
        String v1FilterStr = '{"version":"v1","followUpToDate":"2022-01-02"}';
        String v2FilterStr = '{"version":"v2","followUpToDate":"2022-01-02"}';

        AdvisorPortalFilter v1Filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        AdvisorPortalFilter v2Filter = (AdvisorPortalFilter) JSON.deserialize(v2FilterStr, AdvisorPortalFilter.class);

        System.assertEquals('2022-01-02', v1Filter.getFollowUpToDate());
        System.assertEquals('2022-01-02', v2Filter.getFollowUpToDate());
    }

    @IsTest
    private static void testGetPersistenceFromDate() {
        String v1FilterStr = '{"version":"v1","persistenceFromDate":"2022-01-02"}';
        String v2FilterStr = '{"version":"v2","persistenceFromDate":"2022-01-02"}';

        AdvisorPortalFilter v1Filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        AdvisorPortalFilter v2Filter = (AdvisorPortalFilter) JSON.deserialize(v2FilterStr, AdvisorPortalFilter.class);

        System.assertEquals('2022-01-02', v1Filter.getPersistenceFromDate());
        System.assertEquals('2022-01-02', v2Filter.getPersistenceFromDate());
    }

    @IsTest
    private static void testGetPersistenceToDate() {
        String v1FilterStr = '{"version":"v1","persistenceToDate":"2022-01-02"}';
        String v2FilterStr = '{"version":"v2","persistenceToDate":"2022-01-02"}';

        AdvisorPortalFilter v1Filter = (AdvisorPortalFilter) JSON.deserialize(v1FilterStr, AdvisorPortalFilter.class);
        AdvisorPortalFilter v2Filter = (AdvisorPortalFilter) JSON.deserialize(v2FilterStr, AdvisorPortalFilter.class);

        System.assertEquals('2022-01-02', v1Filter.getPersistenceToDate());
        System.assertEquals('2022-01-02', v2Filter.getPersistenceToDate());
    }
}