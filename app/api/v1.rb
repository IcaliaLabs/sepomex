module API
  class V1 < Grape::API
    version 'v1', using: :path
    format :json
    formatter :json, Grape::Formatter::ActiveModelSerializers
    helpers ApplicationHelper

    get :zip_codes do
      zip_codes = ZipCode.search(params).page(params[:page]).per(50)
      render zip_codes, meta: pagination_json(zip_codes, 50)
    end

    get :states do
      states = State.page(params[:page]).per(50)
      render states, meta: pagination_json(states, 50)
    end

    get :municipalities do
      municipalities = Municipality.search(params).page(params[:page]).per(50)
      render municipalities, meta: pagination_json(municipalities, 50)
    end
  end
end
