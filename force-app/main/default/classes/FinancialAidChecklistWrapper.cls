public class FinancialAidChecklistWrapper {
    public String empl_id;
    public List<FinancialAidChecklist> checklist_items;

    public class FinancialAidChecklist {
        public String seq_3c { get; set; }
        public String checklist_cd { get; set; }
        public String status { get; set; }
        public String status_code { get; set; }
        public String checklist_seq { get; set; }
        public String checklistitemcd { get; set; }
        public String item_status {
            get {
                if (item_status == null) {
                    item_status = '--';
                }
                return item_status;
            }
            set;
        }
        public String item_status_code { get; set; }
        public String due_dt { get; set; }
        public String status_dt {
            get {
                if (status_dt == null) {
                    status_dt = '--';
                }
                return status_dt;
            }
            set;
        }
        public String initialize_dt { get; set; }
        public String asu_fa_status_rsn { get; set; }
        public String strm {
            get {
                if (strm == null) {
                    strm = '--';
                }
                return strm;
            }
            set;
        }
        public String descrption { get; set; }
        public String institution { get; set; }
        public String aid_year { get; set; }
        public String admin_function { get; set; }
    }

    public static FinancialAidChecklistWrapper parse(String json) {
        try {
            return (FinancialAidChecklistWrapper) System.JSON.deserialize(json, FinancialAidChecklistWrapper.class);
        } catch (Exception e) {
            return new FinancialAidChecklistWrapper();
        }
    }
}