#include "operations.h"
#include "common.h"

#define S 5

bool free_session[S];
int session_pipe[S];

int server_pipe;

int tfs_server_init() {
    
    for (int i = 0; i < S; i++)
        free_session[i] = true;
    
    for (int i = 0; i < S; i++)
        session_pipe[i] = -1;

    return 0;
}

int get_session_id(int client_pipe) {

    int i;
    for (i = 0; i < S; i++) {
        if (free_session[i] == true) {
            free_session[i] = false;
            break;
        }

        if (i == S - 1)
            return -1; // no sessions available
    }
    
    session_pipe[i] = client_pipe;

    return i;
}

int get_client_pipe(int session_id) {

    return session_pipe[session_id];
}

int close_session(int session_id) {

    free_session[session_id] = true;
    session_pipe[session_id] = -1;

    return 0;
}

int tfs_mount_server() {

    // read client pipe name from server pipe
    char client_pipe_path[40];
    ssize_t ret = read(server_pipe, client_pipe_path, 40);
    if (ret == 0) {
        // ret == 0 signals EOF
        fprintf(stderr, "[INFO]: pipe closed\n");
        return 0;
    } else if (ret == -1) {
        // ret == -1 signals error
        fprintf(stderr, "[ERR]: read failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    // open pipe for writting
    // this waits for someone to open it for reading
    int client_pipe = open(client_pipe_path, O_WRONLY);
    if (client_pipe == -1) {
        fprintf(stderr, "[ERR]: open failed: %s\n", strerror(errno));
        return -1;
    }

    int session_id = get_session_id(client_pipe);
    if (session_id < 0) {
        exit(EXIT_FAILURE);
    }

    printf("SESSION ID = %d\n", session_id);

    char encoded_session_id[sizeof(int)];
    encode_int(session_id, encoded_session_id);

    ret = write(client_pipe, encoded_session_id, sizeof(int));
    if (ret < 0) {
        fprintf(stderr, "[ERR]: write failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    return 0;
}

int tfs_unmount_server() {

    char encoded_session_id[sizeof(int)];
    ssize_t ret = read(server_pipe, encoded_session_id, sizeof(int));
    if (ret == 0) {
        // ret == 0 signals EOF
        fprintf(stderr, "[INFO]: pipe closed\n");
        return 0;
    } else if (ret == -1) {
        // ret == -1 signals error
        fprintf(stderr, "[ERR]: read failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    int session_id = decode_int(encoded_session_id);
    int client_pipe = get_client_pipe(session_id);

    // return 0
    char encoded_ret[sizeof(int)];
    encode_int(0, encoded_ret);

    ret = write(client_pipe, encoded_ret, sizeof(int));
    if (ret < 0) {
        fprintf(stderr, "[ERR]: write failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    close(client_pipe);

    close_session(session_id);

    return 0;
}

int tfs_open_server() {

    char encoded_session_id[sizeof(int)];
    ssize_t ret = read(server_pipe, encoded_session_id, sizeof(int));
    if (ret == 0) {
        // ret == 0 signals EOF
        fprintf(stderr, "[INFO]: pipe closed\n");
        return 0;
    } else if (ret == -1) {
        // ret == -1 signals error
        fprintf(stderr, "[ERR]: read failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    int session_id = decode_int(encoded_session_id);
    int client_pipe = get_client_pipe(session_id);

    char name[40];
    ret = read(server_pipe, name, 40);
    if (ret == 0) {
        // ret == 0 signals EOF
        fprintf(stderr, "[INFO]: pipe closed\n");
        return 0;
    } else if (ret == -1) {
        // ret == -1 signals error
        fprintf(stderr, "[ERR]: read failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    char encoded_flags[sizeof(int)];
    ret = read(server_pipe, encoded_flags, sizeof(int));
    if (ret == 0) {
        // ret == 0 signals EOF
        fprintf(stderr, "[INFO]: pipe closed\n");
        return 0;
    } else if (ret == -1) {
        // ret == -1 signals error
        fprintf(stderr, "[ERR]: read failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    int flags = decode_int(encoded_flags);

    ret = tfs_open(name, flags);

    char encoded_ret[sizeof(int)];
    encode_int((int)ret, encoded_ret);

    ret = write(client_pipe, encoded_ret, sizeof(int));
    if (ret < 0) {
        fprintf(stderr, "[ERR]: write failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    return 0;
}

int tfs_close_server() {

    char encoded_session_id[sizeof(int)];
    ssize_t ret = read(server_pipe, encoded_session_id, sizeof(int));
    if (ret == 0) {
        // ret == 0 signals EOF
        fprintf(stderr, "[INFO]: pipe closed\n");
        return 0;
    } else if (ret == -1) {
        // ret == -1 signals error
        fprintf(stderr, "[ERR]: read failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    int session_id = decode_int(encoded_session_id);
    int client_pipe = get_client_pipe(session_id);

    char encoded_fhandle[sizeof(int)];
    ret = read(server_pipe, encoded_fhandle, sizeof(int));
    if (ret == 0) {
        // ret == 0 signals EOF
        fprintf(stderr, "[INFO]: pipe closed\n");
        return 0;
    } else if (ret == -1) {
        // ret == -1 signals error
        fprintf(stderr, "[ERR]: read failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    int fhandle = decode_int(encoded_fhandle);

    ret = tfs_close(fhandle);
    
    char encoded_ret[sizeof(int)];
    encode_int((int)ret, encoded_ret);

    ret = write(client_pipe, encoded_ret, sizeof(int));
    if (ret < 0) {
        fprintf(stderr, "[ERR]: write failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    return 0;
}

int tfs_write_server() {

    char encoded_session_id[sizeof(int)];
    ssize_t ret = read(server_pipe, encoded_session_id, sizeof(int));
    if (ret == 0) {
        // ret == 0 signals EOF
        fprintf(stderr, "[INFO]: pipe closed\n");
        return 0;
    } else if (ret == -1) {
        // ret == -1 signals error
        fprintf(stderr, "[ERR]: read failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    int session_id = decode_int(encoded_session_id);
    int client_pipe = get_client_pipe(session_id);

    char encoded_fhandle[sizeof(int)];
    ret = read(server_pipe, encoded_fhandle, sizeof(int));
    if (ret == 0) {
        // ret == 0 signals EOF
        fprintf(stderr, "[INFO]: pipe closed\n");
        return 0;
    } else if (ret == -1) {
        // ret == -1 signals error
        fprintf(stderr, "[ERR]: read failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    int fhandle = decode_int(encoded_fhandle);

    char encoded_len[sizeof(int)];
    ret = read(server_pipe, encoded_len, sizeof(int));
    if (ret == 0) {
        // ret == 0 signals EOF
        fprintf(stderr, "[INFO]: pipe closed\n");
        return 0;
    } else if (ret == -1) {
        // ret == -1 signals error
        fprintf(stderr, "[ERR]: read failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    int len = decode_int(encoded_len);

    char buffer[len];
    ret = read(server_pipe, buffer, (size_t)len);
    if (ret == 0) {
        // ret == 0 signals EOF
        fprintf(stderr, "[INFO]: pipe closed\n");
        return 0;
    } else if (ret == -1) {
        // ret == -1 signals error
        fprintf(stderr, "[ERR]: read failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    ret = tfs_write(fhandle, buffer, (size_t)len);

    char encoded_ret[sizeof(int)];
    encode_int((int)ret, encoded_ret);

    ret = write(client_pipe, encoded_ret, sizeof(int));
    if (ret < 0) {
        fprintf(stderr, "[ERR]: write failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    return 0;
}

int tfs_read_server() {

    char encoded_session_id[sizeof(int)];
    ssize_t ret = read(server_pipe, encoded_session_id, sizeof(int));
    if (ret == 0) {
        // ret == 0 signals EOF
        fprintf(stderr, "[INFO]: pipe closed\n");
        return 0;
    } else if (ret == -1) {
        // ret == -1 signals error
        fprintf(stderr, "[ERR]: read failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    int session_id = decode_int(encoded_session_id);
    int client_pipe = get_client_pipe(session_id);

    char encoded_fhandle[sizeof(int)];
    ret = read(server_pipe, encoded_fhandle, sizeof(int));
    if (ret == 0) {
        // ret == 0 signals EOF
        fprintf(stderr, "[INFO]: pipe closed\n");
        return 0;
    } else if (ret == -1) {
        // ret == -1 signals error
        fprintf(stderr, "[ERR]: read failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    int fhandle = decode_int(encoded_fhandle);

    char encoded_len[sizeof(int)];
    ret = read(server_pipe, encoded_len, sizeof(int));
    if (ret == 0) {
        // ret == 0 signals EOF
        fprintf(stderr, "[INFO]: pipe closed\n");
        return 0;
    } else if (ret == -1) {
        // ret == -1 signals error
        fprintf(stderr, "[ERR]: read failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    int len = decode_int(encoded_len);

    char buffer[len];
    ret = tfs_read(fhandle, buffer, (size_t)len);
    
    char encoded_ret[sizeof(int)];
    encode_int((int)ret, encoded_ret);

    char msg[sizeof(int) + (size_t)ret];

    int current_byte = 0;
    compose_msg(msg, encoded_ret, current_byte, sizeof(int));
    current_byte += (int)sizeof(int);
    compose_msg(msg, buffer, current_byte, len);

    ret = write(client_pipe, msg, sizeof(int) + (size_t)ret);
    if (ret < 0) {
        fprintf(stderr, "[ERR]: write failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    return 0;
}

int tfs_saac_server() {

    char encoded_session_id[sizeof(int)];
    ssize_t ret = read(server_pipe, encoded_session_id, sizeof(int));
    if (ret == 0) {
        // ret == 0 signals EOF
        fprintf(stderr, "[INFO]: pipe closed\n");
        return 0;
    } else if (ret == -1) {
        // ret == -1 signals error
        fprintf(stderr, "[ERR]: read failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    int session_id = decode_int(encoded_session_id);
    int client_pipe = get_client_pipe(session_id);

    ret = tfs_destroy_after_all_closed();
    char encoded_ret[sizeof(int)];
    encode_int((int)ret, encoded_ret);

    ret = write(client_pipe, encoded_ret, sizeof(int));
    if (ret < 0) {
        fprintf(stderr, "[ERR]: write failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    return 0;
}

int main(int argc, char **argv) {

    if (argc < 2) {
        printf("Please specify the pathname of the server's pipe.\n");
        return 1;
    }

    char *pipename = argv[1];
    printf("Starting TecnicoFS server with pipe called %s\n", pipename);

    /* TO DO */
    assert(tfs_init() != -1);

    assert(tfs_server_init() != -1);

    // unlink and mkfifo
    if (make_pipe(pipename) != 0)
        exit(EXIT_FAILURE);

    // open pipe for reading
    // this waits for someone to open it for writting
    server_pipe = open(pipename, O_RDONLY);
    if (server_pipe == -1) {
        fprintf(stderr, "[ERR]: open failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    while (true) {

        // gets the OP_CODE
        char op_code;
        ssize_t ret = read(server_pipe, &op_code, sizeof(char));
        if (ret == 0) {
            // ret == 0 signals EOF
            continue;
            fprintf(stderr, "[INFO]: pipe closed\n");
            return 0;
        } else if (ret == -1) {
            // ret == -1 signals error
            fprintf(stderr, "[ERR]: read failed: %s\n", strerror(errno));
            exit(EXIT_FAILURE);
        }

        switch (op_code) {
            case '1': // tfs_mount
                if (tfs_mount_server() < 0)
                    exit(EXIT_FAILURE);
                break;
            case '2': // tfs_unmount
                if (tfs_unmount_server() < 0)
                    exit(EXIT_FAILURE);
                break;
            case '3': // tfs_open
                if (tfs_open_server() < 0)
                    exit(EXIT_FAILURE);
                break;
            case '4': // tfs_close
                if (tfs_close_server() < 0)
                    exit(EXIT_FAILURE);
                break;
            case '5': // tfs_write
                if (tfs_write_server() < 0)
                    exit(EXIT_FAILURE);
                break;
            case '6': // tfs_read
                if (tfs_read_server() < 0)
                    exit(EXIT_FAILURE);
                break;
            case '7': // tfs_shutdown_after_all_closed
                if (tfs_saac_server() < 0)
                    exit(EXIT_FAILURE);
                return 0;
            default:
                fprintf(stderr, "[ERR]: invalid OP_CODE: %s\n", strerror(errno));
                exit(EXIT_FAILURE);
        }
    }
}