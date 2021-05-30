#ifndef __FIR_AST_LEAVE_H__
#define __FIR_AST_LEAVE_H__

#include <cdk/ast/expression_node.h>

namespace fir {
  /*Variables*/
  class leave_node: public cdk::basic_node {
    cdk::expression_node *_literal;
  
  public:
    /*Constructor*/
    leave_node(int lineno, cdk::expression_node *literal) :
        cdk::basic_node(lineno), _literal(literal) {
    }

  public:
    /*Getter*/
    cdk::expression_node *literal() {
        return _literal;
    }

    /*Accept*/
    void accept(basic_ast_visitor *sp, int level) {
      sp->do_leave_node(this, level);
    }

  };

}

#endif
