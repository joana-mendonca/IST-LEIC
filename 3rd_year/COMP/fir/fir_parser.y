%{
//-- don't change *any* of these: if you do, you'll break the compiler.
#include <algorithm>
#include <memory>
#include <cstring>
#include <cdk/compiler.h>
#include <cdk/types/types.h>
#include "ast/all.h"
#define LINE                         compiler->scanner()->lineno()
#define yylex()                      compiler->scanner()->scan()
#define yyerror(compiler, s)         compiler->scanner()->error(s)
//-- don't change *any* of these --- END!
%}

%parse-param {std::shared_ptr<cdk::compiler> compiler}

%union {
  //--- don't change *any* of these: if you do, you'll break the compiler.
  YYSTYPE() : type(cdk::primitive_type::create(0, cdk::TYPE_VOID)) {}
  ~YYSTYPE() {}
  YYSTYPE(const YYSTYPE &other) { *this = other; }
  YYSTYPE& operator=(const YYSTYPE &other) { type = other.type; return *this; }

  std::shared_ptr<cdk::basic_type> type;        /* expression type */
  //-- don't change *any* of these --- END!
  
  int                       i;	/* integer value */
  double                    d;
  std::string              *s;	/* symbol name or string literal */
  cdk::basic_node          *node;	/* node pointer */
  cdk::sequence_node       *sequence;
  cdk::expression_node     *expression; /* expression nodes */
  cdk::lvalue_node         *lvalue;
  fir::block_node          *block;
};

%token <i> tINTEGER 
%token <s> tID tSTRING
%token <d> tREAL
%token tWRITE tWRITELN tRETURN tRESTART tLEAVE tBREAK tCONTINUE
%token tPUBLIC tPRIVATE tEXTERNAL
%token tTYPE_VOID tTYPE_INT tTYPE_STRING tTYPE_REAL tNULLPTR
%token tARROW


%nonassoc tIF
%nonassoc tTHEN
%nonassoc tELSE
%nonassoc tWHILE 
%nonassoc tDO
%nonassoc tFINALLY 

%right '=' '~'
%left tGE tLE tEQ tNE '>' '<'
%left '+' '-'
%left '*' '/' '%'
%left tOR tAND
%nonassoc tUNARY

%type <node>       declaration  vardecl  argdecl  instruction fundec fundef
%type <sequence>   declarations vardecls argdecls instructions opt_vardecls opt_instructions expressions 
%type <sequence>   program
%type <expression> expr opt_initializer literal
%type <lvalue>     lval
//%type <s>          string
//%type <i>          opt_integer
%type <type>       data_type void_type
%type <block>      block 



%{
//-- The rules below will be included in yyparse, the main parsing function.
%}
%%

program : /* empty */       { compiler->ast( $$ = new cdk::sequence_node(LINE)); }
        | declarations      { compiler->ast( $$ = $1); }
        ;


declarations : declaration              { $$ = new cdk::sequence_node(LINE, $1); }
             | declarations declaration { $$ = new cdk::sequence_node(LINE, $2, $1); }
             ; 

declaration  : vardecl ';'   { $$ = $1; }
             | fundec        { $$ = $1; }
             | fundef        { $$ = $1; }
             ;
             
/***************************************************************************************************************
 * Function Declaration
 ***************************************************************************************************************/             
fundec     : data_type     tID '(' argdecls ')' { $$ = new fir::function_declaration_node(LINE, tPRIVATE, $1, *$2, $4); }
           | data_type '*' tID '(' argdecls ')' { $$ = new fir::function_declaration_node(LINE, tPUBLIC, $1, *$3, $5); }
           | data_type '?' tID '(' argdecls ')' { $$ = new fir::function_declaration_node(LINE, tEXTERNAL, $1, *$3, $5); }
           | void_type     tID '(' argdecls ')' { $$ = new fir::function_declaration_node(LINE, tPRIVATE, $1, *$2, $4); }
           | void_type '*' tID '(' argdecls ')' { $$ = new fir::function_declaration_node(LINE, tPUBLIC, $1, *$3, $5); }
           | void_type '?' tID '(' argdecls ')' { $$ = new fir::function_declaration_node(LINE, tEXTERNAL, $1, *$3, $5); }
           ;

/***************************************************************************************************************
 * Function definition 
 ***************************************************************************************************************/
fundef      : data_type     tID '(' argdecls ')' tARROW literal block { $$ = new fir::function_definition_node(LINE, tPRIVATE, $1, *$2, $4, $7, $8); }                     
            | data_type '*' tID '(' argdecls ')' tARROW literal block { $$ = new fir::function_definition_node(LINE, tPUBLIC, $1, *$3, $5, $8, $9); }
            | void_type     tID '(' argdecls ')'                block { $$ = new fir::function_definition_node(LINE, tPRIVATE, $1, *$2, $4, $6); }
            | void_type '*' tID '(' argdecls ')'                block { $$ = new fir::function_definition_node(LINE, tPUBLIC, $1, *$3, $5, $7); }
            | data_type     tID '(' argdecls ')'                block { $$ = new fir::function_definition_node(LINE, tPRIVATE, $1, *$2, $4, $6); }
            | data_type '*' tID '(' argdecls ')'                block { $$ = new fir::function_definition_node(LINE, tPUBLIC, $1, *$3, $5, $7); }
            ;

block    : '{' opt_vardecls opt_instructions '}' { $$ = new fir::block_node(LINE, $2, $3); }
         ;

/***************************************************************************************************************
* Variable Declaration
***************************************************************************************************************/
opt_vardecls : /* empty */ { $$ = nullptr; }
             | vardecls    { $$ = $1; }
             ;
            
vardecls     : vardecl ';'          { $$ = new cdk::sequence_node(LINE, $1);     }
             | vardecls vardecl ';' { $$ = new cdk::sequence_node(LINE, $2, $1); }
             ;

vardecl      : data_type     tID opt_initializer { $$ = new fir::variable_declaration_node(LINE, tPRIVATE, $1, *$2, $3); }
             | data_type '*' tID opt_initializer { $$ = new fir::variable_declaration_node(LINE, tPUBLIC, $1, *$3, $4); }
             | data_type '?' tID                 { $$ = new fir::variable_declaration_node(LINE, tEXTERNAL, $1, *$3, nullptr); }
             ;

opt_initializer  : /* empty */     { $$ = nullptr; }
                 | '=' expr        { $$ = $2; }
                 ;
 
void_type    : tTYPE_VOID          { $$ = cdk::primitive_type::create(0, cdk::TYPE_VOID); }
             ;
             
data_type    : tTYPE_INT           { $$ = cdk::primitive_type::create(4, cdk::TYPE_INT); }
             | tTYPE_STRING                     { $$ = cdk::primitive_type::create(4, cdk::TYPE_STRING);  }              
             | tTYPE_REAL                       { $$ = cdk::primitive_type::create(8, cdk::TYPE_DOUBLE);  }
             ;
       
argdecls  : /* empty */           { $$ = new cdk::sequence_node(LINE);  }
          |              argdecl  { $$ = new cdk::sequence_node(LINE, $1);     }
          | argdecls ',' argdecl  { $$ = new cdk::sequence_node(LINE, $3, $1); }
          ;

argdecl   : data_type tID { $$ = new fir::variable_declaration_node(LINE, tPRIVATE, $1, *$2, nullptr); }
          ;
         

/***************************************************************************************************************
* Instructions
***************************************************************************************************************/
opt_instructions: /* empty */  { $$ = new cdk::sequence_node(LINE); }
                | instructions { $$ = $1; }
                ;       

instructions    : instruction                { $$ = new cdk::sequence_node(LINE, $1);     }
                | instructions instruction   { $$ = new cdk::sequence_node(LINE, $2, $1); }
                ;


instruction     : tIF expr tTHEN instruction                        { $$ = new fir::if_node(LINE, $2, $4); }
                | tIF expr tTHEN instruction tELSE instruction      { $$ = new fir::if_else_node(LINE, $2, $4, $6); }
                | tWHILE expr tDO instruction                       { $$ = new fir::while_node(LINE, $2, $4); }
                | tWHILE expr tDO instruction tFINALLY instruction  { $$ = new fir::while_node(LINE, $2, $4, $6); }
                | expr ';'                                          { $$ = new fir::evaluation_node(LINE, $1); }
                | tWRITE   expressions ';'                          { $$ = new fir::write_node(LINE, $2); } 
                | tWRITELN expressions ';'                          { $$ = new fir::writeln_node(LINE, $2); }
                | tRETURN                                           { $$ = new fir::return_node(LINE);  }
                | tLEAVE literal                                    { $$ = new fir::leave_node(LINE, $2); }
                | tRESTART literal                                  { $$ = new fir::restart_node(LINE, $2); }
                | block                                             { $$ = $1; }
                ;
 
         
/***************************************************************************************************************
 * Other
 ***************************************************************************************************************/        
expressions     : expr                 { $$ = new cdk::sequence_node(LINE, $1); }
                | expressions ',' expr { $$ = new cdk::sequence_node(LINE, $3, $1); }
                ;
 
expr : literal                   { $$ = $1; }
     | '-' expr %prec tUNARY     { $$ = new cdk::neg_node(LINE, $2); }
     | '+' expr %prec tUNARY     { $$ = new fir::identity_node(LINE, $2); }
     | '~' expr                  { $$ = new cdk::not_node(LINE, $2); }
     | expr '+' expr	         { $$ = new cdk::add_node(LINE, $1, $3); }
     | expr '-' expr	         { $$ = new cdk::sub_node(LINE, $1, $3); }
     | expr '*' expr	         { $$ = new cdk::mul_node(LINE, $1, $3); }
     | expr '/' expr	         { $$ = new cdk::div_node(LINE, $1, $3); }
     | expr '%' expr	         { $$ = new cdk::mod_node(LINE, $1, $3); }
     | expr '<' expr	         { $$ = new cdk::lt_node(LINE, $1, $3); }
     | expr '>' expr	         { $$ = new cdk::gt_node(LINE, $1, $3); }
     | expr tGE expr	         { $$ = new cdk::ge_node(LINE, $1, $3); }
     | expr tLE expr             { $$ = new cdk::le_node(LINE, $1, $3); }
     | expr tNE expr	         { $$ = new cdk::ne_node(LINE, $1, $3); }
     | expr tEQ expr	         { $$ = new cdk::eq_node(LINE, $1, $3); }
     | '(' expr ')'              { $$ = $2; }
     | lval                      { $$ = new cdk::rvalue_node(LINE, $1); }  //FIXME
     | lval '=' expr             { $$ = new cdk::assignment_node(LINE, $1, $3); }
     ;

     
literal : tINTEGER               { $$ = new cdk::integer_node(LINE, $1); }
        | tSTRING                { $$ = new cdk::string_node(LINE, $1); }
        | tREAL                  { $$ = new cdk::double_node(LINE, $1); }
        | tNULLPTR               { $$ = new fir::null_node(LINE); }
        ;
   
lval : tID                      { $$ = new cdk::variable_node(LINE, $1); }
     ;

%%
