# CheckAD
Usage .\CheckAD.ps1 [options] <br>
A tool to quickly search AD and output relevant details<br>

Options: <br>
  -o: output to txt file <br>
  -p: define path to save log file <br>
  -u: specify the user to search for. can be either by username or email address <br>
  -h: show this help message <br>
  -f: define path to file for list of users to search for <br>

Examples: <br>
Searching for a user with output printed to screen. <br>
.\CheckAD.ps1 [username\email] <br>

Searching for a user with a log file created in current directory <br>
.\CheckAD.ps1 [username\email] -o <br>

Searching for a user with a log file created in a specific directory <br>
.\CheckAD.ps1 [username\email] -o -p C:\path\to\directory <br>

Searching for a list of users. CSV log created in current directory. <br>
.\CheckAD.ps1 -f C:\path\to\userlist.csv <br>

Searching for a list of users. CSV log created in specific directory. <br>
.\CheckAD.ps1 -f C:\path\to\userlist.csv -p C:\path\to\directory <br>
