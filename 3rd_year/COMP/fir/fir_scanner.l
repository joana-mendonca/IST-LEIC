%option c++ prefix="fir_scanner_" outfile="fir_scanner.cpp"
%option stack noyywrap yylineno 8bit
%{ 
// make relevant includes before including the parser's tab file
#include <string>
#include <cdk/ast/sequence_node.h>
#include <cdk/ast/expression_node.h>
#include <cdk/ast/lvalue_node.h>
#include "fir_parser.tab.h"

// don't change this
#define yyerror LexerError
%}
%x X_STRING X_COMMENT
%%

                        {set_debug(true); yydebug=1;} 
"--".*                 ; /* ignore comments */

[A-Za-z][A-Za-z0-9_]*  yylval.s = new std::string(yytext); return tID;

[0-9]+                 yylval.i = strtol(yytext, nullptr, 10); return tINTEGER;

[ \t\n]+               ; /* ignore whitespace */

.                      yyerror("Unknown character");

  /* ====================================================================== */
  /* ====[                     Operadores de expressões               ]==== */
  /* ====================================================================== */
">="                   return tGE; 
"<="                   return tLE; 
"=="                   return tEQ; 
"!="                   return tNE; 
"->"                   return tARROW;

  /* ====================================================================== */
  /* ====[                Delimitadores e separadores                 ]==== */
  /* ====[                    Corpo (de função)                       ]==== */
  /* ====[                       Instruções                           ]==== */
  /* ====================================================================== */

[-()<>=+*/%;{}.]               return *yytext;
"return"                       return tRETURN;
"restart"                      return tRESTART;
"leave"                        return tLEAVE;
"write"                        return tWRITE;
"writeln"                      return tWRITELN;

  /* ====================================================================== */
  /* ====[                            STRINGS                         ]==== */
  /* ====================================================================== */

\'                     yy_push_state(X_STRING); yylval.s = new std::string("");
<X_STRING>\'           yy_pop_state(); return tSTRING;
<X_STRING>\\\'         *yylval.s += yytext + 1;
<X_STRING>.            *yylval.s += yytext;
<X_STRING>\n           yyerror("newline in string");

  /* ====================================================================== */
  /* ====[                            COMMENTS                        ]==== */
  /* ====================================================================== */

"//".*$                /* match the whole line (it is ignored) */

"/*"                   yy_push_state(X_COMMENT);
<X_COMMENT>"*/"        yy_pop_state();
<X_COMMENT>.|"\n"      ;  /* ignore inside comments */

  /* ====================================================================== */
  /* ====[                   Tipos de dados                           ]==== */
  /* ====[                   Procedures                               ]==== */
  /* ====================================================================== */

"void"                   return tTYPE_VOID;
"int"                    return tTYPE_INT;
"real"                   return tTYPE_REAL;
"string"                 return tTYPE_STRING;
"nullptr"                return tNULLPTR;
[<>]                     return *yytext;


  /* ====================================================================== */
  /* ====[                          Símbolos globais                  ]==== */
  /* ====================================================================== */

"*"                      return tPUBLIC;
""                       return tPRIVATE;
"?"                      return tEXTERNAL;

  /* ====================================================================== */
  /* ====[                       Instrução condicional                ]==== */
  /* ====================================================================== */

"if"                   return tIF;
"then"                 return tTHEN;
"else"                 return tELSE;
"while"                return tWHILE;
"do"                   return tDO;
"finally"              return tFINALLY;

%%
