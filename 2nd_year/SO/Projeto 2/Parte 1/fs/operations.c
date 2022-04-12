#include "operations.h"
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

pthread_mutex_t global_mutex;

int tfs_init() {

    /* initialize global mutex */
    if(pthread_mutex_init(&global_mutex, NULL) != 0)
        return -1;

    state_init();

    /* create root inode */
    int root = inode_create(T_DIRECTORY);
    if (root != ROOT_DIR_INUM) {
        return -1;
    }

    return 0;
}

int tfs_destroy() {
    if(pthread_mutex_destroy(&global_mutex) != 0)
    return -1;

    state_destroy();
    
    return 0;
}

static bool valid_pathname(char const *name) {
    return name != NULL && strlen(name) > 1 && name[0] == '/';
}


int tfs_lookup(char const *name) {
    if (!valid_pathname(name)) {
        return -1;
    }

    // skip the initial '/' character
    name++;

    return find_in_dir(ROOT_DIR_INUM, name);
}

int tfs_open(char const *name, int flags) {
    int inum;
    size_t offset;

    /* Checks if the path name is valid */
    if (!valid_pathname(name)) {
        return -1;
    }

    pthread_mutex_lock(&global_mutex);

    inum = tfs_lookup(name);
    if (inum >= 0) {
        /* The file already exists */
        inode_t *inode = inode_get(inum);
        if (inode == NULL) {
            pthread_mutex_unlock(&global_mutex);                
            return -1;
        }

        /* Trucate (if requested) */
        if (flags & TFS_O_TRUNC) {
            if (inode->i_size > 0) {

                /* Determine the current file block (1 to MAX_FILE_BLOCKS) */
                int current_file_block_size = ((int)inode->i_size / BLOCK_SIZE) + 1;

                /* Free the direct references */
                for (int i = 0; (i < 10) && (i < current_file_block_size); i++) {
                    if (data_block_free(inode->i_data_block[i]) == -1) {
                        pthread_mutex_unlock(&global_mutex);
                        return -1;
                    }
                }

                /* Deal with the indirect references */
                if (current_file_block_size > 10) {

                    /* Get the indirect references block */
                    void *indirect_refences_block = data_block_get(inode->i_data_block[10]);
                        if (indirect_refences_block == NULL) {
                            pthread_mutex_unlock(&global_mutex);
                            return -1;
                    }

                    int i_data_block;
                    for (int file_block = 12; file_block <= current_file_block_size; file_block++) {
                        /* Get the indirect reference from memory */
                        memcpy(&i_data_block, indirect_refences_block + (((size_t)file_block - 12) * sizeof(int)), sizeof(int));
                        
                        if (data_block_free(i_data_block) == -1) {
                            pthread_mutex_unlock(&global_mutex);
                            return -1;
                        }
                    }

                    /* Free the indirect reference */
                    if (data_block_free(inode->i_data_block[10]) == -1) {
                        pthread_mutex_unlock(&global_mutex);
                        return -1;
                    }
                }               

                inode->i_size = 0;
            }
        }
        /* Determine initial offset */
        if (flags & TFS_O_APPEND) {
            offset = inode->i_size;
        } else {
            offset = 0;
        }
    } else if (flags & TFS_O_CREAT) {
        /* The file doesn't exist; the flags specify that it should be created*/
        /* Create inode */
        inum = inode_create(T_FILE);
        if (inum == -1) {
            pthread_mutex_unlock(&global_mutex);
            return -1;
        }
        /* Add entry in the root directory */
        if (add_dir_entry(ROOT_DIR_INUM, inum, name + 1) == -1) {
            inode_delete(inum);
            pthread_mutex_unlock(&global_mutex);
            return -1;
        }
        offset = 0;
    } else {
        pthread_mutex_unlock(&global_mutex);
        return -1;
    }

    /* Finally, add entry to the open file table and
     * return the corresponding handle */
    int fhandle = add_to_open_file_table(inum, offset);

    pthread_mutex_unlock(&global_mutex);

    return fhandle;

    /* Note: for simplification, if file was created with TFS_O_CREAT and there
     * is an error adding an entry to the open file table, the file is not
     * opened but it remains created */
}


int tfs_close(int fhandle) {

    pthread_mutex_lock(&global_mutex);
    int r = remove_from_open_file_table(fhandle);
    pthread_mutex_unlock(&global_mutex);

    return r; 
}

ssize_t tfs_write(int fhandle, void const *buffer, size_t to_write) {
    pthread_mutex_lock(&global_mutex);

    open_file_entry_t *file = get_open_file_entry(fhandle);
    if (file == NULL) {
        pthread_mutex_unlock(&global_mutex);
        return -1;
    }

    /* From the open file table entry, we get the inode */
    inode_t *inode = inode_get(file->of_inumber);
    if (inode == NULL) {
        pthread_mutex_unlock(&global_mutex);
        return -1;
    }

    /* Keep the total to write in case we write in multiple data blocks */
    size_t total_to_write = to_write;
    size_t total_written = 0;

    /* Determine the current file block (1 to MAX_FILE_BLOCKS) */
    int current_file_block = ((int)file->of_offset / BLOCK_SIZE) + 1;

    while ((to_write > 0) && (current_file_block <= MAX_FILE_BLOCKS)) {
        /* Determine how many bytes to write */
        if (to_write + (file->of_offset % BLOCK_SIZE) > BLOCK_SIZE) {
            to_write = BLOCK_SIZE - (file->of_offset % BLOCK_SIZE);
        }

        /* Get the current i_data_block */
        int current_i_data_block;
        if (current_file_block <= 10){
            /* Deal with the DIRECT refences */

            if ((inode->i_size % BLOCK_SIZE == 0) && (inode->i_size == file->of_offset)) {
                /* Allocate new block */

                inode->i_data_block[current_file_block - 1] = data_block_alloc();
            }
            current_i_data_block = inode->i_data_block[current_file_block - 1];
        
        } else {
            /* Deal with the INDIRECT references */

            if (current_file_block == 11) {
                /* Allocate indirect references block */
                if (inode->i_data_block[current_file_block - 1] == 0) {
                    inode->i_data_block[current_file_block - 1] = data_block_alloc();
                    
                }
                current_file_block++;                    
            }

            /* Get the indirect references block */
            void *indirect_refences_block = data_block_get(inode->i_data_block[10]);
            if (indirect_refences_block == NULL) {
                pthread_mutex_unlock(&global_mutex);
                return -1;
            }

            if ((inode->i_size % BLOCK_SIZE == 0) && (inode->i_size == file->of_offset)) {
                /* Allocate new block and write the representative int in the right place */
                current_i_data_block = data_block_alloc();

                memcpy(indirect_refences_block + (((size_t)current_file_block - 12) * sizeof(int)), &current_i_data_block, sizeof(int));
            
            } else {
                /* Get the current i_data_block from memory */
                memcpy(&current_i_data_block, indirect_refences_block + (((size_t)current_file_block - 12) * sizeof(int)), sizeof(int));    
            }
        }

        void *block = data_block_get(current_i_data_block);
        if (block == NULL) {
            pthread_mutex_unlock(&global_mutex);
            return -1;
        }

        /* Perform the actual write */
        memcpy(block + file->of_offset % BLOCK_SIZE, buffer, to_write);

        /* The offset associated with the file handle is
         * incremented accordingly */
        file->of_offset += to_write;
        if (file->of_offset > inode->i_size) {
            inode->i_size = file->of_offset;
        }

        total_written += to_write;
        to_write = total_to_write - to_write;
        total_to_write = to_write;
        current_file_block++;
    }

    pthread_mutex_unlock(&global_mutex);
    return (ssize_t)total_written;
}


ssize_t tfs_read(int fhandle, void *buffer, size_t len) {
    pthread_mutex_lock(&global_mutex);

    open_file_entry_t *file = get_open_file_entry(fhandle);
    if (file == NULL) {
        pthread_mutex_unlock(&global_mutex);
        return -1;
    }

    /* From the open file table entry, we get the inode */
    inode_t *inode = inode_get(file->of_inumber);
    if (inode == NULL) {
        pthread_mutex_unlock(&global_mutex);
        return -1;
    }

    /* Determine how many bytes to read */
    size_t to_read = inode->i_size - file->of_offset;
    if (to_read > len) {
        to_read = len;
    }

    /* Keep the total to write in case we write in multiple data blocks */
    size_t total_to_read = to_read;
    size_t total_read = 0;

    /* Determine the current file block (1 to MAX_FILE_BLOCKS) */
    int current_file_block = ((int)file->of_offset / BLOCK_SIZE) + 1;

    while (to_read > 0) {
        /* Determine how many bytes to read again in case we read from multiple blocks */
        if (to_read + (file->of_offset % BLOCK_SIZE) > BLOCK_SIZE) {
            to_read = BLOCK_SIZE - (file->of_offset % BLOCK_SIZE);
        }

        /* Get the current i_data_block */
        int current_i_data_block;
        if (current_file_block <= 10){
            /* Deal with the DIRECT refences */

            current_i_data_block = inode->i_data_block[current_file_block - 1];

        } else {
            /* Deal with the INDIRECT references */

            if (current_file_block == 11) {
                current_file_block++;                    
            }

            /* Get the indirect references block */
            void *indirect_refences_block = data_block_get(inode->i_data_block[10]);
            if (indirect_refences_block == NULL) {
                pthread_mutex_unlock(&global_mutex);
                return -1;
            }

            /* Get the current i_data_block from memory */
            memcpy(&current_i_data_block, indirect_refences_block + (((size_t)current_file_block - 12) * sizeof(int)), sizeof(int));
        }
        
        void *block = data_block_get(current_i_data_block);
        if (block == NULL) {
            pthread_mutex_unlock(&global_mutex);
            return -1;
        }

        /* Perform the actual read */
        memcpy(buffer, block + file->of_offset % BLOCK_SIZE, to_read);
        /* The offset associated with the file handle is
         * incremented accordingly */
        file->of_offset += to_read;

        total_read += to_read;
        to_read = total_to_read - to_read;
        total_to_read = to_read;
        current_file_block++;
    }

    pthread_mutex_unlock(&global_mutex);
    return (ssize_t)total_read;
}

int tfs_copy_to_external_fs(char const *source_path, char const *dest_path) {
    pthread_mutex_lock(&global_mutex);

    FILE *pointer_dest;
    char buffer[BUFFER_SIZE];
    int handle_source;
    ssize_t bytes_read, bytes_written;

    /* Open source_path if it does exist */
    if ((handle_source = tfs_open(source_path, 0)) < 0) {
        pthread_mutex_unlock(&global_mutex);
        return -1;
    }

    /* Open dest_path to write if it does exist and create if it doesn't */
    if ((pointer_dest = fopen(dest_path, "w")) == NULL) {
        tfs_close(handle_source);
        pthread_mutex_unlock(&global_mutex);
        return -1;
    }

    /* Read BUFFER_SIZE bytes from source_path and write them in dest_path
     * while there are still some left to be read */
    do {
        bytes_read = tfs_read(handle_source, buffer, sizeof(buffer));
        if (bytes_read < 0) {
            tfs_close(handle_source);
            fclose(pointer_dest);
            pthread_mutex_unlock(&global_mutex);
            return -1;
        }
        
        bytes_written = (ssize_t)fwrite(buffer, 1, (size_t)bytes_read, pointer_dest);
        if (bytes_written < 0) {
            tfs_close(handle_source);
            fclose(pointer_dest);
            pthread_mutex_unlock(&global_mutex);
            return -1;
        }

    } while(bytes_read == BUFFER_SIZE);

    /* Close both files */
    if (tfs_close(handle_source) == -1) {
        pthread_mutex_unlock(&global_mutex);
        return -1;
    }
    if (fclose(pointer_dest) == -1) {
        pthread_mutex_unlock(&global_mutex);
        return -1;
    }

    pthread_mutex_unlock(&global_mutex);

    return 0;
}
