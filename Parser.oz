% Parser a = [Token] -> [(a,[Token])]

%result of a parser is a record in the form parse(a [UnparsedTokens])

declare RESERVEDWORDS = ["fun" "in" "="]
        BINOP = ["+" "-" "/" "*"]
        COSA = {NewCell 0}

%% GENERAL PARSER LIBRARY
declare

fun {PSat Cond TokenList}
    case TokenList of H|T then
        if {Cond H} then parse(H T) | nil
        else nil
        end
    else
        nil
    end
end

fun {PLit Literal TokenList}
    {PSat fun {$ X} X==Literal end TokenList}
end

fun {PVar TokenList}
    Cond = fun {$ X} {And {Not {Member X RESERVEDWORDS}} {Char.isAlpha X.1}} end
in
    {PSat Cond TokenList}
end

fun {PNum TokenList}
    Cond = fun {$ X} {Or {String.isInt X} {String.isFloat X}} end
in
    {PSat Cond TokenList}
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

fun {PEmpty Input TokenList}
    [parse(Input TokenList)]
end

fun {POneOrMore P1 TokenList}
    Parsed1 = {Flatten {Map {P1 TokenList} fun {$ X} {PEmpty X.1|nil X.2} end}}
in
    case Parsed1 of nil then
        nil
    else
        {POneOrMoreImp Parsed1 P1}
    end
end

fun {POneOrMoreImp PrevParse P1}
    fun {Mapper X} % X = parse([V] Tokens)
        [parse({Append X.1 V|nil} Tokens) suchthat parse(V Tokens) in {P1 X.2}]
    end
    Then = {Flatten {Map PrevParse Mapper}}
in
    case Then of nil then
        PrevParse
    else
        {Append PrevParse {POneOrMoreImp Then P1}}
    end
end

fun {PZeroOrMore P1 TokenList}
    {PAlt fun {$ Tokens} {POneOrMore P1 Tokens} end fun {$ Tokens} {PEmpty nil Tokens} end TokenList}
end

fun {POneOrMoreWithSep P PSep TokenList}
    PRest = fun {$ Tokens} {PThen fun {$ Sep PToken} PToken end PSep P Tokens} end
    PRepeat = fun {$ Tokens} {PZeroOrMore PRest Tokens} end
    Combinator = fun {$ First Rest} {Append First|nil Rest} end
in
    {PThen Combinator P PRepeat TokenList}
end


fun {PApply Function P TokenList}
    Parsed = {P TokenList}
    fun {Mapper X}
        case X of parse(A Tokens) then parse({Function A} Tokens)
        else
            nil
        end
    end
in
    {Map Parsed Mapper}
end

%% LANGUAGE PARSER
% Only going to parse the expresions part because yolo

fun {PExpression TokenList}
    PBinop = fun {$ Tokens} {PSat fun {$ X} {Member X BINOP} end Tokens} end
    POneOrMoreAtomicExpr = fun {$ Tokens} {POneOrMore PAtomicExpression Tokens} end
    PExpression2 = fun {$ Tokens} {PApply fun {$ X} {FoldL X.2 fun {$ Y Z} app(Y Z) end X.1} end POneOrMoreAtomicExpr Tokens} end

    PExpression1 = fun {$ Tokens} {PThen3 fun {$ X Y Z} app(app(X Y) Z) end PBinop PExpression PExpression Tokens} end
    PReturn = fun {$ Tokens} {PAlt PExpression1 PExpression2 Tokens} end
in
    {PReturn TokenList}
end


fun {PAtomicExpression TokenList}
    PAlt1 = fun {$ X} {PAlt PVar PNum TokenList} end
    COSA := @COSA + 1
in
    %{PAlt PAlt1 PExpression TokenList}
    {PAlt1 TokenList}
end

{Browse before}
local Tokens1 = ["*" "+" "x" "1" "+" "x" "1"]
    Parses = {PExpression Tokens1}
in
    {Browse Tokens1}
    {Browse Parses}
    {Browse {Filter Parses fun {$ X} parse(_ B) = X in B == nil end}}
    {Browse @COSA}
end
