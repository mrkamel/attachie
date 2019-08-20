
require File.expand_path("../../lib/attachie", __FILE__)

require "attachie/file_driver"
require "attachie/fake_driver"
require "attachie/s3_driver"

class Product
  include Attachie

  attr_accessor :id

  def initialize(attributes = {})
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  attachment :image, host: ":subdomain.example.com", path_prefix: ":bucket", bucket: "images", driver: Attachie::FileDriver.new("/tmp/attachie"), versions: {
    thumbnail: { path: "products/:id/thumbnail.jpg" },
    original: { path: "products/:id/original.jpg" }
  }

  def subdomain
    "images"
  end
end

RSpec::Matchers.define :be_url do |expected|
  match do |actual|
    URI.parse(actual) rescue false
  end
end
