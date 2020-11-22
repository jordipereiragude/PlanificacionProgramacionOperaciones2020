include("ulsp.jl")
Random.seed!(100003)

useCPLEX=0

periodos=10
ratioFijoVariable=250
mu=100
sigma=15
sinicial=0

periodos=parse(Int64,ARGS[1])
tipo=parse(Int64,ARGS[2])
precioFijo,precioStock,Demanda=generarInstancia(periodos,ratioFijoVariable,mu,sigma)
if tipo==1
  start=time()
  ulsp(periodos,precioFijo,precioStock,Demanda,sinicial,useCPLEX)
  println("tiempo modelo basico $periodos periodos: ",time()-start)
end
if tipo==2
  start=time()
  ulspAlt(periodos,precioFijo,precioStock,Demanda,sinicial,useCPLEX)
  println("tiempo modelo alternativo $periodos periodos: ",time()-start)
end
if tipo==3
  start=time()
  ulspAlt2(periodos,precioFijo,precioStock,Demanda,sinicial,useCPLEX)
  println("tiempo modelo alternativo2 $periodos periodos: ",time()-start)
end
