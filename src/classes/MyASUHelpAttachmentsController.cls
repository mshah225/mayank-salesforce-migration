public with sharing class MyASUHelpAttachmentsController {
    public Id attParentId { get; set; }
    public Attachment objAtt { get; set; }
    public List<String> vars;

    public List<Attachment> listAtt {
        get {
            listAtt = new List<Attachment>(
                [SELECT id, Name, CreatedDate FROM Attachment WHERE ParentId = :attParentId ORDER BY CreatedDate DESC]
            );

            return listAtt;
        }
        set;
    }

    public Boolean isAtt {
        get {
            isAtt = listAtt == null || listAtt.size() == 0 ? false : true;
            return isAtt;
        }
        set;
    }

    public MyASUHelpAttachmentsController() {
        objAtt = new Attachment();
    }

    /**
     *Assigns parent Id to uploaded attachment and then inserts it.
     *<p> SFE-7653: Upload Attachments from My ASU Service Center
     *
     *@param void
     *@return void
     **/

    public void uploadAtt() {
        if (objAtt.Name != null && objAtt.Body != null && attParentId != null) {
            objAtt.ParentId = attParentId;
            try {
                insert objAtt;
            } catch (Exception e) {
                vars = new List<String>();
                vars.add(ErrorLogger.convertStringToJSON('name', objAtt.name));
                ErrorLogger.log(e, vars, false);
            }
            objAtt = new Attachment();
        }
    }
}
