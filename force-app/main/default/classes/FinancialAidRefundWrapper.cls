global class FinancialAidRefundWrapper{
	global String emplid;	
	global List<cls_refunds> refunds;
	global Integer total_refunds;	

	global class cls_refunds {
		global String refund_date;	
		global Integer id;	
		global Integer applied_amount;	
		global String refund_format;	
		global String refund_type;	
	}

	global static FinancialAidRefundWrapper parse(String json){
		return (FinancialAidRefundWrapper) System.JSON.deserialize(json, FinancialAidRefundWrapper.class);
	}

	static testMethod void testParse() {
		String json=		'{'+
		'    "emplid": "1226380586",'+
		'    "refunds": ['+
		'        {'+
		'            "refund_date": "2023-01-13",'+
		'            "id": 3514350,'+
		'            "applied_amount": 2164,'+
		'            "refund_format": "P",'+
		'            "refund_type": "Paper Check"'+
		'        }'+
		'    ],'+
		'    "total_refunds": 2164'+
		'}';
		FinancialAidRefundWrapper obj = parse(json);
		System.assert(obj != null);
	}
}