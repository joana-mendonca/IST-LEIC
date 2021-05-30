#ifndef __FIR_AST_STACK_ALLOC_NODE_H__
#define __FIR_AST_STACK_ALLOC_NODE_H__

#include <cdk/ast/expression_node.h>

namespace fir {

  class stack_alloc_node: public cdk::expression_node{
    cdk::expression_node *_index;

  public:
    stack_alloc_node(int lineno, cdk::expression_node *index) :
        cdk::expression_node(lineno), _index(index) {
    }

  public:
    cdk::expression_node *index() {
      return _index;
    }

  public:
    void accept(basic_ast_visitor *sp, int level) {
      sp->do_stack_alloc_node(this, level);
    }

  };

}

#endif
