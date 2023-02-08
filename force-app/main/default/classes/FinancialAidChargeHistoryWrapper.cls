global class FinancialAidChargeHistoryWrapper {
	global List<cls_charges> charges {get; set;}

	global class cls_charges implements Comparable {
		global String term_name {get; set;}	
		global String term_code {get; set;}		
		global Decimal total_charges {get; set;}		
		global Decimal total_payment {get; set;}		
		global Decimal total_balance {get; set;}		
		global List<cls_charge_details> charge_details {get; set;}

        global Integer compareTo(Object compareTo) {
			cls_charges compareToAward = (cls_charges) compareTo;

			if (term_code < compareToAward.term_code) { 
				return 1;
			}

			if (term_code > compareToAward.term_code) { 
				return -1;
			}

			return 0;
		}
	}

	global class cls_charge_details implements Comparable {
		global String description {get; set;}		
		global Decimal charge {get; set;}		
		global Decimal payment {get; set;}	
		global Decimal balance {get; set;}	

        global Integer compareTo(Object compareTo) {
			cls_charge_details compareToCharge = (cls_charge_details) compareTo;

			return description.compareTo(compareToCharge.description);
		}
	}

	global static FinancialAidChargeHistoryWrapper parse(String json) {
		return (FinancialAidChargeHistoryWrapper) System.JSON.deserialize(json, FinancialAidChargeHistoryWrapper.class);
	}
}