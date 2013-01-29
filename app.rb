class DeploymentApp < Sinatra::Base
  set :root, File.dirname(__FILE__)
  
  # Include CSS and JS and compile coffee-script
  register Sinatra::AssetPack
  assets {
      js :app, [
        '/js/jquery.js',
        '/js/script.js',
        '/js/underscore-min.js'
      ]

      css :application, [
        '/css/style.css'
      ]
    }

  register Sinatra::ConfigFile

  config_file 'config/settings.yml'
  include Trello
  include Trello::Authorization
  Trello::Authorization.const_set :AuthPolicy, OAuthPolicy

  OAuthPolicy.consumer_credential = OAuthCredential.new settings.trello_pub_key, settings.trello_secret
  OAuthPolicy.token               = OAuthCredential.new settings.trello_priv_key, nil

  get '/' do
    @pub = settings.public_folder
    @title = "Deploy to QA"
    @post_url = '/deploy'
    @platforms = settings.platforms
    haml :index
  end

  get '/branches/:project' do
    @branches = get_branches(params[:project])
    content_type :json
    @branches.to_json
  end

  def get_branches(project)
    url = settings.send("#{project}_branches_url".to_sym)
    branches = JSON.parse(RestClient.get url)
  end

  # Handle deployment form submit and route request to Jenkins trigger
  post '/deploy' do
    move_trello_card(params[:branch])
    # Triggers the Jenkins job.
    RestClient.post(settings.jenkins_url, 'payload' => params.to_json){|response, request, result, &block|
      if [301, 302, 307].include? response.code
        response.follow_redirection(request, result, &block)
      else
        response.return!(request, result, &block)
      end
    }
    content_type :json
    params.to_json
  end

  def move_trello_card(branch)
    boards = Board.all
    board = boards.detect {|board| board.name == settings.trello_board_name}
    cards = board.cards
    card = cards.detect {|card| card.name == "#{branch}"}
    unless card.nil?
      done_list = board.lists.detect {|list| list.name == "Done"}
      card.move_to_list(done_list)
    end
  end
  
  # A route for testing
  get '/test' do
  end
end

