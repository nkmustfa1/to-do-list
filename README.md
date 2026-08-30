# DevReady To-Do Application

A compact offline-first Flutter task manager built to match the DevReady Explorer portfolio brief.

## Features

- Create tasks with clear validation feedback.
- Edit existing task titles without affecting other work.
- Mark tasks complete with an idempotent completion action, so duplicate taps do not undo completion.
- Delete tasks with confirmation.
- Persist only non-sensitive task data locally with `shared_preferences`.
- Restore completed tasks after relaunch.
- Show explicit loading and empty states.
- Recover safely from malformed local JSON instead of crashing.
- Keep controls usable on narrow mobile layouts.
- Add semantics labels and standard Material touch targets for accessibility.

## Architecture

The app keeps responsibilities small and testable:

- `lib/models/task.dart` — immutable task model and JSON validation.
- `lib/repositories/task_repository.dart` — local persistence boundary and corrupt-data recovery.
- `lib/controllers/task_controller.dart` — validation, state transitions, and persistence coordination.
- `lib/screens/task_home_page.dart` — responsive task workflow UI.
- `lib/widgets/task_tile.dart` — reusable accessible task row.

No remote service is required. Repository analysis can inspect this source statically; the app itself does not send task data to a backend.

## Setup

1. Install a current Flutter stable release with Dart 3.4 or newer.
2. Clone this repository.
3. From the repository root run:

```bash
flutter pub get
```

If platform folders are not present in your clone yet, generate the standard Flutter host files once:

```bash
flutter create .
```

Then run the application on an available device or emulator:

```bash
flutter run
```

## Testing

Run static analysis and tests with:

```bash
flutter analyze
flutter test
```

The focused tests cover model serialization, malformed data, title validation, persistence behavior, duplicate completion, and the empty/add-task widget flow.

## Verification

Manual verification checklist:

1. Launch with no stored tasks and confirm the empty state appears.
2. Attempt to add an empty title and confirm an actionable validation message appears.
3. Add two tasks, edit one, and confirm the other is unchanged.
4. Mark one task complete twice and confirm it remains completed.
5. Relaunch the app and confirm tasks and completion status remain.
6. Delete one task and confirm the remaining task is preserved.
7. Test on a narrow phone viewport and confirm there is no horizontal overflow.
8. Seed malformed local JSON during development and confirm the app resets that invalid draft without crashing.

## Screenshots

Screenshots are not committed yet. For portfolio submission, capture the empty state, populated task list, validation state, and completed-task state from a phone-sized viewport.

## Known limitations

- Data is intentionally local to one device; there is no account sync.
- Completed tasks are intentionally one-way in this brief. A separate reopen action can be added later if product requirements need it.
- `shared_preferences` is appropriate for this small non-sensitive portfolio task list, not for large relational datasets.
