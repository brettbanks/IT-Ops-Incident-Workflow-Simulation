# IT Ops Incident Workflow Simulation

End-to-end demo of a security incident pipeline:

**Splunk detection → Alert → Jira incident → Priority SLAs & escalation → Evidence attached.**

---

## What’s here
IT-Ops-Workflow-Sim/
├─ scripts/                      # automation / helper scripts
│  ├─ powershell-ad-export.ps1   # exports AD change log (CSV)
│  └─ Fix-HighCPU.ps1            # example health script (placeholder)
├─ logs/
│  └─ sysmon_sample.log.txt      # sample Windows Sysmon event
├─ splunk/                       # Splunk ingestion, search & alert screenshots
│  ├─ splunk-login.png
│  ├─ splunk-upload-source.png
│  ├─ splunk-upload-review.png
│  ├─ splunk-search-result.png
│  ├─ splunk-alert-config.png
│  ├─ splunk-alert-triggered.png
│  ├─ splunk-alert-email.png
│  └─ splunk-alert-email-alt.png
└─ jira/                         # Jira incident form, SLAs & breach/escalation
├─ jira-incident-critical.png
├─ jira-incident-high.png
├─ jira-incident-medium.png
├─ jira-incident-low.png
└─ jira-sla-breach.png
---

## Prereqs

- **Splunk Cloud/Enterprise** (any trial works)
- **Jira Service Management** project (ITSM/Service project)
- **Windows PowerShell** (to run the sample evidence script)

---

## Reproduce the flow

### 1) Splunk — ingest + detect + alert

1. **Upload the sample log**
   - *Add Data* → **Upload** → select `logs/sysmon_sample.log.txt`
   - **Source type:** `sysmon_sample`
   - **Index:** `main`  
   _Refs: `splunk-upload-source.png`, `splunk-upload-review.png`_

2. **Verify the event**
   - Search:
     ```spl
     index="main" sourcetype="sysmon_sample"
     ```
   - You should see a line with `Process=powershell.exe` and `Command=Invoke-WebRequest`.  
   _Ref: `splunk-search-result.png`_

3. **Create the alert**
   - Save the search as **Alert**: “Suspicious PowerShell Execution”
   - **Schedule:** run hourly (or cron `*/5 * * * *` for quick testing)
   - **Trigger condition:** `Number of results > 0`
   - **Actions:** Send email to yourself
   - Enable the alert  
   _Refs: `splunk-alert-config.png`, `splunk-alert-email*.png`, `splunk-alert-triggered.png`_

> Tip: Some Splunk Cloud tiers don’t show “Real-time” alerts. Use a short cron schedule for fast feedback.

---

### 2) Jira — incident, SLAs, escalation

1. **Incident request type**
   - Fields: Summary, Description, **Service affected**, **Priority**, **Root cause**, **Resolution notes**  
   _Ref: `jira-incident-*.png`_

2. **Priority SLAs** (example targets)
   - Highest: **4h** (for demo, you can temporarily set **1m** to force a breach)
   - High: **24h**
   - Medium: **36h**
   - Low: **48h**
   - “Critical Incident Resolution SLA”: **4h** (special rule you’ll use for escalation)  
   _Ref: `jira-incident-*.png`_

3. **Escalation on breach**
   - Automation rule: **When:** *SLA threshold breached* → **SLA:** *Critical Incident Resolution SLA* → *breached*
   - **Condition:** Priority equals *Highest* (or your critical class)
   - **Then:** Assign to *Tier-2 Analyst* (and/or add comment, notify)  
   _Ref: `jira-sla-breach.png`_

---

### 3) Evidence script (optional)

Use the sample PowerShell script to export a simple “AD change log” CSV and attach it to the Jira ticket.

```powershell
# one-session bypass for scripts
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# run from repo root or via full path
.\scripts\powershell-ad-export.ps1
	•	Default export path in the script is C:\IT-Ops-Lab\AD_ChangeLog.csv.
	•	Create the folder or change $ExportPath in the script, then re-run.
	•	Attach the CSV to your Jira incident as evidence.

⸻

What “success” looks like
	•	Splunk shows the sample event and the alert fires (email received).
	•	Jira incident is created/updated; SLAs display per priority.
	•	If you set a tiny target (e.g., 1m) you can demonstrate a breach and see the automation escalate.
	•	The evidence CSV from the PowerShell script is attached to the ticket.

⸻

Common hiccups
	•	Splunk real-time not available: use a frequent scheduled alert instead.
	•	PowerShell execution policy blocks script: use the one-session bypass shown above.
	•	CSV path missing: create C:\IT-Ops-Lab\ or update $ExportPath in the script.

⸻

License / reuse

This repository is for personal portfolio/demo use. Feel free to adapt the structure and the steps for your own lab or interview walkthroughs.