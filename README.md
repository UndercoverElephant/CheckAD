# CheckAD
Usage .\CheckAD.ps1 [options]
A tool to quickly search AD and output relevant details

Options:
  -o: output to txt file
  -p: define path to save log file
  -u: specify the user to search for. can be either by username or email address
  -h: show this help message
  -f: define path to file for list of users to search for

Examples:
Searching for a user with output printed to screen.
.\CheckAD.ps1 [username\email]

Searching for a user with a log file created in current directory
.\CheckAD.ps1 [username\email] -o

Searching for a user with a log file created in a specific directory
.\CheckAD.ps1 [username\email] -o -p C:\path\to\directory

Searching for a list of users. CSV log created in current directory.
.\CheckAD.ps1 -f C:\path\to\userlist.csv

Searching for a list of users. CSV log created in specific directory.
.\CheckAD.ps1 -f C:\path\to\userlist.csv -p C:\path\to\directory
