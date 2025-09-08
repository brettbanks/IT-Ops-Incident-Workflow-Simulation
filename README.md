# IT Ops Incident Workflow Simulation

End-to-end incident flow to demonstrate practical IT Ops & SecOps skills:

- **Detection (Splunk):** Ingest a sample Sysmon log and alert on suspicious PowerShell.
- **Triage (Jira):** Create a Jira incident and track it with **priority SLAs**.
- **SLA Enforcement:** Visual timers + an **escalation rule** on breach.
- **Evidence:** PowerShell exports an **AD change log (CSV)** and it’s attached to the ticket.

<p align="center">
  <img src="splunk/splunk-search-result.png" width="760" alt="Splunk search: suspicious PowerShell">
</p>

---

## Table of contents
- [Repository structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Step-by-step](#step-by-step)
  - [1) Splunk — ingest, search, alert](#1-splunk--ingest-search-alert)
  - [2) Jira — incident + SLAs + escalation](#2-jira--incident--slas--escalation)
  - [3) Evidence — export AD change log (PowerShell)](#3-evidence--export-ad-change-log-powershell)
- [SLA targets](#sla-targets)
- [SPL used](#spl-used)
- [Git quick commands](#git-quick-commands)
- [Notes](#notes)

---

## Repository structure
```text
IT-Ops-Incident-Workflow-Simulation/
├─ scripts/                     # automation
│  ├─ Fix-HighCPU.ps1
│  └─ powershell-ad-export.ps1
├─ logs/                        # sample data
│  └─ sysmon_sample.log.txt
├─ splunk/                      # Splunk steps & alert
│  ├─ splunk-login.png
│  ├─ splunk-upload-source.png
│  ├─ splunk-upload-review.png
│  ├─ splunk-search-result.png
│  ├─ splunk-alert-config.png
│  ├─ splunk-alert-triggered.png
│  ├─ splunk-alert-email.png
│  ├─ splunk-alert-email-alt.png
│  └─ jira-splunk-alert-ticket.png
└─ jira/                        # Jira incidents & SLA views
   ├─ jira-incident-critical.png
   ├─ jira-incident-high.png
   ├─ jira-incident-medium.png
   ├─ jira-incident-low.png
   └─ jira-sla-breach.png
Prerequisites
Splunk Cloud/Enterprise (trial is fine)

Jira Service Management (ITSM/Service project)

Windows PowerShell (for the evidence script)

Step-by-step
1) Splunk — ingest, search, alert
Upload sample log
Add Data → Upload → choose logs/sysmon_sample.log.txt → set a simple sourcetype (e.g., sysmon_sample) → index main.

<p align="center"> <img src="splunk/splunk-upload-source.png" width="760" alt="Splunk - Select source"> </p>
Review & index
Confirm fields look sane, then continue.

<p align="center"> <img src="splunk/splunk-upload-review.png" width="760" alt="Splunk - Review before indexing"> </p>
Search for suspicious PowerShell

spl
Copy code
index="main" sourcetype="sysmon_sample" (powershell OR "Invoke-WebRequest")
<p align="center"> <img src="splunk/splunk-search-result.png" width="760" alt="Splunk - Search result"> </p>
Create an alert
Save as Alert: “Suspicious PowerShell Execution” → Trigger Number of results > 0 → (for demo) schedule every minute → Action Send email (or webhook/Jira).

<p align="center"> <img src="splunk/splunk-alert-config.png" width="760" alt="Splunk - Alert configuration"> </p>
When it fires:

<p align="center"> <img src="splunk/splunk-alert-triggered.png" width="680" alt="Splunk - Alert triggered"> </p> <p align="center"> <img src="splunk/splunk-alert-email.png" width="520" alt="Splunk - Alert email sample"> </p>
(Optional) If you create a Jira issue from a webhook/mail handler:

<p align="center"> <img src="splunk/jira-splunk-alert-ticket.png" width="760" alt="Jira ticket created from Splunk alert"> </p>
2) Jira — incident + SLAs + escalation
Create/inspect the incident
Fill Summary, Description, Service affected, Priority, Root cause, Resolution Notes.

<p align="center"> <img src="jira/jira-incident-critical.png" width="760" alt="Jira - Critical incident"> </p>
Validate priority SLAs
Timers should reflect policy and priority.

<p align="center"> <img src="jira/jira-incident-low.png" width="420" alt="Jira - Low priority SLA"> <img src="jira/jira-incident-medium.png" width="420" alt="Jira - Medium priority SLA"> </p> <p align="center"> <img src="jira/jira-incident-high.png" width="760" alt="Jira - High priority SLA"> </p>
Test escalation on breach
Use a short target (e.g., 1 minute) on Critical Incident Resolution SLA to demonstrate breach → auto-assign / notify.

<p align="center"> <img src="jira/jira-sla-breach.png" width="760" alt="Jira - SLA breach and escalation"> </p>
3) Evidence — export AD change log (PowerShell)
Script: scripts/powershell-ad-export.ps1
Default export path inside the script: C:\IT-Ops-Lab\AD_ChangeLog.csv (create the folder or change $ExportPath).

Run

powershell
Copy code
# one-session bypass for scripts
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# run from repo root or adjust path
.\scripts\powershell-ad-export.ps1
Attach the resulting CSV to the Jira incident as audit evidence.

SLA targets
Priority	Time to first response	Time to resolution
Highest	2h	4h
High	4h	24h
Medium	6h	36h
Low	8h	48–72h

SPL used
spl
Copy code
index=main sourcetype=sysmon_sample (Process="powershell.exe" OR Image="*\\powershell.exe" OR Command="*Invoke-WebRequest*" OR Command="*EncodedCommand*")
| table _time host User Process Command
| sort - _time
