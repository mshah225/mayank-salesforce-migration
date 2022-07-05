public class ServiceIndicatorWrapper {

	public String EmplId;
	public List<ServiceIndicators> ServiceIndicators;

	public class ServiceIndicators  implements Comparable {
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
        
        public Integer compareTo (Object comparison) {
            ServiceIndicators compareToSI = (ServiceIndicators)comparison;
            Date thisDate = date.parse(ServiceIndicatorActiveDate);
            Date otherDate = date.parse(compareToSI.ServiceIndicatorActiveDate);
            
            if(thisDate > otherDate) {
                return 1;
            } else if (thisDate < otherDate) {
                return -1;
            } else {
                return 0;
            }
        }
	}

	public class ServiceImpact {
		public String ServiceImpactCode;
		public String ServiceImpactDescription;
	}

	
	public static ServiceIndicatorWrapper parse(String json) {
		return (ServiceIndicatorWrapper) System.JSON.deserialize(json, ServiceIndicatorWrapper.class);
	}
}