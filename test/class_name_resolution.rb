module M0
    class A
        class B
        end
    end

    module M1
        class C
        end
    end

    module M2
        class E
        end

        class M0::D
        end
        class M0::M2::E
            class X
            end
        end
    end

    module ::M0
    end
end

module M3
end
