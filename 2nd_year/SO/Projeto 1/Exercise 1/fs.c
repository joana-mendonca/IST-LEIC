#include "fs.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <pthread.h>

pthread_mutex_t locker;
pthread_rwlock_t rwlock;

int obtainNewInumber(tecnicofs* fs){
	int newInumber = ++(fs->nextINumber);
	return newInumber;
}

tecnicofs* new_tecnicofs(){
	tecnicofs*fs = malloc(sizeof(tecnicofs));
	if (!fs) {
		perror("failed to allocate tecnicofs");
		exit(EXIT_FAILURE);
	}
	fs->bstRoot = NULL;
	fs->nextINumber = 0;
	return fs;
}

void free_tecnicofs(tecnicofs* fs){
	free_tree(fs->bstRoot);
	free(fs);
}


void create(tecnicofs* fs, char *name, int inumber){
	/*Fecha locker e fecha rwlock para escrita*/
	#ifdef MUTEX
    	pthread_mutex_lock(&locker);
  	#elif RWLOCK
    	pthread_rwlock_wrlock(&rwlock);
  	#endif
	fs->bstRoot = insert(fs->bstRoot, name, inumber);
	/*Abre trincos*/
	#ifdef MUTEX
    	pthread_mutex_unlock(&locker);
 	 #elif RWLOCK
    	pthread_rwlock_unlock(&rwlock);
	#endif
}

void delete(tecnicofs* fs, char *name){
	/*Fecha locker e fecha rwlock para escrita*/
	#ifdef MUTEX
    	pthread_mutex_lock(&locker);
  	#elif RWLOCK
    	pthread_rwlock_wrlock(&rwlock);
  	#endif
	fs->bstRoot = remove_item(fs->bstRoot, name);
	/*Abre trincos*/
	#ifdef MUTEX
    	pthread_mutex_unlock(&locker);
  	#elif RWLOCK
    	pthread_rwlock_unlock(&rwlock);
  	#endif
}

int lookup(tecnicofs* fs, char *name){
	/*Fecha locker e fecha rwlock para leitura*/
	#ifdef MUTEX
    	pthread_mutex_lock(&locker);
  	#elif RWLOCK
    	pthread_rwlock_rdlock(&rwlock);
  	#endif
	node* searchNode = search(fs->bstRoot, name);
	if ( searchNode ){
	/*Abre trincos*/
	#ifdef MUTEX
    	pthread_mutex_unlock(&locker);
  	#elif RWLOCK
    	pthread_rwlock_unlock(&rwlock);
  	#endif
	  return searchNode->inumber;
	
	}
	/*Abre trincos*/ 
	#ifdef MUTEX
    	pthread_mutex_unlock(&locker);
  	#elif RWLOCK
    	pthread_rwlock_unlock(&rwlock);
  	#endif

	return 0;
}



void print_tecnicofs_tree(FILE * fp, tecnicofs *fs){
	print_tree(fp, fs->bstRoot);
}
