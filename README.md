# IT Ops Incident Workflow Simulation

**Splunk detection → Alert → Jira incident → Priority SLAs & escalation → Evidence attached.**  
A portfolio-grade, end-to-end simulation that shows you can connect SIEM detections to service management with SLAs and audit evidence.

---

## What’s in this repo
IT-Ops-Workflow-Sim/
├─ README.md
├─ scripts/
│  ├─ powershell-ad-export.ps1     # exports AD-style change log (CSV) for evidence
│  └─ Fix-HighCPU.ps1              # example health script (placeholder)
├─ logs/
│  └─ sysmon_sample.log.txt        # sample Sysmon-style event containing powershell.exe
├─ splunk/                         # ingestion, search & alert evidence
│  ├─ splunk-login.png
│  ├─ splunk-upload-source.png
│  ├─ splunk-upload-review.png
│  ├─ splunk-search-result.png
│  ├─ splunk-alert-config.png
│  ├─ splunk-alert-triggered.png
│  ├─ splunk-alert-email.png
│  ├─ splunk-alert-email-alt.png
│  └─ jira-splunk-alert-ticket.png
└─ jira/                           # incident form, SLAs & breach/escalation
├─ jira-incident-critical.png
├─ jira-incident-high.png
├─ jira-incident-medium.png
├─ jira-incident-low.png
└─ jira-sla-breach.png
---

## Workflow overview

```mermaid
flowchart LR
A[Endpoint/User] --> B[Logs]
B --> C[Splunk: Search & Alert]
C -->|Email/Integration| D[Jira Incident]
D --> E[SLA Timers]
E -->|Breach| F[Escalate (assign/notify)]
D --> G[Attach Evidence (AD CSV)]
G --> H[Resolve / Close]
Prerequisites
	•	Splunk (Cloud trial or Enterprise)
	•	Jira Service Management (ITSM/Service project)
	•	Windows PowerShell (to run the evidence script)

⸻

How to reproduce the simulation

1) Splunk — ingest, search, alert
	1.	Ingest the sample log
	•	Add Data → Upload → select logs/sysmon_sample.log.txt
	•	Sourcetype: sysmon_sample (custom or auto)
	•	Index: main
Refs: splunk/splunk-upload-source.png, splunk/splunk-upload-review.png
	2.	Verify the event
	•	Search:index=main sourcetype=sysmon_sample powershell.exe
	•	You should see Process=powershell.exe and Command=Invoke-WebRequest.
Ref: splunk/splunk-search-result.png

	3.	Create the alert
	•	Save the search as an Alert: “Suspicious PowerShell Execution”
	•	Schedule: every minute (cron */1 * * * *)
	•	Trigger condition: Number of results > 0
	•	Trigger mode: For each result
	•	Action: Send Email (to Jira’s incoming email if configured, otherwise to yourself)
	•	Enable the alert.
Refs: splunk/splunk-alert-config.png, splunk/splunk-alert-triggered.png, splunk/splunk-alert-email*.png

Note: Some Splunk Cloud tiers don’t show “Real-time” alerts. Scheduling every minute achieves near-real-time behavior for demo purposes.

⸻

2) Jira — incident, SLAs, escalation
	1.	Incident request type
	•	Fields: Summary, Description, Service Affected, Priority, Root Cause, Resolution Notes
Refs: jira/jira-incident-*.png
	2.	Priority SLAs (example targets)
	•	Highest: 4h (for demos, temporarily set 1m to force a breach)
	•	High: 24h
	•	Medium: 36h
	•	Low: 48h
	•	Special rule: Critical Incident Resolution SLA (used by escalation)
Refs: jira/jira-incident-*.png
	3.	Escalation on breach
	•	Automation rule: When SLA threshold is breached → SLA: Critical Incident Resolution SLA
	•	If Priority = Highest
	•	Then Assign to Tier-2 Analyst (and/or comment/notify channel)
Ref: jira/jira-sla-breach.png

⸻

3) Evidence script (PowerShell)

Export a simple “AD change log” CSV and attach it to the incident.
# (Optional) allow scripts for this session only
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Run from the repo root or with full path
cd "$env:USERPROFILE\Documents\IT-Ops-Workflow-Sim\scripts"
.\powershell-ad-export.ps1
•	The script writes a CSV (default path inside the script is C:\IT-Ops-Lab\AD_ChangeLog.csv).
	•	Create the folder or edit $ExportPath in the script.
	•	Attach the CSV to your Jira incident as audit evidence.

⸻

Screenshot gallery (embedded)

Splunk
<p><img src="splunk/splunk-login.png" width="840"></p>
<p><img src="splunk/splunk-upload-source.png" width="840"></p>
<p><img src="splunk/splunk-upload-review.png" width="840"></p>
<p><img src="splunk/splunk-search-result.png" width="840"></p>
<p><img src="splunk/splunk-alert-config.png" width="840"></p>
<p><img src="splunk/splunk-alert-triggered.png" width="840"></p>
<p>
  <img src="splunk/splunk-alert-email.png" width="840"><br>
  <img src="splunk/splunk-alert-email-alt.png" width="840">
</p>
<p><img src="splunk/jira-splunk-alert-ticket.png" width="840"></p>
Jira
<p><img src="jira/jira-incident-critical.png" width="840"></p>
<p><img src="jira/jira-incident-high.png" width="840"></p>
<p><img src="jira/jira-incident-medium.png" width="840"></p>
<p><img src="jira/jira-incident-low.png" width="840"></p>
<p><img src="jira/jira-sla-breach.png" width="840"></p>

Success criteria
	•	Splunk ingests the sample log and the alert fires.
	•	Jira incident displays priority SLAs and an escalation occurs on breach.
	•	Evidence CSV from PowerShell is attached in the ticket.

⸻

Troubleshooting
	•	No “Real-time” alerts in Splunk: use a frequent Scheduled alert (cron */1 * * * *).
	•	PowerShell blocked: use the session-only bypass shown above.
	•	CSV path missing: create C:\IT-Ops-Lab\ or change $ExportPath and rerun.
	•	Images don’t render in README: ensure paths/case match exactly (e.g., splunk/splunk-login.png).

⸻

Extend the lab
	•	Replace email with Splunk HEC + Jira REST for fully automated ticket creation.
	•	Add firewall (pfSense) logs and parsing; attach results to incidents.
	•	Publish a one-page runbook PDF in /docs for non-technical stakeholders.
	•	Track MTTR/SLA compliance and visualize in a dashboard.

⸻

Git quick commands
git add .
git commit -m "Update screenshots and docs"
git push origin main

License

MIT (or your preferred license).