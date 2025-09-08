IT Ops Incident Workflow Simulation

End-to-end incident flow to demonstrate practical IT Ops & SecOps skills.
This project simulates detection, ticketing, SLA tracking, escalation, and evidence handling using free tools.

💡 Why This Matters

Employers want proof you can do the job — not just theory. This lab shows you can:

Ingest & detect real log data (Splunk Sysmon → suspicious PowerShell).

Triage & track incidents in a ticketing system with SLA timers (Jira).

Escalate & enforce SLAs when breaches occur.

Produce evidence using PowerShell exports for audit/compliance.

This isn’t just a demo — it mirrors how SOC and IT Ops teams actually run in enterprise environments. That’s the value you bring to the table.

🚀 What You’ll Build

An end-to-end workflow:
Detection → Ticketing → SLA → Escalation → Evidence

⚙️ Prerequisites

Splunk Cloud (trial or dev instance)

Jira Service Management (free plan is fine)

Windows PowerShell

📸 Demo Screenshot

📑 Table of Contents

Repository Structure

What You’ll Build

Prerequisites

Step-by-Step

Splunk

Jira

Evidence

SLA Targets

SPL Used

Git Quick Commands

Notes

📂 Repository Structure
IT-Ops-Incident-Workflow-Simulation/
├── scripts/                # automation
│   ├── Fix-HighCPU.ps1
│   └── powershell-ad-export.ps1
├── logs/                   # sample data
│   └── sysmon_sample.log.txt
├── splunk/                 # Splunk steps & alert
│   ├── splunk-login.png
│   ├── splunk-upload-source.png
│   ├── splunk-upload-review.png
│   ├── splunk-search-result.png
│   ├── splunk-alert-config.png
│   ├── splunk-alert-triggered.png
│   ├── splunk-alert-email.png
│   ├── splunk-alert-email-alt.png
│   └── jira-splunk-alert-ticket.png
└── jira/                   # Jira incidents & SLA views
    ├── jira-incident-critical.png
    ├── jira-incident-high.png
    ├── jira-incident-medium.png
    ├── jira-incident-low.png
    └── jira-sla-breach.png

📝 Step-by-Step
1) Splunk — Ingest, Search, Alert

Upload sample log:


Review before indexing:


Search suspicious PowerShell activity:

index="main" sourcetype="sysmon_sample" powershell OR "Invoke-WebRequest"


Create alert:


Triggered alert:


Alert email example:


2) Jira — Incident + SLAs + Escalation

Critical incident example:


Low → High priority timers:


Escalation breach example:


3) Evidence — Export AD Change Log (PowerShell)

Run evidence export:

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\powershell-ad-export.ps1


Attach exported AD_ChangeLog.csv to Jira ticket.

📊 SLA Targets
Priority	First Response	Resolution
Highest	2h	4h
High	4h	24h
Medium	6h	36h
Low	8h	48–72h
🧩 SPL Used
index=main sourcetype=sysmon_sample (Process="powershell.exe" OR Command="*Invoke-WebRequest*")
| table _time host User Process Command
| sort - _time

🛠️ Git Quick Commands
git add .
git commit -m "Update README with screenshots"
git push origin main

🗒️ Notes

This repo simulates an end-to-end SOC workflow using free tools (Splunk, Jira, PowerShell).
It is designed as a practical lab to demonstrate IT Ops + SecOps workflows.
