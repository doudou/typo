class SimpleExpressions
    def regexp_capture
        a = $1
    end
    def regexp_backref
        a = $`
    end

    def range_inclusive
        a = (1..2)
    end
    def range_exclusive
        a = (1...2)
    end
    def hash
        a = {}
    end
end


