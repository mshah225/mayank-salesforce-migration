<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><rules>
        <fullName>Task%3A GRES Assign Angela Harguess</fullName>
        <actions>
            <name>Task_GRES_Assign_Angela_Harguess</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Plan_Code__c</field>
            <operation>equals</operation>
            <value>ESENGRMENG,ESSFEMSE</value>
        </criteriaItems>
        <description>Assign task to Alicia Richardson for the following plan codes: ESENGRMENG, ESSFEMSE</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>Task%3A GRLA Assign Alicia Richardson</fullName>
        <actions>
            <name>Task_GRLA_Assign_Alicia_Richardson</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Plan_Code__c</field>
            <operation>equals</operation>
            <value>LAAISCMS,LAAISIMS,LAAISTMS,LAAISVMS</value>
        </criteriaItems>
        <description>Assign task to Alicia Richardson for the following plan codes: LAAISCMS, LAAISIMS, LAAISTMS, LAAISVMS</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>Task%3A GRLA Assign Andra Williams</fullName>
        <actions>
            <name>Task_GRLA_Assign_Andra_Williams</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Plan_Code__c</field>
            <operation>equals</operation>
            <value>GCRSESGRCT,LAHSDPSM,GCHSDSTPHD,LAAEPMEMA,LAAEPSEEMA,LSGTDMS</value>
        </criteriaItems>
        <description>Assign web form submission task to Andra Williams for GCRSESGRCT,LAHSDPSM,GCHSDSTPHD, LAAEPMEMA, LAAEPSEEMA, LSGTDMS</description>
        <triggerType>onCreateOnly</triggerType>
    </rules><rules>
        <fullName>Task%3A GRLA Assign David Nutt</fullName>
        <actions>
            <name>Task_GRLA_Assign_to_David_Nutt</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Plan_Code__c</field>
            <operation>equals</operation>
            <value>LABCHMCMS,LABIOCHMS,LABIOCHPHD,LACHEMMNS,LACHEMMS,LACHEMPHD</value>
        </criteriaItems>
        <description>Assign web form submission to David Nutt for plan codes LABCHMCMS, LABIOCHMS, LABIOCHPHD, LACHEMMNS, LACHEMMS, LACHEMPHD</description>
        <triggerType>onCreateOnly</triggerType>
    </rules><rules>
        <fullName>Task%3A GRLA Assign Gina Perez</fullName>
        <actions>
            <name>GRTE_Assign_Task_Gina</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Plan_Code__c</field>
            <operation>equals</operation>
            <value>LACDEMAS,LAFAMHDMS,LAFAMSCPHD,LAMFTMAS,LASOCMA,LASOCPHD</value>
        </criteriaItems>
        <description>Assign web form submission tasks to Gina Perez for the plan codes LACDEMAS, LAFAMHDMS, LAFAMSCPHD, LAMFTMAS, LASOCMA, LASOCPHD</description>
        <triggerType>onCreateOnly</triggerType>
    </rules><rules>
        <fullName>Task%3A GRLA Assign Heather Freireich</fullName>
        <actions>
            <name>Task_GRLA_Assign_Heather_Freireich</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Plan_Code__c</field>
            <operation>equals</operation>
            <value>LACOMMOPHD</value>
        </criteriaItems>
        <description>Assign web form submission tasks to Heather Freireich for the plan codes LACOMMOPHD</description>
        <triggerType>onCreateOnly</triggerType>
    </rules><rules>
        <fullName>Task%3A GRLA Assign Ixchell Paape</fullName>
        <actions>
            <name>Task_GRLA_Assign_Ixchell_Paape</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Plan_Code__c</field>
            <operation>equals</operation>
            <value>LANANPSM,LAPHYSMNS,LAPHYSIPHD</value>
        </criteriaItems>
        <description>Assign web form submission tasks to Ixchell Paape for the plan codes LAPHYSMNS, LAPHYSIPHD, LANANPSM</description>
        <triggerType>onCreateOnly</triggerType>
    </rules><rules>
        <fullName>Task%3A GRLA Assign Kira Assad</fullName>
        <actions>
            <name>Task_GRLA_Assign_Kira_Assad</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Plan_Code__c</field>
            <operation>equals</operation>
            <value>EDAPLPHD,LAAMPCMAS,LAENEDPHD,LAENGLMA,LAENGMTESL,LAENLITPHD,LAENRHTPHD,LALINGUICE</value>
        </criteriaItems>
        <description>Assign web form submission tasks to Kira Assad (Shelia Luna's assistant) for the plan codes EDAPLPHD, LAAMPCMAS, LAENEDPHD, LAENGLMA, LAENGMTESL, LAENLITPHD, LAENRHTPHD, LALINGUICE</description>
        <triggerType>onCreateOnly</triggerType>
    </rules><rules>
        <fullName>Task%3A GRLA Assign Leah Legg</fullName>
        <actions>
            <name>GRLA_Assign_Leah_Legg</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Plan_Code__c</field>
            <operation>equals</operation>
            <value>LAPOLSCPHD,LAPOLSCMA</value>
        </criteriaItems>
        <description>Assign task to Leah Legg for the following plan codes: LAPOLSCPHD, LAPOLSCMA</description>
        <triggerType>onCreateOnly</triggerType>
    </rules><rules>
        <fullName>Task%3A GRLA Assign Nancy Winn</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Task.Plan_Code__c</field>
            <operation>equals</operation>
            <value>LAGSTPHD,LAJUSSTPHD</value>
        </criteriaItems>
        <description>Assign web form submission tasks to Nancy Winn for the plan codes LAJUSSTPHD
LAGSTPHD</description>
        <triggerType>onCreateOnly</triggerType>
    </rules><rules>
        <fullName>Task%3A GRLA Assign Paul Morris</fullName>
        <actions>
            <name>Task_GRLA_Assign_Paul_Morris</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Plan_Code__c</field>
            <operation>equals</operation>
            <value>LAFMSMLS,LAMLSMLS</value>
        </criteriaItems>
        <description>Assign web form submission tasks to Paul Morris for the plan codes LAFMSMLS, LAMLSMLS</description>
        <triggerType>onCreateOnly</triggerType>
    </rules><rules>
        <fullName>Task%3A GRLA Assign Rebecca Dial</fullName>
        <actions>
            <name>Task_GRLA_Assign_Rebecca_Dial</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Plan_Code__c</field>
            <operation>equals</operation>
            <value>LAASTPHPHD,LAASTPHMS,LAESDPHD,LAESDSEPHD,LAESDIPHD,LAGEOSCPHD,LAGEOSCMS,LANATSCIMN</value>
        </criteriaItems>
        <description>Assign task to Rebecca Dial for the following plan codes: LAASTPHPHD, LAASTPHMS, LAESDPHD, LAESDSEPHD, LAESDIPHD, LAGEOSCPHD, LAGEOSCMS, LANATSCIMN</description>
        <triggerType>onCreateOnly</triggerType>
    </rules><rules>
        <fullName>Task%3A GRLA Assign Roxanne Shand</fullName>
        <actions>
            <name>GRLA_Assign_to_Roxanne_Shand</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Plan_Code__c</field>
            <operation>equals</operation>
            <value>LAAMSTMA,LAASIANCE,LAHISTMA,LAPHILMA,LARELIGMA,LASCHPUBCE,LAHISTPHD,LAPHILPHD,LARELIGPHD</value>
        </criteriaItems>
        <description>Assign task to Roxanne Shand for the following plan codes: LAASIANCE, LAHISTMA, LAPHILMA, LARELIGMA, LASCHPUBCE, LAAMSTMA, LAHISTPHD, LAPHILPHD, LARELIGPHD, LASCHPUBCE, LAASIANCE</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>Task%3A GRLA Assign Wendi Simonson</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Task.Plan_Code__c</field>
            <operation>equals</operation>
            <value>LAPLBIOMS,LAANBPHD,LABIOCPHD,LABIOMS,LABIOPHD,LABIOSMS,LABIOSPHD,LAELSPHD,LAHPSCIPHD,LAMICROPHD,LACELLPHD,LACELLMS,LAEVOPHD,GCBMENPHD</value>
        </criteriaItems>
        <description>Assign web form submission tasks to Wendi Simonson for the plan codes LAANBPHD, LABIOCPHD, LABIOMS, LABIOPHD, LABIOSMS, LABIOSPHD, LAELSPHD, LAHPSCIPHD, LAMICROPHD, LACELLMS, GCBMENPHD,  LACELLPHD, LAEVOPHD,LAPLBIOMS</description>
        <triggerType>onCreateOnly</triggerType>
    </rules><rules>
        <fullName>Task%3A GRNH Assign Anita Youmara</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Task.Plan_Code__c</field>
            <operation>equals</operation>
            <value>LAAUDAUDD,LAHEARPHD,LACOMDISMS</value>
        </criteriaItems>
        <description>Assign web form submissions for plan codes LAAUDAUDD, LACOMDISMS, LAHEARPHD to Anita Youmara</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>Task%3A GRNH Assign Lauren Madjidi</fullName>
        <actions>
            <name>Task_GRNH_Assign_to_Lauren_Madjidi</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Plan_Code__c</field>
            <operation>equals</operation>
            <value>ESBIOINFMS,NHBMDMS,ESBMIPHD</value>
        </criteriaItems>
        <description>Assign web submission tasks to Lauren Madjidi for Biomedical Informatics (MS) (ESBIOINFMS), Biomedical Informatics (PHD) (ESBMIPHD), and Biomedical Diagnostics (NHBMDMS)</description>
        <triggerType>onCreateOnly</triggerType>
    </rules><rules>
        <fullName>Task%3A GRSU Assign Katie</fullName>
        <actions>
            <name>GRSU_Assign_Task</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Plan_Code__c</field>
            <operation>equals</operation>
            <value>SUCASGRCT,SUSUSGGRCT,SUSUSTMAP,SUSUSTMSP,SUSUSTCPHD,SUSUSTMA,SUSUSTMS,SUSUSTPHD,SUSUSOMSUS</value>
        </criteriaItems>
        <description>Assign task created from web form submission to Katie Kinast in GRSU</description>
        <triggerType>onCreateOnly</triggerType>
    </rules><rules>
        <fullName>Task%3A GRTE Assign Amy</fullName>
        <actions>
            <name>GRTE_Assign_Web_Submission_Task</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Plan_Code__c</field>
            <operation>equals</operation>
            <value>TELINEDD</value>
        </criteriaItems>
        <description>Assign web form submission to Amy H for GRTE plan codes: TELINEDD</description>
        <triggerType>onCreateOnly</triggerType>
    </rules><rules>
        <fullName>Task%3A GRTE Assign Donna</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Task.Plan_Code__c</field>
            <operation>equals</operation>
            <value>EDSPFMA,ESPSYCHMA,EDACCTCMA,EDSUPVMED,EDTECHMED,EDPOSTMED,EDINSRESCE,EDEDTGRCT,EDLANGMA,TEEDTGRCT</value>
        </criteriaItems>
        <description>Assign web submission tasks to Donna Parris for plan codes: EDACCTCMA, EDSUPVMED, EDTECHMED, EDPOSTMED, EDINSRESCE, EDEDTGRCT, EDLANGM, TEEDTGRCT, EDSPFMA, ESPSYCHMA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>Task%3A GRTE Assign EDD PhD</fullName>
        <actions>
            <name>GRTE_Assign_Web_Submission_Task</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Plan_Code__c</field>
            <operation>equals</operation>
            <value>EDLDRSHPHD,EDCIPHD</value>
        </criteriaItems>
        <description>Assign web form submission tasks for GRTE to Amy H. for the plan codes EDCIPHD, EDLDRSHPHD - temporary</description>
        <triggerType>onCreateOnly</triggerType>
    </rules><rules>
        <fullName>Task%3A GRTE Complete ASU Managed</fullName>
        <actions>
            <name>Complete_Task</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Plan_Code__c</field>
            <operation>equals</operation>
            <value>TEABAMED,TEASDMED,TEGEDGRCT,TEESLGRCT,TEABAGRCT,EDSPEGRCA,TEECDMED,TEGEDMED,TEPRINMED,EDESLMA</value>
        </criteriaItems>
        <description>Complete tasks for ASU Managed programs for GRTE plan codes: EDSPEGRCA, TEABAMED, TEASDMED, TEECDMED, TEGEDMED, TEPRINMED, EDESLMA, TEGEDGRCT, TEESLGRCT, TEABAGRCT,TEABAMED,TEASDMED</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>Task%3A GRTS Assign Grant Griffin</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Task.Plan_Code__c</field>
            <operation>equals</operation>
            <value>TSATMSTECH,TSCOMPMCST,TSEGRMS,TSGEMSTECH,TSGIMSTECH,TSHFMSTECH,TSIFTMS,TSMEGRMS,TSMFMSTECH,TSMGMSTECH,TSMHMSTECH,TSMRMSTECH,TSSERMS,TSSMACSPHD,TSSYMSTECH,ECAPSYCHMS,LAAEPEETMA</value>
        </criteriaItems>
        <description>Assign tasks for the GRES: Poly College
ECAPSYCHMS, LAAEPEETMA, TSATMSTECH, TSCOMPMCST, TSEGRMS, TSGEMSTECH, TSGIMSTECH, TSHFMSTECH, TSIFTMS, TSMEGRMS, TSMFMSTECH, TSMGMSTECH, TSMHMSTECH, TSMRMSTECH, TSSERMS, TSSMACSPHD, TSSYMSTECH</description>
        <triggerType>onCreateOnly</triggerType>
    </rules></Workflow>