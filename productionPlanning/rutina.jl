include("ulsp.jl")

Random.seed!(100003)
useCPLEX=0

periodos=10
ratioFijoVariable=250
mu=100
sigma=15
sinicial=0

for periodos in 10:20
  println("\n\nMirando solucion con $periodos")
  precioFijo,precioStock,Demanda=generarInstancia(periodos,ratioFijoVariable,mu,sigma)
  println("\n\n\n\t\tEMPEZAMOS modelo básico\n\n")
  start=time()
  ulsp(periodos,precioFijo,precioStock,Demanda,sinicial,useCPLEX)
  println("tiempo modelo basico $periodos periodos: ",time()-start)
#  println("\n\n\n\t\tEMPEZAMOS modelo Alternativo\n\n")
#  start=time()
#  ulspAlt(periodos,precioFijo,precioStock,Demanda,sinicial,useCPLEX)
#  println("tiempo modelo alternativo $periodos periodos: ",time()-start)
#  println("\n\n\n\t\tEMPEZAMOS modelo Alternativo2\n\n")
#  start=time()
#  ulspAlt2(periodos,precioFijo,precioStock,Demanda,sinicial,useCPLEX)
#  println("tiempo modelo alternativo2 $periodos periodos: ",time()-start)
end
