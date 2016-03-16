require 'dotenv'
Dotenv.load

require 'sinatra'
require 'mysql2'

class HelloWorldApp < Sinatra::Base
  helpers do
    def mysql_client
      @mysql_client ||= Mysql2::Client.new(
        host: ENV['MYSQL_HOST'] || 'localhost',
        username: ENV['MYSQL_USERNAME'] || 'root',
        password: ENV['MYSQL_PASSWORD'] || 'mysql',
        port: ENV['MYSQL_PORT'] || 3306,
        database: ENV['MYSQL_DATABASE'] || 'test',
        encoding: 'utf8',
      )
    end

    def add_log
      sql = format(
        %(
          INSERT INTO logs
          (method, path, ip, created_at) VALUES ('%s', '%s', '%s', '%s')
        ),
        request.request_method,
        request.path,
        mysql_client.escape(request.ip),
        Time.now.utc.strftime('%Y-%m-%d %H:%M:%S')
      )
      mysql_client.query(sql)
    end

    def logs_count
      mysql_client.query('SELECT COUNT(*) AS c FROM logs').first['c']
    end
  end

  before do
    add_log
  end

  get '/' do
    format('Hello World %s! There are %d logs in the database',
           request.ip, logs_count)
  end
end
