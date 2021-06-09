#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <signal.h>
#include "fs.h"
#include "lib/hash.h"
#include "constants.h"
#include "lib/timer.h"
#include "sync.h"

#define MAX_OPENFILE_SIZE 5
#define BUFFER_SIZE 400
#define CLIENT_NUMBER 50
#define TECNICOFS_FILE_COUNTER 50 //igual ao tamanho da tabela de inodes

char* global_outputFile = NULL;
char* socketName = NULL;
int numberBuckets = 0, fileNumber = 0;
int serverSocket, newSocketfd, file_counter = 0;
socklen_t cli_len, serv_len;
struct sockaddr_un end_client, end_server;

pthread_mutex_t commandsLock;

hash_bst hashArray;

void* runThread(struct ucred ucred);
int applyCommand(char *buffer, struct ucred ucred, openFiles *of);
int insert_hash(char *name, int index, int iNumber);
int verifyFileExistence(char *name);
int verifyOpenFilePermissions(openFiles *of, char *filename, int mode);
int verifyOpenFileMaxCapacity(openFiles *of);
void r_command(char *name, char *f2);
openFiles* new_openFiles();
void free_openFiles(openFiles* of);
FILE * openOutputFile(char* buffer);
void display(FILE * fp);

static void displayUsage (const char* appName){
    printf("Usage: %s input_filepath output_filepath threads_number\n", appName);
    exit(EXIT_FAILURE);
}

static void parseArgs (long argc, char* const argv[]){
    if (argc != 4) {
        fprintf(stderr, "Invalid format:\n");
        displayUsage(argv[0]);
    }

    socketName = argv[1];
    global_outputFile = argv[2];
    numberBuckets = atoi(argv[3]);
    if (!numberBuckets) {
        fprintf(stderr, "Invalid number of buckets\n");
        displayUsage(argv[0]);
    }
}

void errorParse(int lineNumber){
    fprintf(stderr, "Error: line %d invalid\n", lineNumber);
    exit(EXIT_FAILURE);
}

int applyCommand(char *buffer, struct ucred ucred, openFiles *of){
    int index = 0, iNumber = 0, err = 0,fd = 0, len_l = 0, number_charsRead = 0, len_w = 0, aux = 0;
    char token;
    char name[20], filenameOld[20], filenameNew[20], fileContent[20], file[20];
    unsigned int permission, ownerPermissions, othersPermissions;
    uid_t owner;

    sscanf(buffer, "%c %s %u", &token, name, &permission); //c, o
    sscanf(buffer, "%c %s %s", &token, filenameOld, filenameNew); //r
    sscanf(buffer, "%c %d %d", &token, &fd, &len_l); //l
    sscanf(buffer, "%c %d %s %d", &token, &fd, fileContent, &len_w); //w
    switch (token) {
    	/*Create file*/
        case 'c':
    		othersPermissions = (permission % 10);
    		ownerPermissions = (permission / 10);
            iNumber = inode_create(ucred.uid, ownerPermissions, othersPermissions);
            iNumber = insert_hash(name, index, iNumber);

			return iNumber;
        
		/*Delete file*/
        case 'd':
			iNumber = lookup(hashArray[index].head, name);
            /*Verifica a existencia de um ficheiro com o nome dado*/
			err = verifyFileExistence(name);
			if(err == 0)
				return -5;

			inode_get(iNumber, &owner, NULL, NULL, NULL, 0);
			if(owner != ucred.uid)
				return -6;
			
			
			for(int i = 0; i < MAX_OPENFILE_SIZE; i++){
				if(of[i].inode == iNumber){
					if(of[i].owner != ucred.uid){
						return -6;
					}
				}
			}

			/*Verifica se o ficheiro se encontra aberto*/
			for(int i = 0; i < MAX_OPENFILE_SIZE; i++){
				if(of[i].inode == iNumber){
					if(of[i].estado == 1){
						return -9;
					}
				}
			}

            //mutex_unlock(&commandsLock);
            if(hashArray[index].head != NULL) {
            	delete(hashArray[index].head, name);
				inode_delete(iNumber);
			}

			return 0;

		/*Read file*/
		case 'l':
		/*Verifica se file esta aberto*/
		if(of[fd].estado != 1)
			return -8;

		if(of[fd].ownerPermissions == 1)
			return -10;
		
		if(of[fd].mode == 1)
			return -10;

		iNumber = of[fd].inode;
		aux = inode_get(iNumber, NULL, NULL, NULL, file, 20);
		if(len_l > aux){
			return aux;
		}
		if(len_l < aux){
			return len_l-1;
		}
		number_charsRead = inode_get(iNumber, NULL, NULL, NULL, file, len_l);
		
		return number_charsRead;

		/*Open file*/
        case 'o':
        	iNumber = lookup(hashArray[index].head, name);

        	/*Verifica a existencia de um ficheiro com o nome dado*/
			err = verifyFileExistence(name);

			if(err == 0)
				return -5; 
			/*Verifica as permissoes do cliente*/  
			err = verifyOpenFilePermissions(of, name, permission);
			if(err == 1)
				return -6;
			/*Verifica se a capacidade max de of ja foi atingida*/	 
			err = verifyOpenFileMaxCapacity(of);
			if(err == 1)
				return -7;

			iNumber = lookup(hashArray[index].head, name);
			for(int i = 0; i < MAX_OPENFILE_SIZE; i++){
				if(of[i].inode == iNumber){
					of[i].estado = 1;
					of[i].mode = permission;

					return i;
				}
			}

		/*Rename file*/
        case 'r':            
        	iNumber = lookup(hashArray[index].head, filenameOld);
			inode_get(iNumber, &owner, NULL, NULL, NULL, 0);
        	/*mutex_unlock(&commandsLock);*/
        	err = verifyFileExistence(filenameNew);
        	if(err == 1)
        		return -4;

        	err = verifyFileExistence(filenameOld);
        	if(err == 0) {
        		return -5;
        	}

			if(owner != ucred.uid)
				return -6;


			/*Verifica se o ficheiro se encontra aberto*/
			for(int i = 0; i < MAX_OPENFILE_SIZE; i++){
				if(of[i].inode == iNumber){
					if(of[i].estado == 1)
						return -9;
				}
			}

            if(hashArray[index].head != NULL)
        		r_command(filenameOld, filenameNew);

            return 0;

        /*Write file*/
        case 'w':
        /*Verifica se file esta aberto*/
		if(of[fd].estado != 1)
			return -8;
		/*Verifica se o ficheiro foi aberto nestas permissoes*/
		if(of[fd].ownerPermissions == 2)
			return -10;
       
        iNumber = of[fd].inode;
        err = inode_set(iNumber, fileContent, len_w);
        return err;

        /*Close file*/
		case 'x':
			if(of[fd].estado != 1){
				return -8;
			}
			of[fd].estado = 0;
			return 0;

        default: { // error 
            /*mutex_unlock(&commandsLock);*/
            fprintf(stderr, "Error: commands to apply\n");
            exit(EXIT_FAILURE);
        }
    }    
    return 0;
}

/***********************************************************************************************************************
 *
 *
 *
 *
 *
 *                                  COMMAND FUNCTIONS
 *
 *
 *
 * 
 ***********************************************************************************************************************/


/***********************************************************************************************************************
 * Command a: Create file
 ***********************************************************************************************************************/
void init() {
    hashArray = (hash_bst)malloc(sizeof(hash_bst) * numberBuckets);
    
    for(int i = 0; i < numberBuckets; i++){
        hashArray[i].head = malloc(sizeof(tecnicofs));
        hashArray[i].head = NULL;
    }
}

int insert_hash(char *name, int index, int iNumber) {
    tecnicofs *fs;
    int i = 0;

    /*Verifica se ja existe um ficheiro com name*/
    i = verifyFileExistence(name);
    if(i == 1)
    	return -4;

    /*Insere tecnicofs na hash*/
    if(hashArray[index].head == NULL){
        fs = new_tecnicofs();
        hashArray[index].head = create(fs, name, iNumber);
    }
    else {
        hashArray[index].head = create(hashArray[index].head, name, iNumber);
    }
	
	return iNumber;
}

int verifyFileExistence(char *name){
	int i = 0, index = 0;
	if (hashArray[index].head != NULL) {
        i = lookup(hashArray[index].head, name);

        if(i != -1){
            /*perror("File already exists");*/
            return 1;
        }
        else
        	return 0;
    }
    return 0;
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
 * Command o: Open File Functions
 ***********************************************************************************************************************/
int verifyOpenFilePermissions(openFiles *of, char *filename, int mode) {
	int inumber = lookup(hashArray[0].head, filename);

	for(int i = 0; i < MAX_OPENFILE_SIZE; i++) {
		if(of[i].inode == inumber) {
			if(of[i].ownerPermissions != 3 && of[i].ownerPermissions != mode){
				return 1; /*Erro: owner nao tem permissoes*/
			}
		}		
	}
	return 0;
}

int verifyOpenFileMaxCapacity(openFiles *of) {
	if(of[4].inode != -1)
		return 1;
	return 0;
}

/***********************************************************************************************************************
 * Command r: rename file functions
 ***********************************************************************************************************************/
void r_command(char *name, char *f2) {
	int iNumber = lookup(hashArray[0].head, name);
                
	delete(hashArray[0].head, name);
	insert_hash(f2, 0, iNumber);
}

/***********************************************************************************************************************
 *
 *
 *
 *
 *                   
 *                                   CLIENTE CONNECTED
 *
 *
 *
 * 
 ***********************************************************************************************************************/
void* runThread(struct ucred ucred) {
	int rn = 0, wr = 0, count = 0, result = 0;
	char token;
    char name[50];

	char buffer[80];
	openFiles *of;
	unsigned int permission, ownerPermissions, othersPermissions;


	/*Initializes open files table*/
	of = new_openFiles();
	while(1) {
		/*Read something from client*/
		rn = read(newSocketfd, &buffer, sizeof(buffer)-1);
		if(rn < 0) {
			perror("Error reading from client.\n");
			exit(EXIT_FAILURE);
		}

    	sscanf(buffer, "%c %s %u", &token, name, &permission);

    	othersPermissions = (permission % 10);
    	ownerPermissions = (permission / 10);
		/*If it reads 0 characters, it recieved EOF. The client exits*/
		if (rn == 0) {
			// 
			result = 0;
			wr = write(newSocketfd, &result,sizeof(int));
			if(wr < 0) {
				perror("Error writting to client.\n");
				exit(EXIT_FAILURE);
			}
			//
			close(newSocketfd);
			free(of);
			return NULL;
		}
		else{
			/*Trata da mensagem do cliente (Tamanho maximo de files abertos: MAX_OPENFILE_SIZE=5=*/
			if(count < MAX_OPENFILE_SIZE) {
				if(strcmp(&token, "c") == 0){
					of[count].owner = ucred.uid;
					of[count].ownerPermissions = ownerPermissions;
					of[count].othersPermissions = othersPermissions;
					result = applyCommand(buffer, ucred, of);
					of[count].inode = result;				
					count++;
				}
				else{
					result = applyCommand(buffer, ucred, of);
				}
			}
			/* Caso ja contenha 5 ficheiros abertos, fica em espera
			else{
				wait(5);
			}
			*/

			/*Envia mensagem ao cliente*/
			wr = write(newSocketfd, &result,sizeof(int));
			if(wr < 0) {
				perror("Error writting to client.\n");
				exit(EXIT_FAILURE);
			}
		}
	}
    return NULL;
}

/***********************************************************************************************************************
 * Create open file
 ***********************************************************************************************************************/
openFiles* new_openFiles() {
	openFiles* of = malloc(MAX_OPENFILE_SIZE * sizeof(openFiles));

	if (!of) {
		perror("Failed to allocate openFile");
		exit(EXIT_FAILURE);
	}
	for(int i = 0; i < MAX_OPENFILE_SIZE; i++){
		of[i].inode = -1;
		of[i].estado = 0; 
		of[i].mode = 0;
	}
	return of;
}

/***********************************************************************************************************************
 * Output File
 ***********************************************************************************************************************/
FILE * openOutputFile(char * global_outputFile) {
    FILE *fp;
    fp = fopen(global_outputFile, "w");
    if (fp == NULL) {
        perror("Error opening output file");
        exit(EXIT_FAILURE);
    }
    return fp;
}


/***********************************************************************************************************************
 *
 *
 *
 *
 *                   
 *                                      SIGNAL
 *
 *
 *
 * 
 ***********************************************************************************************************************/
void ctrl_c() {
	char buffer[2];

	if(signal(SIGINT, ctrl_c) == SIG_ERR) {
		perror("Error creating signal handler");
		exit(1);
	}
	fgets(buffer, 2, stdin);
	if(buffer[0] == 's') exit(1);

}


/***********************************************************************************************************************
 *
 *
 *
 *
 *                   
 *                                      MAIN
 *
 *
 *
 * 
 ***********************************************************************************************************************/
int main(int argc, char* argv[]) {
	int err = 0, count = 0;
    socklen_t len;
	pthread_t* worker = (pthread_t*) malloc(CLIENT_NUMBER * sizeof(pthread_t));
	struct ucred ucred;
	TIMER_T startTime, stopTime;

    parseArgs(argc, argv);
    numberBuckets = 1;
    FILE * fp = openOutputFile(global_outputFile);
    mutex_init(&commandsLock);
    init(); /*Initializes hashtable*/
    inode_table_init();

    /*Creates socket stream*/
    if((serverSocket =  socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
        perror("Error creating stream server socket.\n");
        exit(1);        
    }

    /*Eliminates preexistant sockets*/
    unlink(socketName);

    bzero((char *)&end_server, sizeof(end_server));    

    /*Dados do socket cliente*/
    end_server.sun_family = AF_UNIX;
    /*strncpy(end_server.sun_path, "/tmp/", sizeof(end_server.sun_path));*/
    strcpy(end_server.sun_path, socketName);
    serv_len = strlen(end_server.sun_path) + sizeof(end_server.sun_family);


    /*Bind socket*/
    if(bind(serverSocket, (struct sockaddr *)&end_server, serv_len) < 0) {
        perror("Error on binding socket.\n");
        exit(1);
    }

    /*Setting server to listen*/
    if(listen(serverSocket, 5) < 0) {
        perror("Error setting server to listen.\n");
        exit(1);
    }

    while(1) {      
        cli_len = sizeof(end_client);
        len = sizeof(struct ucred);

        /*Connects client client socket*/
	    if((newSocketfd = accept(serverSocket, (struct sockaddr *)&end_client, &cli_len)) < 0) {
	        perror("Error accepting client.\n");
	        exit(1);
	    }
	
        /*Getsockopt: permite obter as credenciais do owner*/
	    if(getsockopt(newSocketfd, SOL_SOCKET, SO_PEERCRED, &ucred, &len) < 0){
	    	perror("Error getsockopt.\n");
	    	exit(EXIT_FAILURE);
	    }

	    TIMER_READ(startTime);

        if((err = pthread_create(&worker[count], NULL, runThread(ucred),  NULL)) < 0) {
        	perror("Can't create thread.\n");
        	exit(1);
        }

	    /*Install handler for the signal SIGINT*/
	    if(signal(SIGINT, ctrl_c) == SIG_ERR) {
	    	perror("Error creating signal handler.\n");
	    	exit(1);
	    }
	    else{
		    for(int i = 0; i < CLIENT_NUMBER; i++){
		        if(pthread_join(worker[i], NULL)){
		        	perror("Can't join thread.\n");
		        	exit(1);
		        }
	    	}
    		TIMER_READ(stopTime);
    		fprintf(stdout, "TecnicoFS completed in %.4f seconds.\n", TIMER_DIFF_SECONDS(startTime, stopTime));
    		free(worker);
        	exit(0);
    	}
        count++;
    }

   	display(fp);
    fflush(fp);
    fclose(fp);
    inode_table_destroy();
    mutex_destroy(&commandsLock);
    free_hash(hashArray);
    exit(EXIT_SUCCESS);
}
