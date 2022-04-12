#include "../fs/operations.h"
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <pthread.h>


#define COUNT 80
#define SIZE 256
#define THREADS 2

int fd;
char *str_A = "A";
char *str_B = "B";

/*Acesso ao mesmo ficheiro para dar append de conteudo*/

struct Args {
    char *name;
    int flag;
};

void *open_file_1(void *arguments){
    struct Args *args = (struct Args*)arguments;   
    ssize_t r;

    int fd_append = tfs_open((*args).name, (*args).flag);
    assert(fd_append != -1);

    assert(fd != fd_append);

    r = tfs_write(fd_append, str_A, strlen(str_A));
    assert(r == strlen(str_A));

    assert(tfs_close(fd_append) != -1);  
    
    return NULL;
}

void *open_file_2(void *arguments){
    struct Args *args = (struct Args*)arguments;
    ssize_t r;

    int fd_append = tfs_open((*args).name, (*args).flag);
    assert(fd_append != -1);

    assert(fd != fd_append);

    r = tfs_write(fd_append, str_B, strlen(str_B));
    assert(r == strlen(str_B));

    assert(tfs_close(fd_append) != -1);  
    
    return NULL;
}

/*Opens the same files to append stuff*/
int main() {
    struct Args *arguments_file_1 = malloc(sizeof(*arguments_file_1));
    struct Args *arguments_file_2 = malloc(sizeof(*arguments_file_2));
    pthread_t tid[THREADS];
    char *path = "/f1";
    ssize_t r;
    int buffer[10];

    assert(tfs_init() != -1);

    fd = tfs_open(path, TFS_O_CREAT);
    //printf("fd=%d\n", fd);
    assert(fd != -1);

    (*arguments_file_1).name = malloc(strlen(path)+1);
    (*arguments_file_2).name = malloc(strlen(path)+1);
    memcpy((*arguments_file_1).name, path, strlen(path));
    memcpy((*arguments_file_2).name, path, strlen(path));
    (*arguments_file_1).flag = TFS_O_APPEND;
    (*arguments_file_2).flag = TFS_O_APPEND;

 

    assert(pthread_create(&tid[0], NULL, open_file_1, (void*)arguments_file_1) == 0);
    assert(pthread_create(&tid[1], NULL, open_file_2, (void*)arguments_file_2) == 0);

    for (int i = 0; i < THREADS; i++){
        assert(pthread_join(tid[i], NULL) == 0);
    }

    /*File must have the same f_handle*/
    //assert(fd != fd_append);
    //assert(fd == fd_2);
    
    r = tfs_read(fd, buffer, sizeof(buffer) - 1);
    size_t aux = strlen(str_A) + strlen(str_B);
    assert(r == (ssize_t)aux);

    assert(tfs_close(fd) != -1);    

    
    free(arguments_file_1);
    free(arguments_file_2);
    
    return 0;
}