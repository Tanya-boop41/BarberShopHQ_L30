#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'


set :database, {adapter: "sqlite3", database: "barbershop.db"}

class Client < ActiveRecord::Base
	validates :name, presence: true
	validates :phone, presence: true
	validates :datestamp, presence: true
	validates :color, presence: true
end

class Barber < ActiveRecord::Base
end

before do
	@barbers = Barber.all
end

get '/' do
	erb :index
end

get '/visit' do
	
	erb :visit
end

post '/visit' do
	
	c = Client.new params[:client]
	if c.save
		erb :record
	else 
		erb "<h3>Заполните пустые поля</h3>"
	end
end

post '/record' do
	erb :visit
end

