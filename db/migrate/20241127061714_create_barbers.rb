class CreateBarbers < ActiveRecord::Migration[7.1]
  def change
  	create_table :barbers do |t|
  		t.text :name
  		
  		t.timestamps
  	end
  

  Barber.create :name => 'Джесси Пинкман'
  Barber.create :name => 'Уолтер Вайт'
  Barber.create :name => 'Гас Фринг'

end
end
