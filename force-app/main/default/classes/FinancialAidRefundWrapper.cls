global class FinancialAidRefundWrapper {
	global String emplid;	
	global List<cls_refunds> refunds;
	global Decimal total_refunds;	

	global class cls_refunds {
		global String refund_date;	
		global Integer id;	
		global Decimal applied_amount;	
		global String refund_format;	
		global String refund_type;	
	}

	global static FinancialAidRefundWrapper parse(String json) {
		return (FinancialAidRefundWrapper) System.JSON.deserialize(json, FinancialAidRefundWrapper.class);
	}
}