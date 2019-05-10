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
  # タイトルの設定
  @title = params['title']
  
  # データベースへの接続
  connection = PG::connect(
    user: "postgres",
    dbname: "rl_message_board"
  )

  # データの取得
  @bid = params[:id]
  cmd = "SELECT * FROM messages WHERE bid=#{@bid}"
  result = connection.exec(cmd)
  @messages = []
  result.each do |message|
    @messages << {
      id: message['id'],
      body: message['body'],
      contributor: message['contributor']
    }
  end

  # データベースの接続切断
  connection.finish

  erb :messages
end

post '/messages' do
  # データベースへ接続し、登録するための id を取得
  @bid = params[:bid].to_i
  connection = PG::connect(
    user: "postgres",
    dbname: "rl_message_board"
  )
  cmd = "SELECT max(id) as max FROM messages WHERE bid=#{@bid}"
  result = connection.exec(cmd)
  nid = result[0]['max'].to_i + 1

  # POST で contributor, text を受け取る
  nbody = params[:body]
  ncontributor = params[:contributor]

  # データの登録
  cmd = "INSERT INTO messages(id, body, contributor, bid) VALUES (#{nid},'#{nbody}', '#{ncontributor}', #{@bid})"
  connection.exec(cmd)

  # 新しいデータの取得
  cmd = "SELECT * FROM messages WHERE bid=#{@bid}"
  result = connection.exec(cmd)
  @messages = []
  result.each do |message|
    @messages << {
      id: message['id'],
      body: message['body'],
      contributor: message['contributor']
    }
  end

  # データベースの接続切断
  connection.finish

  erb :messages
end

get '/board' do
  # タイトル
  @title = 'Message Board'
  @subtitle = 'rl_message_board'
  
  # データベースへの接続
  connection = PG::connect(
    user: "postgres",
    dbname: "rl_message_board"
  )

  # データの取得
  cmd = "SELECT * FROM board_id"
  result = connection.exec(cmd)
  @titles = []
  result.each do |title|
    @titles << {
      id: title['id'],
      body: title['daimei']
    }
  end

  # データベースの接続切断
  connection.finish

  # html
  erb :board
end

post '/board' do
  # データベースへの接続
  connection = PG::connect(
    user: "postgres",
    dbname: "rl_message_board"
  )
  # データ数の取得
  cmd = "SELECT count(*) AS count1 FROM board_id"
  result = connection.exec(cmd)
  @id = result[0]['count1']
  @daimei = params[:daimei]

  # データを挿入
  cmd = "INSERT INTO board_id(id, daimei) VALUES (#{@id}, '#{@daimei}')"
  result = connection.exec(cmd)

  connection.finish

  redirect '/board'
end

  
