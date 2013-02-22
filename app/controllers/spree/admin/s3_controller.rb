class Spree::Admin::S3Controller < Spree::Admin::BaseController

	respond_to :json

	def index
		respond_with({ filelink: "http://#{Spree::Config.get_preference(:s3_bucket)}.s3.amazonaws.com/#{params[:key]}" })
	end
end