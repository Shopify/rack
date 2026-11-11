# frozen_string_literal: true

module Rack
  # Rack::MediaType parse media type and parameters out of content_type string

  class MediaType
    SPLIT_PATTERN = /[;,]/

    # parameter = token "=" ( token / quoted-string ). A quoted value may
    # contain the separator characters and escaped quotes, so parameters are
    # matched individually rather than split on SPLIT_PATTERN.
    PARAMETER = /([^=;,\s]+)\s*(?:=\s*(?:(["'])((?:\\.|[^"])*)\2|([^;,]*)))?/

    class << self
      # The media type (type/subtype) portion of the CONTENT_TYPE header
      # without any media type parameters. e.g., when CONTENT_TYPE is
      # "text/plain;charset=utf-8", the media-type is "text/plain".
      #
      # For more information on the use of media types in HTTP, see:
      # http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.7
      def type(content_type)
        return nil unless content_type && !content_type.empty?
        type = content_type.split(SPLIT_PATTERN, 2).first
        type.rstrip!
        type.downcase!
        type
      end

      # The media type parameters provided in CONTENT_TYPE as a Hash, or
      # an empty Hash if no CONTENT_TYPE or media-type parameters were
      # provided.  e.g., when the CONTENT_TYPE is "text/plain;charset=utf-8",
      # this method responds with the following Hash:
      #   { 'charset' => 'utf-8' }
      #
      # This will pass back parameters with empty strings in the hash if they
      # lack a value (e.g., "text/plain;charset=" will return { 'charset' => '' },
      # and "text/plain;charset" will return { 'charset' => '' }, similarly to 
      # the query params parser (barring the latter case, which returns nil instead)).
      def params(content_type)
        return {} if content_type.nil? || content_type.empty?
        return {} unless parameters = content_type.split(SPLIT_PATTERN, 2)[1]

        parameters.scan(PARAMETER).each_with_object({}) do |(name, _, quoted, token), hsh|
          hsh[name.downcase] = quoted || token&.strip || ''
        end
      end
    end
  end
end
