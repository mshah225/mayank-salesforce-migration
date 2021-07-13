/*****************************************
 * File: FullCaseCommentsComponentController
 * Author: Mathew Ruff, Sierra-Cedar Inc.
 * Description: Custom Controller logic for FullCaseComments.component
 ******************************************/
public with sharing class FullCaseCommentsComponentController {
    public List<CaseComment> comments { get; set; }

    public List<Case> theCases {
        get {
            if (theCases == null) {
                Set<Id> parentIds = new Set<Id>();

                for (CaseComment cc : comments)
                    parentIds.add(cc.ParentId);

                theCases = new List<Case>([SELECT Subject, CaseNumber FROM Case WHERE Id IN :parentIds]);
            }

            return theCases;
        }
        set;
    }

    public Map<Id, String> caseSubjectMap {
        get {
            if (caseSubjectMap == null) {
                caseSubjectMap = new Map<Id, String>();

                if (comments != null) {
                    for (Case c : theCases) {
                        caseSubjectMap.put(c.Id, c.Subject);
                    }
                }
            }

            return caseSubjectMap;
        }
        set;
    }

    public Map<Id, String> caseNumberMap {
        get {
            if (caseNumberMap == null) {
                caseNumberMap = new Map<Id, String>();

                if (comments != null) {
                    for (Case c : theCases) {
                        caseNumberMap.put(c.Id, c.CaseNumber);
                    }
                }
            }

            return caseNumberMap;
        }
        set;
    }
}
