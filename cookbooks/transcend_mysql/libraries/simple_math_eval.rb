module Math
  def self.eval(expression)
    allowed_characters = Regexp.escape('+-*/.')
    safe_expression = expression.match(/[\d#{allowed_characters}]*/).to_s
    Kernel.eval(safe_expression)
  end
end
