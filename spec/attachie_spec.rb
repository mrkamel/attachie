
require File.expand_path("../spec_helper", __FILE__)

class TestModel
  include Attachie

  attachment :file, driver: Attachie::FakeDriver.new, bucket: "bucket", host: "www.example.com", versions: {
    small: { path: "path/to/small/:filename", attribute: "value" },
    large: { path: "path/to/large/:filename" }
  }

  attr_accessor :filename, :updated_at

  def initialize(filename:)
    self.filename = filename
  end
end

RSpec.describe TestModel do
  it "should interpolate the path" do
    test_model = TestModel.new(filename: "file.jpg")

    expect(test_model.file(:small).path).to eq("path/to/small/file.jpg")
  end

  it "should allow arbitrary version methods" do
    test_model = TestModel.new(filename: "file.jpg")

    expect(test_model.file(:small).attribute).to eq("value")
  end

  it "should respect the host" do
    test_model = TestModel.new(filename: "file.jpg")

    expect(test_model.file(:large).url).to eq("http://www.example.com/path/to/large/file.jpg")
  end

  it "should correctly use the driver" do
    test_model = TestModel.new(filename: "blob.txt")
    test_model.file(:large).store "blob"

    expect(test_model.file(:large).value).to eq("blob")
  end

  it "should set updated_at" do
    test_model = TestModel.new(filename: "file.jpg")
    test_model.file = "file"

    expect(test_model.updated_at).to_not be_nil

    test_model = TestModel.new(filename: "file.jpg")
    test_model.file = nil

    expect(test_model.updated_at).to be_nil
  end

  describe '#info' do
    it 'returns info about the attachment' do
      test_model = TestModel.new(filename: "blob.txt")
      test_model.file(:large).store "blob"

      expect(test_model.file(:large).info).to match(
        last_modified: anything,
        content_type: anything,
        content_length: anything
      )
    end
  end
end

