
require File.expand_path("../../spec_helper", __FILE__)

RSpec.describe Attachie::FileDriver do
  let(:driver) { Attachie::FileDriver.new("/tmp/attachie") }

  describe "#presigned_post" do
    it "raises NotSupported" do
      expect { driver.presigned_post("path", "bucket") }.to raise_error(Attachie::NotSupported)
    end
  end

  describe "#store" do
    it "stores a blob" do
      begin
        driver.store("name", "blob", "bucket")

        expect(driver.exists?("name", "bucket")).to be(true)
        expect(driver.value("name", "bucket")).to eq("blob")
      ensure
        driver.delete("name", "bucket")
      end
    end
  end

  describe" #store_multipart" do
    it "stores a blob via multipart upload" do
      begin
        driver.store_multipart("name", "bucket") do |upload|
          upload.upload_part("chunk1")
          upload.upload_part("chunk2")
        end

        expect(driver.exists?("name", "bucket")).to be(true)
        expect(driver.value("name", "bucket")).to eq("chunk1chunk2")
      ensure
        driver.delete("name", "bucket")
      end
    end
  end

  describe "#delete" do
    it "deletes a blob" do
      begin
        driver.store("name", "blob", "bucket")
        expect(driver.exists?("name", "bucket")).to be(true)

        driver.delete("name", "bucket")
        expect(driver.exists?("name", "bucket")).to be(false)
      ensure
        driver.delete("name", "bucket")
      end
    end
  end

  describe "#info" do
    it "returns info about the object" do
      begin
        driver.store("name.txt", "blob", "bucket")

        expect(driver.info("name.txt", "bucket")).to match(
          content_length: 4,
          content_type: "text/plain",
          last_modified: anything
        )
      ensure
        driver.delete("name.txt", "bucket")
      end
    end
  end
end

