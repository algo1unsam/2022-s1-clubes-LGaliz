object municipio{
    const clubs = []
   // method todosLosSocios() = 
}


class Club {
    var calidad = 0
    const property actividades = []
    var gastoMensual = 0
    const property socios = #{}

    method socios() = actividades.sum({actividad => actividad.todosLosMiembros()})

}

class Actividad {

    method evaluacion(){}
    method todosLosMiembros()
  
}
class Social inherits Actividad{
   const property integrantes = #{}
   var socioFundador

   override method todosLosMiembros() = integrantes

}

class Equipo inherits Actividad{
   const property integrantes = #{}
   var capitan

   override method todosLosMiembros() = integrantes
}

class Jugador {
    var pase =0
    var partidos =0

}

class Socio {
    var antiguedad =0
}






