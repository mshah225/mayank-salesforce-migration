global class FinancialEditMessageWrapper {
	global String emplid;
	global List<cls_edit_messages> edit_messages;

	global class cls_edit_messages implements Comparable {
		global String academic_year {get; set;}	
		global String aid_year {get; set;}		
		global List<cls_message_details> message_details {get; set;}	

		global Integer compareTo(Object compareTo) {
			cls_edit_messages compareToMessages = (cls_edit_messages) compareTo;

			if (compareToMessages.academic_year > academic_year) {
				return 1;
			} else {
				return -1;
			}
		}
	}

	global class cls_message_details implements Comparable {
		global String term {get; set;}	
		global String action_description {get; set;}		
		global String description {get; set;}		
		global String item_type {get; set;}		

		global Integer compareTo(Object compareTo) {
			cls_message_details compareToMessage = (cls_message_details) compareTo;

			return item_type.compareTo(compareToMessage.item_type);
		}
	}

	global static FinancialEditMessageWrapper parse(String json){
		return (FinancialEditMessageWrapper) System.JSON.deserialize(json, FinancialEditMessageWrapper.class);
	}
}