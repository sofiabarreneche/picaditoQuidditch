class Equipo{
	var property jugadores = #{}
	var pelotas = #{}
	var puntosAFavor
	var tienenSnitch 
	var seguirJugando
	var puntosBloqueo
	var property promedio
	method jugadoresBlancoUtil(){
		jugadores.filter({unJugador => unJugador.esBlancoUtil()})
	}
	method ganarPuntosBloqueo(cant){
		puntosBloqueo += cant
	}
	method jugarContra(unEquipo){
		jugadores.all({unJugador => unJugador.jugar(unEquipo)})
	}						
	method jugadorEstrella(otroEquipo){
		jugadores.any({unJugador => unJugador.esEstrella(otroEquipo)})
	}
	method tenerSnitch(){
		tienenSnitch = true
		self.terminarPartido()
	}
	method terminarPartido(){
		seguirJugando = false			//medio rancio
	}
	method sumarPuntos(cant){
		puntosAFavor += cant
	}
	method lePasanElTrapo(otroJugador){
		jugadores.all({unJugador => otroJugador.lePasaElTrapo(unJugador)})
	}
}
class Jugador{
	var  skills
	var peso
	var escoba
	var nivelManejo
	var equipo
	var  tieneQuaffle
	
	method atraparQuaffle(){ 
		tieneQuaffle = true
	}
	method bloquearTiro(unEquipo){//la parte de bloquear tiro esta mal pero me harte :)
		unEquipo.jugadores().all({unJugador => unJugador.interrumpirTiro(unEquipo)})
		unEquipo.ganarPuntosBloqueo(10)
	}
	method interrumpirTiro(unEquipo){	//me maree demasiado con el de interrumpir tiro, preguntar si esta bien
		unEquipo.jugadores({unJugador => !unJugador.meterGol() and unJugador.modificarSkills(2)})			
		
	}
	method aumentarSkillsEn(cant){
		skills += cant
	}
	method modificarSkills(cant){
		skills -= cant
	}
	method esEstrella(otroEquipo){
		otroEquipo.lePasanElTrapo(self)
	}
	method lePasaElTrapo(jugador) =  self.habilidad() > jugador.habilidad()*2 
	method groso() = self.habilidad() > equipo.promedio() and self.velocidad() > escoba.valor()
	method habilidad(){
		return self.velocidad() + skills
	}
	method velocidad(){
		return escoba.velocidad()*nivelManejo
	}
	method meterPelota(pelota){
		pelota.anotarPunto(equipo)
	}
	method serGolpeado(){		
		skills -= 2
		escoba.golpearse()
	}
	method nivelManejoEscoba(){
		return skills/peso
	}
}

//Posiciones de cada Jugador
class Guardian inherits Jugador{
	method esBlancoUtil() = !tieneQuaffle
}
class Cazador inherits Jugador{
	var punteria
	var fuerza
	method esBlancoUtil() = tieneQuaffle
	method jugar(unEquipo){
		if(tieneQuaffle){
			self.intentarMeterGol(unEquipo)
		} self.perderQuaffle(unEquipo)
	}
	method intentarMeterGol(unEquipo){
		self.realizarTiro(unEquipo)
	}
	method realizarTiro(unEquipo){
		self.evitarBloqueos(unEquipo)
		
	}
	method meterGol(){
		equipo.sumarPuntos(10)
		skills += 5
		
	}
	override method serGolpeado(){
		super()
		tieneQuaffle = false
	}
	method perderQuaffle(unEquipo){
		tieneQuaffle = false
		var elMasRapidoContrincante = unEquipo.jugadores().max({unJugador => unJugador.velocidad()})
		elMasRapidoContrincante.atraparQuaffle()
	}
	method evitarBloqueos(unEquipo){
		if(unEquipo.jugadores({unJugador => !unJugador.bloquearTiro()})){
			self.meterGol()
		}
	}
	override method habilidad(){
		return (super() + punteria)* fuerza
	}
}
class Buscador inherits Jugador{
	var nombre
	var tieneSnitch
	var property nivelReflejos
	var nivelVision
	var turnos = 0
	var kmRecorridos
	var estaBuscandoSnitch
	method serGolpeado(){
		kmRecorridos = 0
	}
	method esBlancoUtil() = estaBuscandoSnitch or kmRecorridos >= 4000
	method jugar(unEquipo){
		self.realizarTarea()
	}
	override method habilidad(){
		return (super() + nivelReflejos)*nivelVision
	}
	method realizarTarea(){
	if(!tieneSnitch){
		self.buscarOAtraparSnitch()
		}	
	}
	method buscarSnitch(){
		estaBuscandoSnitch = true
		const random = (1..1000).anyOne()
		if(random < self.habilidad() + turnos) 
		self.perseguirSnitch()
	}
	method pasarTurnoDe() {
		turnos ++
		kmRecorridos += self.velocidad() / 1.6
	}
	
	method perseguirSnitch() {
		if(kmRecorridos >= 5000) {
			self.aumentarSkillsEn(10)
			equipo.sumarPuntos(150)
			tieneSnitch = true
		}
	}
	method buscarOAtraparSnitch(){
		if(tieneSnitch){
			snitch.anotarPunto(self)
		}else self.buscarSnitch() 
	}
	
}
class Golpeador inherits Jugador{
	var groso
	var punteria
	var fuerza
	method jugar(unEquipo){
		var victima = unEquipo.jugadoresBlancoUtil().any()
		if(punteria >victima.nivelReflejos()){
			self.golpear(victima)
			}
	}
	override method habilidad(){
		return super() + punteria + fuerza
	}
	method golpear(jugador){
		jugador.serGolpeado()
		skills += 1
	}
}
//Escobas
class Escoba{
	var property valor
	method mejoraMercado(){
		valor += 1
	}
	
}
object nimbus inherits Escoba{
	var aniosDesdeFabricacion
	var porcentajeSalud
	var property velocidad =(80- aniosDesdeFabricacion) * porcentajeSalud
	method golpearse(){
		porcentajeSalud -= 10
		
		}
}
object saetaDeFuego inherits Escoba{
	var property velocidad = 100
}

//Pelotas
object snitch{
	
	method anotarPunto(equipo){
		equipo.sumarPuntos(150)
		equipo.terminarPartido()
	}
}
object bludger{
	const cant = 2
	method anotarPunto(equipo){	}
}
object quaffle{
	const cant = 1
	method anotarPunto(equipo){
		equipo.sumarPuntos(10)
	}
}
