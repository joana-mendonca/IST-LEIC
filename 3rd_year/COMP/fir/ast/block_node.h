#ifndef __FIR_AST_BLOCK_H__
#define __FIR_AST_BLOCK_H__

#include <cdk/ast/basic_node.h>

namespace fir {

  /**
   * Class for describing block nodes variables.
   */
  class block_node: public cdk::basic_node {
    cdk::sequence_node *_declaration, *_instruction;

  /*Constructor*/
  public:
    inline block_node(int lineno, cdk::sequence_node *declaration, cdk::sequence_node *instruction) :
        cdk::basic_node(lineno), _declaration(declaration), _instruction(instruction) {
    }

  /*Getters*/
  public:
    inline cdk::sequence_node *declaration() {
      return _declaration;
    }
    inline cdk::sequence_node *instruction() {
      return _instruction;
    }

    /*Accept*/
    void accept(basic_ast_visitor *sp, int level) {
      sp->do_block_node(this, level);
    }

  };

}

#endif
