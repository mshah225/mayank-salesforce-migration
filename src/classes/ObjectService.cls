public class ObjectService 
{
	/**
	* Returns all the fields for a specified object
	* @param The object API name
	* @return A map containing the fields of the specified object
	*/
	public static Map<String, SObjectField> getObjectFieldMap(String objectName)
	{
		SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
		DescribeSObjectResult objDef = objToken.getDescribe();
		Map<String, SObjectField> fields = objDef.fields.getMap();

		return fields;
	}

	/**
	* Returns all the fields on an object in a string delimited by ','
	* @param A map containing the fields of an object
	* @return A string of the field names
	*/
	public static String objectFieldsToString(Map<String, SObjectField> objectFieldMap)
	{
		String fieldsToString = null;

		Set<String> fieldSet = objectFieldMap.keySet();
		for(String s : fieldSet)
		{
			SObjectField fieldToken = objectFieldMap.get(s);
			DescribeFieldResult selectedField = fieldToken.getDescribe();

			if (fieldsToString == null)
			{
				fieldsToString = selectedField.getName();
			}
			else
			{
				fieldsToString = fieldsToString + ', ' + selectedField.getName();
			}
		}

		return fieldsToString;
	}
}