/* Sistemas Operativos, DEI/IST/ULisboa 2019-20 */

#ifndef FS_H
#define FS_H
#include "lib/bst.h"
#include "lib/inodes.h"
#include "sync.h"


typedef struct openFiles {
	int inode;
	int estado; //0-fechado 1-aberto
	int mode;
    uid_t owner; //onde recebe o uid do owner
    permission ownerPermissions;
    permission othersPermissions;
} openFiles;


typedef struct tecnicofs {
    node* bstRoot;
    syncMech bstLock;
} tecnicofs;


typedef struct hash_bst {
	tecnicofs* head;
} *hash_bst;


//int obtainNewInumber(tecnicofs* fs);
tecnicofs* new_tecnicofs();
void free_tecnicofs(tecnicofs* fs);
tecnicofs* create(tecnicofs* fs, char *name, int inumber);
void delete(tecnicofs* fs, char *name);
int lookup(tecnicofs* fs, char *name);
void print_tecnicofs_tree(FILE * fp, tecnicofs *fs);

#endif /* FS_H */
