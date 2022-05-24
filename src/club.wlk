object municipio{
	const property clubes = #{}
	const property valorTope = 50000

	method addClub(club) {	clubes.add(club)	}	

	method club(socio) = clubes.find({club => club.socios().contains(socio)})

	method sancionar(club) { if(club.sancionable())  club.actividades().forEach({actividad => actividad.sancionar() })}

	method tranferir(jugador,equipoOrigen, equipoDestino) { 
		if(not self.esDestacado(jugador, equipoOrigen) and not self.equiposMismoClub(equipoOrigen, equipoDestino)){
			self.removerDeActividadesYEquiposA(jugador, equipoOrigen)
			self.agregar(jugador, equipoDestino)
			self.quitarSocioClub(jugador, equipoOrigen)
			self.agregarSocioClub(jugador, equipoDestino)
			jugador.partidos(0)
		}
	}
	
	method equiposMismoClub(equipoOrigen, equipoDestino) = clubes.any({club => club.tieneEste(equipoOrigen) and club.tieneEste(equipoDestino)})
	
	method removerDeActividadesYEquiposA(jugador, equipoOrigen) { self.clubPor(equipoOrigen).removerDetodasLasActividades(jugador)}
	
	method clubPor(equipo) = clubes.find({club => club.actividades().contains(equipo)})
	
	method agregar(jugador, equipoDestino) { equipoDestino.integrantes(jugador)	}
	
	method quitarSocioClub(jugador, equipoOrigen) { self.clubPor(equipoOrigen).remover(jugador)	}
	
	method agregarSocioClub(jugador, equipoDestino) { self.clubPor(equipoDestino).socios(jugador)	}
	
	method esDestacado(jugador, equipoOrigen) = equipoOrigen.destacado() === jugador	
}

class Club {
var property calidad = 0
const property socios = #{}
const property actividades = #{}
var property gastoMensual = 0

	method socios(socio){	socios.add(socio)}//if(not municipio.club(socio)) socios.add(socio)	}
   
	method socios() = socios	 //Saber todos los socios de un club
	
	method socioMasAntiguo() =	socios.max({socio => socio.antiguedad()})
	
	method sociosDestacados() = actividades.map({actividad => actividad.destacado()})   //esSocioOrganizador() or socio.esCapitan()})
	
	method sociosDestacadosYEstrellas() = self.sociosDestacados().filter({socio => self.esEstrella(socio)})
	
	method esEstrella(socio)
	
	method cantidadActividades(jugador) = actividades.count({actividad => actividad.participa(jugador)})	

	method sancionable() = self.socios().size() > 500
	
	method evaluar() = self.evaluacionBruta() / socios.size()
	
	method evaluacionBruta() = self.sumaEvaluacionesActividades()
	
	method sumaEvaluacionesActividades() = actividades.sum({actividad => actividad.evaluar()})
	
	method esPrestigioso() = actividades.any({actividad => actividad.prestigiosa()})
	
	method tieneEste(equipo) = actividades.contains(equipo)
	
	method actividadesQueParticipa(socio) = actividades.filter({actividad => actividad.participa(socio)})

	method removerDetodasLasActividades(socio) {self.actividadesQueParticipa(socio).forEach({actividad => actividad.remover(socio)})}//{ self.actividadesQueParticipa(socio).forEach({actividad => actividad.remover(socio)})}

	method remover(socio) { socios.remove(socio)}
}

class Tradicional inherits Club{
	override method esEstrella(jugador) =  jugador.superaValorDePase() or jugador.participaMucho()
	
	//override method evaluacionBruta() = self.sumaEvaluacionesActividades() - gastoMensual
	override method evaluacionBruta() = super() - gastoMensual
	
}
class Comunitario inherits Club{
	override method esEstrella(jugador) = jugador.participaMucho()	
	
	//override method evaluacionBruta() = self.sumaEvaluacionesActividades()
}
class Profesional inherits Club{
	override method esEstrella(jugador) = jugador.superaValorDePase()

	//override method evaluacionBruta() = 2 * self.sumaEvaluacionesActividades() - 5 * gastoMensual
	override method evaluacionBruta() = 2 * super() - 5 * gastoMensual
}

class Socio{
	var property antiguedad = 0
	
	method esEstrella() = antiguedad > 20
}

class Jugador inherits Socio{
	var property pase = 0
	var property partidos = 0
	
	override method esEstrella() = partidos >= 50 or self.club().esEstrella(self)

	method cantidadActividades() = self.club().cantidadActividades(self)
	
	method participaMucho() = self.cantidadActividades() >= 3
	
	method superaValorDePase() = pase > municipio.valorTope()
	
	method club() = municipio.club(self)
}

class Actividad{
	const property integrantes = #{}
	var property destacado
	
	method integrantes(socio){ integrantes.add(socio) }

	method todos() = integrantes	//todos los jugadores/socios de un equipo 
	
	method participa(socio) = integrantes.contains(socio)
	
	method sancionar()	
	
	method evaluar()
	
	method prestigiosa()
	
	method remover(socio) { integrantes.remove(socio)}
}

class Equipo inherits Actividad {
	
	var property cantidadSanciones = 0
	var property campeonatos = 0
	var property descuento = 20
	
	override method sancionar() { cantidadSanciones =+ 1 }

	method evaluar() =  self.puntosPorCampeonatos() + self.puntosPorIntegrantes() + self.puntosPorEstrellaDestacado() - self.puntosPorSanciones()
	
	method puntosPorCampeonatos() = campeonatos * 5
	method puntosPorIntegrantes() = 2 * integrantes.size()
	method puntosPorEstrellaDestacado() = (if(self.capitanEsEstrella()) 5 else 0)
	method puntosPorSanciones() = descuento * cantidadSanciones
	method capitanEsEstrella() =  destacado.esEstrella()
	
	method experimentado() = integrantes.all({integrante => integrante.partidos() >= 10})
	
	override method prestigiosa() = self.experimentado()
}

class Futbol inherits Equipo {
	
	override method descuento() = 30
		
	override method evaluar() = super() + 5 * self.cantidadDeEstrellasEquipo() - (10 * cantidadSanciones)  //.max(0)
	
	method cantidadDeEstrellasEquipo() = integrantes.count({ jugador => jugador.esEstrella()})
}

class ActividadSocial inherits Actividad{

	var property suspendida = false
	var property valor = 0

	override method sancionar() { suspendida = true	}

	method reanudar(){ suspendida = false}
	
	override method evaluar() = if(suspendida) 0 else valor
	
	override method prestigiosa() = self.muchosParticipantesEstrellas()

	method muchosParticipantesEstrellas() = integrantes.count({integrante => integrante.esEstrella()}) >= 5
}


