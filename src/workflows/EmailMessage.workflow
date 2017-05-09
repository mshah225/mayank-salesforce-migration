<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><fieldUpdates xmlns="http://soap.sforce.com/2006/04/metadata">
        <fullName>Set_Illegal_Characters_In_Email_to_True</fullName>
        <field>Illegal_Characters_In_Outbound_Email__c</field>
        <literalValue>1</literalValue>
        <name>Set Illegal Characters In Email to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates><rules>
        <fullName>Set Illegal Character Checkbox to True</fullName>
        <actions>
            <name>Set_Illegal_Characters_In_Email_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2 OR 3) AND 4</booleanFilter>
        <criteriaItems>
            <field>EmailMessage.TextBody</field>
            <operation>contains</operation>
            <value>&lt;&lt;</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.TextBody</field>
            <operation>contains</operation>
            <value>&gt;&gt;</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.TextBody</field>
            <operation>contains</operation>
            <value>__</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>If an outbound Email is sent that contains "__", "&lt;&lt;", or "&gt;&gt;" (indicating information the individual sending the email should fill out), the "Illegal Characters In Outbound Email" is set to True. The activates a Validation Rule.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules></Workflow>