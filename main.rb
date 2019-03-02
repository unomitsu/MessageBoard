# coding: utf-8
require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'json'

set :bind, '0.0.0.0'

# URLのパスを入れる
get '/hello' do
  'Hello Ruby!!'
end

get '/messages' do
  @title = 'Message Board'
  @subtitle = 'messages'
  
  connection = PG::connect(
    user: "postgres",
    dbname: "rl_message_board"
  )
  cmd = "SELECT * FROM messages"
  result = connection.exec(cmd)
  @messages = []
  result.each do |message|
    @messages << {
      id: message['id'],
      body: message['body'],
      contributor: message['contributor']
    }
  end
  connection.finish

  erb :messages
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

get '/board' do
  @title = 'Message Board'
  @subtitle = 'rl_message_board'
  
  connection = PG::connect(
    user: "postgres",
    dbname: "rl_message_board"
  )
  cmd = "SELECT * FROM board_id"
  result = connection.exec(cmd)
  @messages = []
  result.each do |message|
    @messages << {
      body: message['id'],
      contributor: message['daimei']
    }
  end
  connection.finish

  erb :index
end
  
