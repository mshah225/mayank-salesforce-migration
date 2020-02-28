public class ConstituentDetail {
    public String asuriteId {get; set;}
    public String email {get; set;}
    public String emplid {get; set;}
    public String firstName {get; set;}
    public String lastName {get; set;}
    public Id contactId {get; set;}
    public String processingNotes {get; set;}

    public ConstituentDetail(Map<String, String> constituentDetailMap) {
        if (constituentDetailMap.containsKey('asuriteId')) {
            this.asuriteId = constituentDetailMap.get('asuriteId');
        }
        if (constituentDetailMap.containsKey('email')) {
            this.email = constituentDetailMap.get('email');
        }
        if (constituentDetailMap.containsKey('emplid')) {
            this.emplid = constituentDetailMap.get('emplid');
        }
        if (constituentDetailMap.containsKey('firstName')) {
            this.firstName = constituentDetailMap.get('firstName');
        }
        if (constituentDetailMap.containsKey('lastName')) {
            this.lastName = constituentDetailMap.get('lastName');
        }
        if (processingNotes == null) {
            processingNotes = '';
        }
    }
}