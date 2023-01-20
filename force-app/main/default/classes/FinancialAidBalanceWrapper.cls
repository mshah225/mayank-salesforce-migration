global class FinancialAidBalanceWrapper {
	global String emplid;	
	global cls_balances balances;

	global class cls_balances {
		global Decimal due_amount;	
		global Decimal balance_amount;	
		global Decimal total_amount;	
	}

	global static FinancialAidBalanceWrapper parse(String json) {
		return (FinancialAidBalanceWrapper) System.JSON.deserialize(json, FinancialAidBalanceWrapper.class);
	}
}