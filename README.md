# IT Ops Incident Workflow Simulation

## 📌 Project Overview
This project simulates a **real-world IT Operations workflow** by integrating:
- **Jira Service Management (JSM):** Incident and change tracking with SLAs and automation.
- **Active Directory (simulated):** User provisioning and access change requests with PowerShell automation.
- **Splunk:** Security log ingestion and alerting tied to Jira ticket creation.
- **pfSense:** Firewall logging and evidence generation for network incidents.

The goal is to demonstrate how enterprise IT teams **detect, track, and resolve incidents** across multiple systems while maintaining **audit trails and SLA compliance.**

---

## ⚙️ Tools & Technologies
- **Jira Service Management (Cloud)**
- **Active Directory (Lab Simulation)**
- **PowerShell, Bash, Python**
- **Splunk Free**
- **pfSense Firewall**
- **Zeek / Sysmon logs**

---

## 🧩 Workflow Diagram
![Workflow Diagram](./images/workflow-diagram.png)  
*(Replace with your actual diagram export from draw.io or Lucidchart.)*

---

## 🚀 Features Implemented
- **Custom Incident Request Type** in JSM with priority, root cause, and resolution fields.
- **SLA Tracking & Escalation Rules** (e.g., Critical tickets auto-escalate in 4 hours).
- **PowerShell AD Automation**: Mock user access report export attached to tickets.
- **Splunk Security Alert → Jira Ticket**: Auto-created tickets for suspicious PowerShell execution.
- **Firewall Log Parsing**: pfSense/Bash script that simulates network alerts tied to incident tickets.
- **Audit Evidence Attachments**: Each incident ticket includes logs or reports as proof.

---

## 📂 Repository Contents
/scripts
powershell-ad-export.ps1
firewall-log-parser.py
sample-zeek-log.txt
/docs
IT-Ops-Runbook.pdf
/images
workflow-diagram.png
jira-screenshot.png
splunk-alert.png
README.md

yaml
Copy code

---

## 📝 Example Ticket Lifecycle
1. Splunk detects a suspicious PowerShell execution.  
2. Alert triggers a Jira ticket via email integration.  
3. Analyst attaches AD audit evidence (PowerShell export).  
4. Ticket moves through workflow (*Open → In Progress → Resolved*).  
5. SLA timers ensure escalation if unresolved.  
6. Final ticket closed with resolution notes and logs attached.  

---

## 📖 Documentation
- [Runbook PDF](./docs/IT-Ops-Runbook.pdf)  
- [Workflow Diagram](./images/workflow-diagram.png)  

---

## 💡 Business Value
- **Demonstrates end-to-end incident handling.**  
- **Shows automation + integrations** recruiters expect in IT Ops / Application Admin roles.  
- **Provides audit-ready documentation** proving attention to compliance and SLA-driven workflows.  

---

## 🔗 Portfolio & Contact
- **Portfolio Website:** [YourWebsiteHere.com](https://brettbanks.site)  
- **LinkedIn:** [linkedin.com/in/brettbanks1](https://linkedin.com/in/brettbanks1)  
- **GitHub:** [github.com/Papertrailhack](https://github.com/Papertrailhack)  

---
