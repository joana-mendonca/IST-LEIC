#ifndef __FIR_AST_FUNCTION_DEFINITION_H__
#define __FIR_AST_FUNCTION_DEFINITION_H__

#include <string>
#include <cdk/ast/typed_node.h>
#include <cdk/ast/sequence_node.h>
#include <cdk/ast/expression_node.h>
#include "ast/block_node.h"

namespace fir {

  class function_definition_node: public cdk::typed_node {
    int _qualifier; /*public/private */
    std::string _identifier;
    cdk::sequence_node *_arguments;
    cdk::expression_node *_literal;
    //fir::block_node *_prologue_block;
    fir::block_node *_block;
    //fir::block_node *_epilogue_block;

  public:
    /*Defines void functions*/
    function_definition_node(int lineno, int qualifier, const std::string &identifier, cdk::sequence_node *arguments, cdk::expression_node *literal, fir::block_node *block) :
        cdk::typed_node(lineno), _qualifier(qualifier), _identifier(identifier), _arguments(arguments), _literal(literal), _block(block) { 
      type(cdk::primitive_type::create(0, cdk::TYPE_VOID));
    }

    function_definition_node(int lineno, int qualifier, std::shared_ptr<cdk::basic_type> functionType, const std::string &identifier, cdk::sequence_node *arguments, cdk::expression_node *literal, fir::block_node *block) :
        cdk::typed_node(lineno), _qualifier(qualifier), _identifier(identifier), _arguments(arguments), _literal(literal),  _block(block) {
      type(functionType);
    }
    
    function_definition_node(int lineno, int qualifier, std::shared_ptr<cdk::basic_type> functionType, const std::string &identifier, cdk::sequence_node *arguments, fir::block_node *block) :
        cdk::typed_node(lineno), _qualifier(qualifier), _identifier(identifier), _arguments(arguments),  _block(block) {
      type(functionType);
    }

  public:
    int qualifier() {
      return _qualifier;
    }
    const std::string& identifier() const {
      return _identifier;
    }
    cdk::sequence_node *arguments() {
      return _arguments;
    }
    cdk::expression_node *literal() {
      return _literal;
    }
    fir::block_node *block() {
      return _block;
    }

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_function_definition_node(this, level);
    }

  };

}

#endif
