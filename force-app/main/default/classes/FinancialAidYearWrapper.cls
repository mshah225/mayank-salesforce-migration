public class FinancialAidYearWrapper {
	public List<cls_aid_years> aid_years;

	class cls_aid_years {
		public String aid_year;	
		public String description;	
		public String aid_year_default;	
	}

	public static FinancialAidYearWrapper parse(String json) {
		return (FinancialAidYearWrapper) System.JSON.deserialize(json, FinancialAidYearWrapper.class);
	}
}