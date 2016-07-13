#require 'rubygems'
#require 'sinatra'
require 'active_record'
#require 'sqlite3'


ActiveRecord::Base.establish_connection(
	:adapter => 'sqlite3',
	:database => 'database.db'
	)

ActiveRecord::Schema.define do
  unless ActiveRecord::Base.connection.tables.include? 'users'
    create_table :users do |table|
      table.column :userid,     :string
      table.column :name, :string
      table.column :lastname, :string
      table.column :passwordhash, :string
      table.column :has, :string
    end
  end

  unless ActiveRecord::Base.connection.tables.include? 'partidas'
    create_table :partidas do |table|
      table.column :userid, :string
      table.column :jugador2_id, :string
      table.column :tipo_tablero, :integer
      table.column :proxturno, :string
      table.column :finalizado, :string
      table.column :comienzo, :string
    end
  end

  unless ActiveRecord::Base.connection.tables.include? 'tableros'
    create_table :tableros do |table|
      table.column :partidaid, :string
      table.column :userid, :string
    end
  end
#1 indica que el barco esta hundido
  unless ActiveRecord::Base.connection.tables.include? 'barcos'
    create_table :barcos do |table|
      table.column :tableroid, :string
      table.column :coordenadas, :string
      table.column :estado, :integer 
    end
  end

#1 Disparos/movimientos
  unless ActiveRecord::Base.connection.tables.include? 'movimientos'
    create_table :movimientos do |table|
      table.column :tableroid, :string
      table.column :coordenadas, :string
      table.column :estado, :integer 
    end
  end

end



class User < ActiveRecord::Base	
end

class Partida < ActiveRecord::Base
end

class Barco < ActiveRecord::Base
end

class Tablero < ActiveRecord::Base
end

class Movimiento < ActiveRecord::Base
end