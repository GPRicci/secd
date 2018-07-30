# SECD
A simple SECD to ARM Assembler compiler. Built using [beautiful-racket](https://github.com/mbutterick/beautiful-racket) by Matthew Butterick. Check out his amazing book [Beautiful Racket](https://beautifulracket.com/).

**Note: This project is a homework assignment, so I'm not accepting contributions at the moment.**

## Installing and Updating the SECD package
The SECD package is registered in the Racket Package Server/Index, so installing and updating it is very easy.
If you have added the `raco` command-line tool to your PATH, you can install and update SECD with the following commands.
```
$ raco pkg install secd
```

```
$ raco pkg update secd
```

You can also install or update SECD directly from DrRacket. Simply go to *File -> Install Package...* and type `secd` into the *Package Source* text field. The dialog will show an *Install* or an *Update* button depending on whether the package is already installed.

### Alternative Installation
You can also install the SECD package from source. Just head over to *Releases*, download the ZIP containing the source code of the version you want to install and unzip it in a convenient location. After that, using your preferred shell navigate to the unzipped folder and install it as a package using the following commands.
```
$ cd path/to/secd
$ raco pkg install
```
**Important! You need to navigate inside the package folder before issuing the `raco pkg install` command. In other words, if you issue `ls` you should see the `main.rkt`, `info.rkt` files, and so on.**

## Documentation and Implementation Details
A live documentation can be found in http://docs.racket-lang.org/secd/. Please note though that when changes to the documentation are committed to `master`, it will appear in the Racket Documentation Index in about 24 hours. So if you feel that the documentation is outdated, check the date and time of the latest commit in `master`.

The code is **_heavily_** commented. Remember that this is a homework assignment and I have to explain to the TA what the heck is going on. Details on the implementation can be found there. If you feel that the comments are not clear enough or that they are missing something, you can open an issue and I will make sure to check it out :smile:

## This is not over!
Even though this started as a homework assignment, I am planning on continuing the development of this project. This has been a very interesting endevour and I have learnt much from it. So stay tuned if you found this interesting too :kissing_heart: