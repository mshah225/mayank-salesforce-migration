public class EmailAlertArticleSchedule implements Schedulable {
	private Map<String, EmailTemplate> templateDevNameToTemplate = new Map<String, EmailTemplate>();
	private Set<String> functionalGroupsToExclude = new Set<String>();
	private List<GroupMember> knowledgeGroupMembers = new List<GroupMember>();
	private Map<Id, List<String>> articleIdToUserList = new Map<Id, List<String>>();
	Map<String, List<Id>> groupNameToUserIds = new Map<String, List<Id>>();
	private Map<Id, User> userMap;
	private boolean debug = false;
	
	public void execute(SchedulableContext sc) {
		dataSetup();

		List<FAQ__kav> stagnantQuery = [
			SELECT Id,
				ArticleNumber,
				Title,
				PublishStatus,
				Functional_Group__c,
				ValidationStatus,
				Article_Expiration_Date__c,
				LastModifiedDate,
				UrlName
			FROM FAQ__kav
			WHERE PublishStatus = 'Draft'
				AND Language = 'en_US'
				AND LastModifiedDate <= LAST_N_DAYS : 14
				AND Functional_Group__c NOT IN :functionalGroupsToExclude
				AND (ValidationStatus = 'Draft'
					OR ValidationStatus = 'Format Review'
					OR ValidationStatus = 'Content Review')
			LIMIT 20000
		];

		List<Messaging.SingleEmailMessage> messagesToEmail = new List<Messaging.SingleEmailMessage>();
		if (!stagnantQuery.isEmpty()) {
			// update Stagnant Articles so that the notification is fired again in 10 days.
			messagesToEmail.addAll(createEmails(stagnantQuery));
		}

		List<FAQ__kav> expiredQuery = [
			SELECT Id,
				ArticleNumber,
				Title,
				PublishStatus,
				Functional_Group__c,
				ValidationStatus,
				Article_Expiration_Date__c,
				LastModifiedDate,
				UrlName 
			FROM FAQ__kav
			WHERE PublishStatus = 'Online'
				AND Language = 'en_US'
				AND Functional_Group__c NOT IN :functionalGroupsToExclude
				AND (Article_Expiration_Date__c < :System.Today()
					OR Article_Expiration_Date__c = :System.Today().addDays(30))
			LIMIT 20000
		];

		if (!expiredQuery.isEmpty()) {
			messagesToEmail.addAll(createEmails(expiredQuery));
		}

		if (!messagesToEmail.isEmpty()) {
			Messaging.sendEmail(messagesToEmail);
		}
	}

	/*
	Method to send an email based on the article query.
	*/
	public List<Messaging.SingleEmailMessage> createEmails(List<FAQ__kav> knowledgeArticles) {
		
		// populate articles to users to notify
		List<String> vars = new List<String>();
		try{
			for (FAQ__kav knowledgeArticle : knowledgeArticles) {
				List<Id> userIds = groupNameToUserIds.get('KB: ' + knowledgeArticle.Functional_Group__c + ' (Approve)');
				if (userIds == null) {
					vars.add('No management group found for ' + knowledgeArticle.Functional_Group__c);
				} else {
					List<String> userEmails = new List<String>();
					for (Id userId : userIds) {
						userEmails.add(userMap.get(userId).Email);
					}
					if (!articleIdToUserList.containsKey(knowledgeArticle.Id)) {
						articleIdToUserList.put(knowledgeArticle.Id, new List<String>());
					}
					articleIdToUserList.get(knowledgeArticle.Id).addAll(userEmails);
				}
			}
		
			// Create emails to send out.
			List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
			
			for (FAQ__kav knowledgeArticle: knowledgeArticles) {
				List<String> usersToEmail = articleIdToUserList.get(knowledgeArticle.Id);
				
				Integer daysUntouched = knowledgeArticle.LastModifiedDate.date().daysBetween(Date.today());
		
				//Assign Email Template based on the Article(Expired or Stagnant)
				EmailTemplate template;
				if (knowledgeArticle.PublishStatus == 'Draft' && (daysUntouched == 14 || Math.mod((daysUntouched - 14), 7) == 0)) {
					template = templateDevNameToTemplate.get('Knowledge_Article_Stagnant');
				} else if (knowledgeArticle.Article_Expiration_Date__c < System.Today()) {
					template = templateDevNameToTemplate.get('Knowledge_Article_Expired');
				} else if (knowledgeArticle.Article_Expiration_Date__c == System.Today().addDays(30)) {
					template = templateDevNameToTemplate.get('Knowledge_Article_30_Day_Expiration');
				}
		
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setToAddresses(usersToEmail);
				if(template == null) {
					continue;
				}
				mail.setSubject(template.Subject.replace('{!FAQ__kav.Title}', knowledgeArticle.Title));
				mail.setHtmlBody(template.HtmlValue
					.replace('{!FAQ__kav.Title}', knowledgeArticle.Title)
					.replace('{!FAQ__kav.ArticleNumber}', knowledgeArticle.ArticleNumber)
					.replace('{!FAQ__kav.Link}', System.Url.getSalesforceBaseUrl().toExternalForm() + 
						'knowledge/publishing/knowledgePublishingHome.apexp'));
				emailsToSend.add(mail);
			}
		
			return emailsToSend;
		} catch(Exception e) {
			ErrorLogger.log(e, vars, debug);
			return null;
		}
	}
	
	public void dataSetup() {
		// Populate excluded functional groups
		for (Knowledge_Functional_Group__c excludedGroup :[SELECT Name, Functional_Group_Name__c FROM Knowledge_Functional_Group__c]) {
			functionalGroupsToExclude.add(excludedGroup.Name);
		}
		List<String> vars = new List<String>();
		try {
			// Populate email templates
			for (EmailTemplate knowledgeEmailTemplate: [
				SELECT Id, DeveloperName, Subject, HtmlValue
				FROM EmailTemplate
				WHERE DeveloperName = 'Knowledge_Article_Expired'
					OR DeveloperName = 'Knowledge_Article_Stagnant'
					OR DeveloperName = 'Knowledge_Article_30_Day_Expiration'
			]){
				templateDevNameToTemplate.put(knowledgeEmailTemplate.DeveloperName, knowledgeEmailTemplate);
				vars.add(knowledgeEmailTemplate.DeveloperName);
			}
			
			if (templateDevNameToTemplate.values().size() != 3) {
				throw new KnowledgeArticleManagmentException('Template does not contain three values');
			} else {
				// Get list of group members
				knowledgeGroupMembers = [
					SELECT
						UserOrGroupId,
						Group.Name
					FROM GroupMember
					WHERE GroupId IN (
						SELECT Id
						FROM Group
						WHERE Type = 'Queue'
							AND (Name LIKE '%Knowledge%'
								OR Name LIKE 'KB%')
						)
				];
				
				Set<Id> userIdsToQuery = new Set<Id>();
				for (GroupMember member : knowledgeGroupMembers) {
					if (member.UserOrGroupId.getSobjectType() == Schema.User.SObjectType) {
						userIdsToQuery.add(member.UserOrGroupId);
						if (!groupNameToUserIds.containsKey(member.Group.Name)) {
							groupNameToUserIds.put(member.Group.Name, new List<Id>());
						}
						groupNameToUserIds.get(member.Group.Name).add(member.UserOrGroupId);
					}
				}
				
				userMap = new Map<Id, User>([
					SELECT Id, Email
					FROM User
					WHERE Id IN : userIdsToQuery
				]);
			}
		} catch (Exception e) {
			ErrorLogger.log(e, vars, debug);	
		}
	}
	
	public class KnowledgeArticleManagmentException extends Exception {}
}