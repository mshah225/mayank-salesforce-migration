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

	/*static testMethod void testParse() {
		String json=		'{'+
		'    "emplid": "1211532150",'+
		'    "deposits": ['+
		'        {'+
		'            "last_update_date": "2021-06-26",'+
		'            "pre_notification_code": "C",'+
		'            "pre_notification_date": "2021-06-26",'+
		'            "campus_id": "995888422",'+
		'            "pre_notification_status": "Completed",'+
		'            "deposit_status": "Active",'+
		'            "days_since_prenote_date": 584'+
		'        },'+
		'        {'+
		'            "last_update_date": "2021-06-26",'+
		'            "pre_notification_code": "C",'+
		'            "pre_notification_date": "2021-06-26",'+
		'            "campus_id": "995888422",'+
		'            "pre_notification_status": "Completed",'+
		'            "deposit_status": "Active",'+
		'            "days_since_prenote_date": 584'+
		'        }'+
		'    ]'+
		'}';
		DepositStatusWrapper obj = parse(json);
		System.assert(obj != null);
	} */
}