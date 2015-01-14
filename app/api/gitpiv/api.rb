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

      def connect_to_pivotal!
        error!('PIVOTAL_API_KEY not set', 500) unless ENV['PIVOTAL_API_KEY'].present?
        @conn ||= RestClient::Resource.new("https://www.pivotaltracker.com/services/v5", :headers => {'X-TrackerToken' => ENV['PIVOTAL_API_KEY'], 'Content-Type' => 'application/json'})
      end

      def change_story_state(pivotal_id, github_pr_url, github_author, pivotal_action)
        connect_to_pivotal!
        pivotal_verb = (pivotal_action == 'finished' ? "Finishes" : "Delivers")
        @conn["source_commit"].post("{'source_commit':{'commit_id':'','message':'[#{pivotal_verb} ##{pivotal_id}] #{pivotal_action.capitalize} via YAGPI GitHub Webhook.','url':'#{github_pr_url}','author':'#{github_author}'}}")
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
      github_pr_url = params['pull_request']['html_url']
      github_author = params['pull_request']['user']['login']

      error!('No action', 500) unless github_action.present?
      error!('No branch', 500) unless github_branch.present?
      error!('No PR URL', 500) unless github_pr_url.present?
      error!('No author', 500) unless github_author.present?

      pivotal_id = find_pivotal_id(github_body, github_branch)

      if github_action == "opened"
        change_story_state(pivotal_id, github_pr_url, github_author, 'finished')
        pivotal_action_taken = "finish"
      elsif github_action == "merged"
        change_story_state(pivotal_id, github_pr_url, github_author, 'delivered')
        pivotal_action_taken = "deliver"
      else
        pivotal_action_taken = "none"
      end
      
      {
        detected_github_action: github_action,
        detected_pivotal_id: pivotal_id,
        detected_github_pr_url: github_pr_url,
        detected_github_author: github_author,
        pivotal_action: pivotal_action_taken
      }
    end
  end
end
