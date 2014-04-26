module AppBase
  class APIV1 < Grape::API
    version 'v1', using: :path
    format :json

    helpers do

      def protected_via_http_basic_auth!
        error!('401 Unauthorized', 401) unless authorized_via_http_basic_auth?
      end

      def authorized_via_http_basic_auth?
        @auth ||= Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? && @auth.basic? && @auth.credentials && current_user
      end

      def current_user
        @current_user ||= User.login_from_api(@auth, params[:session_token])
      end

      def protected_via_access_token!
        error!('401 Unauthorized', 401) unless authorized_via_token?
      end

      def authorized_via_token?
        params[:session_token] && current_user
      end

    end
      
    resources :sessions do

      # Open Session (Login)
      # POST /api/v1/sessions
      # `curl -s -X POST --data "client=v1" http://testuser:password@localhost:3000/api/v1/sessions`
      post do
        protected_via_http_basic_auth!
        status(201)
        { "errorcode" => 0, "result" =>{"session_token" => current_user.authentication_token, "member_token" => current_user.id.to_s} }.as_json
      end

      # Close Session (Logout)
      # DELETE /api/v1/sessions
      delete do
        protected_via_access_token!
        current_user.reset_authentication_token!
        status(201)
      end

    end 
    
    resources :users do

      # Create User
      # `curl -s -X POST --data "client=v1" http://testuser%40example.org:password@localhost:3000/api/v1/sessions`
      # POST /api/v1/users
      # requires params EMAIL
      #          params PASSWORD
      #          params NAME
      post do
        user = User.new(:email => params[:email],
                        :password => params[:password])
        if user.save
          { "errorcode" => 0, "result" => {"session_token" => user.authentication_token, "member_token" => user.id.to_s} }.as_json
        else
          error!({ "errorcode" => 406, "result" => "Not Acceptable"}, 406)
        end
      end

      # GET /api/v1/users/:id
      get ":id" do
        protected_via_access_token!
        if params[:id] && user = User.where(:id => params[:id]).first
          hash = {}
          # hash["name"] = user.name
          hash.as_json
        else
          error!({ "errorcode" => 403, "result" => "Forbidden"}, 403)
        end
      end
    end
    
    # GET /api/v1/server_error
    resource :server_error do
      get do
        error!({ "errorcode" => 500, "result" => "Internal Server Error"}, 500)
      end
    end

  end  # APIV1
end  #CMS