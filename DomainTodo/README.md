# DomainTodo

Simple bash script to check the status and expiry date for domains in bulk.

# Why?

There used to be a lot of domains pending in the whmcs todo list especially the renewals. So, checking each through a manual process is the pain in the ass. Why not automate the process and check it automatically in no time?

# How it works?

First, get the list of all domains from whmcs todo page. Save it in a file and parse the file to the script which will server all domains through whois and filter out the required datas.

# Dependencies
- bash
- grep
- awk
- cut
- whois

# How to use?

- **Get the Domains list from WHMCS todo page.**
>> Go to WHMCS todo page, apply necessary filters and inspect the page in the browser and copy all contents in `<tbody>` section and save it in a file.

- **Use the Script**
>> Get the script  `domaintodo.sh` in your local machine and parse the saved file to it using `-f` flag.  
>> Get the required output.
