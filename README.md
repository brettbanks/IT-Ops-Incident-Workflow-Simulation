# IT Ops Incident Workflow Simulation

End-to-end incident flow to demonstrate practical IT Ops & SecOps skills:

- **Detection (Splunk):** Ingest a sample Sysmon log and alert on suspicious PowerShell.
- **Triage (Jira):** Auto/Manually create a Jira incident and track it with priority SLAs.
- **SLA Enforcement:** Visual timers + an escalation rule on breach.
- **Evidence:** PowerShell script exports an **AD change log (CSV)** and is attached to the ticket.

<p align="center">
  <img src="splunk/splunk-search-result.png" width="720" alt="Splunk search result showing suspicious PowerShell"/>
</p>

---

## Table of contents
- [Repository structure](#repository-structure)
- [What you’ll build](#what-youll-build)
- [Prerequisites](#prerequisites)
- [Step-by-step](#step-by-step)
  - [1) Splunk — ingest, search, alert](#1-splunk--ingest-search-alert)
  - [2) Jira — create/validate incident + SLAs](#2-jira--createvalidate-incident--slas)
  - [3) Evidence — export AD change log (PowerShell)](#3-evidence--export-ad-change-log-powershell)
- [Screenshot gallery](#screenshot-gallery)
- [Git quick commands](#git-quick-commands)
- [Notes](#notes)

---

## Repository structure
IT-Ops-Incident-Workflow-Simulation/
├─ scripts/ # automation
│ ├─ Fix-HighCPU.ps1
│ └─ powershell-ad-export.ps1
├─ logs/ # sample data
│ └─ sysmon_sample.log.txt
├─ splunk/ # Splunk steps & alert
│ ├─ splunk-login.png
│ ├─ splunk-upload-source.png
│ ├─ splunk-upload-review.png
│ ├─ splunk-search-result.png
│ ├─ splunk-alert-config.png
│ ├─ splunk-alert-triggered.png
│ ├─ splunk-alert-email.png
│ ├─ splunk-alert-email-alt.png
│ └─ jira-splunk-alert-ticket.png
└─ jira/ # Jira incidents & SLA views
├─ jira-incident-critical.png
├─ jira-incident-high.png
├─ jira-incident-medium.png
├─ jira-incident-low.png
└─ jira-sla-breach.png

---

## What you’ll build

**Goal:** Show the full path from detection → ticketing → SLA → escalation → evidence, using **Splunk** and **Jira Service Management**.  

<p align="center">
  <img src="jira/jira-incident-high.png" width="680" alt="Jira high-priority incident view"/>
</p>

---

## Prerequisites

- Splunk Cloud (free trial or dev instance)
- Jira Service Management (free plan is fine)
- Windows PowerShell (to run the evidence export script)

---

## Step-by-step

### 1) Splunk — ingest, search, alert

1. **Upload sample log**  
   *Splunk → Add Data → Upload* and choose `logs/sysmon_sample.log.txt`.  
   Use a clean sourcetype like `sysmon_sample` (or your own).

   <p align="center">
     <img src="splunk/splunk-upload-source.png" width="720" alt="Splunk - Select source"/>
   </p>

2. **Verify parsing**  
   Check the preview and proceed.

   <p align="center">
     <img src="splunk/splunk-upload-review.png" width="720" alt="Splunk - Review before indexing"/>
   </p>

3. **Search for suspicious PowerShell**  
   Example SPL (adapt to your fields):
   ```spl
   index="main" sourcetype="sysmon_sample" powershell OR "Invoke-WebRequest"
<p align="center"> <img src="splunk/splunk-search-result.png" width="720" alt="Splunk - Search result"/> </p>

Create alert
Save → Alert. Condition: Number of Results > 0.
Action: Send email (and/or webhook/Jira integration).

<p align="center"> <img src="splunk/splunk-alert-config.png" width="720" alt="Splunk - Alert configuration"/> </p>

When it fires, you’ll see the confirmation + email:

<p align="center"> <img src="splunk/splunk-alert-triggered.png" width="680" alt="Splunk - Alert triggered"/> </p> <p align="center"> <img src="splunk/splunk-alert-email.png" width="520" alt="Splunk - Alert email sample"/> </p>

If you create a Jira issue from the alert (via webhook/integration), you can capture it too:

<p align="center"> <img src="splunk/jira-splunk-alert-ticket.png" width="720" alt="Jira ticket created from Splunk alert"/> </p>
2) Jira — create/validate incident + SLAs

Create incident (or open the one from Splunk integration).
Fill Summary, Description, Service affected, Priority, Root cause, Resolution Notes.

<p align="center"> <img src="jira/jira-incident-critical.png" width="720" alt="Jira - Critical incident"/> </p>

Validate priority SLAs
Confirm timers appear and reflect your SLA policy (examples below):

<p align="center"> <img src="jira/jira-incident-low.png" width="420" alt="Jira - Low priority SLA"/> <img src="jira/jira-incident-medium.png" width="420" alt="Jira - Medium priority SLA"/> </p> <p align="center"> <img src="jira/jira-incident-high.png" width="680" alt="Jira - High priority SLA"/> </p>

Test escalation on breach
Use a short threshold for a test rule (e.g., Critical Incident Resolution SLA breached → auto-assign or notify).
Capture the breach state:

<p align="center"> <img src="jira/jira-sla-breach.png" width="720" alt="Jira - SLA breach and escalation"/> </p>
3) Evidence — export AD change log (PowerShell)

Use the provided script to simulate collecting and attaching evidence.

Script: scripts/powershell-ad-export.ps1

Default export path (feel free to change inside the script): C:\IT-Ops-Lab\AD_ChangeLog.csv
Run (in a PowerShell administrator window):
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
./scripts/powershell-ad-export.ps1
Attach the resulting CSV to the Jira incident (Add attachment).
Note: If the folder C:\IT-Ops-Lab\ doesn’t exist, create it first:
New-Item -Path "C:\IT-Ops-Lab" -ItemType Directory -Force

