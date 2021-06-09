/* Sistemas Operativos, DEI/IST/ULisboa 2019-20 */

#ifndef FS_H
#define FS_H
#include "lib/bst.h"
#include "sync.h"

typedef struct tecnicofs {
    node* bstRoot;
    int nextINumber;
    syncMech bstLock;

    //struct tecnicofs *next;
} tecnicofs;


typedef struct hash_bst {
	tecnicofs* head;
	//struct hash_bst *next;
} *hash_bst;

int obtainNewInumber(tecnicofs* fs);
tecnicofs* new_tecnicofs();
void free_tecnicofs(tecnicofs* fs);
tecnicofs* create(tecnicofs* fs, char *name, int inumber);
void delete(tecnicofs* fs, char *name);
int lookup(tecnicofs* fs, char *name);
void print_tecnicofs_tree(FILE * fp, tecnicofs *fs);

#endif /* FS_H */
