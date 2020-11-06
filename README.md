# Airstream

An Airsonic Client built for the android built with usability and performance.

This app is still in early development and as such there will be regular breaking changes.

## File Structure

The project started out by organising folders and files according to their functionality (e.g.
screen, bloc, widgets, states). However the growth of the project (as functionality was added to
the app) has made it increasingly difficult to locate files quickly and more importantly
intuitively. Thus the folder structure will now slowly change to one oriented around the feature it
implements rather than the superficial function/type.

Here's an example:

```
|-- album
|   |-- bloc
|   |   |-- album_cubit.dart
|   |   |-- album_state.dart
|   |-- widgets
|   |   |-- more_options.dart
|   |   |-- shuffle_button.dart
|   |   |-- star_button.dart
|   |   |-- success.dart
|   |-- album_screen.dart
```

The goal is to pack as much of the code used by a feature into a single place for easy maintenance/
upgrade.

## Helpful Links

Being an open source project, community involvement is welcome and encouraged, however to ensure
that time isn't spent backtracking (refactoring or debugging) here are a few helpful links:

- [Github Glow](https://guides.github.com/introduction/flow/)
- [Git: Best Practices](https://github.com/ck3g/git-best-practices)