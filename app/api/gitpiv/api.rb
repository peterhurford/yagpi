module Gitpiv
  class API < Grape::API
    version 'v1'
    format :json

    desc 'Test API'
    get '/status' do
      {status: 'OK'}
    end

    desc 'Receive PR information from GitHub'
    post '/github_hook' do
      {status: 'OK'}
    end
  end
end
