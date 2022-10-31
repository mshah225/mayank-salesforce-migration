public class FinancialEditMessageWrapper {
	public String emplid;
	public List<cls_edit_messages> edit_messages;

	public class cls_edit_messages {
		public String academic_year {get; set;}	
		public String aid_year {get; set;}		
		public List<cls_message_details> message_details {get; set;}	
	}

	public class cls_message_details implements Comparable {
		public String term {get; set;}	
		public String action_description {get; set;}		
		public String description {get; set;}		
		public String item_type {get; set;}		

		public Integer compareTo(Object compareTo) {
			cls_message_details compareToMessage = (cls_message_details) compareTo;

			return item_type.compareTo(compareToMessage.item_type);
		}
	}

	public static FinancialEditMessageWrapper parse(String json){
		return (FinancialEditMessageWrapper) System.JSON.deserialize(json, FinancialEditMessageWrapper.class);
	}
}