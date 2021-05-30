#ifndef __FIR_AST_WRITELN_NODE_H__
#define __FIR_AST_WRITELN_NODE_H__

#include <cdk/ast/sequence_node.h>

namespace fir {

  /**
   * Class for describing write nodes variables.
   */
  class writeln_node: public cdk::basic_node {
    cdk::sequence_node *_expressions;

  /*Constructor*/
  public:
    inline writeln_node(int lineno, cdk::sequence_node *expressions) :
        cdk::basic_node(lineno), _expressions(expressions) {
    }

  public:
    /*Getter*/
    inline cdk::sequence_node *expressions() {
      return _expressions;
    }
    /*Accept*/
    void accept(basic_ast_visitor *sp, int level) {
      sp->do_writeln_node(this, level);
    }

  };

} // fir

#endif
