# Security Centre Device Tagging
## What is it
The tool was created using 100% powershell. This tool connects to the Sec Centre API, gets all your machines and tags them accordingly.
Lots of things hashed out in this script as names are internal etc.
## Why I created it
We have a number of endpoints. Some are PCI, some process sensitive information etc. We needed a way of grouping them. This allows us to do the following:
- Different remediation policies for each group
- Different access rights
- Different incident response priorities
- Basically it makes management easier in loads of ways

## Pre Reqs
Create app reg in AAD as described here. Note you will need to use different permissions, i used: 

Machine.ReadWrite.All (Application)

https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/api/exposed-apis-create-app-webapp?view=o365-worldwide

## Roadmap Items
- This is working good ATM
