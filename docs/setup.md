# 🛠 Setup Instructions

Reproducibility is critical in demonstrating engineering workflows.  
This guide walks through setting up the IT Ops Incident Workflow Simulation from scratch.

---

## 1. Splunk Cloud Free Trial

1. Go to [Splunk Cloud Free Trial](https://www.splunk.com/en_us/download/splunk-cloud.html)
2. Sign up with a work/personal email.
3. Verify your account and log in to the Splunk Cloud instance.

---

## 2. Upload Sample Logs

1. In Splunk, go to **Add Data → Upload**.
2. Select `logs/sysmon_sample.log.txt` from this repository.
3. Set **Sourcetype** = `sysmon_sample`.
4. Complete the upload and verify the logs are indexed.

---

## 3. Create a Search & Alert

1. Open **Search & Reporting** app in Splunk.
2. Run the following SPL query:

   ```spl
   index="main" sourcetype="sysmon_sample" powershell OR "Invoke-WebRequest"
   ```

3. Verify events return for suspicious PowerShell activity.
4. Click **Save As → Alert**.
5. Configure the alert:
   - Trigger: **Per Result** or **Number of Results > 0**
   - Action: **Send Email** (or preview email output)
   - Severity: High

---

## 4. Jira Free Plan + SLA Setup

1. Go to [Jira Service Management Free](https://www.atlassian.com/software/jira/service-management/free)
2. Create a new service desk project (IT Ops template is fine).
3. In **Project Settings → SLAs**, create SLA goals:

   | Priority | First Response | Resolution |
   |----------|----------------|------------|
   | Highest  | 2h             | 4h         |
   | High     | 4h             | 24h        |
   | Medium   | 6h             | 36h        |
   | Low      | 8h             | 48–72h     |

4. Add **automation rules** for escalation:
   - IF SLA breached → Notify Tier 2 / escalate priority.

---

## 5. PowerShell Evidence Export

1. Open PowerShell on Windows.
2. Run:

   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   .\scripts\powershell-ad-export.ps1
   ```

3. Output file `AD_ChangeLog.csv` will be generated.
4. Attach this file to the related Jira ticket as evidence.

---

##  Summary

After completing this setup, you’ll have a working simulation of:

- Sysmon logs ingested into Splunk Cloud.
- Detection of suspicious PowerShell activity.
- Alert triggering an incident in Jira.
- SLA timers enforcing escalation policies.
- Evidence exported from PowerShell to Jira.

This demonstrates an **end-to-end SOC workflow** using free tools.
