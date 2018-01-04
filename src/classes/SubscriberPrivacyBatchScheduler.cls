global class SubscriberPrivacyBatchScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		BatchApplySubscriberPrivacy b = new BatchApplySubscriberPrivacy();
		database.executebatch(b, 200);
	}
}