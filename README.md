# IT Ops Incident Workflow Simulation
End-to-end incident flow:
- **Detection:** Splunk ingests a log and alerts on suspicious PowerShell execution.
- **Triage:** Alert routes into **Jira Service Management** as an incident.
- **SLA Enforcement:** Priority SLAs with **escalation on breach**.
- **Evidence:** PowerShell script exports an **AD change log (CSV)** and is attached to the ticket.

## Repository Structure
scripts/ # automation
logs/ # sample logs
jira/ # incident + SLA screenshots
splunk/ # ingestion/search/alert screenshots

markdown
Copy code

## Steps to Reproduce
1) **Jira:** incident form (Service Affected, Priority, Root Cause, Resolution Notes), SLAs (Crit 4h, High 8h, Med 24h, Low 72h), automation on SLA breach to escalate.
   - ![Critical](/jira/jira-incident-critical.png)
   - ![High](/jira/jira-incident-high.png) ![Medium](/jira/jira-incident-medium.png) ![Low](/jira/jira-incident-low.png)
   - ![Breach](/jira/jira-sla-breach.png)

2) **PowerShell Evidence:** `scripts/powershell-ad-export.ps1`
   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   cd "$env:USERPROFILE\Documents\IT-Ops-Workflow-Sim\scripts"
   .\powershell-ad-export.ps1
Attach the CSV to the Jira ticket as audit evidence.

Splunk: upload logs/sysmon_sample.log.txt (index=main), search index=main powershell.exe, alert every 1 min (cron */1 * * * *), trigger on results > 0, action Send Email.






Why It Matters
Operational reality (detection → triage → SLA pressure → escalation → resolve), audit evidence stored in-ticket, and automation mindset.

Extend
Replace email with Splunk HEC + Jira REST, add pfSense logs + parser, publish a 1-page runbook PDF in /docs.

Git Tips
bash
Copy code
git add .
git commit -m "Update screenshots and docs"
git push origin main
