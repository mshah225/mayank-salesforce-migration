public class FinancialEditMessageWrapper {
	public String emplid;
	public List<cls_edit_messages> edit_messages;

	class cls_edit_messages {
		public String academic_year;
		public String aid_year;	
		public List<cls_message_details> message_details;
	}

	class cls_message_details {
		public String term;	
		public String action_description;	
		public String description;	
		public String item_type;	
	}
	public static FinancialEditMessageWrapper parse(String json){
		return (FinancialEditMessageWrapper) System.JSON.deserialize(json, FinancialEditMessageWrapper.class);
	}
}