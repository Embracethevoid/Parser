#ifndef EXPR_H
#define EXPR_H

typedef struct expr_val* exp;
struct expr_val
{
	char* str;
	int num;
        float num;
};

extern exp mk_int(int item);
extern exp mk_str(char* item);
extern exp mk_float(float item);


#endif
