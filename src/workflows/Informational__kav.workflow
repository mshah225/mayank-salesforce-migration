<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><alerts>
        <fullName>Email_Article_Creator_Article_Published</fullName>
        <description>Email Article Creator: Article Published</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Knowledge_Templates/Knowledge_Published_Creator_Notification</template>
    </alerts><alerts>
        <fullName>Email_Article_Creator_Article_Rejected</fullName>
        <description>Email Article Creator: Article Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Knowledge_Templates/Knowledge_Rejected_Creator_Notification</template>
    </alerts><alerts>
        <fullName>Email_Group_for_Graduate_Admissions_Article_Published</fullName>
        <description>Email Group for Graduate Admissions: Article Published</description>
        <protected>false</protected>
        <recipients>
            <recipient>Knowledge_Admission_Services</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Knowledge_Templates/Knowledge_Published_Queue_Notification</template>
    </alerts><alerts>
        <fullName>Email_Knowledge_Group_for_Financial_Assistance_Article_Published</fullName>
        <description>Email Knowledge Group for Financial Assistance: Article Published</description>
        <protected>false</protected>
        <recipients>
            <recipient>Student_Financial_Assistance</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Knowledge_Templates/Knowledge_Published_Queue_Notification</template>
    </alerts><alerts>
        <fullName>Email_Knowledge_Group_for_Registrar_Article_Published</fullName>
        <description>Email Knowledge Group for Registrar: Article Published</description>
        <protected>false</protected>
        <recipients>
            <recipient>Registrar</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Knowledge_Templates/Knowledge_Published_Queue_Notification</template>
    </alerts><alerts>
        <fullName>Email_Knowledge_Group_for_Service_Center_Article_Published</fullName>
        <description>Email Knowledge Group for Service Center: Article Published</description>
        <protected>false</protected>
        <recipients>
            <recipient>Service_Center</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Knowledge_Templates/Knowledge_Published_Queue_Notification</template>
    </alerts><alerts>
        <fullName>Email_Knowledge_Group_for_Student_Business_Services_Article_Published</fullName>
        <description>Email Knowledge Group for Student Business Services: Article Published</description>
        <protected>false</protected>
        <recipients>
            <recipient>Student_Business_Services</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Knowledge_Templates/Knowledge_Published_Queue_Notification</template>
    </alerts><alerts>
        <fullName>Email_Knowledge_Group_for_University_Housing_Article_Published</fullName>
        <description>Email Knowledge Group for University Housing: Article Published</description>
        <protected>false</protected>
        <recipients>
            <recipient>University_Housing</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Knowledge_Templates/Knowledge_Published_Queue_Notification</template>
    </alerts><alerts>
        <fullName>Email_Knowledge_group_for_Undergraduate_Admissions_Article_Published</fullName>
        <description>Email Knowledge group for Undergraduate Admissions: Article Published</description>
        <protected>false</protected>
        <recipients>
            <recipient>Undergraduate_Admissions</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Knowledge_Templates/Knowledge_Published_Queue_Notification</template>
    </alerts><fieldUpdates>
        <fullName>Set_Expiration_Date_to_Today_180</fullName>
        <field>Article_Expiration_Date__c</field>
        <formula>TODAY() + 180</formula>
        <name>Set Expiration Date to Today + 180</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Set_validation_status_to_Approved</fullName>
        <field>ValidationStatus</field>
        <literalValue>Approved</literalValue>
        <name>Set validation status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Set_validation_status_to_Content_Review</fullName>
        <field>ValidationStatus</field>
        <literalValue>Content Review</literalValue>
        <name>Set validation status to Content Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Set_validation_status_to_Draft</fullName>
        <field>ValidationStatus</field>
        <literalValue>Draft</literalValue>
        <name>Set validation status to Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Set_validation_status_to_Format_Review</fullName>
        <field>ValidationStatus</field>
        <literalValue>Format Review</literalValue>
        <name>Set validation status to Format Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Set_validation_status_to_Published</fullName>
        <field>ValidationStatus</field>
        <literalValue>Published</literalValue>
        <name>Set validation status to Published</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Set_validation_status_to_Rejected</fullName>
        <field>ValidationStatus</field>
        <literalValue>Rejected</literalValue>
        <name>Set validation status to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><knowledgePublishes>
        <fullName>Publish_Article</fullName>
        <action>Publish</action>
        <description>Action publishes Informational articles.</description>
        <label>Publish Article</label>
        <language>en_US</language>
        <protected>false</protected>
    </knowledgePublishes></Workflow>