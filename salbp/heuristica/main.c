#include <stdio.h>
#include <stdlib.h>
#include "utils.h"
#include "salbp.h"

/* cuando me refiero a inst tengo >
typedef struct instance
{
  int nt; //numero de tareas
  int c; //tiempo de ciclo
  int* d; //duración de las tareas -> equivalente a un vector (del que no sé el tamaño a priori)
  //precedencias
  int** p; // p[i][j]=1 si la tarea i es predecesora de la j -> equivalente a una matriz (de la que no sé el tamaño a priori)
  //matriz reducida con sólo las tareas que son precedentes (eliminando los ceros)
}instance;

typedef struct solucion
{
  int* asignacion; // asignacion[i], en qué estación se hace la tarea i
  int numEstaciones;
}solucion;
*/

int readFile(instance* inst,char* nombre)
{
  FILE* in;
  int d,d1;

  in=fopen(nombre,"rt");
  fscanf(in,"%d\n",&d);
  inst->nt=d;
  printf("el problema tiene %d tareas\n",inst->nt);
  inst->d=generateIntVector(inst->nt+1); //¿por qué uso +1 aquí? 0 a n-1
  inst->prioridad=generateIntVector(inst->nt+1); //¿por qué uso +1 aquí? 0 a n-1
  inst->p=generateIntMatrix(inst->nt+1,inst->nt+1);
  for(int i=1;i<=inst->nt;i++)
  {
    fscanf(in,"%d\n",&d);
    inst->d[i]=d;
  }
  for(int i=1;i<=inst->nt;i++)
  {
    printf("la tarea %d dura %d\n",i,inst->d[i]);
  }
  for(int i=1;i<=inst->nt;i++) //inicializo las precedencias  
  {
    for(int j=1;j<=inst->nt;j++)
    {
      inst->p[i][j]=0;
    }
  }
  //for(qué hacer al principio; qué desencadena el fin del for; qué hacer en cada paso por el for)
  //haga esto hasta el infinito
  for(;;)
  {
    fscanf(in,"%d,%d\n",&d,&d1);
    if(d==(-1)) break; //pero esto es lo que hace que salga
    //precedencias
    inst->p[d][d1]=1;
  } 
  for(int i=1;i<=inst->nt;i++)
  {
    printf("tarea %d es predecesora de: \t",i);
    for(int j=1;j<=inst->nt;j++)
    {
      if(inst->p[i][j]==1)
      {
        printf("%d ",j);
      }
    }
    printf("\n");
  }
  //inst->p[i][j] indica si i precede a j
  int cambio;
  do
  {
    cambio=0;
    for(int i=1;i<=inst->nt;i++) //amarillo
    {
      for(int j=1;j<=inst->nt;j++) //verde
      {
        if((i!=j)&&(inst->p[i][j]==1))
        {
          for(int k=1;k<=inst->nt;k++) //lila
          {
            if((i!=k)&&(j!=k)&&(inst->p[j][k]==1)&&(inst->p[i][k]==0)) //tengo que añadir una precedencia
            {
              inst->p[i][k]=1;
              cambio=1;
            }
          }
        }
      }
    }
  }while(cambio==1); //cambio igual a 1 quiere decir que he hecho algo
  printf("\nDespues de calcular transitive closure:\n");
  for(int i=1;i<=inst->nt;i++)
  {
    inst->prioridad[i]=d;
    printf("tarea %d es predecesora de: \t",i);
    for(int j=1;j<=inst->nt;j++)
    {
      if(inst->p[i][j]==1)
      {
        printf("%d ",j);
      }
    }
    printf("\n");
  }
  for(int i=1;i<=inst->nt;i++)
  {
    for(int j=1;j<=inst->nt;j++)
    {
      if(inst->p[i][j]==1)
      {
        inst->prioridad[i] += inst->d[j];
      }
    }
  }

  fclose(in);
  return(0);
}

//rutina que genera las soluciones de forma heurística
int greedy(instance* inst,solucion* s)
{
  int numTareasAsignadas=0;
  int tiempoLibreEstacionEnCurso;
  int estacionEnCurso;
  int precedentesPendientes[inst->nt+1];

  //inicializar el vector asignación
  s->asignacion=generateIntVector(inst->nt+1);
  for(int i=1;i<=inst->nt;i++) s->asignacion[i]=0;
  //inicializar estacion en curso
  estacionEnCurso=1;
  tiempoLibreEstacionEnCurso=inst->c;
  //inicializar precedentes pendientes
  for(int i=1;i<=inst->nt;i++)
  {
    precedentesPendientes[i]=0; //precedentesPendientes que permite verificar si puedo seleccionar la tarea
    for(int j=1;j<=inst->nt;j++)
    {
      precedentesPendientes[i] += inst->p[j][i]; 
    }
  }
  printf("\nPrecedentesPendientes:\n");
  for(int i=1;i<=inst->nt;i++)
  {
    printf("tarea %d precedentes pendientes %d\n",i,precedentesPendientes[i]); //número de precedentes pendientes
  }
  //comentarios de los pasos que voy a hacer
  //mientras tareas que no están asignadas a una estación
  while(numTareasAsignadas<inst->nt)
  {
    int tareaCandidata=0;
    int prioridadTareaCandidata=0;
    //buscar una tarea que cumpla las limitaciones de tiempo de trabajo Y que tenga a todas sus precedentes asignadas Y que no esté asignada a ninguna otra estacion
    //me quedo con la tarea que cumpla:
    //    Si cabe en la estación
    //    No quedan precedentes por hacer <-- ¡¡¡Importante porque yo no lo recalculo!!!
    //    No asignada (s->asignacion[i]==0)
    //    Entre todas las que cumplan las condiciones anteriores sólo quiero una (la que tenga mejor peso)
    for(int i=1;i<=inst->nt;i++)
    {
      if((tiempoLibreEstacionEnCurso>=inst->d[i])&&(precedentesPendientes[i]==0)&&(s->asignacion[i]==0)&&(inst->prioridad[i]>prioridadTareaCandidata))
      {
        tareaCandidata=i; //ahora mismo me quedo con la última que cumple (lo cual no es muy recomendable, trabajo pendiente) -> Nahmias
        prioridadTareaCandidata=inst->prioridad[i];
      }
    }
    if(tareaCandidata!=0) //Si existe -> asignar esa tarea a la estación en curso
    {
      //1. Tengo que asignar la tarea
      s->asignacion[tareaCandidata]=estacionEnCurso;
      //2. Tengo que actualizar el tiempo libre
      tiempoLibreEstacionEnCurso -= inst->d[tareaCandidata];
      //3. Tengo que actualizar las precedentesPendientes
      for(int j=1;j<=inst->nt;j++) //cuando he escogido una tarea
      {
        if(inst->p[tareaCandidata][j]==1) precedentesPendientes[j]--; //actualizo la suma
      }
      //4. He asignado una tarea más
      numTareasAsignadas++;
      printf("he escogido la tarea %d y la he asignado a la estacion %d, ha dejado tiempo libre %d\n",tareaCandidata,estacionEnCurso,tiempoLibreEstacionEnCurso);
    } 
    else //Si no existe -> tengo que "abrir" una nueva estación
    {
      estacionEnCurso++; //creo nueva estación
      tiempoLibreEstacionEnCurso=inst->c; //con tiempo libre completo
      printf("no cabía ninguna tarea en estación, he creado la estacion %d\n",estacionEnCurso);
    }
  }
  return(0);
}

int main(int argc, char* argv[]) //función principal
{
  instance instancia;
  solucion sol;

  if(argc<3)
  {
    printf("%s instancia tiempoCiclo\n",argv[0]);
    return(0);
  }
  readFile(&instancia,argv[1]);
  instancia.c=atoi(argv[2]);
  greedy(&instancia,&sol);

}
