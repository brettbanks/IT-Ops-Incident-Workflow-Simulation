📊 SLA Targets
| Priority | First Response | Resolution |
| -------- | -------------- | ---------- |
| Highest  | 2h             | 4h         |
| High     | 4h             | 24h        |
| Medium   | 6h             | 36h        |
| Low      | 8h             | 48–72h     |


🧩 SPL Used
index=main sourcetype=sysmon_sample (Process="powershell.exe" OR Command="*Invoke-WebRequest*")
| table _time host User Process Command
| sort - _time
