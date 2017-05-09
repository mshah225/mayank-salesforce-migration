<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><alerts xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>AS_Processing_Fee_Waiver_Approved</fullName>
        <description>AS Processing - Fee Waiver Approved</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Admission_Services_Undergrad/Fee_Waiver_Approved_Posted</template>
    </alerts><alerts xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>AS_Processing_Fee_Waiver_Incomplete_Waiver_Submitted</fullName>
        <description>AS Processing - Fee Waiver: Incomplete Waiver Submitted</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Admission_Services_Undergrad/Fee_Waiver_Incomplete_Waiver_Submitted1</template>
    </alerts><alerts xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>AS_Processing_Fee_Waiver_No_Application_on_File</fullName>
        <description>AS Processing - Fee Waiver: No Application on File</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Admission_Services_Undergrad/Fee_Waiver_No_Application_on_File</template>
    </alerts><alerts xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>AS_Processing_Fee_Waiver_Not_Applicable</fullName>
        <description>AS Processing - Fee Waiver Not Applicable</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Admission_Services_Undergrad/Fee_Waiver_Not_Applicable_Not_Approved</template>
    </alerts><alerts xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>AS_Processing_Major_Change_Applicant_Approved_Email_Notification_to_Student</fullName>
        <description>AS Processing - Major Change: Applicant Approved Email Notification to Student</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Admission_Services_Undergrad/Major_Change_Applicant_Approved_Email_Notification_to_Student</template>
    </alerts><alerts xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>AS_Processing_Major_change_NOT_approved_Email</fullName>
        <description>AS Processing - Major change NOT approved Email</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Admission_Services_Undergrad/Major_change_NOT_approved_Email</template>
    </alerts><alerts xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>AS_Processing_Major_change_NOT_approved_Online</fullName>
        <description>AS Processing - Major change NOT approved - Online</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Admission_Services_Undergrad/Major_change_NOT_approved_Email_ONLINE</template>
    </alerts><alerts xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>AS_Processing_Major_change_approved_Online</fullName>
        <description>AS Processing - Major change approved - Online</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Admission_Services_Undergrad/Major_Change_Approved_Email_ONLINE</template>
    </alerts><alerts xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>AS_Processing_Non_FTF_Major_Change_Approved_Email_Notification_to_Student</fullName>
        <description>AS Processing - Non FTF Major Change Approved Email Notification to Student</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Admission_Services_Undergrad/Major_Change_Non_FTF_Major_Change_Approved_Email_Notification_to_Student</template>
    </alerts><alerts xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Email_Contact_Case_Creation_Verification</fullName>
        <description>Email Contact Case Creation Verification</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>customerservice@asu.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Management/Case_Received_Template_Default</template>
    </alerts><alerts xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Send_GetFeedback_Survey</fullName>
        <description>Send GetFeedback Survey</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>service@asu.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Management/Case_Management_Survey</template>
    </alerts><fieldUpdates xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Case_Copy_Original_Category</fullName>
        <description>Grab the original category when the case was created.</description>
        <field>Original_Category__c</field>
        <formula>Text( Category__c )</formula>
        <name>Case: Copy Original Category</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Case_Copy_Original_Functional_Group</fullName>
        <description>Update original functional group field.</description>
        <field>Original_Functional_Group__c</field>
        <formula>TEXT(Functional_Group__c)</formula>
        <name>Case: Copy Original Functional Group</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Case_Record_Type_to_ASU_Admission_Servi</fullName>
        <description>If the Record Type is currently "ASU Service" and the Functional Group or Category indicates a connection to the Admissions Services group, set the Record Type to "ASU Admission Services".</description>
        <field>RecordTypeId</field>
        <lookupValue>ASU_Admission_Services</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Case: Record Type to ASU Admission Servi</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><fieldUpdates xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Case_Record_Type_to_ASU_Service</fullName>
        <description>If the Record Type is currently "ASU Admission Services" and the Functional Group or Category does not indicate a connection to the Admissions Services group, set the Record Type to "ASU Service"</description>
        <field>RecordTypeId</field>
        <lookupValue>ASU_Service</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Case: Record Type to ASU Service</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><fieldUpdates xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Case_Security_Checkbox_to_False</fullName>
        <field>Open_Security_Case__c</field>
        <literalValue>0</literalValue>
        <name>Case Security Checkbox to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><fieldUpdates xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Case_Survey_Sent_Date_Set_to_Now</fullName>
        <field>Case_Survey_Sent_Date__c</field>
        <formula>NOW()</formula>
        <name>Case Survey Sent Date - Set to Now</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><fieldUpdates xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Set_Case_Origin_to_My_ASU</fullName>
        <field>Origin__c</field>
        <literalValue>My ASU</literalValue>
        <name>Set Case Origin to My ASU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Set_Category_to_Applicant_Services</fullName>
        <description>Updates the Case Category field to Applicant Services - Undergraduate</description>
        <field>Category__c</field>
        <literalValue>Applicant Services - Undergraduate</literalValue>
        <name>Set Category to Applicant Services - UG</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Set_Category_to_Applicant_Services_GR</fullName>
        <field>Category__c</field>
        <literalValue>Applicant Services - Graduate</literalValue>
        <name>Set Category to Applicant Services - GR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><fieldUpdates xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Set_Category_to_Freshman_Recruitment</fullName>
        <description>Updates the Case Category field to Freshman Recruitment</description>
        <field>Category__c</field>
        <literalValue>Freshman Recruitment</literalValue>
        <name>Set Category to Freshman Recruitment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Set_Category_to_General_Help_Desk</fullName>
        <field>Category__c</field>
        <literalValue>General Help Desk</literalValue>
        <name>Set Category to General Help Desk</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Set_Category_to_Recruitment_Operations</fullName>
        <description>Updates the Case Category field to Recruitment Operations</description>
        <field>Category__c</field>
        <literalValue>Recruitment Operations</literalValue>
        <name>Set Category to Recruitment Operations</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Set_Category_to_Transfer_Recruitment</fullName>
        <description>Updates the Case Category field to Transfer Recruitment</description>
        <field>Category__c</field>
        <literalValue>Transfer Recruitment</literalValue>
        <name>Set Category to Transfer Recruitment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Set_Forward_Case_To_Email</fullName>
        <field>Forward_To_Email__c</field>
        <formula>Forward_To_Email_Calculation__c</formula>
        <name>Set Forward Case To Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><fieldUpdates xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Set_Forward_to_Unit_to_Other_Unit</fullName>
        <field>Forward_To_Unit__c</field>
        <literalValue>Other Unit</literalValue>
        <name>Set Forward to Unit to Other Unit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Set_Functional_Group_to_Help_Desk</fullName>
        <field>Functional_Group__c</field>
        <literalValue>Help Desk</literalValue>
        <name>Set Functional Group to Help Desk</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><fieldUpdates xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Set_Inbound_Interaction_Date</fullName>
        <field>Inbound_Interaction_Date__c</field>
        <formula>NOW()</formula>
        <name>Set Inbound Interaction Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Set_Inbound_Interaction_Term</fullName>
        <field>Inbound_Interaction_Term__c</field>
        <formula>Opportunity__r.Term__r.Name</formula>
        <name>Set Inbound Interaction Term</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Set_Inbound_Interaction_to_True</fullName>
        <description>Will indicate that a Case record was created through an inbound interaction.</description>
        <field>Inbound_Interaction__c</field>
        <literalValue>1</literalValue>
        <name>Set Inbound Interaction to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Set_Origin_to_My_ASU</fullName>
        <field>Origin__c</field>
        <literalValue>My ASU</literalValue>
        <name>Set Origin to My ASU</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Update_Case_Origin</fullName>
        <field>Origin__c</field>
        <literalValue>Error Logger</literalValue>
        <name>Update Case Origin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Set_Owner_to_Admission_Services_UG</fullName>
        <description>Update case owner to the Admission Services queue</description>
        <field>OwnerId</field>
        <lookupValue>Admission_Services_Undergrad_Case</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Set Owner to Admission Services</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Set_Owner_to_Help_Desk_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Help_Desk_Case</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Set Owner to Help Desk Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates><rules xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Case Security Checkbox to False</fullName>
        <actions>
            <name>Case_Security_Checkbox_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>Owner:Queue.DeveloperName = "CLAS_Air_Force_ROTC_Case"</formula>
        <triggerType>onAllChanges</triggerType>
    </rules><rules xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Case%3A AS NAS Applicant Services - Graduate</fullName>
        <actions>
            <name>Set_Category_to_Applicant_Services_GR</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Owner_to_Admission_Services_UG</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASU Admission Services</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Needs_Attention__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sub_Category__c</field>
            <operation>equals</operation>
            <value>Grad - Voluntary Withdrawals,Grad - Deferrals,Grad - Plan Changes,Grad - Degree Posting,Grad - Matching Documents</value>
        </criteriaItems>
        <description>Route cases to the Applicant Services - Graduate team where the subcategory is defined and the Needs Attention checkbox = TRUE</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Case%3A AS NAS Applicant Services - UG</fullName>
        <actions>
            <name>Set_Category_to_Applicant_Services</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Owner_to_Admission_Services_UG</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASU Admission Services</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Needs_Attention__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sub_Category__c</field>
            <operation>notEqual</operation>
            <value>Application Fee,ASURITE Reset,Test Scores - Search / Find</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sub_Category__c</field>
            <operation>notEqual</operation>
            <value>Personal Info - Needs Changed,Request for Outreach Materials</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sub_Category__c</field>
            <operation>notEqual</operation>
            <value>Admit/Conditional Letter Inquiry,Fee Waiver Inquiry</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sub_Category__c</field>
            <operation>notEqual</operation>
            <value>National Merit,WUE - FTF,WUE - TRN</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sub_Category__c</field>
            <operation>notEqual</operation>
            <value>Grad - Deferals,Grad - Degree Posting,Grad - Matching Documents,Grad - Plan Changes,Grad - Voluntary Withdrawals</value>
        </criteriaItems>
        <description>Workflow rule used when a "Needs Attention" case should be routed to the Applicant Services Team.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Case%3A AS NAS Freshman Recruitment</fullName>
        <actions>
            <name>Set_Category_to_Freshman_Recruitment</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Owner_to_Admission_Services_UG</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Needs_Attention__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sub_Category__c</field>
            <operation>equals</operation>
            <value>National Merit,WUE - FTF</value>
        </criteriaItems>
        <description>Workflow rule used when a "Needs Attention" case should be routed to the Freshman Recruiter Team</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Case%3A AS NAS Recruitment Operations</fullName>
        <actions>
            <name>Set_Category_to_Recruitment_Operations</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Owner_to_Admission_Services_UG</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASU Admission Services</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Needs_Attention__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sub_Category__c</field>
            <operation>equals</operation>
            <value>Admit/Conditional Letter Inquiry,Application Fee,ASURITE Reset,Fee Waiver Inquiry,Personal Info - Needs Changed,Request for Outreach Materials,Test Scores - Search / Find</value>
        </criteriaItems>
        <description>Workflow rule used when a Case should be routed to the Admission Services Recruitment Operations Team</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Case%3A AS NAS Transfer Recruitment</fullName>
        <actions>
            <name>Set_Category_to_Transfer_Recruitment</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Owner_to_Admission_Services_UG</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Needs_Attention__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sub_Category__c</field>
            <operation>equals</operation>
            <value>WUE - TRN</value>
        </criteriaItems>
        <description>Workflow rule used when a "Needs Attention" case should be routed to the Transfer Recruiter Team</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Case%3A My ASU Submission</fullName>
        <actions>
            <name>Email_Contact_Case_Creation_Verification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Set_Case_Origin_to_My_ASU</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Category_to_General_Help_Desk</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Functional_Group_to_Help_Desk</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Owner_to_Help_Desk_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Web_Submission__c</field>
            <operation>equals</operation>
            <value>My ASU Standard</value>
        </criteriaItems>
        <description>When a case is created with "My ASU Standard" passed in the Web Submission field, an Email notices is sent &amp; the following  values are set -

Origin: My ASU
Functional Group: Help Desk
Category: General Help Desk
Owner: Help Desk Queue</description>
        <triggerType>onCreateOnly</triggerType>
    </rules><rules xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Case%3A Record Type to ASU Admission Services</fullName>
        <actions>
            <name>Case_Record_Type_to_ASU_Admission_Servi</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND (3 OR 4 OR 5)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASU Service</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Functional_Group__c</field>
            <operation>notEqual</operation>
            <value>ASU Salesforce Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Functional_Group__c</field>
            <operation>equals</operation>
            <value>Admission Services</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Category__c</field>
            <operation>contains</operation>
            <value>Recruitment</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sub_Category__c</field>
            <operation>contains</operation>
            <value>Recruitment</value>
        </criteriaItems>
        <description>If the Record Type is currently "ASU Service" and the Functional Group or Category indicates a connection to the Admissions Services group, set the Record Type to "ASU Admission Services".</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Case%3A Record Type to ASU Service</fullName>
        <actions>
            <name>Case_Record_Type_to_ASU_Service</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND (3 AND 4)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASU Admission Services</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Functional_Group__c</field>
            <operation>notEqual</operation>
            <value>Admission Services,External Unit</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Category__c</field>
            <operation>notContain</operation>
            <value>Recruitment</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sub_Category__c</field>
            <operation>notContain</operation>
            <value>Recruitment</value>
        </criteriaItems>
        <description>If the Record Type is currently "ASU Admission Services" and the Functional Group or Category does not indicate a connection to the Admissions Services group, set the Record Type to "ASU Service"</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Case%3A Send GetFeedback survey</fullName>
        <actions>
            <name>Send_GetFeedback_Survey</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Case_Survey_Sent_Date_Set_to_Now</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Rule to send feedback survey to student after case is closed. REMINDER update Formula field Feedback_Link__c on Case Object to match.</description>
        <formula>/* Since the Case Custom Field "Feedback Link" only displays the text "Take a survey to tell us how we did" if the Case is eligible to receive a survey, check for part of that text*/ 
BEGINS(Feedback_Link__c,"Take") &amp;&amp; 
/*Limit to only sending when the case number ends in a number less than 25. This limits to a maximum of 25% of Cases being sent the email */ 
VALUE(RIGHT(CaseNumber,2)) &lt; 25 &amp;&amp;  
/*Only send the survey if it hasn't already been sent*/ ISBLANK(Case_Survey_Sent_Date__c) &amp;&amp; 
/*Check to ensure that the Contact has not received a survey in the past month*/ 
OR(ISBLANK( Contact.Last_Case_Survey_Sent_Date__c),( TODAY() -30) &gt; DATEVALUE( Contact.Last_Case_Survey_Sent_Date__c )) &amp;&amp; 
/*Check to ensure that the email that was used to open the Case is not associated with teams that do not want to participate in surveys.*/ 
OR( NOT(CONTAINS(Initial_Request_Sent_To_Addresses__c,"gograd@asu.edu")), ISBLANK(Initial_Request_Sent_To_Addresses__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Case%3A Set Forward Case To Email</fullName>
        <actions>
            <name>Set_Forward_Case_To_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Forward_To_Email_Calculation__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Forward_To_Email__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules><rules xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Case%3A Set Forward to Unit to Other Unit</fullName>
        <actions>
            <name>Set_Forward_to_Unit_to_Other_Unit</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Forward_To_Unit__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Forward_To_Email__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>If the Forward to Unit is left blank, but a Forward to Email is Provided, set the Forward to Unit to "Other Unit".</description>
        <triggerType>onAllChanges</triggerType>
    </rules><rules xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Case%3A Set Opportunity Indicators</fullName>
        <actions>
            <name>Set_Inbound_Interaction_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Inbound_Interaction_Stage</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Inbound_Interaction_Term</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Inbound_Interaction_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Inbound_Interaction_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When an Opportunity is first associated to a Case Contact that is set as a Source, or when a Case Contact with an Associated Opportunity is set as a Source, set the Type, Term and Stage.</description>
        <formula>RecordType.DeveloperName = "ASU_Admission_Services" &amp;&amp; NOT(ISBLANK(Opportunity__c)) &amp;&amp; ( ISNEW() || NOT(Inbound_Interaction__c) || ISCHANGED(Opportunity__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules><rules xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Case%3A Update original functional group and category</fullName>
        <actions>
            <name>Case_Copy_Original_Category</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Case_Copy_Original_Functional_Group</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Functional_Group__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>When a case is created get the original functional group and category.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules><rules xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Set Fields for My ASU Submission</fullName>
        <actions>
            <name>Set_Category_to_General_Help_Desk</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Functional_Group_to_Help_Desk</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Origin_to_My_ASU</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Owner_to_Help_Desk_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Web_Submission__c</field>
            <operation>equals</operation>
            <value>My ASU Standard</value>
        </criteriaItems>
        <description>When a case is created with "My ASU Standard" passed into the Web Submission field, the following other field values are set -

Case Origin: My ASU
Functional Group: Help Desk
Category: General Help Desk
Owner: Help Desk Queue</description>
        <triggerType>onCreateOnly</triggerType>
    </rules><rules xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Update Origin To Error Logger</fullName>
        <actions>
            <name>Update_Case_Origin</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  Contains(Subject, 'Apex Exception: '),  Contains(Subject, 'Date: ' &amp;  TEXT(TODAY())) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules></Workflow>