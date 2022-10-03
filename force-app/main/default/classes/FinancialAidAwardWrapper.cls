public class FinancialAidAwardWrapper {
	public String emplid;
	public List<cls_awards> awards;

	public class cls_awards {
		public String aid_year;	
		public cls_year_awards year_awards;
	}

	public class cls_year_awards {
		public String term_description;	
		public Integer total_offer_amount;	
		public Integer total_accepted_amount;	
		public Integer total_disbursed_amount;	
		public List<cls_term_awards> term_awards;
	}

	public class cls_term_awards {
		public String term;	
		public String term_description;	
		public String item_type;	
		public Integer offer_balance;	
		public Integer accept_balance;	
		public Integer disbursed_balance;	
		public String disbursement_status;	
		public String term_src;	
		public String term_src_description;	
		public String category;
		public String category_description;	
	}

	public static FinancialAidAwardWrapper parse(String json) {
		return (FinancialAidAwardWrapper) System.JSON.deserialize(json, FinancialAidAwardWrapper.class);
	}
}