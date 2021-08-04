
module Attachie
  class FakeMultipartUpload
    include MonitorMixin

    def initialize(name, bucket, options, &block)
      super()

      @name = name
      @bucket = bucket

      block.call(self) if block_given?
    end

    def upload_part(data)
      synchronize do
        @data ||= ""
        @data << data
      end

      true
    end

    def data
      synchronize do
        @data
      end
    end

    def abort_upload; end
    def complete_upload; end
  end

  class FakeDriver
    include MonitorMixin

    class ItemNotFound < StandardError; end

    def list(bucket, prefix: nil)
      return enum_for(:list, bucket, prefix: prefix) unless block_given?

      synchronize do
        objects(bucket).sort { |a, b| a[0] <=> b[0] }.each do |key, _|
          yield key if prefix.nil? || key.start_with?(prefix)
        end
      end
    end

    def info(name, bucket)
      synchronize do
        {
          last_modified: nil,
          content_length: objects(bucket)[name].size,
          content_type: MIME::Types.of(name).first&.to_s
        }
      end
    end

    def presigned_post(name, bucket, options = {})
      raise NotSupported, 'presigned_post is not supported in FakeDriver'
    end

    def store(name, data_or_io, bucket, options = {})
      synchronize do
        objects(bucket)[name] = data_or_io.respond_to?(:read) ? data_or_io.read : data_or_io
      end
    end 

    def store_multipart(name, bucket, options = {}, &block)
      synchronize do
        objects(bucket)[name] = FakeMultipartUpload.new(name, bucket, options, &block).data
      end
    end

    def exists?(name, bucket)
      synchronize do
        objects(bucket).key?(name)
      end
    end 

    def delete(name, bucket)
      synchronize do
        objects(bucket).delete(name)
      end
    end 

    def value(name, bucket)
      synchronize do
        raise(ItemNotFound) unless objects(bucket).key?(name)

        objects(bucket)[name]
      end
    end 

    def download(name, bucket, path)
      content = value(name, bucket)

      open(path, "wb") { |stream| stream.write(content) }
    end

    def temp_url(name, bucket, options = {})
      "https://example.com/#{bucket}/#{name}?signature=signature&expires=expires"
    end

    def flush
      synchronize do
        @objects = {}
      end
    end 

    private

    def objects(bucket)
      synchronize do
        @objects ||= {}
        @objects[bucket] ||= {}
      end
    end 
  end 
end

