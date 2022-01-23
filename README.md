# KPass

## An Alfred KeePassXC Workflow

![Screenshot](https://github.com/Angoll/KPass/blob/master/example.gif)

## Features

- List all entries from a KeePassXC database
- Get the password for the selected entry, and put it in the clipboard
- The password is copied to the transient clipboard. 


## Setup

#### Prerequisites
 - Alfred 4
 - KeePassXC
 - A created KeePassXC database
 - homebrew installed( https://brew.sh/ )
 - jq installed  ( https://stedolan.github.io/jq/download/ )

#### Configuration

Run **kpassinit** KPass Setup and follow the instructions:

1. Select the KeePassXC database file
2. [Optinally] If need it full path to the keychain file to use, leave it blank otherwise
3. Select which keychain will be used to store the database password
4. Enter the password for the KeePassXC database selected
5. Done!


## Known problems

### Slowness to load database

Try reconfiguring the format and number of transform rounds of your database (KDF), increasing the format value and reduce the transformation rounds.

This Alfred workflow integrate with keepassxc using keepassxc cli, the script add a very low overhead and all time is spend in opening the database.

Having a high transformation rounds allows to slow down bruteforce attacks so pickup a number that is seems right for you.

More information:
 - https://github.com/Angoll/KPass/issues/17#issuecomment-888096305
 - https://github.com/keepassxreboot/keepassxc/issues/6778

### Keepass file appears unselectable

Open the Alfred workflow from the Alfred App, double click the Run Script /usr/bin/osascript connected to the kpassinit. And remove the following line (on line 20)

```
    ofType: ["dyn.ah62d4rv4ge8003dcta"] //.kdbx extension type identifier
```

This will make any file selectable.


## References
- https://www.alfredapp.com/
- https://keepassxc.org/


Any feedback is welcome!

Love it? Give it a ⭐️ or a tweet to help spread the word!
