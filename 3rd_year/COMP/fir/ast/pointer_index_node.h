#ifndef __FIR_AST_POINTER_INDEX_NODE_H__
#define __FIR_AST_POINTER_INDEX_NODE_H__

#include <cdk/ast/expression_node.h>

namespace fir {

  class pointer_index_node: public cdk::lvalue_node {
    cdk::expression_node *_pointer, *_index;

  public:
    pointer_index_node(int lineno, cdk::expression_node *pointer, cdk::expression_node *index) :
        cdk::lvalue_node(lineno), _pointer(pointer), _index(index) {
    }

  public:
    cdk::expression_node *pointer() {
      return _pointer;
    }
    cdk::expression_node *index() {
      return _index;
    }

  public:
    void accept(basic_ast_visitor *sp, int level) {
      sp->do_pointer_index_node(this, level);
    }

  };

}

#endif
