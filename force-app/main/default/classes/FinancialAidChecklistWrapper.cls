global class FinancialAidChecklistWrapper {
    global String empl_id;
    global List<FinancialAidChecklist> checklist_items;

    global class FinancialAidChecklist {
        global String seq_3c { get; set; }
        global String checklist_cd { get; set; }
        global String status { get; set; }
        global String status_code { get; set; }
        global String checklist_seq { get; set; }
        global String checklistitemcd { get; set; }
        global String item_status {
            get {
                if (item_status == null) {
                    item_status = '--';
                }
                return item_status;
            }
            set;
        }
        global String item_status_code { get; set; }
        global String due_dt { get; set; }
        global String status_dt {
            get {
                if (status_dt == null) {
                    status_dt = '--';
                }
                return status_dt;
            }
            set;
        }
        global String asu_fa_status_rsn { get; set; }
        global String strm_code { get; set; }
        global String term {
            get {
                if (term == null) {
                    term = '--';
                }
                return term;
            }
            set;
        }
        global String description { get; set; }
        global String institution { get; set; }
        global String aid_year { get; set; }
        global String admin_function { get; set; }
    }

    global static FinancialAidChecklistWrapper parse(String json) {
        try {
            return (FinancialAidChecklistWrapper) System.JSON.deserialize(json, FinancialAidChecklistWrapper.class);
        } catch (Exception e) {
            return new FinancialAidChecklistWrapper();
        }
    }
}