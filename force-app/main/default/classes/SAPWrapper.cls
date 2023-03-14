global class SAPWrapper {
	global String emplid;	
	global List<cls_academic_year> academic_year;

	global class cls_academic_year implements Comparable {
		global String aid_year {get; set;}	
		global List<cls_sap> sap {get; set;}	

		global Integer compareTo(Object compareTo) {
			cls_academic_year compareToSAP = (cls_academic_year) compareTo;

			return aid_year.compareTo(compareToSAP.aid_year);
		}
	}

	global class cls_sap  implements Comparable {
		global String term {get; set;}		
		global String processTerm;	
		global String sapDescription {get; set;}	
		global String paceRateDescription {get; set;}		
		global String maximumHourDescription {get; set;}	
		global String minimumGpaDescription {get; set;}		

		global Integer compareTo(Object compareTo) {
			cls_sap compareToSAP = (cls_sap) compareTo;

			return term.compareTo(compareToSAP.term);
		}
	}

	global static SAPWrapper parse(String json) {
		String currentTerm = [SELECT CurrTerm__c FROM StudentTerm__c LIMIT 1].CurrTerm__c;
		String currentAidYear = [SELECT Aid_Year__c FROM Term__c WHERE PeopleSoft_Code__c =: currentTerm LIMIT 1].Aid_Year__c;


		SAPWrapper wrapperResults = (SAPWrapper) System.JSON.deserialize(json, SAPWrapper.class);

		wrapperResults.academic_year.sort();

		List<cls_academic_year> currentAndFutureYears = new List<cls_academic_year>();

		for (cls_academic_year academicYear : wrapperResults.academic_year) {
			if (academicYear.aid_year < currentAidYear) {
				continue;
			}
			if (academicYear.sap.size() != 3) {
				Boolean fall = false;
				Boolean spring = false;
				Boolean summer = false;
				for (cls_sap sap : academicYear.sap) {
					if (sap.term.right(1) == '1') {
						spring = true;
					}
					if (sap.term.right(1) == '4') {
						summer = true;
					}
					if (sap.term.right(1) == '7') {
						fall = true;
					}
				}
				if (!fall) {
					cls_sap fallSap = new cls_sap();
					String adjustedYear = '' + (Integer.valueOf(academicYear.aid_year) - 1);
					fallSap.term = '2' + adjustedYear.right(2) + '7';
					fallSap.sapDescription = '--';
					fallSap.paceRateDescription = '--';
					fallSap.maximumHourDescription = '--';
					fallSap.minimumGpaDescription = '--';
					academicYear.sap.add(fallSap);
				}
				if (!spring) {
					cls_sap springSap = new cls_sap();
					springSap.term = '2' + academicYear.aid_year.right(2) + '1';
					springSap.sapDescription = '--';
					springSap.paceRateDescription = '--';
					springSap.maximumHourDescription = '--';
					springSap.minimumGpaDescription = '--';
					academicYear.sap.add(springSap);
				}
				if (!summer) {
					cls_sap summerSap = new cls_sap();
					summerSap.term = '2' + academicYear.aid_year.right(2) + '1';
					summerSap.sapDescription = '--';
					summerSap.paceRateDescription = '--';
					summerSap.maximumHourDescription = '--';
					summerSap.minimumGpaDescription = '--';
					academicYear.sap.add(summerSap);
				}
			}
			academicYear.sap.sort();
			currentAndFutureYears.add(academicYear);
		}

		wrapperResults.academic_year = currentAndFutureYears;
		return wrapperResults;
	}
}