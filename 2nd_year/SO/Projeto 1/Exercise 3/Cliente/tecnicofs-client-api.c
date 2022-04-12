#include <stdio.h> 
#include <stdlib.h>
#include <sys/socket.h> 
#include <arpa/inet.h> 
#include <unistd.h> 
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <assert.h>
#include "tecnicofs-api-constants.h"
#include "tecnicofs-client-api.h"

char buff[80];
int x;
int socketfd = -1;
socklen_t dim_serv;
struct sockaddr_un end_serv;

int tfsMount(char * address) {
    int err = 0;
    if((socketfd = socket(AF_UNIX,SOCK_STREAM,0)) < 0)
        return TECNICOFS_ERROR_OPEN_SESSION;

    /* Limpeza*/
    bzero((char*) &end_serv, sizeof(end_serv));

    /*Dados do socket String */
    end_serv.sun_family = AF_UNIX;
    //strncpy(end_serv.sun_path, "/tmp/", sizeof(end_serv.sun_path));
    strcpy(end_serv.sun_path, address);
    dim_serv = strlen(end_serv.sun_path) + sizeof(end_serv.sun_family);

    /*Estabelece uma ligação*/
    err = connect(socketfd,(struct sockaddr*) &end_serv, dim_serv);
    if (err < 0)
        return TECNICOFS_ERROR_CONNECTION_ERROR ;

    return 0;
}
int tfsUnmount(){
    int c;
    if (socketfd < 0)
        return TECNICOFS_ERROR_NO_OPEN_SESSION;
    c = close(socketfd);
    if(c != 0)
        return TECNICOFS_ERROR_OPEN_SESSION ;
    socketfd = -1;
    return 0;   
}

int tfsCreate(char *filename, permission ownerPermissions, permission othersPermissions) {
    int result = 0;

    if (socketfd < 0)
        return TECNICOFS_ERROR_NO_OPEN_SESSION;    
    
    sprintf(buff,"c %s %u%u", filename, ownerPermissions, othersPermissions);
    int w = write(socketfd,&buff,strlen(buff)+1);

    if (w != (strlen(buff)+1))
        perror("Error writting message to server.\n");

    int v = read(socketfd,&result,sizeof(int));

    if (result == -4)
        return TECNICOFS_ERROR_FILE_ALREADY_EXISTS;
    if (v < 0)
        perror("Error reading message from server.\n");
    return 0; 
}
int tfsDelete(char *filename){
    int result;

    if (socketfd < 0)
        return TECNICOFS_ERROR_NO_OPEN_SESSION;

    sprintf(buff,"d %s",filename); 

    int w = write(socketfd,&buff,strlen(buff)+1);
    if (w != strlen(buff)+1)
        perror("writting error");

    int v = read(socketfd,&result,sizeof(int));
    if (result == -5)
        return TECNICOFS_ERROR_FILE_NOT_FOUND;
    if (result == -6)
        return TECNICOFS_ERROR_PERMISSION_DENIED;
    if (result == -9)
        return TECNICOFS_ERROR_FILE_IS_OPEN;
    if ( v < 0)
        perror("reading error");

    return 0;
}
int tfsRename(char *filenameOld, char *filenameNew){
    int result;

    if (socketfd < 0)
        return TECNICOFS_ERROR_NO_OPEN_SESSION;

    sprintf(buff,"r %s %s",filenameOld, filenameNew);

    int w = write(socketfd,&buff,strlen(buff)+1);
    if (w != strlen(buff)+1)
        perror("writting error");

    int v = read(socketfd,&result,sizeof(int));
    if (result == -5)
        return TECNICOFS_ERROR_FILE_NOT_FOUND;
    if (result == -6)
        return TECNICOFS_ERROR_PERMISSION_DENIED;
    if (result == -4)
        return TECNICOFS_ERROR_FILE_ALREADY_EXISTS;
    if (result == -9)
        return TECNICOFS_ERROR_FILE_IS_OPEN;
    if (v < 0)
        perror("reading error");

    return 0;

}
int tfsOpen(char *filename, permission mode){
    int result;

    if (socketfd < 0)
        return TECNICOFS_ERROR_NO_OPEN_SESSION;

    sprintf(buff,"o %s %u",filename, mode);

    int w = write(socketfd,&buff,strlen(buff)+1);
    if (w != strlen(buff)+1)
        perror("writting error");

    int v = read(socketfd,&result,sizeof(int));

    if (result == -5)
        return TECNICOFS_ERROR_FILE_NOT_FOUND;
    if (result == -6)
        return TECNICOFS_ERROR_PERMISSION_DENIED;
    if (result == -7)
        return TECNICOFS_ERROR_MAXED_OPEN_FILES;
    if (v < 0)
        perror("reading error");
    return result;
}
int tfsClose(int fd){
    int result;

    if (socketfd < 0)
        return TECNICOFS_ERROR_NO_OPEN_SESSION;

    sprintf(buff,"x %d",fd);

    int w = write(socketfd,&buff,strlen(buff)+1);
    if (w != strlen(buff)+1)
        perror("writting error");

    int v = read(socketfd,&result,sizeof(int));
    if (result == -8)
        return TECNICOFS_ERROR_FILE_NOT_OPEN;
    if (v < 0)
        perror("reading error");

    return 0;
}
int tfsRead(int fd, char *buffer, int len){
    int result;

    if (socketfd < 0)
        return TECNICOFS_ERROR_NO_OPEN_SESSION;

    sprintf(buff,"l %d %d", fd, len);

    int w = write(socketfd, &buff,strlen(buff)+1);
    if (w != (strlen(buff)+1))
        perror("writting error");

    int v = read(socketfd,&result,sizeof(int));
    if(result == -8)
        return TECNICOFS_ERROR_FILE_NOT_OPEN;
    if(result == -10)
        return TECNICOFS_ERROR_INVALID_MODE;
    if (v < 0)
        perror("reading error");
    
    return result;
}
int tfsWrite(int fd, char *buffer, int len){
    int result;

    if (socketfd < 0)
        return TECNICOFS_ERROR_NO_OPEN_SESSION;

    sprintf(buff,"w %d %s %d",fd, buffer, len);

    int w = write(socketfd,buff,strlen(buff)+1);
    if (w != strlen(buff)+1)
        perror("writting error");

    int v = read(socketfd,&result,sizeof(int));
    if(result == -8)
        return TECNICOFS_ERROR_FILE_NOT_OPEN;
    if(result == -10)
        return TECNICOFS_ERROR_INVALID_MODE;

    if (v < 0)
        perror("reading error");

    return 0;
}

