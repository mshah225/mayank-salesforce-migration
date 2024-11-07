/**
 * Leaving this in because Gearset in complaining when I remove it.  The references it is giving (the Visualforce pages,
 * fullContactCaseComments and fullCaseComments) don't use it. They include a VF Component - which has been modified to not
 * use it either. But this can be deleted in a later ticket. ¯\_(ツ)_/¯
 * @deprecated If you find this - you can delete this.
 */
public with sharing class FullCaseCommentsComponentController {
    public List<CaseComment> comments { get; set; }
}
