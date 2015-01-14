module Gitpiv
  class API < Grape::API
    version 'v1'
    format :json

    helpers do
      def regex_for_pivotal_id(what)
        what[/[0-9]{7,}/]
      end
      def find_pivotal_id(body, branch)
        regex_for_pivotal_id(body) || regex_for_pivotal_id(branch)
      end
    end

    desc 'Test API'
    get '/status' do
      {status: 'OK'}
    end

    desc 'Receive PR information from GitHub'
    post '/github_hook' do
      github_body = params['pull_request']['body']
      github_branch = params['pull_request']['head']['ref']
      github_action = params['action']
      error!('No action', 500) unless github_action.present?
      error!('No branch', 500) unless github_branch.present?
      pivotal_id = find_pivotal_id(github_body, github_branch)
      {
        action: github_action,
        pivotal_id: pivotal_id
      }
    end
  end
end
