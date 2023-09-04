# Attachie

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

Please note, Attachie will interpolate colon prefixed segments like `:id` by
replacing it with the return value of the respective method.

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
user.avator(:icon).download("/path/to/destination")
```

## Drivers

The `Attachie` gem ships with the following drivers:

* `Attachie::FileDriver`: To store files on the local file system
* `Attachie::FakeDriver`: To store files in memory (for testing)
* `Attachie::S3Driver`: To store files on S3

### FileDriver

To use the file driver:

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

### S3Driver

To use the s3 driver:

```ruby
require "attachie/s3_driver"

Attachie.default_options[:driver] = Attachie::S3Driver.new(Aws::S3::Client.new('...'))
```

### FakeDriver

To use the fake driver (useful for testing):

```ruby
require "attachie/fake_driver"

Attachie.default_options[:driver] = Attache::FakeDriver.new
```

Drivers and other options can be set on an attachment level as well:

```ruby
class User
  include Attachie

  attachment :avatar, driver: MyFileDriver, versions: {
    # ...
  }
end
```

## Direct S3 Uploads

Attachie allows to presign s3 post requests like:

```ruby
user.avatar(:icon).presign_post(content_type: 'image/jpeg', ...)
# => {"fields"=>{"key"=>"path/to/object","x-amz-signature"=>"..."},"headers":{},"method"=>"post","url"=>"..."}
```

## Contributing

1. Fork it ( https://github.com/mrkamel/attachie/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
