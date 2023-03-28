
require "fileutils"

module Attachie
  class FileDriver
    class FileMultipartUpload
      include MonitorMixin

      def initialize(name, bucket, driver, &block)
        super()

        @name = name
        @bucket = bucket
        @driver = driver

        @stream = open(driver.path_for(name, bucket), "wb")

        if block_given?
          begin
            block.call(self)
          rescue => e
            abort_upload

            raise e
          end

          complete_upload
        end
      end

      def upload_part(data)
        synchronize do
          @stream.write(data)
        end
      end

      def abort_upload
        @stream.close

        @target.delete(name, bucket)
      end

      def complete_upload
        @stream.close
      end
    end

    def initialize(base_path)
      @base_path = base_path
    end

    def store(name, data_or_io, bucket, options = {})
      path = path_for(name, bucket)

      FileUtils.mkdir_p File.dirname(path)

      open(path, "wb") do |stream|
        io = data_or_io.respond_to?(:read) ? data_or_io : StringIO.new(data_or_io)

        while chunk = io.read(1024)
          stream.write chunk
        end
      end

      true
    end

    def presigned_post(name, bucket, options = {})
      raise NotSupported, 'presigned_post is not supported in FileDriver'
    end

    def info(name, bucket)
      {
        last_modified: File.mtime(path_for(name, bucket)),
        content_type: MIME::Types.of(name).first&.to_s,
        content_length: File.size(path_for(name, bucket))
      }
    end

    def store_multipart(name, bucket, options = {}, &block)
      path = path_for(name, bucket)

      FileUtils.mkdir_p File.dirname(path)

      FileMultipartUpload.new(name, bucket, self, &block)
    end

    def value(name, bucket)
      File.binread path_for(name, bucket)
    end

    def download(name, bucket, dest_path)
      path = path_for(name, bucket)

      FileUtils.mkdir_p File.dirname(path)

      FileUtils.cp(path, dest_path)
    end

    def delete(name, bucket)
      path = path_for(name, bucket)

      FileUtils.rm_f(path)

      begin
        dir = File.dirname(File.join(bucket, name))

        until dir == bucket
          Dir.rmdir File.join(@base_path, dir)

          dir = File.dirname(dir)
        end
      rescue Errno::ENOTEMPTY, Errno::ENOENT
        # nothing
      end

      true
    end

    def exists?(name, bucket)
      File.exist? path_for(name, bucket)
    end

    def path_for(name, bucket)
      File.join(@base_path, bucket, name)
    end
  end
end

