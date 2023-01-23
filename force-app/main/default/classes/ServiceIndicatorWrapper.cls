global class ServiceIndicatorWrapper {
    global String EmplId;
    global List<ServiceIndicator> ServiceIndicators;

    global class ServiceIndicator implements Comparable {
        global String Institution { get; set; }
        global String ServiceIndicatorCode { get; set; }
        global String ServiceIndicatorReason { get; set; }
        global String ServiceIndicatorActiveTerm;
        global String ServiceIndicatorActiveDate { get; set; }
        global String ServiceIndicatorEndTerm;
        global String ServiceIndicatorEndDate;
        global String PositiveServiceIndicator { get; set; }
        global String Comments;
        global String ServiceIndicatorDateTime;
        global String ServiceIndicatorCodeDescr { get; set; }
        global String DisplayInSS;
        global String ServiceIndReasonCodeDescr { get; set; }
        global String ServiceIndReasonCodeDescrLong;
        global List<ServiceImpact> ServiceImpacts;

        global Integer compareTo(Object comparison) {
            ServiceIndicator compareToSI = (ServiceIndicator) comparison;

            return ServiceIndicatorCode.compareTo(compareToSI.ServiceIndicatorCode);
        }
    }

    global class ServiceImpact {
        global String ServiceImpactCode;
        global String ServiceImpactDescription;
    }

    global static ServiceIndicatorWrapper parse(String json) {
        try {
            return (ServiceIndicatorWrapper) System.JSON.deserialize(json, ServiceIndicatorWrapper.class);
        } catch (Exception e) {
            return new ServiceIndicatorWrapper();
        }
    }
}