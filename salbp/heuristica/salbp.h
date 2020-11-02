#include <stdio.h>
#include <stdlib.h>

typedef struct instance
{
  int nt; //numero de tareas
  int c; //tiempo de ciclo
  int* d; //duración de las tareas -> equivalente a un vector (del que no sé el tamaño a priori)
  //precedencias
  int** p; // p[i][j]=1 si la tarea i es predecesora de la j -> equivalente a una matriz (de la que no sé el tamaño a priori)
}instance;

typedef struct solucion
{
  int* asignacion; // asignacion[i], en qué estación se hace la tarea i
  int numEstaciones;
}solucion;

int readFile(instance* inst,char* nombre);
int greedy(instance* inst,solucion* s);
