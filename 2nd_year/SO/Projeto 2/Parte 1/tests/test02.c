#include "fs/operations.h"
#include <assert.h>
#include <string.h>
#include <pthread.h>


char *path = "/f1";

void* open_and_close_1000000_times() {

    for (int i = 0; i < 1000000; i++) {
        int f = tfs_open(path, TFS_O_APPEND);
        assert(f != -1);

        assert(tfs_close(f) != -1);
    }

    return NULL;
}

int main(){


    assert(tfs_init() != -1);

    int f = tfs_open(path, TFS_O_CREAT);
    assert(f != -1);
    assert(tfs_close(f) != -1);


    pthread_t tid[2];

    if (pthread_create (&tid[0], NULL, open_and_close_1000000_times, NULL))
        exit(EXIT_FAILURE);
    if (pthread_create (&tid[1], NULL, open_and_close_1000000_times, NULL))
        exit(EXIT_FAILURE);

    for (int i = 0; i < 2; i++) {
        pthread_join(tid[i], NULL);
    }

    return 0;
}
