/* Sistemas Operativos, DEI/IST/ULisboa 2019-20 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <semaphore.h>
#include "fs.h"
#include "lib/hash.h"
#include "constants.h"
#include "lib/timer.h"
#include "sync.h"

char* global_inputFile = NULL;
char* global_outputFile = NULL;
int numberThreads = 0;
int numberBuckets = 0;

sem_t semProd;
sem_t semCons;
pthread_mutex_t commandsLock;
int prod = 0;
int cons = 0;

char inputCommands[MAX_COMMANDS][MAX_INPUT_SIZE]; /*buffer*/

hash_bst hashArray;

void* processInput();
void* applyCommands();
void insert_hash(char *name, int index);
void r_command(char *name, char *f2);

static void displayUsage (const char* appName){
    printf("Usage: %s input_filepath output_filepath threads_number\n", appName);
    exit(EXIT_FAILURE);
}

static void parseArgs (long argc, char* const argv[]){
    if (argc != 5) {
        fprintf(stderr, "Invalid format:\n");
        displayUsage(argv[0]);
    }

    global_inputFile = argv[1];
    global_outputFile = argv[2];
    numberThreads = atoi(argv[3]);
    numberBuckets = atoi(argv[4]);
    if (!numberThreads) {
        fprintf(stderr, "Invalid number of threads\n");
        displayUsage(argv[0]);
    }
}
/*Produce*/
int insertCommand(char* data) {	    
	sem_wait(&semProd);
	mutex_lock(&commandsLock);
    strcpy(inputCommands[prod], data);
    prod = (prod+1) % MAX_COMMANDS;
    mutex_unlock(&commandsLock);
    sem_post(&semCons);
    return 1;	    
}

/*Consume*/
char* removeCommand() {
	sem_wait(&semCons);
	mutex_lock(&commandsLock);
    char * command = inputCommands[cons];
    //numberCommands--;
    if (command[0] == 'z'){
    	sem_post(&semCons);
    	return command;
    }
    cons = (cons+1) % MAX_COMMANDS;
    sem_post(&semProd);

    return command;  
}

void errorParse(int lineNumber){
    fprintf(stderr, "Error: line %d invalid\n", lineNumber);
    exit(EXIT_FAILURE);
}

void* processInput(){
    FILE* inputFile;
    inputFile = fopen(global_inputFile, "r");
    if(!inputFile){
        fprintf(stderr, "Error: Could not read %s\n", global_inputFile);
        exit(EXIT_FAILURE);
    }
    char line[MAX_INPUT_SIZE];
    int lineNumber = 0;

    while (fgets(line, sizeof(line)/sizeof(char), inputFile)) {
        char token;
        char name[MAX_INPUT_SIZE];
        char f2[MAX_INPUT_SIZE];

        lineNumber++;

        int numTokens = sscanf(line, "%c %s %s", &token, name, f2);

        /* perform minimal validation */
        if (numTokens < 1) {
            continue;
        }
        switch (token) {
            case 'c':
            case 'l':
            case 'd':
                if(numTokens != 2)
                    errorParse(lineNumber);
                if(insertCommand(line))
                    break;
                return NULL;
            case 'r': 
                if(numTokens != 3)
                    errorParse(lineNumber);
                if(insertCommand(line))
                    break;
                return NULL;
            case '#':
                break;
            default: { /* error */
                errorParse(lineNumber);
            }
        }
    }
    /*z: condicao de paragem*/
    insertCommand("z");

	fclose(inputFile);
	return NULL;
}

FILE* openOutputFile() {
    FILE *fp;
    fp = fopen(global_outputFile, "w");
    if (fp == NULL) {
        perror("Error opening output file");
        exit(EXIT_FAILURE);
    }
    return fp;
}

void* applyCommands(){
    while(1){
        const char* command = removeCommand();
        if (command == NULL){
            mutex_unlock(&commandsLock);
            continue;
        }

        int index;
        char token;
        char name[MAX_INPUT_SIZE/2];
        char f2[MAX_INPUT_SIZE/2];

        sscanf(command, "%c %s %s", &token, name, f2);

        switch (token) {
        	case 'z':
        		mutex_unlock(&commandsLock);
        		return NULL;

            case 'c':
            	index = hash(name, numberBuckets);
                mutex_unlock(&commandsLock);
                insert_hash(name, index);
                break;
            
            case 'l':
                mutex_unlock(&commandsLock);
                index = hash(name, numberBuckets);
                if(hashArray[index].head != NULL){
	                int searchResult = lookup(hashArray[index].head, name);
	                if(!searchResult)
	                    printf("%s not found\n", name);
	                else
	                    printf("%s found with inumber %d\n", name, searchResult);
                }
                break;
            
            case 'd':
                mutex_unlock(&commandsLock);
                index = hash(name, numberBuckets);
                if(hashArray[index].head != NULL)
                	delete(hashArray[index].head, name);
                break;

            case 'r':            
            	mutex_unlock(&commandsLock);
                if(hashArray[index].head != NULL){
            		r_command(name, f2);
            	}
                break;
            default: { /* error */
                mutex_unlock(&commandsLock);
                fprintf(stderr, "Error: commands to apply\n");
                exit(EXIT_FAILURE);
            }
        }    
    }
    return NULL;
}

/***********************************************************************************************************************
 * Thread Function
 ***********************************************************************************************************************/
pthread_t* runThreads(FILE* timeFp){
    TIMER_T startTime, stopTime;

    #if defined (NOSYNC)
    	numberThreads = 1;
    #endif

    #if defined (RWLOCK) || defined (MUTEX) || defined (NOSYNC)
   		pthread_t* worker = (pthread_t*) malloc(sizeof(pthread_t));
    	pthread_t* workers = (pthread_t*) malloc((numberThreads) * sizeof(pthread_t));
    #endif

    TIMER_READ(startTime);

    /*Tarefa Master*/
    #if defined (RWLOCK) || defined (MUTEX) || defined (NOSYNC)
        int err = pthread_create(&worker[0], NULL, processInput, NULL);
        
        if (err != 0){
            perror("Can't create thread");
            exit(EXIT_FAILURE);
        }

    #else
        processInput();
    #endif

    /*Tarefas escravas*/
    #if defined (RWLOCK) || defined (MUTEX) || defined (NOSYNC)

        for(int i = 0; i < numberThreads; i++){
           	int err_2 = pthread_create(&workers[i], NULL, applyCommands, NULL);
           	if (err_2 != 0){
            	perror("Can't create thread");
            	exit(EXIT_FAILURE);
        	}
        }

        /*Join master*/
    	if(pthread_join(worker[0], NULL)) {
            perror("Can't join thread");
        }
        /*Join slaves*/
        for(int i = 0; i < numberThreads; i++) {
            //printf("Tarefa master joined.\n");
            if(pthread_join(workers[i], NULL)) {
                perror("Can't join thread");
            }
        }
    #else
        applyCommands();
    #endif

    TIMER_READ(stopTime);
    fprintf(timeFp, "TecnicoFS completed in %.4f seconds.\n", TIMER_DIFF_SECONDS(startTime, stopTime));

    #if defined (RWLOCK) || defined (MUTEX) || defined (NOSYNC)
    	free(worker);
        free(workers);
    #endif
    return NULL;
}

/***********************************************************************************************************************
 * Hash Functions
 ***********************************************************************************************************************/
void init() {
    hashArray = (hash_bst)malloc(sizeof(hash_bst) * numberBuckets);
    
    for(int i = 0; i < numberBuckets; i++){
        hashArray[i].head = malloc(sizeof(tecnicofs));
        hashArray[i].head = NULL;
    }
}

void insert_hash(char *name, int index) {
    int iNumber;
    tecnicofs *fs;

    if(hashArray[index].head == NULL){
        fs = new_tecnicofs();
        iNumber = obtainNewInumber(fs);
        hashArray[index].head = create(fs, name, iNumber);
    }
    else {
        iNumber = hashArray[index].head->nextINumber;
        hashArray[index].head = create(hashArray[index].head, name, iNumber);
    }
}

void display(FILE * fp) {
	for(int i = 0; i < numberBuckets; i++) {
		tecnicofs *tree = hashArray[i].head;
		if(tree == NULL)
			continue;
		else
			print_tecnicofs_tree(fp, tree);
	}
}

void free_hash() {
    for (int i = 0; i < numberBuckets; i++) {
    	if (hashArray[i].head == NULL) continue;
        free_tecnicofs(hashArray[i].head);
    }
}

/***********************************************************************************************************************
 * r_command : rename file
 ***********************************************************************************************************************/
void r_command(char *name, char *f2) {
	int index_f1 = hash(name, numberBuckets);
	int index_f2 = hash(f2, numberBuckets);
	int searchResult_f1 = lookup(hashArray[index_f1].head, name);
	int searchResult_f2 = lookup(hashArray[index_f2].head, f2);

	if(!searchResult_f1)
		printf("File %s doesn't exist.\n", name);
	else{
        /*rename*/
        if(!searchResult_f2){	                
        	delete(hashArray[index_f1].head, name);
        	insert_hash(f2, index_f2);
        }
        else
            printf("Unable to rename. File %s already exists.\n", f2);
    }
}

/***********************************************************************************************************************
 * Main
 ***********************************************************************************************************************/
int main(int argc, char* argv[]) {
    parseArgs(argc, argv);
    FILE * outputFp = openOutputFile();

    mutex_init(&commandsLock);
    sem_init(&semProd, 0, MAX_COMMANDS);
    sem_init(&semCons, 0, 0);

    init(); /*Initializes hashtable*/
    runThreads(stdout);
    display(outputFp); /*Prints trees from hash table*/
    fflush(outputFp);
    fclose(outputFp);

    mutex_destroy(&commandsLock);
    sem_destroy(&semProd);
    sem_destroy(&semCons);

    free_hash(hashArray);
    exit(EXIT_SUCCESS);
}
