class String
  def present?
    !empty?
  end

  def presence
    present?? self : nil
  end
end

