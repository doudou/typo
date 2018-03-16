class LocalVariableAssignation
    def simple
        a = 2
    end
    def chained
        a = b = 2
    end
    def re_assigned
        a = 2
        a = false
    end
    def parallel
        a, b = 2, 3
    end
    def parallel_too_short
        a, b = 2
    end
    def parallel_splat
        a, b, c = 2, *d
    end
end


