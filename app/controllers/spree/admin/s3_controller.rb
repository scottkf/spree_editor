class Spree::Admin::S3Controller < Spree::Admin::BaseController

	def index
    response = { filelink: "https://#{Spree::Config.get_preference(:s3_bucket)}.s3.amazonaws.com/#{params[:key]}" }
    render json: response, status: :ok
	end
end
