# Morning Message

A Flutter app for preparing a custom good morning message, choosing recipients,
and receiving a daily reminder at a selected time. The reminder brings the user
back to a prefilled SMS composer for review and confirmation.

## Why confirmation is required

iOS does not allow third-party apps to silently send SMS messages in the
background. Using the system composer is the dependable, privacy-preserving
behavior shared by iOS and Android and avoids requesting sensitive SMS
permissions.

## Run

```sh
flutter pub get
flutter run
```

On iOS, run `pod install` in `ios/` if your Flutter setup does not do so
automatically.
