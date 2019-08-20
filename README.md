# Attachie

[![Build Status](https://secure.travis-ci.org/mrkamel/attachie.png?branch=master)](http://travis-ci.org/mrkamel/attachie)

Declarative and flexible attachments.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'attachie'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install attachie

## Usage

First, `include Attachie` and specify an attachment:

```ruby
class User
  include Attachie

  attachment :avatar, versions: {
    icon: { path: "users/:id/avatar/icon.jpg" },
    thumbnail: { path: "users/:id/avatar/thumbnail.jpg" },
    original: { path: "users/:id/avatar/original.jpg" }
  }
end
```

Second, store blobs for your version:

```ruby
user.avatar(:icon).store("blob")
user.avatar(:thumbnail).store("blob")
user.avatar(:original).store("blob")
```

or via multipart upload

```ruby
user.avatar(:icon).store_multipart do |upload|
  upload.upload_part "chunk1"
  upload.upload_part "chunk2"
  # ...
end
```

Third, add the images url to your views:

```
image_tag user.avatar(:thumbnail).url
```

More methods to manipulate the blobs:

```ruby
user.avatar(:icon).delete
user.avatar(:icon).exists?
user.avatar(:icon).value
user.avatar(:icon).temp_url(expires_in: 2.days) # Must be supported by the driver
```

## Drivers

The `attachie` gem ships with the following drivers:

* `Attachie::FileDriver`: To store files on the local file system
* `Attachie::FakeDriver`: To store files in memory (for testing)
* `Attachie::S3Driver`: To store files on S3
* `Attachie::SwiftDriver`: To store files on an Openstack Swift provider

You can eg use the file system driver:

```ruby
require "attachie/file_driver"

Attachie.default_options[:driver] = Attachie::FileDriver.new("/path/to/attachments")

class User
  include Attachie

  attachment :avatar, host: "www.example.com", versions: {
    # ...
  }
end
```

## Contributing

1. Fork it ( https://github.com/mrkamel/attachie/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
