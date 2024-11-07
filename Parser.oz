% Parser a = [Token] -> [(a,[Token])]
declare PLit

fun {PLit Literal TokenList}
    case TokenList of H|T then
        if H == Literal then parse(Literal T) | nil
        else nil
        end
    else
        nil
    end
end

fun {PVar TokenList}
    case TokenList of H|T then
        if {Member H ["=" "fun" "in"]} then nil
        else
            if {Char.isAlpha H.1} then parse(H T) | nil
            else nil
            end
        end
    else 
        nil
    end
end

fun {PAlt P1 P2 TokenList}
    {Append {P1 TokenList} {P2 TokenList}}
end

fun {PThen Combine P1 P2 TokenList}
    Parsed1 = {P1 TokenList}
    fun {Mapper X} % X = parse(V1 Toks)
        [parse({Combine X.1 V2} Toks2) suchthat parse(V2 Toks2) in {P2 X.2}]
    end
in
    {Flatten {Map Parsed1 Mapper}}
end

fun {PThen3 Combine P1 P2 P3 TokenList}
    Parsed1 = {P1 TokenList}
    fun {Mapper1 X} % X = parse(V1 Toks1)
        [parse1(vs(X.1 V2) Toks2) suchthat parse(V2 Toks2) in {P2 X.2}]
    end
    Parsed2 = {Flatten {Map Parsed1 Mapper1}}
    fun {Mapper2 Y} % Y = parse1(vs(V1 V2) Toks2)
        [parse({Combine Y.1.1 Y.1.2 V3} Toks3) suchthat parse(V3 Toks3) in {P3 Y.2}]
    end
in
    {Browse entersAfterLocal}
    {Flatten {Map Parsed2 Mapper2}}
end

fun {PThen4 Combine P1 P2 P3 P4 TokenList}
    Parsed1 = {P1 TokenList}
    fun {Mapper1 X}
        [parse1(vs(X.1 V2) Toks2) suchthat parse(V2 Toks2) in {P2 X.2}]
    end
    Parsed2 = {Flatten {Map Parsed1 Mapper1}}
    fun {Mapper2 Y}
        [parse2(vs(Y.1.1 Y.1.2 V3) Toks3) suchthat parse(V3 Toks3) in {P3 Y.2}]
    end
    Parsed3 = {Flatten {Map Parsed2 Mapper2}}
    fun {Mapper3 Z}
        [parse({Combine Z.1.1 Z.1.2 Z.1.3 V4} Toks4) suchthat parse(V4 Toks4) in {P4 Z.2}]
    end
in
    {Flatten {Map Parsed3 Mapper3}}

end




local Tokens = ["hello" "John" "!" "Want" "to" "suck" "me" "dick?"]
    PHello = fun {$ X} {PLit "hello" X} end
    PGoodbye = fun {$ X} {PLit "goodbye" X} end
    PHelloOrGoodBye = fun {$ X} {PAlt PHello PGoodbye X} end
    PWant = fun {$ X} {PLit "Want" X} end
    PExcl = fun {$ X} {PLit "!" X} end
    PGreeting = fun {$ X} fun {Foo Hg Name Excl} Hg#Name end in {PThen3 Foo PHelloOrGoodBye PVar PExcl X} end
    PGreetingWant = fun {$ X} fun {Foo Hg Name Excl Want} Hg#Name end in {PThen4 Foo PHelloOrGoodBye PVar PExcl PWant X} end
in
    %{Browse {PLit "hello" Tokens}}
    %{Browse {PLit "Goodbye" Tokens}}

    %{Browse {PAlt fun {$ X} {PLit "coco" X} end fun {$ Y} {PLit "hello" Y} end Tokens}}
    {Browse hello}
    {Browse {PGreeting Tokens}}
    {Browse {PGreetingWant Tokens}}
end