global class DepositStatusWrapper {
	global String emplid;	
	global List<cls_deposits> deposits;

	global class cls_deposits {
		global String last_update_date {get; set;}	
		global String pre_notification_code {get; set;}		
		global String pre_notification_date {get; set;}		
		global String campus_id {get; set;}		
		global String pre_notification_status {get; set;}		
		global String deposit_status {get; set;}		
		global Integer days_since_prenote_date {get; set;}	
	}

	global static DepositStatusWrapper parse(String json) {
		return (DepositStatusWrapper) System.JSON.deserialize(json, DepositStatusWrapper.class);
	}
}