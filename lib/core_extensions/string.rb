module StringRefinements
  refine String do
    def utf8downcase
      self.mb_chars.downcase.to_s
    end
  end
end
