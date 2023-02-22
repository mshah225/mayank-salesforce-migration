global class RenewableAidWrapper {
	global String emplid;	
	global List<cls_aid_years> aid_years {get; set;}

	global class cls_aid_years {
		global String aid_year {get; set;}	
		global String name {get; set;}	
		global String terms_used {get; set;}	
		global String current_award {get; set;}	
		global String awards_description {get; set;}	
		global String renewal_status {get; set;}	
		global String measurement_description {get; set;}	
		global String max_amount {get; set;}	
	}

	global static RenewableAidWrapper parse(String json) {
		return (RenewableAidWrapper) System.JSON.deserialize(json, RenewableAidWrapper.class);
	}

}