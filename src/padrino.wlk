class Mafioso {
	var salud = 4 
	const armas = [] 
	var property rango = soldado
	var property lealtad = 1
	
	// por defecto se inicializa en 4, que es la cantidad de heridas más frecuente que mata a un mafioso.
	// para personas mas resistentes, se instancia con otro valor
	
	//A) Durmiendo con los peces 
	method estaMuerto() = salud <= 0 
	
	method herir() {
		salud -= 1
	}
	method morir() {
		salud = 0
	}

	method acondicionarArmas(){
		armas.forEach{arma=>arma.acondicionar()}
	}
	
	method trabajar(victima){
		rango.hacerTrabajo(self,victima)
	}
	
	method intimidacion() = rango.intimidacion(self.intimidacionBase())
	
	method intimidacionBase() = armas.sum{arma=>arma.peligrosidad()}
	
	method armaAMano() = armas.first()
	method armaEnCondiciones() = armas.findOrDefault({arma=>arma.enCondiciones()},armas.anyOne())
	
	method reorganizarse() {
		const nuevoRango = rango.nuevoRango()
		if (armas.size() > 2)
			rango = nuevoRango
		self.acondicionarArmas()
		armas.add(new Revolver())
	}	
	
	// C) Ataque sorpresa
	method atacar(familia){
		self.trabajar(familia.masPeligroso())
	}
	method desarmar() {
		armas.clear()
	}
}


object soldado {
	
	method hacerTrabajo(atacante,victima){
		atacante.armaAMano().usarseEn(victima)
	}

	method nuevoRango() = new SubJefe()
	
	method intimidacion(base) = base
}

object don {
	
	method hacerTrabajo(atacante, victima) {
		victima.desarmar()
	}
	
	method nuevoRango() = throw new Exception(message = "¡Soy el don y sigo vivo! no se reorganicen...")
	
	method intimidacion(base) = base + 20
}

class SubJefe {
	
	method hacerTrabajo(atacante, victima) {
		atacante.armaEnCondiciones().usarseEn(victima)
	}
	
	method nuevoRango() = soldado
	
	method intimidacion(base) = base * 2
}

class Familia {
	
	const miembros = []
	
	// B) El mas peligroso!
	method masPeligroso() = self.miembrosVivos().max{m=>m.intimidacion()}
	
	method miembrosVivos() = miembros.filter{m=> not m.estaMuerto()}
	
	
	// D) Luto
	method luto(){
		self.miembrosVivos().forEach{m=>m.reorganizarse()}
		self.masPeligroso().rango(don)
	}

}

class Arma {
	method peligrosidad() =
		if (self.enCondiciones()) self.peligrosidadBase() else 1

	method enCondiciones()
	method peligrosidadBase()
}


class Revolver inherits Arma{
	var balas = 6
	
	method usarseEn(victima) {
		if (self.enCondiciones() ) {
			self.disparar(victima)
				balas -= 1
		}
	}
	method disparar(victima){
		victima.morir()
	}
	method acondicionar() {
		balas = 6
	}
	override method enCondiciones() = balas > 0
	override method peligrosidadBase() = balas * 2
}

class RevolverOxidado inherits Revolver {
	override method disparar(victima){
		if(self.balaMortal())
			victima.morir()
		else
			victima.herir()
	}
	method balaMortal() = [true,true,false].anyOne()
	//Hay muchas formas de hacerlo
	
	override method peligrosidadBase() = super()/2
}

class Daga inherits Arma {
	var property peligrosidadBase
	
	method usarseEn(victima) {
		victima.herir()
	}
	
	override method enCondiciones() = true
	method acondicionar() {}
}
	
class Cuerda inherits Arma{
	var property enCondiciones = true
	
	method usarseEn(victima) {
		if (enCondiciones) 
			victima.morir()
		else
			victima.herir()
	}
	
	method acondicionar() {
		enCondiciones = true
	}
	override method peligrosidadBase() = 5
	
}

