public class ConstituentDetail {
    public String asuriteId { get; set; }
    public Date birthdate { get; set; }
    public Id constituentId { get; set; }
    public String email { get; set; }
    public String emplid { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String mailingStreet { get; set; }
    public String mailingCity { get; set; }
    public String mailingCountry { get; set; }
    public String mailingPostalCode { get; set; }
    public String mailingState { get; set; }
    public String middleName { get; set; }
    public String partialFirstName { get; set; }
    public String phone { get; set; }
    public String preferredName { get; set; }
    public String processingNotes { get; set; }
    public String status { get; set; }

    public ConstituentDetail(Map<String, String> constituentDetailMap) {
        if (constituentDetailMap.containsKey('asuriteId')) {
            this.asuriteId = constituentDetailMap.get('asuriteId');
        }
        if (constituentDetailMap.containsKey('birthdate')) {
            try {
                this.birthdate = Date.valueOf(constituentDetailMap.get('birthdate'));
            } catch (TypeException e) {
                List<String> vars = new List<String>();
                vars.add(
                    ErrorLogger.convertStringToJSON(
                        'Could not get date value from provided birthdate',
                        constituentDetailMap.get('birthdate')
                    )
                );
                ErrorLogger.log(e, vars, false);
            }
        }
        if (constituentDetailMap.containsKey('constituentId')) {
            this.constituentId = constituentDetailMap.get('constituentId');
        }
        if (constituentDetailMap.containsKey('email')) {
            this.email = constituentDetailMap.get('email');
        }
        if (constituentDetailMap.containsKey('emplid')) {
            this.emplid = constituentDetailMap.get('emplid');
        }
        if (constituentDetailMap.containsKey('firstName')) {
            this.firstName = constituentDetailMap.get('firstName');
            String firstNameCopy = firstName;
            if (firstNameCopy.length() >= 3) {
                partialFirstName = firstName.substring(0, 3) + '%';
            } else if (firstNameCopy.length() < 3) {
                partialFirstName = firstName.substring(0, firstNameCopy.length()) + '%';
            }
        }
        if (constituentDetailMap.containsKey('lastName')) {
            this.lastName = constituentDetailMap.get('lastName');
        }
        if (constituentDetailMap.containsKey('mailingStreet')) {
            this.mailingStreet = constituentDetailMap.get('mailingStreet');
        }
        if (constituentDetailMap.containsKey('mailingCity')) {
            this.mailingCity = constituentDetailMap.get('mailingCity');
        }
        if (constituentDetailMap.containsKey('mailingCountry')) {
            this.mailingCountry = constituentDetailMap.get('mailingCountry');
        }
        if (constituentDetailMap.containsKey('mailingPostalCode')) {
            this.mailingPostalCode = constituentDetailMap.get('mailingPostalCode');
        }
        if (constituentDetailMap.containsKey('mailingState')) {
            this.mailingState = constituentDetailMap.get('mailingState');
        }
        if (constituentDetailMap.containsKey('middleName')) {
            this.middleName = constituentDetailMap.get('middleName');
        }
        if (constituentDetailMap.containsKey('phone')) {
            this.phone = constituentDetailMap.get('phone');
        }
        if (constituentDetailMap.containsKey('preferredName')) {
            this.preferredName = constituentDetailMap.get('preferredName');
        }

        if (constituentDetailMap.containsKey('processingNotes')) {
            this.processingNotes = constituentDetailMap.get('processingNotes');
        } else {
            this.processingNotes = '';
        }

        if (constituentDetailMap.containsKey('status')) {
            this.status = constituentDetailMap.get('status');
        } else {
            this.status = '';
        }
    }
}
