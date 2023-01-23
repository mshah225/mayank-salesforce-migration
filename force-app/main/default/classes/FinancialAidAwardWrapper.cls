global class FinancialAidAwardWrapper {
	global List<cls_aid_years> aid_years;

	global class cls_aid_years implements Comparable {
		global String financial_year {get; set;}	
		global List<cls_term_awards> term_awards {get; set;}

		global Integer compareTo(Object compareTo) {
			cls_aid_years compareToMessages = (cls_aid_years) compareTo;

			if (compareToMessages.financial_year > financial_year) {
				return 1;
			} else {
				return -1;
			}
		}
	}

	global class cls_term_awards implements Comparable {
		global String term_description {get; set;}
		global Decimal total_current_amount {get; set;}
		global Decimal total_accepted_amount {get; set;}	
		global Decimal total_disbursed_amount {get; set;}	
		global List<cls_award_details> award_details {get; set;}

		global Integer compareTo(Object compareTo) {
			cls_term_awards compareToAward = (cls_term_awards) compareTo;

			if (term_description.contains('Fall') || compareToAward.term_description.contains('Summer')) { 
				return -1;
			}

			if (compareToAward.term_description.contains('Fall') || term_description.contains('Summer') ) {
				return 1;
			} 

			return 0;
		}
	}

	global class cls_award_details implements Comparable {
		global String award_name {get; set;}	
		global Decimal current_offer {get; set;}	
		global Decimal accept_balance {get; set;}	
		global Decimal disbursed_balance {get; set;}
		global String disbursement_status {get; set;}	
		global String category_description {get; set;}	
		global String aid_year {get; set;}
		global String item_type {get; set;}

		global Integer compareTo(Object compareTo) {
			cls_award_details compareToAward = (cls_award_details) compareTo;

			return item_type.compareTo(compareToAward.item_type);
		}
	}

	global static FinancialAidAwardWrapper parse(String json){
		return (FinancialAidAwardWrapper) System.JSON.deserialize(json, FinancialAidAwardWrapper.class);
	}
}