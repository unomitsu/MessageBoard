# coding: utf-8
require 'sinatra'
require 'pg'
require 'json'

set :bind, '0.0.0.0'

# URLのパスを入れる
get '/hello' do
  'Hello World!!'
end

get '/messages' do
  connection = PG::connect(
    user: "postgres",
    dbname: "rl_message_board"
  )
  cmd = "SELECT * FROM messages"
  result = connection.exec(cmd)
  messages = []
  result.each do |message|
    messages << {
      body: message['body'],
      contributor: message['contributor']
    }
  end
  connection.finish
  "#{JSON.dump(messages)}"
end

post '/messages' do
  body = params['body']
  contributor = params['contributor']
  cmd = "INSERT INTO messages(body, contributor) VALUES ('#{body}', '#{contributor}')"
  connection = PG::connect(
    user: "postgres",
    dbname: "rl_message_board"
  )
  connection.exec(cmd)
  connection.finish
end
  
