require "uri"
require "net/http"

# This is a basic backend for supporting remote files. It receives on
# initialization the server where the remote translations reside, the
# remote files and the authentication token to access the remote files.
# It fetaches the translations from the remote files and stores them in
# an in-memory hash. Inherits from the Simple backend and should be chained
# to the simple backend store so the local translations are used in case
# of Network errors.
#
# I18n.backend = I18n::Backend::Chain.new(I18n::Backend::RemoteFile.new(params), I18n.backend)
# The remote files to be fetched should have the following JSON format
# "translation_file_1": {
#  "en":
#   {
#     "name": "Name",
#      "title": "Title",
#      "content": "Content"
#    }
# }

module I18nRemote
  module Backend
    class RemoteFile < I18n::Backend::Simple
      def initialize(params)
        @translations_server = params[:translations_server]
        @filenames = params[:filenames]
      end

      private

      def init_translations
        fetch_remote_translations
        @initialized = true
      end

      def fetch_remote_translations
        @filenames.flatten.each do |filename|
          load_translation(filename)
        end
      end

      def load_translation(filename)
        data = load_content(filename)
        raise InvalidLocaleData.new(filename, "expects it to return a hash, but does not") unless data.is_a?(Hash)

        data.each { |locale, d| store_translations(locale, d || {}) }

        data
      end

      def load_content(filename)
        ## Authentication should be set up to access the server securely.
        ## For the sake of using this gem for testing purposes, it is here skipped.
        uri = URI(@translations_server + filename)
        response = Net::HTTP.get_response(uri)
        begin
          response.is_a?(Net::HTTPSuccess)
          JSON.parse(response.body)
        rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
               Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
          raise InvalidLocaleData.new(filename, "The remote translations could not be loaded")
        end
      end
    end
  end
end
