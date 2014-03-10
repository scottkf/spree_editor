module AwsS3Signature

  def self.build_s3_str_to_sign(options = {})
    options = {
      :http_verb => "PUT",
      :content_md5 => nil,
      :content_type => nil,
      :date => 1.hours.from_now.rfc822,
      :amz_headers => [],
      :resource => ""
    }.merge(options)

    str = options[:http_verb].to_s + "\n" +
      options[:content_md5].to_s + "\n" +
      options[:content_type].to_s + "\n" +
      options[:date].to_s + "\n" +
      (options[:amz_headers].any? ? (options[:amz_headers].join("\n") + "\n") : "") +
      options[:resource]
  end

  def self.build_s3_rest_signature(secret_access_key, options = {})
    str = build_s3_str_to_sign(options).encode("UTF-8")
    result = CGI::escape(Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::SHA1.new, secret_access_key, str)).strip)
  end

  def self.build_s3_upload_url(endpoint, aws_access_key, secret_access_key, signature_options = {})
    signature = build_s3_rest_signature(secret_access_key, signature_options)
    signature = signature.gsub("+", "%20").gsub("\n", "")
    expires = signature_options[:date] || 1.day.from_now.rfc822
    "#{endpoint}?Signature=#{signature}&AWSAccessKeyId=#{aws_access_key}&Expires=#{expires}"
  end

end