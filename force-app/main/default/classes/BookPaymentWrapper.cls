global class BookPaymentWrapper {
	global String emplid {get; set;}	
	global List<cls_aid_years> aid_years {get; set;}

	global class cls_aid_years implements Comparable {
		global String aid_year {get; set;}
		global String term {get; set;}
		global String term_description {get; set;}
		global Integer amount {get; set;}
		global String begin_date {get; set;}
		global String end_date {get; set;}
		global String description {get; set;}

		global Integer compareTo(Object comparison) {
			cls_aid_years aidYearComparison = (cls_aid_years) comparison;

			if (aidYearComparison.term > term) {
				return 1;
			} else {
				return -1;
			}
        }
	}

	global static BookPaymentWrapper parse(String json) {
		return (BookPaymentWrapper) System.JSON.deserialize(json, BookPaymentWrapper.class);
	}
}