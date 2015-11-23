module API
  class V1 < Grape::API
    version 'v1', using: :path
    format :json
    helpers ApplicationHelper

    get :zip_codes do
      zip_codes = ZipCode.search(params).page(params[:page]).per(50)
      zip_codes_response zip_codes, meta: pagination_json(zip_codes, 50)
    end
  end
end
