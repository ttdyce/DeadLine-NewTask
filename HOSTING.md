# DeadLine-NewTask Self-hosting

This project has 2 parts, the flutter application and the Firebase backend services.

To host the project, you will need the codespace (which is this repo) and a Firebase account.

## Firebase service

Here are the required Firebase services

1. Authentication
2. Cloud Firestore
3. Hosting

Then, setup the firebase sdk for flutter: `FlutterFire`

First, [install the Firebase CLI and activate FlutterFire CLI](https://firebase.google.com/docs/flutter/setup?platform=web) if you haven't, and run:

```bash
cd dlnt # assuming cloned this repo under dlnt
firebase login # flutterfire relies on firebase cli
firebase projects:list # confirm your login, it should list your Firebase projects
flutterfire configure
```

For more details, see also https://firebase.google.com/docs/flutter/setup?platform=web

## Flutter application

Now, it should be ready to be built and deployed.

```bash
flutter build web
# it produces a folder `./build/web` which is ready for deploy
```

For more details, see also https://docs.flutter.dev/deployment/web#deploying-to-the-web