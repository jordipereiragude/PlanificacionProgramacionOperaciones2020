#vamos a imprimir el archivo (funciona en linux, en windows debería ejecutarse otra orden)
run(`cat ../instances/SAWYER30.IN2`)

using JuMP, CPLEX #CPLEX es el solver de IP de IBM.
#using JuMP, GLPK

## leo archivo y guardo datos
function readFile(filename)
    f = open(filename, "r") # "r" -> read
    s = readlines(f) #leer el archivo y guardarlo en la variable s
    nt=parse(Int,s[1]) #lee el número de tareas
    duracion=zeros(Int, nt) #crea vector de duraciones
    precedencias=zeros(Int,nt,nt) #crea vector de precedencias
    println("tareas ",nt)
    for i in 1:nt #para cada pieza
        duracion[i]=parse(Int,s[1+i])
    end
    println("duraciones",duracion)    
    c=1
    while true
        divided=split(s[nt+1+c],",")
        if parse(Int,divided[1])==(-1)
            break
        end
        precedencias[parse(Int,divided[1]),parse(Int,divided[2])]=1
        c+=1
    end
    println("precedencias",precedencias)
    close(f)
    return nt,duracion,precedencias
end


function salbp1(nt,c,duracion,precedencias)
    model = Model(CPLEX.Optimizer)
    #model=Model(GLPK.Optimizer)
    #set_optimizer_attribute(model,"msg_lev",GLPK.GLP_MSG_ALL)
    @variable(model,x[1:nt,1:nt],Bin) #tarea i en estación j
    @variable(model,y[1:nt],Bin) #Estación j
    #minimizar el número de estaciones
    @objective(model, Min, sum(y[i] for i in 1:nt))
    #asignar cada tarea
    @constraint(model,[i in 1:nt],
        sum(x[i,j] for j in 1:nt) == 1
    ) 
    #tiempo de ciclo
    @constraint(model,[j in 1:nt],
        sum(duracion[i]*x[i,j] for i in 1:nt) <= c*y[j]
    ) 
    #precedencias
    for i in 1:nt
        for j in 1:nt
            if precedencias[i,j]==1
                @constraint(model,
                    sum(k*x[i,k] for k in 1:nt) <= sum(k*x[j,k] for k in 1:nt)
                )
            end
        end
    end

    #println(model)
    optimize!(model)
    println("Objective: ",objective_value(model))
    for i in 1:nt
        println("y[$i] = ", JuMP.value(y[i]))
    end
end

nt,duracion,precedencias=readFile("../instances/SAWYER30.IN2")
for i in 25:40
  salbp1(nt,i,duracion,precedencias)
end



