# Airstream

An [Airsonic](https://github.com/airsonic/airsonic) client built for the android 
with usability and performance in mind.

This app is still in early development and as such there will be regular
breaking changes.

## File Structure

Top level folders should indicate the feature a set of files implement and
subsequent folders should be organised by type.

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

Take note that "album" is the top-level folder and "bloc" and "widgets" are
subsequent folders that organise files by type. The goal is to pack as much of
the code used by a feature into a single place for an intuitive workflow.

## Helpful Links

Being an open source project, community involvement is welcome and encouraged,
however to ensure that time isn't spent backtracking (refactoring or debugging)
here are a few helpful links:

- [Github Glow](https://guides.github.com/introduction/flow/)
- [Git: Best Practices](https://github.com/ck3g/git-best-practices)
