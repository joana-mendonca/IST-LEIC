#include <arpa/inet.h>
#include <errno.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>
#include <netdb.h>

#define BUFFER_SIZE 4097

int main(int argc, char const *argv[]) {
    if (argc < 3) {
        fprintf(stderr, "Format invalid. Please use the following syntax:\n./chat-client server_IP server_port\n");
        exit(1);
    }

    char buffer[BUFFER_SIZE];
    int clientSocket, rn;
    struct sockaddr_in server_addr;
    struct hostent *hostt;

    fd_set fdset;

    /* initialize server address */
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(atoi(argv[2]));

    if ((hostt = gethostbyname(argv[1])) == NULL) { 
        fprintf(stderr, "Error converting address: \"%s\"\nAborting...\n", strerror(errno));
        exit(1);
    }

    server_addr.sin_addr = *((struct in_addr *) hostt->h_addr);

    /* creating socket */
    if ((clientSocket = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        fprintf(stderr, "Error creating socket: \"%s\"\nAborting...\n", strerror(errno));
        exit(1);
    }

    /* connecting to server */
    if (connect(clientSocket, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        fprintf(stderr, "Error connection to server: \"%s\"\nAborting...\n", strerror(errno));
        exit(1);
    }

    /* now, the client will listen through stdin and clientSocket */
    FD_ZERO(&fdset);
    while (1) {
        FD_SET(0, &fdset);
        FD_SET(clientSocket, &fdset);
        select(clientSocket + 1, &fdset, NULL, NULL, NULL);

        if (FD_ISSET(0, &fdset)) {
            if (!fgets(buffer, BUFFER_SIZE, stdin)) {
                /* got a CTRL-D! */
                exit(0);
            }

            send(clientSocket, buffer, strlen(buffer) + 1, 0);
        }

        else if (FD_ISSET(clientSocket, &fdset)) {
            if (!(rn = read(clientSocket, buffer, BUFFER_SIZE))) {
                /* reads 0 bytes from clientSocket, therefore it was closed in the server */
                fprintf(stderr, "The server has been closed. Exiting.\n");
                break;
            }

            buffer[rn] = '\0';

            printf("%s", buffer);
        }
    }

    return 0;
}