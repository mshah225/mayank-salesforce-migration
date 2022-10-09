public class FinancialAidAwardWrapper {
	public List<cls_term_awards> term_awards;

	public class cls_term_awards {
        public String term_description {get; set;}	
		public Integer total_offer_amount {get; set;}	
		public Integer total_accepted_amount {get; set;}
		public Integer total_disbursed_amount {get; set;}	
		public List<cls_award_details> award_details {get; set;}
	}

	public class cls_award_details {
		public String award_name {get; set;}	
		public Integer offer_balance {get; set;}	
		public Integer accept_balance {get; set;}	
		public Integer disbursed_balance {get; set;}	
		public String disbursement_status {get; set;}	
		public String category_description {get; set;}	
	}
	
	public static FinancialAidAwardWrapper parse(String json) {
		return (FinancialAidAwardWrapper) System.JSON.deserialize(json, FinancialAidAwardWrapper.class);
	}
}