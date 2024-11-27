#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def get_db
	db = SQLite3::Database.new 'barbershop.db'
	db.results_as_hash = true
	return db
end

def is_barber_exists? db, name
	db.execute('SELECT * FROM Barbers WHERE name=?', [name]).length > 0
end
	
def seed_db db, barbers
	barbers.each do |barber|
		if !is_barber_exists? db, barber
			db.execute 'INSERT INTO Barbers (name) VALUES (?)', [barber]
		end
	end
end

before do
	db = get_db
	@barbers = db.execute 'SELECT * FROM Barbers'
end

configure do
	db = get_db
	db.execute 'CREATE TABLE IF NOT EXISTS
		Users
		(	"id" INTEGER PRIMARY KEY AUTOINCREMENT,
			"username" TEXT,
			"phone" TEXT,
			"datestamp" TEXT,
			"barber" TEXT,
			"color" TEXT)'

	db.execute 'CREATE TABLE IF NOT EXISTS
		Barbers
		(	"id" INTEGER PRIMARY KEY AUTOINCREMENT,
			"name" TEXT)'

	seed_db db, ['Выберите парикмахера', 'Джесси Пинкман', 'Уолтер Вайт', 'Гус Фринг', 'Майк Эрих']
end

get '/' do
	erb "Hello!"			
end

get '/about' do
	erb :about
end

get '/visit' do
	
	erb :visit
end

get '/contacts' do
	erb :contacts
end

post '/contacts' do
	require 'pony'
	@email = params[:email]
	@text = params[:text]

	hh = {  :email => 'Введите ваш электронный адрес',
			:text => 'Введите сообщение'}

	hh.each do |key, value|
		if params[key] == ''
			@error = hh[key]
			return erb :contacts
		end
	end

	#Pony.mail({:to => 'tanya.syrova.91@mail.ru',
	#	:subject => 'BarberShop new contact',
	#	:body => "#{@email}, #{@text}",
	#	:via => :smtp,
	#	:via_options => { 
	#	:address => 'smtp.mail.ru',
	#	:port => '587',
	#	:enable_starttls_auto => true,
	#	:user_name => 'tanya.syrova.91',
	#	:password => '54TVA7BeqB9ZknG6RjTK',
	#	:authentification => :plain,
	#	:domain => 'mail.ru'}
	#	}) 
		
	erb :contacts
end

post '/visit' do
	@username = params[:username]
	@phone = params[:phone]
	@date_time = params[:date_time]
	@barber = params[:barber]
	@color = params[:color]

	hh = { :username => 'Введите имя',
			:phone => 'Введите телефон',
			:date_time => 'Введите дату и время',
			:barber => 'Выберите парикмахера'}

	hh.each do |key, value|
		if params[key] == '' || params[key] == 'Выберите парикмахера'
			@error = hh[key]
			return erb :visit
		end
	end
	
	#@error = hh.select {|key,_| params[key] == ""}.values.join(", ")
	#if @error != ''
	# return erv :visit
	#endS
	
	db = get_db
	db.execute 'INSERT INTO
	Users (username, phone, datestamp, barber, color)
	VALUES (?, ?, ?, ?, ?)', [@username, @phone, @date_time, @barber, @color]
	
	f = File.open './public/users.txt', 'a'
	f.write "Имя: #{@username}, телефон: #{@phone}, дата и время записи: #{@date_time}, парикмахер: #{@barber}, цвет: #{@color} \n"
	f.close

	erb :record
end

post '/record' do
	erb :visit
end

get '/admin' do
	erb :admin
end

post '/admin' do
	@login = params[:login]
	@password = params[:password]

	if @login == 'admin' && @password == 'secret'
		db = get_db 		
		@results = db.execute 'SELECT * FROM Users ORDER BY id DESC' 
		erb :users
	else
		erb 'Некорректные логин или пароль'
	end
end
