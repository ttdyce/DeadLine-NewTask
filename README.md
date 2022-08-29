# DeadLine-NewTask

dlnt - A simple todo list for side projects (in software), built with Flutter.

The idea of this app is to eliminate my infinite-growing todo list. By developing this project, it creates a window for me to rethink a project's lifecycle and implement my own way to manage different projects.  

Currently, a distribution is available on the Web, see: https://dlnt.ttdyce.com

## Idea

Too long; Didn't write... See [IDEA.md](/IDEA.md)

## Setup

- [Install Flutter](https://docs.flutter.dev/get-started/install)
- Get an editor / IDE
  - [VSCode](https://docs.flutter.dev/get-started/editor?tab=vscode)
  - [Android Studio](https://docs.flutter.dev/get-started/editor?tab=androidstudio)

## Getting Started

### Quick Start

Flutter is cool, just run

```bash
git clone https://github.com/ttdyce/DeadLine-NewTask dlnt
cd dlnt
flutter pub get
flutter pub run build_runner build
flutter run
```

And, you will find some errors asking for the file `lib/firebase_options.dart`... as this project needs a Firebase backend services.  
With the commands above, you have prepared the flutter part. Now, see [Self-hosting](#self-hosting) part for the full setup.

For those know what is going on and just asking for the commands:

```bash
flutterfire configure # can't run? you should see the Self-hosting part...
# choose android, ios, web for configuration support, while only web is being tested for now
flutter run
```

## Debugging

- [For VSCode](https://docs.flutter.dev/development/tools/devtools/vscode)
- [For Android Studio](https://docs.flutter.dev/development/tools/devtools/android-studio)

## Deployment

A distribution is available on the Web, see: https://dlnt.ttdyce.com

Android version will be released soon on Google Play Store.

For self-hosting, this project required a Firebase service as a backend database. See the steps in the following.  

### Self-hosting

In short:

1. Prepare your Firebase account
2. Setup your Firebase account on this project
3. and just run:

```bash
flutter build web
# it produces a folder `./build/web` which is ready for deploy
```

A detailed version: [HOSTING.md](HOSTING.md)

## Versioning

- [SemVer](http://semver.org/)

For the versions available, see the [tags on this repository](https://github.com/ttdyce/DeadLine-NewTask/tags)

## Authors

- **ttdyce** - *Author, maintainer* - [github](https://github.com/ttdyce)

## Acknowledgments

- Inspired by

  - [Microsoft To Do](https://to-do.office.com)
  - [Tick Tick](https://ticktick.com)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
