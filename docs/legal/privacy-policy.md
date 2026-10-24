# FocusForge Privacy Policy

**Effective:** May 15, 2026
**Last updated:** October 24, 2026

## The short version

FocusForge stores task names and progress on your device, and its template-based coach runs locally. Firebase Analytics is enabled by default and receives usage events, including session durations and progression details. Firebase Crashlytics collects crash diagnostics and can include copies of those usage events. You can turn analytics off in Settings; crash reporting remains enabled.

## Who we are

FocusForge is built and operated by Kristen Martino, an independent developer. For privacy questions or requests, email [privacy@kristenmartino.ai](mailto:privacy@kristenmartino.ai).

## Local records and coaching

The app stores task names, session history, character and inventory state, streaks, quests, timer settings, and coaching preferences locally using SwiftData. It does not require an account.

The AI Coach selects from written templates on your device. It uses task keywords and local signals such as completion rates, session length, and streak risk. It does not send your task to a hosted language model.

The app’s custom analytics events send task-name length, not task-name text or an edited coaching prompt. Some information about your activity is transmitted as described below; local coaching does not make the entire app offline.

## Product analytics

Firebase Analytics, provided by Google, is **on by default**. We use it to understand feature use, session completion, and progression. The app sends events with the following kinds of information:

- **Sessions:** focus or break phase, planned duration in seconds, actual duration for completed or abandoned sessions, completion fraction for abandonment, and the character count of the trimmed task name.

- **Progression:** XP and coins earned, streak days, whether a level increased, skipped days, streak freezes used or remaining, and milestone identifiers.

- **Cosmetics:** item identifier, equipment slot, rarity, and coin cost for purchases.

- **Coaching:** prompt type, template identifier or reflection category, whether a suggestion was accepted, edited, or dismissed, reflection feedback, and streak days for rescue nudges. Editing is recorded as a flag; the edited text is not included.

These are event-level records, not just aggregate counts. Google Analytics also collects SDK-generated information such as app-instance identifiers, device and app information, session statistics, and approximate location. On iOS, its SDK can use the vendor identifier when an advertising identifier is unavailable. See [Google’s Analytics data-collection documentation](https://support.google.com/analytics/answer/11593727?hl=en).

Installation and device identifiers can connect activity across sessions. We do not treat this data as fully anonymous simply because the app does not ask for your name or email address.

## Crash reporting and event logs

Firebase Crashlytics collects crash reports automatically. Reports can contain stack traces, app and operating-system versions, device information, installation identifiers, and diagnostic logs. We use these reports to investigate and fix failures.

While analytics is enabled, the app also copies each custom analytics event name and its full parameter dictionary into a Crashlytics log. This means crash reports can include the session durations, reward and streak details, cosmetic identifiers, and coaching interaction metadata listed above. These logs are not limited to screen names.

Turning analytics off blocks new custom events through the app’s analytics wrapper, including these copies into Crashlytics logs. **It does not disable Crashlytics itself**, erase logs already recorded, or delete data already sent. Crash reports may be stored on the device and uploaded on a later launch. See [Firebase’s crash-reporting documentation](https://firebase.google.com/docs/crashlytics/ios/customize-crash-reports).

## Your analytics control

Open **Settings → Privacy → Send anonymous analytics** and turn the toggle off. This is the control’s current label; the events use the identifiers described above.

The preference is saved on the device. The app checks it before forwarding custom events and user properties, and applies it to Firebase Analytics collection at launch and when you change the setting.

**There is currently no in-app switch to disable crash reporting.** iOS advertising or tracking settings are not a control for FocusForge’s Crashlytics collection. Turning analytics off does not remove the app’s other features.

## Exports and local deletion

**Settings → Export My Progress** creates a JSON file containing local progress, including task names and session history, character and inventory state, unlocks, quests, coaching preferences, and timer settings. It is not an export of Firebase Analytics or Crashlytics records.

If you save or share that file through Files, email, AirDrop, or another destination, its contents leave the app at your direction. Your chosen service and device backup settings may retain copies.

Deleting the app removes its local app data from the device. It does not delete separately saved exports, device or cloud backups, or information already sent to Google. Uninstalling is not a request to delete server-side analytics or crash reports.

## Service providers and storage

Analytics and crash diagnostics are sent to Google’s Firebase and Google Analytics services. Google may process data outside your country, including in the United States. Processing is governed by the applicable Google service and data-processing terms; this policy does not promise a particular storage region.

We use these integrations for product analytics and crash diagnosis. We do not sell your data or use it to serve advertisements in FocusForge. See [Firebase’s privacy and security information](https://firebase.google.com/support/privacy) for provider details.

## Retention

Local records remain on the device until the app’s data is removed. Exports and backups have their own lifetimes in the destinations you choose.

Firebase states that Crashlytics retains crash traces and associated installation identifiers for 90 days before beginning removal from live and backup systems.

Google Analytics retention depends on the property’s configured retention controls. Standard aggregate reports are not covered by the same event-level retention limit and may remain longer. Contact us for the current retention period, or read [Google’s retention documentation](https://support.google.com/analytics/answer/7667196?hl=en).

## Privacy requests

You can contact [privacy@kristenmartino.ai](mailto:privacy@kristenmartino.ai) to ask about access, correction, deletion, or other privacy rights available where you live. We aim to respond within 7 business days.

We may need information to identify the relevant installation or records before handling a request. The app has no account or built-in screen for viewing Firebase identifiers, so an email address alone may not identify your analytics or crash records. Please do not send task contents or exported progress unless needed for your request.

## Children

FocusForge is not intended for children under 13. If you believe a child under 13 has provided personal information through the app, contact [privacy@kristenmartino.ai](mailto:privacy@kristenmartino.ai) so we can investigate and address the request.

## Changes to this policy

We will update this page and its last-updated date when the policy changes. Material changes will be announced on this page and in the app’s Settings → About screen at least 30 days before taking effect.

## Source code

The event names, payloads, and collection controls can be reviewed in the app source:

- [Analytics preference and event wrapper](https://github.com/kristenmartino/focusforge/blob/main/app/FocusForge/Services/AnalyticsService.swift)

- [Session event payloads](https://github.com/kristenmartino/focusforge/blob/main/app/FocusForge/Services/SessionLogger.swift)

- [Firebase events and Crashlytics logs](https://github.com/kristenmartino/focusforge/blob/main/app/FocusForge/Services/FirebaseAnalyticsBackend.swift)

- [Full app source](https://github.com/kristenmartino/focusforge)

- [On-device coach engine](https://github.com/kristenmartino/focusforge-coach-engine)

The source shows app-defined events; Google’s SDKs also collect the service data described above. If you find a mismatch, please contact [privacy@kristenmartino.ai](mailto:privacy@kristenmartino.ai).
