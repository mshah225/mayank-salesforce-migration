public class OpportunityService 
{
	public static Integer generateOpportunityAssignmentNumber()
	{
		Double randNumber = Math.random()*100;

		return randNumber.intValue();
	}
}