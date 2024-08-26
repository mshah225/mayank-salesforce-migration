public with sharing class MasterTrackerService {

    public static Graduate_Master_Tracker__c createMasterTrackerRecord(Opportunity oppIn) {

        Graduate_Master_Tracker__c masterTrackerRecord = new Graduate_Master_Tracker__c();
        masterTrackerRecord.Opportunity__c = oppIn.Id;
        setObjectTags(masterTrackerRecord);
        setInterviewScores(masterTrackerRecord);
        setTestScores(masterTrackerRecord, oppIn);

        insert masterTrackerRecord;
        
        return masterTrackerRecord;
    }

    public static void updateMasterTrackerWithNewTestScores(Map<Id, Opportunity> oppsWithNewTestScores) {

        List<Graduate_Master_Tracker__c> masterTrackerRecordList = [
            SELECT Id, Opportunity__c
            FROM Graduate_Master_Tracker__c
            WHERE Opportunity__c IN: oppsWithNewTestScores.keyset()
        ];

        for (Graduate_Master_Tracker__c trackerRecord : masterTrackerRecordList) {
            setTestScores(trackerRecord, oppsWithNewTestScores.get(trackerRecord.Opportunity__c));
        }

        if (masterTrackerRecordList.size() > 0) {
            update masterTrackerRecordList;
        }
    }

    private static void setTestScores(Graduate_Master_Tracker__c trackerRecord, Opportunity oppIn) {

        Test_Score__c mainTestRecord;

        //1825 is the number of days in 5 years
        List<Test_Score__c> testScores = [
            SELECT Id, Test_Component_Score__c, Test_Date__c, Test_Component__c
            FROM Test_Score__c
            WHERE Contact__c =: oppIn.Contact__c AND 
            Integration_Source__c = 'PeopleSoft' AND
            Test_Source__c = 'Educational Testing Service' AND
            Test_Type__c =: oppIn.Admission_Test_Type__c
            AND Test_Component__c = 'DISPLAY'
            AND Test_Date__c < LAST_N_DAYS:1825
        ];

        if (testScores.size() == 0) {
            return;
        }

        if (testScores.size() == 1) {            
            mainTestRecord = testScores[0];
            trackerRecord.Display_Score__c = mainTestRecord.Test_Component_Score__c;
        } else {
            Decimal highestScore = 0;             
            for (Test_Score__c testScore : testScores) {
                if (testScore.Test_Component_Score__c > highestScore) {
                    mainTestRecord = testScore;
                    highestScore = testScore.Test_Component_Score__c;
                }
            }

            if (mainTestRecord != null) {
                trackerRecord.Display_Score__c = mainTestRecord.Test_Component_Score__c;
            }
        }

        testScores = [
            SELECT Id, Test_Component_Score__c, Test_Date__c, Test_Component__c,
            		Test_Component_Percentile__c
            FROM Test_Score__c
            WHERE Contact__c =: oppIn.Contact__c AND 
            Integration_Source__c = 'PeopleSoft' AND
            Test_Source__c = 'Educational Testing Service' AND
            Test_Type__c =: oppIn.Admission_Test_Type__c AND 
            Test_Date__c =: mainTestRecord.Test_Date__c
        ];

        System.debug(testScores);

        switch on oppIn.Admission_Test_Type__c {
            when 'GMAT' {
                for (Test_Score__c score : testScores) {
                    if (score.Test_Component__c == 'QUAN') {
                        trackerRecord.Quantitative_Percentile__c = score.Test_Component_Percentile__c;
                        trackerRecord.Quantitative_Total__c = score.Test_Component_Score__c;
                    } else if (score.Test_Component__c == 'VERB') {
                        trackerRecord.Verbal_Percentile__c = score.Test_Component_Percentile__c;
                        trackerRecord.Verbal_Total__c = score.Test_Component_Score__c;
                    }
                }
            }	
            when 'GRE' {
                for (Test_Score__c score : testScores) {
                    if (score.Test_Component__c == 'QUAR') {
                        trackerRecord.Quantitative_Percentile__c = score.Test_Component_Percentile__c;
                        trackerRecord.Quantitative_Total__c = score.Test_Component_Score__c;
                    } else if (score.Test_Component__c == 'VERR') {
                        trackerRecord.Verbal_Percentile__c = score.Test_Component_Percentile__c;
                        trackerRecord.Verbal_Total__c = score.Test_Component_Score__c;
                    }
                }
            }
            when 'GMAT Focus' {
                for (Test_Score__c score : testScores) {
                    if (score.Test_Component__c == 'QUANF') {
                        if (score.Test_Date__c >= Date.ValueOf('07/01/2024')) {
                            trackerRecord.Quantitative_Percentile__c = score.Test_Component_Percentile__c;
                            trackerRecord.Quantitative_Total__c = score.Test_Component_Score__c;
                        } else {
                            trackerRecord.GMAT_Focus_Quantitative_Percentile__c = score.Test_Component_Percentile__c;
                            trackerRecord.GMAT_Focus_Quantitative_Total__c = score.Test_Component_Score__c;
                        }
                    } else if (score.Test_Component__c == 'VERBF') {
                        if (score.Test_Date__c >= Date.ValueOf('07/01/2024')) {
                            trackerRecord.Verbal_Percentile__c = score.Test_Component_Percentile__c;
                            trackerRecord.Verbal_Total__c = score.Test_Component_Score__c;
                        } else {
                            trackerRecord.GMAT_Focus_Verbal_Percentile__c = score.Test_Component_Percentile__c;
                            trackerRecord.GMAT_Focus_Verbal_Total__c = score.Test_Component_Score__c;
                        }
                    }
                }                
            }
        }
    }

    private static void setObjectTags(Graduate_Master_Tracker__c trackerRecord) {
        String tagsForOpp = '';

        System.debug(trackerRecord);
        System.debug(trackerRecord.Opportunity__c);

        List<Object_Tag__c> tags = [
            SELECT Name
            FROM Object_Tag__c
            WHERE Opportunity__c =: trackerRecord.Opportunity__c
            AND isActive__c = true
        ];

        for (Object_Tag__c tag : tags) {
            tagsForOpp += (tag.Name + '; ');
        }

        trackerRecord.Tags__c = tagsForOpp;
    }

    private static void setInterviewScores(Graduate_Master_Tracker__c trackerRecord) {
        List<Admission_Interview_Evaluation__c> evalScores = [
            SELECT Total_Score__c
            FROM Admission_Interview_Evaluation__c
            WHERE Opportunity__c =: trackerRecord.Opportunity__c
            ORDER BY Interview_Date__c ASC 
            LIMIT 2
        ];

        if (evalScores.size() == 0) {
            trackerRecord.Interview_1_Score__c = 0;
            trackerRecord.Interview_2_Score__c = 0;
            trackerRecord.Interview_Total_Score__c = 0;
        } else {
            trackerRecord.Interview_1_Score__c = evalScores[0].Total_Score__c;
            trackerRecord.Interview_2_Score__c = evalScores[1].Total_Score__c;
            trackerRecord.Interview_Total_Score__c = evalScores[0].Total_Score__c + evalScores[1].Total_Score__c;
        }
    }
}