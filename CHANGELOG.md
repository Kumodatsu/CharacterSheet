# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2020-07-03
### Added
- Changelog file.
- Command: `/cs clear`. Allows one to clear their stat block.

### Changed
- Some output messages have been improved to make them more accurate and clear.

### Fixed
- Fix handling of events. Event functions are now called, as intended.
- Fix saving and loading of data. This now happens as intended.

## [0.0.3] - 2020-05-20
### Added
- Basic stat system. Allows one to set stat values and perform rolls.
- Command: `/cs set`. Allows one to create a stat and set its value.
- Command: `/cs roll`. Allows one to roll with a given stat.
- Command: `/cs stats`. Allows one to view their stats and their values.

## [0.0.2] - 2020-05-11
### Added
- (Code) Command system. Creates an abstraction which makes it easier to add new commands.
- (Code) Table utilities. Includes functions to operate on tables.
