#using JuMP, CPLEX
using JuMP, GLPK

function jobshop(n, m, p, r)
  #model = Model(CPLEX.Optimizer)
  model = Model(GLPK.Optimizer)
  set_optimizer_attribute(model, "msg_lev", GLPK.GLP_MSG_ALL)
  @variable(model,s[1:n,1:m]>=0)
  @variable(model,C>=0)
  @objective(model, Min, C)
  M=sum(p)
  #print(M,"\n")

  for i in 1:n
    for j in 1:m-1
      @constraint(model,s[i,j]+p[i,j]<=s[i,j+1])
    end
    @constraint(model,s[i,m]+p[i,m]<=C)
  end
  for i in 1:n
    for ii in i+1:n
      for j in 1:m
        for jj in 1:m
          if ruta[i,j]==ruta[ii,jj]
            z=@variable(model,base_name ="z_$(i)_$(ii)_$(j)",binary=true)
            @constraint(model,s[i,j]+p[i,j]-s[ii,jj]<=z*M)
            @constraint(model,s[ii,jj]+p[ii,jj]-s[i,j]<=(1-z)*M)
          end
        end
      end
    end
  end
  #println(model)
  optimize!(model)
  println("Objective: ",objective_value(model))
#  for i in 1:n
#    for j in 1:m
#      println(i,"\t",j,"\t",value(s[i,j]))
#    end
#  end
end



## leo archivo y guardo datos
f = open(ARGS[1], "r")
s = readlines(f)
print("filename:", s)
n=parse(Int,s[2])
m=parse(Int,s[4])
ruta=zeros(Int, n, m)
processing=zeros(Int,n,m)
print("número piezas ",n,"\nnúmero de máquinas ",m,"\n")
print("ruta:\n")
for i in 1:n
  divided=split(s[5+i])
  for j in 1:m
    ruta[i,j]=parse(Int,divided[j])
    print(ruta[i,j],"\t")
  end
  print("\n")
end
print("duraciones:\n")
for i in 1:n
  divided=split(s[6+n+i])
  for j in 1:m
    processing[i,j]=parse(Int,divided[j])
    print(processing[i,j],"\t")
  end
  print("\n")
end
close(f)
jobshop(n,m,processing,ruta)
