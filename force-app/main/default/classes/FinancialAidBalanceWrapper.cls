global class FinancialAidBalanceWrapper{
	global String emplid;	//1226380586
	global cls_balances balances;

	global class cls_balances {
		global Integer due_amount;	//0
		global Integer balance_amount;	//0
		global Integer total_amount;	//0
	}

	global static FinancialAidBalanceWrapper parse(String json){
		return (FinancialAidBalanceWrapper) System.JSON.deserialize(json, FinancialAidBalanceWrapper.class);
	}

	static testMethod void testParse() {
		String json=		'{'+
		'    "emplid": "1226380586",'+
		'    "balances": {'+
		'        "due_amount": 0,'+
		'        "balance_amount": 0,'+
		'        "total_amount": 0'+
		'    }'+
		'}';
		FinancialAidBalanceWrapper obj = parse(json);
		System.assert(obj != null);
	}
}