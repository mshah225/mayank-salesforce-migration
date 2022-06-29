public class ServiceIndicatorWrapper {

	public String EmplId;
	public List<ServiceIndicators> ServiceIndicators;

	public class ServiceIndicators {
        public String Institution {get; set;}
		public String ServiceIndicatorCode {get; set;}
		public String ServiceIndicatorReason {get; set;}
		public String ServiceIndicatorActiveTerm;
		public String ServiceIndicatorActiveDate {get; set;}
		public String ServiceIndicatorEndTerm;
		public String ServiceIndicatorEndDate;
		public String PositiveServiceIndicator;
		public String Comments;
		public String ServiceIndicatorDateTime;
		public String ServiceIndicatorCodeDescr {get; set;}
		public String DisplayInSS;
		public String ServiceIndReasonCodeDescr;
		public String ServiceIndReasonCodeDescrLong;
		public ServiceImpact ServiceImpact;
	}

	public class ServiceImpact {
		public String ServiceImpactCode;
		public String ServiceImpactDescription;
	}

	
	public static ServiceIndicatorWrapper parse(String json) {
		return (ServiceIndicatorWrapper) System.JSON.deserialize(json, ServiceIndicatorWrapper.class);
	}
}