# Dart Authentication
A simple program to register user and validate a login using hash256 with salt.
This version is using text file to store the information, but ideally should use a secure database.

## How it works:
On **register.dart** the user enter a username and password, the program then validate if the username is available, in this case, it checks if the file with the same name already exists on the defined path, but again it could be a database query to verify the same information, once a valid username is typed the user is prompted to enter a password, the password should be at least 8 characters long. Upon entering a valid password, the program starts the process to hash and salt the password, first generating a random salt, then it applies the salt to the password and hash. It does this process for as mine times as desired, but by default it will do 2^16 = 65536 times + 1 time. To apply the salt to the password I used I very simple function to mix the words.

Once it finishes hashing the password, it will save the information necessary for validate the user when the user try to log in, that's where it creates a file and save the information: Username, Date, Time, Salt, and Hash. Again, should save this information on a secure database.

That's it for the registration, now the user can log in using the username and password.

On **login.dart** the process is almost the same, but this time when the user enters a name the program validate if the user is already registered, verifying the files created, if doesn't find, inform the user that there is no user with the name or username is wrong.
To validate the password, once the user enter a valid name and a password, the program open the file for the specific username and read the salt value, as I was working with text file, it extracts this value from a line where contains the word "Salt:", it would be easier to get this data from a database. Upon getting the salt generate for the user, it does the same process as in registration, but this time without generating new salt because the user already has one. Once it finishes the program compare if the hash generated with the password provided by the user is the same as the hash generate on registration. If matched, success! if don't, display Wrong password, the user has 3 chances to enter the correct password otherwise the program finishes.

# How to use
To use this program without compile it, it's necessary to have Dart SDK installed, to install it see https://dart.dev/get-dart

## Registration
To start the process to register a user run the following command:

    dart run bin/registration.dart

from inside the directory encryption.
Enter a username and password.

![example_registration](https://lh3.googleusercontent.com/pw/ACtC-3ffTApm_J96pk-soB2K8XLECjBbibXDxBrIw2FgFuwo77t0RvY9du0t5WIjElWQYNGzZY_vZLO59PNORTmwKHyNGSlSCjBBCc3eTA5b0w3Qz6Vl38LLMqE-TCqBmOuajOk2VE0QkdVL6oX3pGnmASX4=w734-h481-no?authuser=0)
## Login
To start the process to login use the following command:

    dart run bin/login.dart

from inside directory encryption
Enter username and password.

![example_login](https://lh3.googleusercontent.com/pw/ACtC-3enqQjtB0E979pQUl6Tfs35bVkGysto5mU_HfAl2QvTroNXqJzZgw5RsY77YzWMd9ttHw2xLW76XZopf-AgKE0jRdHuFpkMv1UiY6OhYsIHMW7CNl9AKifoyYIWJltLrbAkEqp6QtSkSNpPWeL3Xesh=w736-h483-no?authuser=0)
# Compile
It's possible to compile both registration.dart and login.dart to binary, unfortunately Dart can only convert to the current System its being run, to do that just run for both files the following commands:

    dart2native bin/registration.dart -o bin/anynameregistration
    dart2native bin/login.dart -o bin/anynamelogin

These commands will generate the binary files that will allow you to execute them directly.
On Linux Systems:

    ./bin/anynameregistration
Then

    ./bin/anynamelogin

# Author
## Luiz Henrique Goncalves - Rckskio

See LICENSE

# Mention
The function to read input from terminal without displaying the password I got from another project, see https://github.com/bsutton/dcli

Function extracted from: https://github.com/bsutton/dcli/blob/master/lib/src/functions/ask.dart

Name of the function: **String _readHidden()**

Author: Brett Sutton