public class FinancialAidChargeHistoryWrapper {
	public List<cls_charges> charges {get; set;}

	public class cls_charges implements Comparable {
		public String term_name {get; set;}	
		public String term_code {get; set;}		
		public Decimal total_charges {get; set;}		
		public Decimal total_payment {get; set;}		
		public Decimal total_balance {get; set;}		
		public List<cls_charge_details> charge_details {get; set;}

        public Integer compareTo(Object compareTo) {
			cls_charges compareToAward = (cls_charges) compareTo;

			if (term_code < compareToAward.term_code) { 
				return -1;
			}

			if (term_code > compareToAward.term_code) { 
				return 1;
			}

			return 0;
		}
	}

	public class cls_charge_details implements Comparable {
		public String description {get; set;}		
		public Decimal charge {get; set;}		
		public Decimal payment {get; set;}	
		public Decimal balance {get; set;}	

        public Integer compareTo(Object compareTo) {
			cls_charge_details compareToCharge = (cls_charge_details) compareTo;

			return description.compareTo(compareToCharge.description);
		}
	}

	public static FinancialAidChargeHistoryWrapper parse(String json) {
		return (FinancialAidChargeHistoryWrapper) System.JSON.deserialize(json, FinancialAidChargeHistoryWrapper.class);
	}
}