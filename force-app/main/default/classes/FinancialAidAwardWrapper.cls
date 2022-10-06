public class FinancialAidAwardWrapper {
	public List<cls_term_awards> term_awards;
	class cls_term_awards {
		public String term_description;	
		public Integer total_offer_amount;	
		public Integer total_accepted_amount;	
		public Integer total_disbursed_amount;	
		public List<cls_award_details> award_details;
	}
	class cls_award_details {
		public String award_name;	
		public Integer offer_balance;	
		public Integer accept_balance;	
		public Integer disbursed_balance;	
		public String disbursement_status;	
		public String category_description;	
	}
	public static FinancialAidAwardWrapper parse(String json) {
		return (FinancialAidAwardWrapper) System.JSON.deserialize(json, FinancialAidAwardWrapper.class);
	}
}