<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><fieldUpdates>
        <fullName>Campaign_Member_Subscribe_Date_Time</fullName>
        <description>Update MC Last Subscribe Date when MC IsSubscribed is changed to true.</description>
        <field>Last_Subscribed__c</field>
        <formula>NOW()</formula>
        <name>Campaign Member: Subscribe Date Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Campaign_Member_Unsubscribe_Date_Time</fullName>
        <description>Update MC Last Unsubscribe when MC IsSubscribed is changed to false.</description>
        <field>Last_Unsubscribe__c</field>
        <formula>NOW()</formula>
        <name>Campaign Member: Unsubscribe Date Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Inbound_Interaction_Set_to_True</fullName>
        <field>Inbound_Interaction__c</field>
        <literalValue>1</literalValue>
        <name>Inbound Interaction Set to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><fieldUpdates>
        <fullName>Last_Member_Status_Change_Set_to_NOW</fullName>
        <field>Last_Member_Status_Change__c</field>
        <formula>NOW()</formula>
        <name>Last Member Status Change - Set to NOW()</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Set_Inbound_Interaction_Date</fullName>
        <field>Inbound_Interaction_Date__c</field>
        <formula>NOW()</formula>
        <name>Set Inbound Interaction Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Set_Inbound_Interaction_Term</fullName>
        <field>Inbound_Interaction_Term__c</field>
        <formula>Opportunity__r.Term__r.Name</formula>
        <name>Set Inbound Interaction Term</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><rules>
        <fullName>Campaign Member%3A Set Oppty Inbound Interaction Indicators</fullName>
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
        <active>true</active>
        <description>When an Opportunity is first assocaited to a Campaign Member that is set as an Inbound Interaction, or when a Campaign Member with an associated Opportunity is set as a Inbound Interaction, set the Type, Term and Stage.</description>
        <formula>NOT(ISBLANK(Opportunity__c)) &amp;&amp; Inbound_Interaction__c &amp;&amp; ( ISNEW() || ISCHANGED(Opportunity__c) || ISCHANGED(Inbound_Interaction__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules><rules>
        <fullName>Campaign Member%3A Set as Inbound Interaction</fullName>
        <actions>
            <name>Inbound_Interaction_Set_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Source_Type__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>CampaignMember.Inbound_Interaction__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>For any Campaign Member associated with a Campaign with a Source Type listed, ensure that Campaign Member is set as an Inbound Interaction.</description>
        <triggerType>onAllChanges</triggerType>
    </rules><rules>
        <fullName>Campaign Member%3A Subscribe</fullName>
        <actions>
            <name>Campaign_Member_Member_Status_Subscribe</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Campaign_Member_Subscribe_Date_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CampaignMember.RecordTypeId</field>
            <operation>equals</operation>
            <value>Subscription Center Campaign Member</value>
        </criteriaItems>
        <criteriaItems>
            <field>CampaignMember.IsSubscribed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Update MC Last Subscribe field when MC IsSubscribed is true.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>Campaign Member%3A Unsubscribe</fullName>
        <actions>
            <name>Campaign_Member_Member_Status_Unsub</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Campaign_Member_Unsubscribe_Date_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CampaignMember.RecordTypeId</field>
            <operation>equals</operation>
            <value>Subscription Center Campaign Member</value>
        </criteriaItems>
        <criteriaItems>
            <field>CampaignMember.IsSubscribed__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Update MC Last Unsubscribe field when MC IsSubscribed is false.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>Campaign Member%3A Update Status Change Time-Date</fullName>
        <actions>
            <name>Last_Member_Status_Change_Set_to_NOW</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets the Last Member Status Change Date/Time field to NOW() anytime the Status is Changed.</description>
        <formula>ISCHANGED(Status)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules></Workflow>