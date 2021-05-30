#ifndef __FIR_AST_RETURN_H__
#define __FIR_AST_RETURN_H__

#include <cdk/ast/basic_node.h>

namespace fir {
  /*Variables*/
  class return_node: public cdk::basic_node {

  /*Constructor*/
  public:
    return_node(int lineno) :
        cdk::basic_node(lineno) {
    }

  public:
    /*Accept*/
    void accept(basic_ast_visitor *sp, int level) {
      sp->do_return_node(this, level);
    }

  };

}

#endif
