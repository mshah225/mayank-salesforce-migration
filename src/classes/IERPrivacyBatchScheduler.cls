global class IERPrivacyBatchScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		BatchApplyIERPrivacy b = new BatchApplyIERPrivacy();
		database.executebatch(b, 200);
	}
}