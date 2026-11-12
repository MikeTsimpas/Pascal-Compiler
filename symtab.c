#include "symtab.h"

Scope    *current_scope = NULL;
int       current_level = 0;
int       sem_errors    = 0;

TypeNode *type_integer, *type_real, *type_boolean,
         *type_char,    *type_string,
         *type_error,   *type_unknown;

void symtab_init(void) {
    type_integer = make_basic_type(T_INTEGER);
    type_real    = make_basic_type(T_REAL);
    type_boolean = make_basic_type(T_BOOLEAN);
    type_char    = make_basic_type(T_CHAR);
    type_string  = make_basic_type(T_STRING);
    type_error   = make_basic_type(T_ERROR);
    type_unknown = make_basic_type(T_UNKNOWN);
}

/* Internal helpers */
static unsigned int hash_str(const char *s) {
    unsigned int h = 5381;
    while (*s) h = ((h << 5) + h) ^ (unsigned char)(*s++);
    return h % SYMTAB_HASH;
}

static void *xalloc(size_t n) {
    void *p = calloc(1, n);
    if (!p) { fprintf(stderr, "Out of memory\n"); exit(1); }
    return p;
}

/* Gia to scope */
void scope_push(void) {
    Scope *s  = xalloc(sizeof(Scope));
    s->parent = current_scope;
    s->level  = current_level++;
    current_scope = s;
}

void scope_pop(void) {
    if (!current_scope) return;
    Scope *old    = current_scope;
    current_scope = old->parent;
    current_level--;
    free(old);
}

/* Elegxos simbolon apo to eksoteriko sto esoteriko */
SymEntry *sym_lookup(const char *name) {        // Anazithsh symbolon
    for (Scope *sc = current_scope; sc; sc = sc->parent) {
        for (SymEntry *e = sc->buckets[hash_str(name)]; e; e = e->next)
            if (strcmp(e->name, name) == 0) return e;
    }
    return NULL;
}

/* Koita mono auto to scope */
SymEntry *sym_lookup_local(const char *name) {
    if (!current_scope) return NULL;
    for (SymEntry *e = current_scope->buckets[hash_str(name)]; e; e = e->next)
        if (strcmp(e->name, name) == 0) return e;
    return NULL;
}

/* Symbol insertion */
SymEntry *sym_insert(const char *name, SymKind kind, TypeNode *type) {
    SymEntry *existing = sym_lookup_local(name);
    if (existing) {
        if ((existing->kind == SK_FUNCTION || existing->kind == SK_PROCEDURE)
                && existing->is_forward)
            return existing;
        sem_error("'%s' έχει ήδη δηλωθεί σε αυτή την εμβέλεια", name);
        return existing;
    }

    SymEntry *e    = xalloc(sizeof(SymEntry));
    e->name        = strdup(name);
    e->kind        = kind;
    e->type        = type;
    e->scope_level = current_level - 1;
    unsigned int h = hash_str(name);
    e->next = current_scope->buckets[h];
    current_scope->buckets[h] = e;
    return e;
}

/* Type constructors */
TypeNode *make_basic_type(TypeKind k) {
    TypeNode *t = xalloc(sizeof(TypeNode));
    t->kind = k;
    return t;
}

TypeNode *make_array_type(DimNode *dims, TypeNode *elem) {
    TypeNode *t = xalloc(sizeof(TypeNode));
    t->kind = T_ARRAY; t->array.dims = dims; t->array.elem_type = elem;
    return t;
}

TypeNode *make_list_type(TypeNode *elem) {
    TypeNode *t = xalloc(sizeof(TypeNode));
    t->kind = T_LIST; t->list.elem_type = elem;
    return t;
}

TypeNode *make_record_type(FieldNode *fields) {
    TypeNode *t = xalloc(sizeof(TypeNode));
    t->kind = T_RECORD; t->record.fields = fields;
    return t;
}

TypeNode *make_enum_type(NameNode *names, int count) {
    TypeNode *t = xalloc(sizeof(TypeNode));
    t->kind = T_ENUM; t->enumt.names = names; t->enumt.count = count;
    return t;
}

TypeNode *make_subrange_type(TypeNode *base, int low, int high) {
    TypeNode *t = xalloc(sizeof(TypeNode));
    t->kind = T_SUBRANGE; t->subrange.base = base;
    t->subrange.low = low; t->subrange.high = high;
    return t;
}

/* Type predicates */
TypeNode *resolve_type(TypeNode *t) {
    while (t && t->kind == T_SUBRANGE) t = t->subrange.base;
    return t;
}

int is_arithmetic(TypeNode *t) {
    TypeNode *r = resolve_type(t);
    return r && (r->kind == T_INTEGER || r->kind == T_REAL);
}

int is_boolean(TypeNode *t) {
    TypeNode *r = resolve_type(t);
    return r && r->kind == T_BOOLEAN;
}

int is_basic(TypeNode *t) {
    TypeNode *r = resolve_type(t);
    return r && (r->kind == T_INTEGER || r->kind == T_REAL ||
                 r->kind == T_BOOLEAN || r->kind == T_CHAR  || r->kind == T_STRING);
}

/* Scalar = oxi array / record / list */
int is_scalar(TypeNode *t) {
    return t && t->kind != T_ARRAY && t->kind != T_RECORD && t->kind != T_LIST;
}

/* Ordered = gia simasiologikous telestes */
int is_ordered(TypeNode *t) {
    TypeNode *r = resolve_type(t);
    return r && (r->kind == T_INTEGER || r->kind == T_REAL   ||
                 r->kind == T_BOOLEAN || r->kind == T_CHAR   ||
                 r->kind == T_STRING  || r->kind == T_ENUM);
}

/* Type compatibility */
int types_compatible_assign(TypeNode *lhs, TypeNode *rhs) {
    if (!lhs || !rhs) return 1;
    if (lhs->kind == T_ERROR || rhs->kind == T_ERROR) return 1;
    if (lhs->kind == T_UNKNOWN || rhs->kind == T_UNKNOWN) return 1;

    TypeNode *l = resolve_type(lhs), *r = resolve_type(rhs);
    if (!l || !r) return 1;
    if (l->kind == r->kind) return 1;
    if (is_arithmetic(l) && is_arithmetic(r)) return 1;
    return 0;
}

/* Epestrece ton tipo mazi me semantic checks */
TypeNode *arithmetic_result(TypeNode *a, TypeNode *b, const char *op) {     // type chencking gia ekfraseis (boolean, int, real,...)
    if (!a || !b || a->kind == T_ERROR || b->kind == T_ERROR) return type_error;

    if (op && (strcmp(op, "AND") == 0 || strcmp(op, "OR") == 0)) {
        if (!is_boolean(a) || !is_boolean(b))
            sem_error("The operator '%s' needs boolean operators", op);
        return type_boolean;
    }

    if (op && (strcmp(op, "DIV") == 0 || strcmp(op, "MOD") == 0)) {
        TypeNode *ra = resolve_type(a), *rb = resolve_type(b);
        if (!ra || ra->kind != T_INTEGER || !rb || rb->kind != T_INTEGER)
            sem_error("The operator '%s' needs intiger operators", op);
        return type_integer;
    }

    if (op && strcmp(op, "/") == 0) {
        if (!is_arithmetic(a) || !is_arithmetic(b))
            sem_error("The operator '/' needs numerical operators");
        return type_real;
    }

    /* +, -, * */
    if (!is_arithmetic(a) || !is_arithmetic(b)) {
        /* Special: string + string, list + list */
        if (op && strcmp(op, "+") == 0) {
            TypeNode *ra = resolve_type(a), *rb = resolve_type(b);
            if (ra && rb && ra->kind == T_STRING && rb->kind == T_STRING) return type_string;
            if (ra && rb && ra->kind == T_LIST   && rb->kind == T_LIST)   return a;
        }
        sem_error("An arithmetic operator is applied to non-arithmetic expressions");
        return type_error;
    }

    /* Ama kapoios einai real */
    TypeNode *ra = resolve_type(a), *rb = resolve_type(b);
    return (ra->kind == T_REAL || rb->kind == T_REAL) ? type_real : type_integer;
}

/* Record field lookup */
FieldNode *find_field(TypeNode *rec, const char *name) {
    if (!rec || rec->kind != T_RECORD) return NULL;
    for (FieldNode *f = rec->record.fields; f; f = f->next)
        if (strcmp(f->name, name) == 0) return f;
    return NULL;
}

/* Semantic error reporting */
extern int yylineno;
void sem_error(const char *fmt, ...) {
    va_list ap;
    sem_errors++;
    fprintf(stderr, "[Line %d] Scemantical error: ", yylineno);
    va_start(ap, fmt); vfprintf(stderr, fmt, ap); va_end(ap);
    fprintf(stderr, "\n");
}

/* Node-list helpers */
NameNode *name_list_new(const char *name) {
    NameNode *n = xalloc(sizeof(NameNode)); n->name = strdup(name); return n;
}
NameNode *name_list_append(NameNode *list, const char *name) {
    NameNode *n = name_list_new(name);
    if (!list) return n;
    NameNode *cur = list; while (cur->next) cur = cur->next; cur->next = n; return list;
}

FieldNode *field_new(const char *name, TypeNode *type) {
    FieldNode *f = xalloc(sizeof(FieldNode)); f->name = strdup(name); f->type = type; return f;
}
FieldNode *fields_append(FieldNode *list, FieldNode *f) {
    if (!list) return f;
    FieldNode *cur = list; while (cur->next) cur = cur->next; cur->next = f; return list;
}

ParamNode *param_new(const char *name, TypeNode *type, int by_ref) {
    ParamNode *p = xalloc(sizeof(ParamNode));
    p->name = strdup(name); p->type = type; p->by_ref = by_ref; return p;
}
ParamNode *params_append(ParamNode *list, ParamNode *p) {
    if (!list) return p;
    ParamNode *cur = list; while (cur->next) cur = cur->next; cur->next = p; return list;
}

DimNode *dim_new(int low, int high) {
    DimNode *d = xalloc(sizeof(DimNode)); d->low = low; d->high = high; return d;
}
DimNode *dims_append(DimNode *list, DimNode *d) {
    if (!list) return d;
    DimNode *cur = list; while (cur->next) cur = cur->next; cur->next = d; return list;
}

/* Debug */
const char *type_name(TypeNode *t) {
    if (!t) return "null";
    switch (t->kind) {
        case T_INTEGER:   return "integer";
        case T_REAL:      return "real";
        case T_BOOLEAN:   return "boolean";
        case T_CHAR:      return "char";
        case T_STRING:    return "string";
        case T_ARRAY:     return "array";
        case T_RECORD:    return "record";
        case T_LIST:      return "list";
        case T_ENUM:      return "enum";
        case T_SUBRANGE:  return "subrange";
        case T_PROCEDURE: return "procedure";
        case T_UNKNOWN:   return "unknown";
        case T_ERROR:     return "error";
        default:          return "???";
    }
}

static const char *kind_name(SymKind k) {
    switch (k) {
        case SK_CONST:      return "CONST";
        case SK_TYPE:       return "TYPE";
        case SK_VAR:        return "VAR";
        case SK_PARAM:      return "PARAM";
        case SK_FUNCTION:   return "FUNCTION";
        case SK_PROCEDURE:  return "PROCEDURE";
        case SK_ENUM_CONST: return "ENUM_CONST";
        default:            return "?";
    }
}

void symtab_print(void) {
    printf("\n========= Symbol Array =========\n");
    for (Scope *sc = current_scope; sc; sc = sc->parent) {
        printf("--- Range %d ---\n", sc->level);
        for (int i = 0; i < SYMTAB_HASH; i++)
            for (SymEntry *e = sc->buckets[i]; e; e = e->next)
                printf("  %-20s  %-10s  %s%s\n",
                    e->name, kind_name(e->kind), type_name(e->type),
                    e->is_forward ? "  [FORWARD]" : "");
    }
    printf("=====================================\n");
}