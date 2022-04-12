#include "tecnicofs_client_api.h"
#include "common.h"

char save_client_pipe_path[40];
int server_pipe, client_pipe, session_id;

void op_code_to_str(int op_code, char *op_code_str) {
    switch (op_code) {
        case 1:
            op_code_str[0] = '1';
            break;
        case 2:
            op_code_str[0] = '2';
            break;
        case 3:
            op_code_str[0] = '3';
            break;
        case 4:
            op_code_str[0] = '4';
            break;
        case 5:
            op_code_str[0] = '5';
            break;
        case 6:
            op_code_str[0] = '6';
            break;
        case 7:
            op_code_str[0] = '7';
            break;
        default:
            exit(EXIT_FAILURE);
    }
}

void format_string(char const *str, char *formatted_str) {
    int i;
    for (i = 0; str[i] != '\0'; i++)
        formatted_str[i] = str[i];

    for (; i < 40; i++) formatted_str[i] = '\0';
}

int tfs_mount(char const *client_pipe_path, char const *server_pipe_path) {
    /* TODO: Implement this */

    // unlink and mkfifo
    if (make_pipe(client_pipe_path) != 0)
        exit(EXIT_FAILURE);

    // open pipe for writting
    // this waits for someone to open it for reading
    server_pipe = open(server_pipe_path, O_WRONLY);
    if (server_pipe == -1) {
        fprintf(stderr, "[ERR]: open failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    // send request to server
    char msg[sizeof(char) + 40];
    
    char op_code[1];
    op_code_to_str(TFS_OP_CODE_MOUNT, op_code);

    // put '\0's in front of the client pipe path
    char client_pipe_path_formatted[40];
    format_string(client_pipe_path, client_pipe_path_formatted);
    
    int current_byte = 0;
    compose_msg(msg, op_code, current_byte, sizeof(char));
    current_byte += (int)sizeof(char);
    compose_msg(msg, client_pipe_path_formatted, current_byte, 40);

    // write in server pipe the message
    ssize_t ret = write(server_pipe, msg, 41);
    if (ret < 0) {
        fprintf(stderr, "[ERR]: write failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    // open client pipe for reading
    // this waits for someone to open it for writing
    client_pipe = open(client_pipe_path, O_RDONLY);
    if (client_pipe == -1) {
        fprintf(stderr, "[ERR]: open failed: %s\n", strerror(errno));
        return -1;
    }

    // get the encoded session id from the server
    char encoded_session_id[sizeof(int)];
    ret = read(client_pipe, encoded_session_id, sizeof(int));
    if (ret == 0) {
        // ret == 0 signals EOF
        fprintf(stderr, "[INFO]: pipe closed\n");
        return 0;
    } else if (ret == -1) {
        // ret == -1 signals error
        fprintf(stderr, "[ERR]: read failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    session_id = decode_int(encoded_session_id);
    strcpy(save_client_pipe_path, client_pipe_path);

    return 0;
}

int tfs_unmount() {
    /* TODO: Implement this */

    // send message to server
    char msg[sizeof(char) + sizeof(int)];    

    char op_code[1];
    op_code_to_str(TFS_OP_CODE_UNMOUNT, op_code);

    char encoded_session_id[sizeof(int)];
    encode_int(session_id, encoded_session_id);

    int current_byte = 0;
    compose_msg(msg, op_code, current_byte, sizeof(char));
    current_byte += (int)sizeof(char);
    compose_msg(msg, encoded_session_id, current_byte, sizeof(int));

    // write in server pipe the message
    ssize_t ret = write(server_pipe, msg, sizeof(char) + sizeof(int));
    if (ret < 0) {
        fprintf(stderr, "[ERR]: write failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    char encoded_ret[sizeof(int)];
    ret = read(client_pipe, encoded_ret, sizeof(int));
    if (ret == 0) {
        // ret == 0 signals EOF
        fprintf(stderr, "[INFO]: pipe closed\n");
        return 0;
    } else if (ret == -1) {
        // ret == -1 signals error
        fprintf(stderr, "[ERR]: read failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    ret = decode_int(encoded_ret);

    // close both named pipes
    close(server_pipe);
    close(client_pipe);

    // remove pipe if it does not exist
    if (unlink(save_client_pipe_path) != 0 && errno != ENOENT) {
        fprintf(stderr, "[ERR]: unlink(%s) failed: %s\n", save_client_pipe_path,
                strerror(errno));
        return -1;
    }

    return (int)ret;
}

int tfs_open(char const *name, int flags) {
    /* TODO: Implement this */

    // send message to server
    char msg[sizeof(char) + sizeof(int) + 40 + sizeof(int)];

    char op_code[1];
    op_code_to_str(TFS_OP_CODE_OPEN, op_code);

    char encoded_session_id[sizeof(int)];
    encode_int(session_id, encoded_session_id);

    // put '\0's in front of the client pipe path
    char name_formatted[40];
    format_string(name, name_formatted);

    char encoded_flags[sizeof(int)];
    encode_int(flags, encoded_flags);

    int current_byte = 0;
    compose_msg(msg, op_code, current_byte, sizeof(char));
    current_byte += (int)sizeof(char);
    compose_msg(msg, encoded_session_id, current_byte, sizeof(int));
    current_byte += (int)sizeof(int);
    compose_msg(msg, name_formatted, current_byte, 40);
    current_byte += 40;
    compose_msg(msg, encoded_flags, current_byte, sizeof(int));

    // write in server pipe the message
    ssize_t ret = write(server_pipe, msg, sizeof(char) + sizeof(int) + 40 + sizeof(int));
    if (ret < 0) {
        fprintf(stderr, "[ERR]: write failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    char encoded_ret[sizeof(int)];
    ret = read(client_pipe, encoded_ret, sizeof(int));
    if (ret == 0) {
        // ret == 0 signals EOF
        fprintf(stderr, "[INFO]: pipe closed\n");
        return 0;
    } else if (ret == -1) {
        // ret == -1 signals error
        fprintf(stderr, "[ERR]: read failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    ret = decode_int(encoded_ret);

    return (int)ret;
}

int tfs_close(int fhandle) {
    /* TODO: Implement this */

    // send message to server
    char msg[sizeof(char) + sizeof(int) + sizeof(int)];

    char op_code[1];
    op_code_to_str(TFS_OP_CODE_CLOSE, op_code);

    char encoded_session_id[sizeof(int)];
    encode_int(session_id, encoded_session_id);

    char encoded_fhandle[sizeof(int)];
    encode_int(fhandle, encoded_fhandle);

    int current_byte = 0;
    compose_msg(msg, op_code, current_byte, sizeof(char));
    current_byte += (int)sizeof(char);
    compose_msg(msg, encoded_session_id, current_byte, sizeof(int));
    current_byte += (int)sizeof(int);
    compose_msg(msg, encoded_fhandle, current_byte, sizeof(int));

    // write in server pipe the message
    ssize_t ret = write(server_pipe, msg, sizeof(char) + sizeof(int) + sizeof(int));
    if (ret < 0) {
        fprintf(stderr, "[ERR]: write failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    char encoded_ret[sizeof(int)];
    ret = read(client_pipe, encoded_ret, sizeof(int));
    if (ret == 0) {
        // ret == 0 signals EOF
        fprintf(stderr, "[INFO]: pipe closed\n");
        return 0;
    } else if (ret == -1) {
        // ret == -1 signals error
        fprintf(stderr, "[ERR]: read failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    ret = decode_int(encoded_ret);

    return (int)ret;
}

ssize_t tfs_write(int fhandle, void const *buffer, size_t len) {
    /* TODO: Implement this */

    // send message to server
    char msg[sizeof(char) + sizeof(int) + sizeof(int) + sizeof(int) + len];

    char op_code[1];
    op_code_to_str(TFS_OP_CODE_WRITE, op_code);

    char encoded_session_id[sizeof(int)];
    encode_int(session_id, encoded_session_id);

    char encoded_fhandle[sizeof(int)];
    encode_int(fhandle, encoded_fhandle);

    char encoded_len[sizeof(int)];
    encode_int((int)len, encoded_len);

    int current_byte = 0;
    compose_msg(msg, op_code, current_byte, sizeof(char));
    current_byte += (int)sizeof(char);
    compose_msg(msg, encoded_session_id, current_byte, sizeof(int));
    current_byte += (int)sizeof(int);
    compose_msg(msg, encoded_fhandle, current_byte, sizeof(int));
    current_byte += (int)sizeof(int);
    compose_msg(msg, encoded_len, current_byte, sizeof(int));
    current_byte += (int)sizeof(int);
    compose_msg(msg, buffer, current_byte, (int)len);

    // write in server pipe the message
    ssize_t ret = write(server_pipe, msg, sizeof(char) + sizeof(int) + sizeof(int) + sizeof(int) + len);
    if (ret < 0) {
        fprintf(stderr, "[ERR]: write failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    char encoded_ret[sizeof(int)];
    ret = read(client_pipe, encoded_ret, sizeof(int));
    if (ret == 0) {
        // ret == 0 signals EOF
        fprintf(stderr, "[INFO]: pipe closed\n");
        return 0;
    } else if (ret == -1) {
        // ret == -1 signals error
        fprintf(stderr, "[ERR]: read failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    ret = decode_int(encoded_ret);

    return ret;
}

ssize_t tfs_read(int fhandle, void *buffer, size_t len) {
    /* TODO: Implement this */

    // send message to server
    char msg[sizeof(char) + sizeof(int) + sizeof(int) + sizeof(int)];

    char op_code[1];
    op_code_to_str(TFS_OP_CODE_READ, op_code);

    char encoded_session_id[sizeof(int)];
    encode_int(session_id, encoded_session_id);

    char encoded_fhandle[sizeof(int)];
    encode_int(fhandle, encoded_fhandle);

    char encoded_len[sizeof(int)];
    encode_int((int)len, encoded_len);

    int current_byte = 0;
    compose_msg(msg, op_code, current_byte, sizeof(char));
    current_byte += (int)sizeof(char);
    compose_msg(msg, encoded_session_id, current_byte, sizeof(int));
    current_byte += (int)sizeof(int);
    compose_msg(msg, encoded_fhandle, current_byte, sizeof(int));
    current_byte += (int)sizeof(int);
    compose_msg(msg, encoded_len, current_byte, sizeof(int));

    // write in server pipe the message
    ssize_t ret = write(server_pipe, msg, sizeof(char) + sizeof(int) + sizeof(int) + sizeof(int));
    if (ret < 0) {
        fprintf(stderr, "[ERR]: write failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    char encoded_ret[sizeof(int)];
    ret = read(client_pipe, encoded_ret, sizeof(int));
    if (ret == 0) {
        // ret == 0 signals EOF
        fprintf(stderr, "[INFO]: pipe closed\n");
        return 0;
    } else if (ret == -1) {
        // ret == -1 signals error
        fprintf(stderr, "[ERR]: read failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    ret = decode_int(encoded_ret);

    if (ret > 0) {
        ssize_t ret2 = read(client_pipe, buffer, (size_t)ret);
        if (ret2 == 0) {
            // ret == 0 signals EOF
            fprintf(stderr, "[INFO]: pipe closed\n");
            return 0;
        } else if (ret2 == -1) {
            // ret == -1 signals error
            fprintf(stderr, "[ERR]: read failed: %s\n", strerror(errno));
            exit(EXIT_FAILURE);
        }
    }    

    return ret;
}

int tfs_shutdown_after_all_closed() {
    /* TODO: Implement this */

    // send message to server
    char msg[sizeof(char) + sizeof(int)];

    char op_code[1];
    op_code_to_str(TFS_OP_CODE_SHUTDOWN_AFTER_ALL_CLOSED, op_code);

    char encoded_session_id[sizeof(int)];
    encode_int(session_id, encoded_session_id);

    int current_byte = 0;
    compose_msg(msg, op_code, current_byte, sizeof(char));
    current_byte += (int)sizeof(char);
    compose_msg(msg, encoded_session_id, current_byte, sizeof(int));

    // write in server pipe the message
    ssize_t ret = write(server_pipe, msg, sizeof(char) + sizeof(int));
    if (ret < 0) {
        fprintf(stderr, "[ERR]: write failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    char encoded_ret[sizeof(int)];
    ret = read(client_pipe, encoded_ret, sizeof(int));
    if (ret == 0) {
        // ret == 0 signals EOF
        fprintf(stderr, "[INFO]: pipe closed\n");
        return 0;
    } else if (ret == -1) {
        // ret == -1 signals error
        fprintf(stderr, "[ERR]: read failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }

    ret = decode_int(encoded_ret);

    return (int)ret;
}
