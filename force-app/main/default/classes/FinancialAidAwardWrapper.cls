public class FinancialAidAwardWrapper {
	public List<cls_aid_years> aid_years;

	public class cls_aid_years implements Comparable {
		public String financial_year {get; set;}	
		public List<cls_term_awards> term_awards {get; set;}

		public Integer compareTo(Object compareTo) {
			cls_aid_years compareToMessages = (cls_aid_years) compareTo;

			if (compareToMessages.financial_year > financial_year) {
				return 1;
			} else {
				return -1;
			}
		}
	}

	public class cls_term_awards implements Comparable {
		public String term_description {get; set;}
		public Decimal total_current_amount {get; set;}
		public Decimal total_accepted_amount {get; set;}	
		public Decimal total_disbursed_amount {get; set;}	
		public List<cls_award_details> award_details {get; set;}

		public Integer compareTo(Object compareTo) {
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

	public class cls_award_details implements Comparable {
		public String award_name {get; set;}	
		public Decimal current_offer {get; set;}	
		public Decimal accept_balance {get; set;}	
		public Decimal disbursed_balance {get; set;}
		public String disbursement_status {get; set;}	
		public String category_description {get; set;}	
		public String aid_year {get; set;}
		public String item_type {get; set;}

		public Integer compareTo(Object compareTo) {
			cls_award_details compareToAward = (cls_award_details) compareTo;

			return item_type.compareTo(compareToAward.item_type);
		}
	}

	public static FinancialAidAwardWrapper parse(String json){
		return (FinancialAidAwardWrapper) System.JSON.deserialize(json, FinancialAidAwardWrapper.class);
	}
}