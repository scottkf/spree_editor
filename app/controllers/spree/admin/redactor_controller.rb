class Spree::Admin::RedactorController < Spree::Admin::BaseController
  protect_from_forgery :except => [:upload]

  def upload
    @image = ::Spree::Image.new(viewable: nil)
    puts params[:file].tempfile
    file = File.open(params[:file].tempfile)
    @image.attachment = file
    @image.attachment_file_name = "#{SecureRandom.hex(4).to_s}_#{params[:file].original_filename}"
    if @image.save
      render json: {filelink: @image.attachment.url}, status: :ok
    else
      render json: {filelink: @image.attachment.url}, status: :ok
      puts @image.errors.inspect
    end
  end

  def encrypt
    key = Spree::Config.get_preference(:s3_access_key)
    secret = Spree::Config.get_preference(:s3_secret)
    bucket = Spree::Config.get_preference(:s3_bucket)

    # To avoid file collision, we prepend string to the filename
    filename = "#{SecureRandom.hex(4).to_s}_#{params[:name]}"
    content_type = MIME::Types.type_for(filename).first.content_type

    resource_endpoint = "//#{bucket}.s3.amazonaws.com/#{filename}"
    options = {
        :http_verb => "PUT", 
        :date => 1.hours.from_now.to_i, 
        :resource => "/#{bucket}/#{filename}",
        :content_type => content_type,
        :amz_headers => ['x-amz-acl:public-read']
      }
    url = AwsS3Signature.build_s3_upload_url(resource_endpoint, key, secret, options)
    render :json => {url: url, content_type: content_type}
  end
end
