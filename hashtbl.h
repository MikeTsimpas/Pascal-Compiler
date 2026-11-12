#ifndef HASHTBL_H
#define HASHTBL_H
#include <stdlib.h>

typedef unsigned int hash_size;

struct hashnode_s {
    char *key;
    void *data;
    int scope;
    struct hashnode_s *next;

};

typedef struct hashtbl {
    hash_size size;
    struct hashnode_s **nodes;
   hash_size (*hash_func)(const char *);
} HASHTBL;


HASHTBL *hashtbl_create(hash_size size, hash_size (*hashfunc)(const char*));
void hashtbl_destroy(HASHTBL *hashtbl);
int hashtbl_insert(HASHTBL *hashtbl, const char *key, void *data, int scope);
int hashtbl_remove(HASHTBL *hashtbl, const char *key, int scope);
void *hashtbl_get(HASHTBL *hashtbl, int scope);

#endif