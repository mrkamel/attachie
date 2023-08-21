# CHANGELOG

## 2.0.0
### BREAKING
* Wrap `Aws::S3::Errors::NotFound` from `Attachie::S3Driver` and
 `Errno::ENOENT` from `Attachie::FileDriver` in `Attachie::ItemNotFound`
* Change `Attachie::FakeDriver::ItemNotFound` to `Attachie::ItemNotFound`
* Make `#delete` always return `true` for all drivers
### Added
* Added `Attachie::BaseError` as a base for all attachie exceptions

## 1.2.1
### Fixed
* Fix regarding `File.exists?` being no longer available in ruby 3.2

## 1.2.0
### Added
* Return proper `last_modified` in `FakeDriver#info`

## 1.1.2
### Fixed
* Make `FakeDriver` thread-safe
* Sort objects in `FakeDriver#list` by key

## 1.1.1
### Fixed
* Use `mkdir_p` in `FileDriver#download`

## 1.1.0
### Added
* Added a download method to download files to a specific path

## 1.0.1
### Fixed
* dup list result in FakeDriver before iterating
