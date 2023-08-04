module Blue
  class Evaluator
    def initialize(instance, input)
      @instance = instance
      @input = input
      @lexer = Lexer.new(input)
      @parser = Parser.new(@lexer)
    end

    def eval
      result = evaluate(@parser.parse)
      result.value
    end

    def evaluate(ast_node)
      case ast_node.class.to_s
      when "Blue::AST::Query"
        evaluate(ast_node.expression)
      when "Blue::AST::Identifier"
        evaluate_identifier(ast_node.value)
      when "Blue::AST::String"
        o = Object::String.new
        o.value = ast_node.value
        o
      when "Blue::AST::Number"
        o = Object::Number.new
        o.value = ast_node.value
        o
      when "Blue::AST::PrefixExpression"
        right_operand = evaluate(ast_node.right_expression)
        evaluate_prefix_expression(ast_node.operator, right_operand)
      when "Blue::AST::InfixExpression"
        left_operand = evaluate(ast_node.left_expression)
        right_operand = evaluate(ast_node.right_expression)
        evaluate_infix_expression(ast_node.operator, left_operand, right_operand)
      else
      end
    end

    def evaluate_prefix_expression(operator, right_operand)
      if right_operand.is_a?(Object::Number)
        o = Object::Number.new
        o.value = right_operand.value * -1
        return o
      end
    end

    def evaluate_infix_expression(operator, left_operand, right_operand)
      resp =
        case operator
        when "and", "AND"
          left_operand.value && right_operand.value
        when "or", "OR"
          left_operand.value || right_operand.value
        when "="
          left_operand.value == right_operand.value
        when "!="
          left_operand.value != right_operand.value
        end
      o = Object::Boolean.new
      o.value = resp
      o
    end

    def evaluate_identifier(identifier)
      resp = @instance.send(identifier)
      case resp.class.name
      when 'Integer'
        o = Object::Number.new
        o.value = resp
      when 'String'
        o = Object::String.new
        o.value = resp
      end

      o
    end
  end
end
