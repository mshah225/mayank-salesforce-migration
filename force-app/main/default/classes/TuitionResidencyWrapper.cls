global class TuitionResidencyWrapper{
	global String emplid;	
	global List<cls_tuition_residency> tuition_residency;

	global class cls_tuition_residency {
		global String acad_career {get; set;}
		global String institution {get; set;}
		global String effective_term {get; set;}	
		global String residency_dt {get; set;}	
		global String residency {get; set;}	
		global String asu_verified {get; set;}	
	}

	global static TuitionResidencyWrapper parse(String json){
		return (TuitionResidencyWrapper) System.JSON.deserialize(json, TuitionResidencyWrapper.class);
	}
}