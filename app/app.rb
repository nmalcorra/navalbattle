#require 'sinatra'
require 'bcrypt'
require 'bundler'
require_relative '../app/models/model.rb'

Bundler.require
configure do 
  enable :sessions
end
 # Metodos de login
helpers do
  
  def login?
    if session[:userid].nil?
      return false
    else
      return true
    end
  end
  
  def userid
    return session[:userid]
  end
  
end
get '/' do
  if login?
    redirect "/home"  
  else
    erb :index
  end
end

post "/login" do
  user=User.find_by(userid: params[:userid])
  if user.nil? 
    @title= "Login error"
    @error= "Incorrect username and password"
    status 401
    @status= status
    erb :error
  else
      if user[:passwordhash] == BCrypt::Engine.hash_secret(params[:password], user[:has])
        session[:userid] = params[:userid]
        redirect "/home"
      end
  end
  
end

get "/signup" do
	erb :register
end

post "/players" do
  password_salt = BCrypt::Engine.generate_salt
  password_hash = BCrypt::Engine.hash_secret(params[:password], password_salt)
  usdb=User.find_by(userid: params[:userid])
  if usdb.nil? 
    if  params[:userid].present?
    	 us = User.create(:userid => params[:userid],
      :name => params[:name] ,
      :lastname => params[:last_name],
      :passwordhash => password_hash,
      :has => password_salt)
      status 201
      @mensaje= "Usuario creado con &eacute;xito"
      @boton= "Iniciar sessi&oacute;n"
      erb :created
    else
      status 400
      @title= "Error en registro"
      @error= "Usuario invalido"
      @status= status
      erb :error 
    end
  else
    status 409
    @title= "Error en registro"
    @error= "el usuario ya existe"
    @status= status
    erb :error
  end
end

get "/singoff" do
  session.clear
  redirect "/"
end

#Metodos de a home page
get "/home" do
  if login?
    @user= userid()
    erb "index-login".to_sym
  else
   erb "index".to_sym
  end
end
#Metos del juego
get '/new-game' do
  if login?
   @selectOpt = ""
   users=User.where.not(userid: userid )
   users.each do |user|
      @selectOpt << "<option name =idplayer2 value = #{user.userid}> #{user.name}</option>" 
    end
    erb "new-game".to_sym
  else
    erb "index".to_sym
  end
end


#merge
post '/players/games' do  #Crear Partida 
  idplayer2= params["idplayer2"]
  size = params[:tab_size].to_i
  usid = userid 
  Partida.create(:userid => usid, :jugador2_id => idplayer2, :tipo_tablero => size, 
    :proxturno => usid, :finalizado => 'N', :comienzo => 'Y' ) 
  part=Partida.where(userid: userid).last
  status 201
  @mensaje= "Partida creada con &eacute;xito"
  @boton= "Inicio"
  erb :created
end


post '/ubicarbarcos/:idpartida' do
    partida=Partida.find_by(id: params["idpartida"])
    @idplayer2= params["idplayer2"] 
    #Crear Partida  
  if partida[:tipo_tablero] == 5
    @nums = [nil,"1","2","3","4","5"]
    @letras = [nil,"A","B","C","D","E"] 

  else
    if partida[:tipo_tablero] == 10
      @nums = [nil,"1","2","3","4","5","6","7","8","9","10"]
      @letras = [nil,"A","B","C","D","E","F","G","H","I","J"]   
    else
      @nums = [nil,"1","2","3","4","5","6","7","8","9","10","11","12","13","14","15"]
      @letras = [nil,"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O"] 
    end
  end

  @idpart = params['idpartida']
  haml :play
end



post '/ubicarbarcos/:idpart/confirm' do 
    @idpart = params[:idpart]
    partida=Partida.find_by(id: params[:idpart] )
    @tab=partida[:tipo_tablero]
    aux = params["check"] 
    @res =aux.keys 
    ok = true
    if @tab == 5 && @res.size != 7 
        ok = false 
        else if @tab == 10 && @res.size != 15 
            ok = false 
            else if @tab == 15 && @res.size != 20 
            ok = false 
            end 
        end
    end 
    if ok 
      @idplayer2 = partida[:jugador2_id] 
      if @tab == 5
        @nums = [nil,"1","2","3","4","5"]
        @letras = [nil,"A","B","C","D","E"] 
      else
        if @tab == 10
          @nums = [nil,"1","2","3","4","5","6","7","8","9","10"]
          @letras = [nil,"A","B","C","D","E","F","G","H","I","J"]   
        else
          @nums = [nil,"1","2","3","4","5","6","7","8","9","10","11","12","13","14","15"]
          @letras = [nil,"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O"] 
        end
      end
      @todos = String.new
      @res.each do |b| 
        @todos = @todos + "," + b.to_s 
      end
      haml :confirm
    else 
      status 409
      @title= "Error en posicionamiento"
      @error= "Cantidad incorrecta de barcos"
      @status= status
      erb :error  
    end 
end

put "/players/game" do
  idpart = params['idpart'].to_i
  #Crear tablero
  tabl=Tablero.create(:partidaid => idpart, :userid => userid )
  ubi = params['ubicaciones'].split(",")
  ubi.delete("")
  ubi.each do |b| 
           Barco.create(:tableroid => tabl.id.to_s, :coordenadas => b, :estado => 0 ) 
  end 
  redirect '/home'
end






post '/play' do
  if params[:tab_size] == "5"
    @nums = [nil,"1","2","3","4","5"]
    @letras = [nil,"A","B","C","D","E"] 

  else
    if params[:tab_size] == "10"
      @nums = [nil,"1","2","3","4","5","6","7","8","9","10"]
      @letras = [nil,"A","B","C","D","E","F","G","H","I","J"]   
    else
      @nums = [nil,"1","2","3","4","5","6","7","8","9","10","11","12","13","14","15"]
      @letras = [nil,"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O"] 
    end
  end
  @idplayer2= params["idplayer2"]
  @size = params[:tab_size]
  haml :play
end


post "/game" do
#Crear Partida
tab=params["tab"].to_i
idplayer2 = params["idplayer2"]
usid = userid
part=Partida.create(:userid => usid,
  :jugador2_id => idplayer2,
  :tipo_tablero => tab,
  :proxturno => idplayer2,
  :finalizado => 'N',
  :comienzo => 'Y'
  )


#Crear tablero
tabl= Tablero.create(:partidaid => part.id,
  :userid => userid
  )
#Get barcos
aux = params["check"]
res =aux.keys
res.each do |b|
   Barco.create(:tableroid => tabl.id.to_s,
    :coordenadas => b,
    :estado => 0
    )
   end
   "Partida creada con exito"
end



get '/play5/playing' do
  @nums = [nil,"1","2","3","4","5"]
  @letras = [nil,"A","B","C","D","E"]
  haml :playing
end

get '/play10/playing' do
  @nums = [nil,"1","2","3","4","5","6","7","8","9","10"]
  @letras = [nil,"A","B","C","D","E","F","G","H","I","J"]
  haml :playing
end

get '/play15/playing' do
  @nums = [nil,"1","2","3","4","5","6","7","8","9","10","11","12","13","14","15"]
  @letras = [nil,"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O"]
  haml :playing
end

get '/turn-invalid' do
  haml "turn-invalid".to_sym
end
# Comentar para ver la ruta que fallor
not_found do
  'Ruta no encontrada'
end


#Listar partidas
get '/players/:id/games' do
  erb :index unless login?
  if params[:id] == userid
    @parts=Partida.where("userid =? OR jugador2_id =?" ,params[:id], params[:id])
    id=""
    @parts.each do |par|
      id=par.id.to_s
    end
    @tabl=Tablero.find_by(partidaid: id, userid: userid)
    haml :partidas
  else
    @title= "Error en ver partidas"
    @error= "No puede ver las partidas de otro usuario"
    erb :error
  end
end

#Ver partida
get '/players/:id/games/:idpartida' do
  erb :index unless login?
  part= Partida.find_by(id: params[:idpartida])
  if part.tipo_tablero == 5
    @nums = [nil,"1","2","3","4","5"]
    @letras = [nil,"A","B","C","D","E"] 

  else
    if part.tipo_tablero == 10
      @nums = [nil,"1","2","3","4","5","6","7","8","9","10"]
      @letras = [nil,"A","B","C","D","E","F","G","H","I","J"]   
    else
      @nums = [nil,"1","2","3","4","5","6","7","8","9","10","11","12","13","14","15"]
      @letras = [nil,"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O"] 
    end
  end
  #Obtener barcos aliados
  #tabl= Tablero.where("partidaid =? AND userid =? " , params[:idpartida] , userid)
  tabl=Tablero.find_by(partidaid: part.id.to_s, userid: userid)
 
  @res=Barco.where("tableroid =?", tabl.id.to_s)
  #Rival
  if params[:id] == part.userid
    @rival = part.jugador2_id
  else
    @rival = part.userid
  end
  #proximo turno
  if part.proxturno == userid
    tablrival=Tablero.find_by(partidaid: part.id.to_s, userid: @rival)
    #No lo dejo jugar si el rival no tiene tablero establecido
    if tablrival.nil? 
      @permitir = true
    else
      @permitir = false
    end
  else
    @permitir = true
  end
  
  if part.finalizado == 'Y'
    @fin = 'Y'
  else
    @fin='N'
  end
  @partid=part.id.to_s
  #Obtener movimientos
  tabl2 = Tablero.find_by(partidaid: part.id.to_s, userid: @rival)
  if !(tabl2.nil?)
    @mov=Movimiento.where("tableroid =?",  tabl2.id.to_s)
  else 
    @mov=nil
  end
  haml :playing
  
end

post '/players/:id/games/:idpartida/move' do
  erb :index unless login?
  tab1 = Tablero.find_by(partidaid: params[:idpartida], userid: params[:id])
  part = Partida.find_by(id: tab1.partidaid.to_s)
  if part.jugador2_id == params[:id]
    rivalid = part.userid
  else
    rivalid = part.jugador2_id
  end
  tabrival = Tablero.find_by(partidaid: params[:idpartida], userid: rivalid)
  barco = Barco.find_by(tableroid: tabrival.id.to_s, coordenadas: params[:seleccion])
  estado = 0
  if !(barco.nil?)
    estado = 1
    barco.update(estado: 1)
  end
  Movimiento.create(tableroid: tabrival.id.to_s, coordenadas: params[:seleccion], estado: estado)
  #Fin de la partida
  movFinal=Movimiento.where(tableroid: tabrival.id.to_s, estado: 1).count
  case part.tipo_tablero
  when 5
     if movFinal == 7 
        part.update(proxturno: "", finalizado: 'Y', comienzo: userid)
        redirect 'home'
     end
  when 10
     if movFinal == 15
        part.update(proxturno: "", finalizado: 'Y' , comienzo: userid)
        redirect 'home'
     end
  else
   if movFinal == 20 
        part.update(proxturno: "", finalizado: 'Y' , comienzo: userid)
        redirect 'home'
     end
  end

  if estado == 1 then
     if part.tipo_tablero == 5
        @nums = [nil,"1","2","3","4","5"]
        @letras = [nil,"A","B","C","D","E"] 

      else
        if part.tipo_tablero == 10
          @nums = [nil,"1","2","3","4","5","6","7","8","9","10"]
          @letras = [nil,"A","B","C","D","E","F","G","H","I","J"]   
        else
          @nums = [nil,"1","2","3","4","5","6","7","8","9","10","11","12","13","14","15"]
          @letras = [nil,"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O"] 
        end
      end
      @mov=Movimiento.where("tableroid =?",  tabrival.id.to_s)
      @res=Barco.where("tableroid =?", tab1.id.to_s)
      @partid=part.id.to_s
      @rival=rivalid
      haml :playing
  else
    part.update(proxturno: rivalid)
   @title= "Move error"
   @error= "Turn invalid"
   status 403
   @status= status
   erb :error
  end
end 