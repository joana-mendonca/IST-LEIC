#include "fs/operations.h"
#include <assert.h>
#include <string.h>
#include <pthread.h>

#define N 100

char *str = "123456789\n";

void* write_str_N_times(void* arg) {

    int f = *((int*)arg);
    ssize_t r;

    for (int i = 0; i < N; i++) {
        r = tfs_write(f, str, strlen(str));
        assert(r == strlen(str));
    }

    return NULL;
}

void* nothing() {
    return NULL;
}

int main(){

    char *path = "/f1";
    char buffer[strlen(str) * 2 * N + 10];

    assert(tfs_init() != -1);

    int f = tfs_open(path, TFS_O_CREAT);
    assert(f != -1);
    assert(tfs_close(f) != -1);

    f = tfs_open(path, TFS_O_APPEND);
    assert(f != -1);

    pthread_t tid[2];
    if (pthread_create (&tid[0], NULL, write_str_N_times, (void*)&f) != 0)
        exit(EXIT_FAILURE);
    if (pthread_create (&tid[1], NULL, write_str_N_times, (void*)&f) != 0)
        exit(EXIT_FAILURE);

    for (int i = 0; i < 2; i++) {
        pthread_join(tid[i], NULL);
    }

    assert(tfs_close(f) != -1);



    f = tfs_open(path, 0);
    assert(f != -1);
    
    ssize_t r = tfs_read(f, buffer, sizeof(buffer) - 1);
    assert(r == strlen(str) * 2 * N);

    assert(tfs_close(f) != -1);

    return 0;
}
