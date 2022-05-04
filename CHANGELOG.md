## [Unreleased]

## [0.3.1] - 2022-05-04

### Fixed

- Fixed bug where keyword arguments were not getting passed correctly through `SerializerDefiner` into `Factory`, resulting in certain method options raising errors.

## [0.3.0] - 2022-01-21

### Added

- Added `Factory#attributes_field_serializer` to allow easy definition of multiple attributes at a time in serializer definition classes.
- Added `Factory#attribute_field_extractor` to simplify using either a `custom_extraction` or a `from_name_extractor`.

### Fixed

- Fixed bug where method alises in `Factory` were not respecting an overriden "source" method.
- Fixed bug where `ArraySerializer` counted hashes as arrays. Note that `ArraySerializer` **no longer counts `ActiveRecord::Relation` instances as arrays.** You must subclass `ArraySerializer` to attain this functionality.

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
