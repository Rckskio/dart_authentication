# Dart Authentication
A simple program to register user and validate a login using hash 256 with salt.
This version is implemented to save all the information on Sqlite3 Database.

## How it works:
On **register.dart** the user enter a username and password, the program then validate if the username is available, in this case, it checks if the username is already registered on the database, once a valid username is typed the user is prompted to enter a password, the password should be at least 8 characters long. Upon entering a valid password, the program starts the process to hash and salt the password, first generating a random salt, then it applies the salt to the password and hash. It does this process for as mine times as desired, but by default it will do 2^16 = 65536 times + 1 time. To apply the salt to the password I used I very simple function to mix the words.

Once it finishes hashing the password, it will save the information necessary for validate the user when the user try to log in, that's when the program queries the database to save the following information: id, username, date, time, salt, and on a separated table save id and hash.

That's it for the registration, now the user can log in using the username and password.

On **login.dart** the process is almost the same, but this time when the user enters a name the program validate if the user is already registered, querying the users' database, if doesn't find, inform the user username not registered.
To validate the password, once the user enter a valid name and a password, 
first it will get the original salt value from the user registered and encrypt the password typed with the same process before,
but this time with a specific salt value, then it will get the user id to retrieve the hash of the specific id and compare the results.
if the values don't match, the program print "Wrong password", if too many attempts the program finish.

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

Obs. I removed the function _readHidden() to read the input password because of unknown bug.