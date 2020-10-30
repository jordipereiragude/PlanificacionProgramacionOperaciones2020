#include <stdio.h>
#include <stdlib.h>

typedef struct instance
{
  int nt; //numero de tareas
  int c; //tiempo de ciclo
  int* d; //duración de las tareas
  //precedencias
  int** p; // p[i][j]=1 si la tarea i es predecesora de la j
  int** ip; // ip[i][0] indica el númeo de predecesoras inmediatas de la tarea i 
            // ip[i][j] indica la j-ésima predecesora inmediata de la tarea i
  int** is; // idem  pero con sucesoras
}instance;

typedef struct solucion
{
  int* asignacion; // asignacion[i], en qué estación se hace la tarea i
  int numEstaciones;
}solucion;

int readFile(instance* inst,char* nombre);
int greedy(instance* inst,solucion* s);
