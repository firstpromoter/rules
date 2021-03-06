module Rules
  module Evaluators
    define_evaluator :equals do
      self.evaluation_method = ->(lhs, rhs) do
        return numeric_equation(lhs, rhs, :==) if numeric_lhs?(lhs)
        lhs == rhs
      end
      self.requires_rhs = true
    end

    define_evaluator :not_equals do
      self.evaluation_method = ->(lhs, rhs) do
        return !numeric_equation(lhs, rhs, :==) if numeric_lhs?(lhs)
        lhs != rhs
      end
      self.name = 'does not equal'
      self.requires_rhs = true
    end

    define_evaluator :contains do
      self.evaluation_method = ->(lhs, rhs) { lhs.include?(rhs) }
      self.name = 'contains'
      self.requires_rhs = true
    end

    define_evaluator :not_contains do
      self.evaluation_method = ->(lhs, rhs) { !lhs.include?(rhs) }
      self.name = 'does not contain'
    end

    define_evaluator :in_list do
      self.evaluation_method = ->(lhs, rhs) { rhs.include?(lhs) }
      self.name = 'in list'
      self.requires_rhs = true
    end

    define_evaluator :not_in_list do
      self.evaluation_method = ->(lhs, rhs) { !rhs.include?(lhs) }
      self.name = 'not in list'
      self.requires_rhs = true
    end

    define_evaluator :nil do
      self.evaluation_method = ->(lhs) { lhs.nil? }
      self.name = 'does not exist'
      self.requires_rhs = false
    end

    define_evaluator :not_nil do
      self.evaluation_method = ->(lhs) { !lhs.nil? }
      self.name = 'exists'
      self.requires_rhs = false
    end

    define_evaluator :matches do
      self.evaluation_method = ->(lhs, rhs) { !!(lhs =~ rhs) }
      self.name = 'matches'
      self.type_for_rhs = :regexp
      self.requires_rhs = true
    end

    define_evaluator :not_matches do
      self.evaluation_method = ->(lhs, rhs) { !(lhs =~ rhs) }
      self.name = 'does not match'
      self.type_for_rhs = :regexp
      self.requires_rhs = true
    end

    define_evaluator :less_than do
      self.evaluation_method = ->(lhs, rhs) do
        return numeric_equation(lhs, rhs, :<) if numeric_lhs?(lhs)
        lhs < rhs
      end
      self.name = 'less than'
      self.requires_rhs = true
    end

    define_evaluator :less_than_or_equal_to do
      self.evaluation_method = ->(lhs, rhs) do
        return numeric_equation(lhs, rhs, :<=) if numeric_lhs?(lhs)
        lhs <= rhs
      end
      self.name = 'less than or equal to'
      self.requires_rhs = true
    end

    define_evaluator :greater_than do
      self.evaluation_method = ->(lhs, rhs) do
        return numeric_equation(lhs, rhs, :>) if numeric_lhs?(lhs)
        lhs > rhs
      end
      self.name = 'greater than'
      self.requires_rhs = true
    end

    define_evaluator :greater_than_or_equal_to do
      self.evaluation_method = ->(lhs, rhs) do
        return numeric_equation(lhs, rhs, :>=) if numeric_lhs?(lhs)
        lhs >= rhs
      end
      self.name = 'greater than or equal to'
      self.requires_rhs = true
    end
  end
end

def numeric_lhs?(lhs)
  lhs.is_a?(Numeric)
end

def numeric_equation(lhs, rhs, operator)
  lhs.to_f.send(operator, rhs.to_f)
end
