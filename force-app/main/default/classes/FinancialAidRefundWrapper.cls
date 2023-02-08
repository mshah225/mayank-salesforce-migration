global class FinancialAidRefundWrapper {
	global String emplid;	
	global List<cls_refunds> refunds;
	global Decimal total_refunds;	

	global class cls_refunds implements Comparable {
		global String refund_date;	
		global Integer id;	
		global Decimal applied_amount;	
		global String refund_format;	
		global String refund_type;
		
		global Integer compareTo(Object compareTo) {
			cls_refunds compareToAward = (cls_refunds) compareTo;

			if (refund_date < compareToAward.refund_date) { 
				return 1;
			}

			if (refund_date > compareToAward.refund_date) { 
				return -1;
			}

			return 0;
		}
	}

	global static FinancialAidRefundWrapper parse(String json) {
		return (FinancialAidRefundWrapper) System.JSON.deserialize(json, FinancialAidRefundWrapper.class);
	}
}