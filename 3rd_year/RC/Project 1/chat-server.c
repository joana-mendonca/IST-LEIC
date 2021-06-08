#include <arpa/inet.h>
#include <errno.h>
#include <net/if.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

#define BUFFER_SIZE 4097
#define MAX_SIZE 32768

void broadcast(char *message, int nfd, int not_this);

struct sockaddr_in **clientsList;
int no_clientsList = 0;

int main(int argc, char const *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Format invalid. Please use the following syntax:\n./chat-server port\n");
        exit(1);
    }

    char buffer[BUFFER_SIZE], send_buffer[BUFFER_SIZE];
    struct sockaddr_in server_addr;
    struct sockaddr_in addr_aux;
    /*struct ifreq ifr;*/

    fd_set fdset;

    int i,
        serverSocket,
        addr_len = sizeof(server_addr),
        ad,
        opt = 1,
        rn,
        fd_max = 0;

    clientsList = (struct sockaddr_in **) calloc(MAX_SIZE, sizeof(struct sockaddr_in *));

    /* creating socket */
    if ((serverSocket = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        fprintf(stderr, "Error creating socket: \"%s\"\nAborting...\n", strerror(errno));
        exit(1);
    }

    /* getting IP address of eth0 connection */
    /*ifr.ifr_addr.sa_family = AF_INET;
    strncpy(ifr.ifr_name, "eth0", IFNAMSIZ - 1);
    ioctl(serverSocket, SIOCGIFADDR, &ifr);*/

    /* initialize server address */
    /*memcpy(&server_addr, &ifr.ifr_addr, addr_len);*/
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(atoi(argv[1]));

    /*printf("%s\n", inet_ntoa(((struct sockaddr_in *)&server_addr)->sin_addr));*/

    /* avoid "address already in use" error */
    if (setsockopt(serverSocket, SOL_SOCKET, SO_REUSEADDR | SO_REUSEPORT, &opt, sizeof(opt))) { 
        fprintf(stderr, "Error binding server: \"%s\"\nAborting...\n", strerror(errno));
        exit(1); 
    }

    /* binding server to address */
    if (bind(serverSocket, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        fprintf(stderr, "Error binding server: \"%s\"\nAborting...\n", strerror(errno));
        exit(1);
    }

    /* setting server to listen */
    if (listen(serverSocket, 5) < 0) {
        fprintf(stderr, "Error setting server to listen: \"%s\"\nAborting...\n", strerror(errno));
        exit(1);
    }

    /* the server will listen through serverSocket and all connected clients */
    FD_ZERO(&fdset);
    while (1) {
        FD_SET(serverSocket, &fdset);
        fd_max = serverSocket;

        /* listens to all children already connected */
        for (i = 0; i < MAX_SIZE; i++) {
            if (clientsList[i] != NULL) {
                FD_SET(i, &fdset);
                if (fd_max < i) fd_max = i;
            }
        }

        while (select(fd_max + 1, &fdset, NULL, NULL, NULL) < 0) {
            /* if it was EINTR, probably was SIGCHLD, so it tries again */
            if (errno != EINTR) {
                fprintf(stderr, "Error with select: \"%s\"\nAborting...\n", strerror(errno));
                exit(1);
            }
        }

        /* read something from serverSocket - shall accept */
        if (FD_ISSET(serverSocket, &fdset)) {
            if ((ad = accept(serverSocket, (struct sockaddr *)&addr_aux, (socklen_t*)&addr_len)) < 0) {
                fprintf(stderr, "Error accepting connection: \"%s\"\nAborting...\n", strerror(errno));
                exit(1);
            }

            clientsList[ad] = (struct sockaddr_in *) malloc(sizeof(struct sockaddr_in));
            memcpy(clientsList[ad], &addr_aux, addr_len);

            sprintf(send_buffer, "%s:%d joined.\n", inet_ntoa((*clientsList[ad]).sin_addr), htons((*clientsList[ad]).sin_port));
            broadcast(send_buffer, fd_max + 1, -1);
        }

        /* read something from a connected client */
        else {
            for (i = 1; i < fd_max + 1; i++) {
                if (FD_ISSET(i, &fdset)) {
                    if ((rn = read(i, buffer, BUFFER_SIZE)) < 0) {
                        fprintf(stderr, "%d; Error reading: \"%s\"\nAborting...\n", i, strerror(errno));
                        exit(1);
                    }

                    if (rn == 0) {
                        sprintf(send_buffer, "%s:%d left.\n", inet_ntoa((*clientsList[i]).sin_addr), htons((*clientsList[i]).sin_port));
                        broadcast(send_buffer, fd_max, i);

                        close(i);
                        FD_CLR(i, &fdset);
                        clientsList[i] = NULL;
                    }

                    /*buffer[rn] = '\0';*/
                    else {
                        sprintf(send_buffer, "%s:%d %s", inet_ntoa((*clientsList[i]).sin_addr), htons((*clientsList[i]).sin_port), buffer);
                        broadcast(send_buffer, fd_max, i);
                    }
                }
            }
        }
    }

    return 0;
}

void broadcast(char *message, int nfd, int not_this) {
    int i;
    printf("%s", message);

    for (i = 0; i < nfd + 1; i++) {
        if (i == not_this) continue;
        if (clientsList[i] != NULL) {
            send(i, message, strlen(message), 0);
        }
    }
}