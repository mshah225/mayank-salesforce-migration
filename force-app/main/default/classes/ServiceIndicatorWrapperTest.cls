@IsTest
public class ServiceIndicatorWrapperTest {
	
    @IsTest
	static void testParse() {
		String json = '{'+
		'    \"Emplid\": \"1210615923\",'+
		'    \"ServiceIndicators\": ['+
		'        {'+
		'            \"Institution\": \"ASU00\",'+
		'            \"ServiceIndicatorCode\": \"A15\",'+
		'            \"ServiceIndicatorReason\": \"COMPL\",'+
		'            \"ServiceIndicatorActiveTerm\": \"2161\",'+
		'            \"ServiceIndicatorActiveDate\": \"09/16/2015\",'+
		'            \"ServiceIndicatorEndTerm\": null,'+
		'            \"ServiceIndicatorEndDate\": null,'+
		'            \"PositiveServiceIndicator\": \"Y\",'+
		'            \"Comments\": null,'+
		'            \"ServiceIndicatorDateTime\": \"09/16/2015 02:15:31 AM\",'+
		'            \"ServiceIndicatorCodeDescr\": \"File Complete\",'+
		'            \"DisplayInSS\": \"N\",'+
		'            \"ServiceIndReasonCodeDescr\": \"File is complete\",'+
		'            \"ServiceIndReasonCodeDescrLong\": null,'+
		'            \"ServiceImpacts\": ['+
		'                {'+
		'                    \"ServiceImpactCode\": \"INFOR\",'+
		'                    \"ServiceImpactDescription\": null'+
		'                }'+
		'            ]'+
		'        }' +
		'    ]'+
		'}';
		ServiceIndicatorWrapper obj = ServiceIndicatorWrapper.parse(json);
		System.assert(obj != null);
	}
}