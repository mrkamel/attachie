
require File.expand_path("../../spec_helper", __FILE__)

RSpec.describe Attachie::FakeDriver do
  let(:driver) { Attachie::FakeDriver.new }

  after { driver.flush }

  describe "#list" do
    it "lists objects" do
      driver.store("object1", "blob", "bucket1")
      driver.store("object2", "blob", "bucket1")
      driver.store("other", "blob", "bucket1")
      driver.store("object", "blob", "bucket3")

      expect(driver.list("bucket1", prefix: "object").to_a).to eq(["object1", "object2"])
    end
  end

  describe "#store" do
    it "stores a blob" do
      driver.store("name", "blob", "bucket")

      expect(driver.exists?("name", "bucket")).to be(true)
      expect(driver.value("name", "bucket")).to eq("blob")
    end
  end

  describe "#store_multipart" do
    it "stores a blob via multipart upload" do
      driver.store_multipart("name", "bucket") do |upload|
        upload.upload_part("chunk1")
        upload.upload_part("chunk2")
      end

      expect(driver.exists?("name", "bucket")).to be(true)
      expect(driver.value("name", "bucket")).to eq("chunk1chunk2")
    end
  end

  describe "#delete" do
    it "deletes a blob" do
      driver.store("name", "blob", "bucket")
      expect(driver.exists?("name", "bucket")).to be(true)

      driver.delete("name", "bucket")
      expect(driver.exists?("name", "bucket")).to be(false)
    end
  end

  describe "#temp_url" do
    it "generates a temp_url" do
      expect(driver.temp_url("name", "bucket")).to eq("https://example.com/bucket/name?signature=signature&expires=expires")
    end
  end

  describe "#info" do
    it "returns info about the object" do
      driver.store("name.txt", "blob", "bucket")

      expect(driver.info("name.txt", "bucket")).to eq(
        content_length: 4,
        content_type: "text/plain",
        last_modified: nil
      )
    end
  end
end

