# polycom-provisioning
A set of scripts to automatically re-provision polycom phones when server details change (manual failover)

The DHCP server should be enabled with option 66 to point the Polycoms to a TFTP server to fetch their boot files.

A spreadsheet (in .xlsx format) should be present with extensions and associated MAC addresses. When the script is run, it should accept two commandline arguments. The first being the name of the spreadsheet, and the second being the IP address of the registration server.

The script then turns the spreadsheet into a CSV, generates a config for each MAC address, changes the appropriate settings ("label", etc.) to the associated extension number, and lastly sets the registration server IP address in each config. The idea is that, in the event that a different registration server is to be used, the script can be run with the appropriate settings, the switches rebooted, and the phones thus forced to download the updated autoprovisioning configs.
