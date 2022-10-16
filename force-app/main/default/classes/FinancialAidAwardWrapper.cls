public class FinancialAidAwardWrapper {
	public List<cls_aid_years> aid_years;

	public class cls_aid_years {
		public String financial_year {get; set;}	
		public List<cls_term_awards> term_awards {get; set;}
	}

	public class cls_term_awards {
		public String term_description {get; set;}
		public Decimal total_offer_amount {get; set;}
		public Decimal total_accepted_amount {get; set;}	
		public Decimal total_disbursed_amount {get; set;}	
		public List<cls_award_details> award_details {get; set;}
	}

	public class cls_award_details {
		public String award_name {get; set;}	
		public Decimal offer_balance {get; set;}	
		public Decimal accept_balance {get; set;}	
		public Decimal disbursed_balance {get; set;}
		public String disbursement_status {get; set;}	
		public String category_description {get; set;}	
		public String aid_year {get; set;}
	}

	public static FinancialAidAwardWrapper parse(String json){
		return (FinancialAidAwardWrapper) System.JSON.deserialize(json, FinancialAidAwardWrapper.class);
	}
}