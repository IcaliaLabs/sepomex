module API
  class V1 < Grape::API
    version 'v1', using: :path
    format :json
    helpers ApplicationHelper

    get :zip_codes do
      zip_codes_response ZipCode.all
    end
  end
end
