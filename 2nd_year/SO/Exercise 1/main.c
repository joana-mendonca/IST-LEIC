#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <string.h>
#include <ctype.h>
#include <time.h>
#include <sys/time.h>
#include <pthread.h>
#include <unistd.h>
#include "fs.h"

#define MAX_COMMANDS 150000
#define MAX_INPUT_SIZE 100

tecnicofs *fs;

char inputCommands[MAX_COMMANDS][MAX_INPUT_SIZE];
int numberCommands = 0;
int headQueue = 0;
int numberThreads = 0;
pthread_mutex_t locker;


static void displayUsage(const char *appName) {
    printf("Usage: %s\n", appName);
    exit(EXIT_FAILURE);
}

static void parseArgs(long argc, char *const argv[]) {
    if (argc != 4) {
        fprintf(stderr, "Invalid format:\n");
        displayUsage(argv[0]);
    }
}

int insertCommand(char *data) {
    if (numberCommands != MAX_COMMANDS) {
        strcpy(inputCommands[numberCommands++], data);
        return 1;
    }
    return 0;
}

char *removeCommand() {
    if ((numberCommands > 0)) {
        numberCommands--;
        return inputCommands[headQueue++];
    }
    return NULL;
}

void errorParse() {
    fprintf(stderr, "Error: command invalid\n");
    exit(EXIT_FAILURE);
}

void processInput(char *const argv[]) {
    char line[MAX_INPUT_SIZE];
    FILE *fp;

    /*Abre ficheiro para leitura*/
    fp = fopen(argv[1], "r");
    if (fp == NULL) {
        perror("Error opening file");
        exit(-1);
    }

    while (fgets(line, sizeof(line) / sizeof(char), fp)) {
        char token;
        char name[MAX_INPUT_SIZE];

        int numTokens = sscanf(line, "%c %s", &token, name);

        /* perform minimal validation */
        if (numTokens < 1) {
            continue;
        }
        switch (token) {
	        case 'c':
	        case 'l':
	        case 'd':
	            if (numTokens != 2)
	                errorParse();
	            if (insertCommand(line))
	                break;
	            return;
	        case '#':
	            break;
	        default: { /* error */
	            errorParse();
	        }
        }
    }
    /*Fecha ficheiro*/
    fclose(fp);
}

void *applyCommands() {
    while(numberCommands > 0){
        const char* command = removeCommand();
        if (command == NULL) {
            continue;
        }

        char token;
        char name[MAX_INPUT_SIZE];
        int numTokens = sscanf(command, "%c %s", &token, name);
        if (numTokens != 2) {
            fprintf(stderr, "Error: invalid command in Queue\n");
            exit(EXIT_FAILURE);
        }

        int searchResult;
        int iNumber;
        switch (token) {
            case 'c':
                iNumber = obtainNewInumber(fs);
                create(fs, name, iNumber);
                break;
            case 'l':
                searchResult = lookup(fs, name);
                if(!searchResult)
                    printf("%s not found\n", name);
                else
                    printf("%s found with inumber %d\n", name, searchResult);
                break;
            case 'd':
                delete(fs, name);
                break;
            default: { /* error */
                fprintf(stderr, "Error: command to apply\n");
                exit(EXIT_FAILURE);
            }
        }
    }
    return 0;
}

int main(int argc, char *argv[]) {

    FILE *fp;
    struct timespec start, stop;
    double accum;
    //int ret1,ret2,ret3,ret4;

    parseArgs(argc, argv);

    /*Abre o ficheiro para escrita*/
    fp = fopen(argv[2], "w");
    /*Converte as tarefas do stdin para int*/
    numberThreads = atoi(argv[3]);
    
    fs = new_tecnicofs();
    processInput(argv);
    
    /*Inicializa a contagem do tempo*/
    if (clock_gettime(CLOCK_REALTIME, &start) == -1) {
        perror("clock gettime");
        exit(EXIT_FAILURE);
    }

    
    
    #if defined(MUTEX) || defined(RWLOCK)
        pthread_t tid[numberThreads];
        int i;

        /*ret1 = pthread_mutex_init(&locker, NULL);
        if (ret1 !=0)
        {
            perror("mutex badly initialized");
        }

        ret3 = pthread_rwlock_init(&rwlock,NULL);
        if (ret3 !=0)
        {
            perror("rwlock badly initialized");
        }*/

        /*Cria as tarefas*/
        for (i = 0; i < numberThreads; i++) {
            if (pthread_create(&tid[i], NULL, applyCommands, inputCommands[i]) != 0) {
            printf("Erro ao criar tarefa.\n");
            exit(1);
        	}
            /*printf("Lancou uma tarefa\n");*/
        }

        /*Suspende a execucao de uma tarefa chamada ate que a tarefa em acao termine a sua execucao*/
        for (i = 0; i < numberThreads; i++) {
            if (pthread_join(tid[i], NULL) != 0) {
            printf("Erro ao esperar por tarefa.\n");
            exit(1);
            }
            /*printf("Tarefa retornou\n");*/
        }
        /*ret2 = pthread_mutex_destroy(&locker);
        if (ret2 !=0)
        {
            perror("mutex badly destroyed");
        }

        ret3 = pthread_rwlock_init(&rwlock,NULL);
        if (ret4 !=0)
        {
            perror("rwlock badly destroyed");
        }*/
    #else
        applyCommands();
    #endif 
    
    print_tecnicofs_tree(fp, fs);
    
    /*Termina a contagem do tempo*/
    if (clock_gettime(CLOCK_REALTIME, &stop) == -1) {
        perror("clock gettime");
        exit(EXIT_FAILURE);
    }   
    accum = (stop.tv_sec - start.tv_sec) + (stop.tv_nsec - start.tv_nsec) / 1e6;
    printf("TecnicoFS completed in %0.4f seconds.\n", accum);

    /*Fecha ficheiro*/
    fclose(fp);
    free_tecnicofs(fs);
    exit(EXIT_SUCCESS);
}