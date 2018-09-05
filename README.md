# IIS SMTP Relay Script
I created this as part of a recent project, there are many examples out there but none of them quite did what I wanted.  Kudos to those folk that I pulled various bits of the script from.

Things that I had to work around/issues with the script
1: For some reason manipulating the arrays dynamically restulted in errors when trying to write back to the SMTP server object, this is one of the reasons the script writes out to a file then reads it back in again
2: The script does an overwrite operation rather than an append, this is the reason the currently configured IP addresses are captured
3: The script will error/fail if there are duplicate IP addresses being imported, this is why it does a de-duplicate activity on the array containing the IP addresses


