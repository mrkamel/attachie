
require File.expand_path("../../spec_helper", __FILE__)

RSpec.describe Attachie::S3Driver do
  let(:driver) do
    Attachie::S3Driver.new(Aws::S3::Client.new(
      access_key_id: "access_key_id",
      secret_access_key: "secret_access_key",
      endpoint: "http://localhost:4569",
      region: "us-east-1"
    ))
  end

  describe "#list" do
    it "lists objects" do
      begin
        driver.store("object1", "blob", "bucket")
        driver.store("object2", "blob", "bucket")
        driver.store("other", "blob", "bucket")

        expect(driver.list("bucket", prefix: "object").to_a).to eq(["object1", "object2"])
      ensure
        driver.delete("object1", "bucket")
        driver.delete("object2", "bucket")
        driver.delete("other", "bucket")
      end
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

  describe "#store_multipart" do
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

  describe "#temp_url" do
    it "generates a temp_url" do
      expect(driver.temp_url("name", "bucket")).to be_url
    end
  end

  describe "#presigned_post" do
    it "generates a presign response" do
      expect(driver.presigned_post("path/to/object", "bucket")).to match(
        fields: hash_including("key" => "path/to/object"),
        headers: {},
        method: "post",
        url: "http://bucket.localhost:4569"
      )
    end

    it "supports and passes additional options" do
      bucket = double
      object = double

      allow(bucket).to receive(:object).and_return(object)
      allow(object).to receive(:presigned_post).and_return(OpenStruct.new)
      allow(driver.s3_resource).to receive(:bucket).and_return(bucket)

      driver.presigned_post("path", "bucket", { key: "value" })

      expect(object).to have_received(:presigned_post).with(hash_including(key: "value"))
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

