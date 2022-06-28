public class ServiceIndicatorWrapper {

	public String EmplId;
	public List<ServiceIndicators> ServiceIndicators;

	public class ServiceIndicators {
		public String Institution;
		public String ServiceIndicatorCode;
		public String ServiceIndicatorReason;
		public String ServiceIndicatorActiveTerm;
		public String ServiceIndicatorActiveDate;
		public String ServiceIndicatorEndTerm;
		public String ServiceIndicatorEndDate;
		public String PositiveServiceIndicator;
		public String Comments;
		public String ServiceIndicatorDateTime;
		public String ServiceIndicatorCodeDescr;
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