## [Unreleased]

### Added

- Added `Factory#attributes_field_serializer` to allow easy definition of multiple attributes at a time in serializer definition classes.
- Added `Factory#attribute_field_extractor` to simplify using either a `custom_extraction` or a `from_name_extractor`.

### Fixed

- Fixed bug where method alises in `Factory` were not respecting an overriden "source" method.

## [0.2.2] - 2022-01-19

### Changed

- Bumped required `activesupport` version to 6.0.x.

## [0.2.1] - 2022-01-19

### Changed

- Bumped required `activesupport` version to 7.0.x.

## [0.2.0] - 2022-01-19

This is the initial functional release of the gem. Extractors, serializers, fields, field policies, and an elegant DSL over top were implemented.

## [0.1.0] - 2022-01-16

- Initial release. This version of the gem has no functionality whatsoever and is intended solely as a deployment test.
