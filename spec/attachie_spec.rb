
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
  it "interpolates the path" do
    test_model = TestModel.new(filename: "file.jpg")

    expect(test_model.file(:small).path).to eq("path/to/small/file.jpg")
  end

  it "allows arbitrary version methods" do
    test_model = TestModel.new(filename: "file.jpg")

    expect(test_model.file(:small).attribute).to eq("value")
  end

  it "respects the host" do
    test_model = TestModel.new(filename: "file.jpg")

    expect(test_model.file(:large).url).to eq("http://www.example.com/path/to/large/file.jpg")
  end

  it "correctly uses the driver" do
    test_model = TestModel.new(filename: "blob.txt")
    test_model.file(:large).store("blob")

    expect(test_model.file(:large).value).to eq("blob")
  end

  it "sets updated_at" do
    test_model = TestModel.new(filename: "file.jpg")
    test_model.file = "file"

    expect(test_model.updated_at).to_not be_nil

    test_model = TestModel.new(filename: "file.jpg")
    test_model.file = nil

    expect(test_model.updated_at).to be_nil
  end

  describe "#download" do
    it "downloads the file to the specified path" do
      tempfile = Tempfile.new

      begin
        test_model = TestModel.new(filename: "blob.txt")
        test_model.file(:large).store("blob")
        test_model.file(:large).download(tempfile.path)

        expect(tempfile.read).to eq("blob")
      ensure
        tempfile.close(true)
      end
    end
  end

  describe "#info" do
    it "returns info about the attachment" do
      test_model = TestModel.new(filename: "blob.txt")
      test_model.file(:large).store("blob")

      expect(test_model.file(:large).info).to match(
        last_modified: anything,
        content_type: anything,
        content_length: anything
      )
    end
  end

  describe "#presigned_post" do
    let(:attachment) { TestModel.new(filename: "file.jpg").file(:large) }
    let(:driver) { TestModel.attachments[:file][:driver] }

    before do
      allow(driver).to receive(:presigned_post)
    end

    it "delegates to the driver" do
      attachment.presigned_post

      expect(driver).to have_received(:presigned_post).with(attachment.path, attachment.bucket, {})
    end

    it "passes the supplied options" do
      attachment.presigned_post(key: "value")

      expect(driver).to have_received(:presigned_post).with(attachment.path, attachment.bucket, { key: "value" })
    end
  end
end
