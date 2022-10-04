public class FinancialAidAwardWrapper {
	public String emplid;
	public List<cls_awards> awards;

	public class cls_awards {
		public String aid_year;	
		public cls_year_awards year_awards;
	}

	public class cls_year_awards {
		public String term_description;	
		public Integer total_offer_amount;	
		public Integer total_accepted_amount;	
		public Integer total_disbursed_amount;	
		public List<cls_term_awards> term_awards;
	}

	public class cls_term_awards {
		public String term;	
		public String term_description;	
		public String item_type;	
		public Integer offer_balance;	
		public Integer accept_balance;	
		public Integer disbursed_balance;	
		public String disbursement_status;	
		public String term_src;	
		public String term_src_description;	
		public String category;
		public String category_description;	
	}

	public class condensed_award_list {
		public String termDescription;
		public Integer totalOffer;
		public Integer totalAccepted;
		public Integer totalDisbursed;
		List<condensed_award> awards;		
	}

	public class condensed_award {		
		public String category;
		public Integer currentOffer;
		public Integer accecptedAmount;
		public Integer disbursedAmount;
		public String status;
	}

	public static FinancialAidAwardWrapper parse(String json) {
		return (FinancialAidAwardWrapper) System.JSON.deserialize(json, FinancialAidAwardWrapper.class);
	}

	public static List<condensed_award_list> convertToCondensed(FinancialAidAwardWrapper awardList) {
		condensed_award_list fallAwards = new condensed_award_list();
		fallAwards.awards = new List<condensed_award>();
		condensed_award_list springAwards = new condensed_award_list();
		springAwards.awards = new List<condensed_award>();

		for (FinancialAidAwardWrapper.cls_awards awardsPerTerm : awardList.awards) {
            cls_year_awards awardDescriptions = awardsPerTerm.year_awards;
			if (awardDescriptions.term_description.contains('Fall')) {
				fallAwards.termDescription = awardDescriptions.term_description;
				fallAwards.totalOffer = awardDescriptions.total_offer_amount;
				fallAwards.totalAccepted = awardDescriptions.total_accepted_amount;
				fallAwards.totalDisbursed = awardDescriptions.total_disbursed_amount;

				for (FinancialAidAwardWrapper.cls_term_awards specificAward : awardDescriptions.term_awards) {
					condensed_award ca = new condensed_award();
					ca.category = specificAward.category_description;
					ca.currentOffer = specificAward.offer_balance;
					ca.accecptedAmount = specificAward.accept_balance;
					ca.disbursedAmount = specificAward.disbursed_balance;
					ca.status = specificAward.disbursement_status;
					fallAwards.awards.add(ca);
				}
			} else {
				springAwards.termDescription = awardDescriptions.term_description;
				springAwards.totalOffer = awardDescriptions.total_offer_amount;
				springAwards.totalAccepted = awardDescriptions.total_accepted_amount;
				springAwards.totalDisbursed = awardDescriptions.total_disbursed_amount;

				for (FinancialAidAwardWrapper.cls_term_awards specificAward : awardDescriptions.term_awards) {
					condensed_award ca = new condensed_award();
					ca.category = specificAward.category_description;
					ca.currentOffer = specificAward.offer_balance;
					ca.accecptedAmount = specificAward.accept_balance;
					ca.disbursedAmount = specificAward.disbursed_balance;
					ca.status = specificAward.disbursement_status;
					springAwards.awards.add(ca);
				}
			}
		}

		List<condensed_award_list> fallAndSpring = new List<condensed_award_list>();
		fallAndSpring.add(fallAwards);
		fallAndSpring.add(springAwards);

		return fallAndSpring;
	}
}