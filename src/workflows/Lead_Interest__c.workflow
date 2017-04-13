<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><fieldUpdates>
        <fullName>Lead_Staus_to_Opt_Out</fullName>
        <description>Change Lead Status to Opt-Out when Lead Interest is Active and Qualifying is No Longer Interested</description>
        <field>Status__c</field>
        <literalValue>Opt Out</literalValue>
        <name>Lead: Update Staus to Opt Out</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Update_Type_Lead</fullName>
        <description>Update Lead Interest Type to Lead</description>
        <field>Type__c</field>
        <literalValue>Lead</literalValue>
        <name>Lead Interest: Update Type Lead</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates></Workflow>