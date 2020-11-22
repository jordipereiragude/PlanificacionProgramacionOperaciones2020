using Random,JuMP,CPLEX,GLPK

function generarInstancia(periodos,ratioFijoVariable,mu,sigma)
    precioFijo=ratioFijoVariable
    precioStock=1
    d=mu.+randn(periodos).*sigma
    demanda=convert.(Int,round.(d,digits=0))
    #alternativamente:
    #demanda=zeros(Int,periodos)
    #for i in 1:periodos
    #    valor=round(d[i],digits=0)
    #    demanda[i]=convert(Int,d[i])
    #end
    return precioFijo,precioStock,demanda
end

function ulsp(n,K,h,d,s0,useCPLEX) #número de periodos, coste por pedido, coste de inventario, demanda, stock inicial
    if useCPLEX==1
        model = Model(CPLEX.Optimizer)
    else
        model=Model(GLPK.Optimizer)
        set_optimizer_attribute(model,"msg_lev",GLPK.GLP_MSG_ALL)
    end
    @variable(model,y[1:n],Bin) #si se compra
    @variable(model,x[1:n]>=0) #unidades compradas
    @variable(model,s[0:n]>=0) #unidades compradas
    M=sum(d)
    @objective(model, Min, K*sum(y[t] for t in 1:n)+h*sum(s[t] for t in 1:n)) #minimizo costes
    @constraint(model,s0==s[0]) #inventario inicial
    @constraint(model,[t in 1:n],s[t]==s[t-1]+x[t]-d[t]) #inventario
    @constraint(model,[t in 1:n],x[t]<=M*y[t]) #activación
    #println(model)
    optimize!(model)
    println("Objective: ",objective_value(model))
    for i in 1:n
        println("y[$i] = ", JuMP.value(y[i])) #sólo imprima variables de uso de estación
        println("s[$i] = ",JuMP.value(s[i]))
    end
end

function ulspAlt(n,K,h,d,s0,useCPLEX) #número de periodos, coste por pedido, coste de inventario, demanda, stock inicial
    if useCPLEX==1
        model = Model(CPLEX.Optimizer)
    else
        model=Model(GLPK.Optimizer)
        set_optimizer_attribute(model,"msg_lev",GLPK.GLP_MSG_ALL)
    end
    #definimos las variables
    @variable(model,y[1:n],Bin) #si se compra en el periodo i
    @variable(model,0<=x[1:n,1:n]<=1) #$x_{i,j}$  porcentaje de la demanda del periodo j
                                      # satisfecho por compras en el periodo i
    #eliminamos el stock inicial del problema, modificando la demanda
    for i in 1:n
        if d[i]>=s0
            d[i]-=s0
            s0=0
            break
        else
            s0-d[i]
            d[i]=0
        end
    end
    println(d)
    #creamos los costes de inventario asociados a cubrir parte de la demanda
    c = [0 for i in 1:n, j in 1:n]
    for i in 1:n
        for j in i+1:n
            c[i,j]=d[j]*(j-i)*h
        end
    end
    println(c,"\n\n\n")
    @objective(model, Min, K*sum(y[i] for i in 1:n)+sum(c[i,j]*x[i,j] for i in 1:n, j in i+1:n)) #minimizo costes
    #alternativamente
    #@objective(model,Min,K*sum(y[i] for i in 1:n)+sum( d[i]*h*(j-i)*x[i,j]  for i in 1:n, j in i+1:n))

    @constraint(model,[i in 1:n,j in i:n],x[i,j]<=y[i]) #asegurar condición de costes fijos
    @constraint(model,[j in 1:n],sum(x[i,j] for i in 1:j)==1) #asegurar satisfacción de la demanda del periodo j

    #println(model)
    optimize!(model)
    println("Objective: ",objective_value(model))
    for i in 1:n
        if(JuMP.value(y[i])==1)
            println("pido en el periodo $i")
            for j in i:n
                if (JuMP.value(x[i,j])>0)
                    println(" para periodos $j cantidad ",JuMP.value(x[i,j]))
                end
            end
        end
    end
end

function ulspAlt2(n,K,h,d,s0,useCPLEX) #número de periodos, coste por pedido, coste de inventario, demanda, stock inicial
    if useCPLEX==1
        model = Model(CPLEX.Optimizer)
    else
        model=Model(GLPK.Optimizer)
        set_optimizer_attribute(model,"msg_lev",GLPK.GLP_MSG_ALL)
    end
    #definimos las variables
    #@variable(model,0<=x[1:n,1:n+1]<=1) #si se compra en el periodo i para que nos quedemos sin en el periodo j
    @variable(model,x[1:n,1:n+1],Bin) #si se compra en el periodo i para que nos quedemos sin en el periodo j
    #eliminamos el stock inicial del problema, modificando la demanda
    for i in 1:n
        if d[i]>=s0
            d[i]-=s0
            s0=0
            break
        else
            s0-d[i]
            d[i]=0
        end
    end
    #println(d)
    #creamos los costes totales de cubrir la demanda de los periodos i,...,j-1
    c = [K for i in 1:n, j in 1:n+1]
    for i in 1:n
        for j in i+1:n
            for k in i+1:j
                c[i,j+1] += d[k]*(k-i)*h
            end
        end
    end
    #println(c)
    #alternativamente
    @objective(model,Min,+sum( c[i,j]*x[i,j]  for i in 1:n, j in i+1:n+1))

    @constraint(model,1 == sum(x[1,d] for d in 2:n+1)) #conservación de flujo (salida)
    @constraint(model,[i in 2:n],sum(x[o,i] for o in 1:i) == sum(x[i,d] for d in i+1:n+1)) #conservación de flujo
    @constraint(model,sum(x[i,n+1] for i in 1:n)==1) #conservación de flujo (llegada)

    #println(model)
    optimize!(model)
    println("Objective: ",objective_value(model))
    for i in 1:n
        for j in i:n+1
            if (JuMP.value(x[i,j])>0)
                println(" de $i a $j")
            end
        end
    end
end

