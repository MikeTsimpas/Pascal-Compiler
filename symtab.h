#ifndef SYMTAB_H
#define SYMTAB_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#define SYMTAB_HASH 211


typedef enum {
    T_INTEGER, T_REAL, T_BOOLEAN, T_CHAR, T_STRING,
    T_ARRAY, T_RECORD, T_LIST, T_ENUM, T_SUBRANGE,
    T_PROCEDURE, T_UNKNOWN, T_ERROR
} TypeKind;

typedef struct TypeNode  TypeNode;
typedef struct FieldNode FieldNode;
typedef struct ParamNode ParamNode;
typedef struct DimNode   DimNode;
typedef struct NameNode  NameNode;

struct NameNode  { char *name; struct NameNode  *next; };
struct DimNode   { int low, high; struct DimNode *next; };
struct FieldNode { char *name; TypeNode *type; struct FieldNode *next; };
struct ParamNode { char *name; TypeNode *type; int by_ref; struct ParamNode *next; };

struct TypeNode {
    TypeKind kind;
    union {
        struct { DimNode  *dims;   TypeNode  *elem_type; } array;
        struct { TypeNode *elem_type; }                    list;
        struct { FieldNode *fields; }                      record;
        struct { NameNode *names; int count; }             enumt;
        struct { TypeNode *base; int low, high; }          subrange;
    };
};

/* Pinakas simbolon */
typedef enum {
    SK_CONST, SK_TYPE, SK_VAR, SK_PARAM,
    SK_FUNCTION, SK_PROCEDURE, SK_ENUM_CONST
} SymKind;

/* Constant value (gia to SK_CONST / SK_ENUM_CONST) */
typedef struct {
    TypeKind type_kind;
    union { int ival; float fval; char cval; char *sval; };
} ConstVal;

typedef struct SymEntry {
    char      *name;
    SymKind    kind;
    TypeNode  *type;
    TypeNode  *return_type;
    ParamNode *params;
    ConstVal  *const_val;
    int        is_forward;
    int        scope_level;
    struct SymEntry *next;
} SymEntry;

/*  Scope stack  */
typedef struct Scope {
    SymEntry     *buckets[SYMTAB_HASH];
    struct Scope *parent;
    int           level;
} Scope;

extern Scope *current_scope;
extern int    current_level;

/*  Singleton primitive types  */
extern TypeNode *type_integer, *type_real, *type_boolean,
                *type_char,    *type_string,
                *type_error,   *type_unknown;

/*  Public API  */
void symtab_init(void);

/* Scope management */
void      scope_push(void);
void      scope_pop(void);

/* Elegxos simbolon kai eisagogh */
SymEntry *sym_lookup(const char *name);
SymEntry *sym_lookup_local(const char *name);
SymEntry *sym_insert(const char *name, SymKind kind, TypeNode *type);

/* Type constructors */
TypeNode *make_basic_type(TypeKind k);
TypeNode *make_array_type(DimNode *dims, TypeNode *elem);
TypeNode *make_list_type(TypeNode *elem);
TypeNode *make_record_type(FieldNode *fields);
TypeNode *make_enum_type(NameNode *names, int count);
TypeNode *make_subrange_type(TypeNode *base, int low, int high);

/* Node-list helpers */
NameNode  *name_list_new(const char *name);
NameNode  *name_list_append(NameNode *list, const char *name);
FieldNode *field_new(const char *name, TypeNode *type);
FieldNode *fields_append(FieldNode *list, FieldNode *f);
ParamNode *param_new(const char *name, TypeNode *type, int by_ref);
ParamNode *params_append(ParamNode *list, ParamNode *p);
DimNode   *dim_new(int low, int high);
DimNode   *dims_append(DimNode *list, DimNode *d);

TypeNode *resolve_type(TypeNode *t);
int is_arithmetic(TypeNode *t);
int is_boolean(TypeNode *t);
int is_scalar(TypeNode *t);
int is_ordered(TypeNode *t);
int is_basic(TypeNode *t);

int       types_compatible_assign(TypeNode *lhs, TypeNode *rhs);
TypeNode *arithmetic_result(TypeNode *a, TypeNode *b, const char *op);
FieldNode *find_field(TypeNode *rec, const char *field_name);
/* Semantic error reporting */
extern int sem_errors;
void sem_error(const char *fmt, ...);

/* Debug  */
const char *type_name(TypeNode *t);
void        symtab_print(void);

#endif