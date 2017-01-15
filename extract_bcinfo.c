#include "stdlib.h"
#include "stdio.h"
#include "stdint.h"
#include "string.h"

// luajit specific libraries for lj_bc_mode[]
#include "lj_bc.h"

// taken from host/buildvm.c to define bc_names[]
const char *const bc_names[] = {
#define BCNAME(name, ma, mb, mc, mt)       #name,
BCDEF(BCNAME)
#undef BCNAME
  NULL
};


/**
  * This prgram uses the constants defined in lj_bc.h to extract the
  * OPCode name and mode.
  * See lj_bc.h and jit/bc.lua (especially the bc_line function) on how to
  * determine if  the OPCode uses 8 bit b & c operands or
  * single 16 bit d operand.
  *
  * The information are outputed into a python script file with a single
  * array 'bcnames', which has tuple elements of type
  *
  * bc_names = [
  *   ...
  *   (OPCodeName, OPCodeMode),
  *   ...
  *   ]
  *
  * The first argument to the program determines the folder in which the
  * python script will be written (the name will always be bcinfo.py).
  * If now argument is given, the current working directory is used.
*/
int main(int argv, char* argc[]) {

  char* filename = "bcinfo.py";
  char* dirname;
  char* outputfileName;
  size_t len = strlen(filename);

  if (argv > 1) {
    len += strlen(argc[1]);
    dirname = argc[1];
  } else {
    len += strlen("./");
    dirname = "./";
  }

  len += 1;

  outputfileName = (char*) malloc(len * sizeof(char));
  outputfileName = strcat(outputfileName, dirname);
  outputfileName = strcat(outputfileName, filename);


  FILE *f = fopen(outputfileName, "wb");

  fprintf(f, "opcodes = [");


  int counter = 0;
  for (int i = 0; bc_names[i]; i++) {
    fprintf(f, "('%s', %hu),", bc_names[i], lj_bc_mode[i]);
    // printf("%s -> ", bc_names[i]);
    // printf("%hu\n", lj_bc_mode[i]);
    // printf("%xu\n", lj_bc_mode[i]);
    counter++;
  }

  fprintf(f, "]");

  fclose(f);

  printf("%i\n", counter);
  return 0;
}
