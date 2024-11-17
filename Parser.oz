%% //////////////////////////////////////////////////////////////
%%
%%  PARSER LIBRARY
%%  Search: parser.oz
%%
%% //////////////////////////////////////////////////////////////

% Parser a = [Token] -> [(a,[Token])]

% result of a parser is a list of records in the form parse(a [UnparsedTokens])
% a is the element that it parsed or searched for and the list of tokens is a list of 
% Tokens that haven't been parsed

%   CONSTANTS
declare BINOP = ["+" "-" "/" "*"]
        RESERVEDWORDS = {Append ["fun" "in" "="] BINOP}

%%  GENERAL PARSER
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
    PVarr = fun {$ Tokens} {PSat Cond Tokens} end 
    Applier = fun {$ X} var({StringToAtom X}) end
in
    {PApply Applier PVarr TokenList}
end

fun {PNum TokenList}
    Cond = fun {$ X} {Or {String.isInt X} {String.isFloat X}} end
    PNumm = fun {$ Tokens} {PSat Cond Tokens} end
    Applier = fun {$ X} num({StringToAtom X}) end
in
    {PApply Applier PNumm TokenList}
end

fun {PAlt P1 P2 TokenList}
    {Append {P1 TokenList} {P2 TokenList}}
end

fun {PAlt3 P1 P2 P3 TokenList}
    {Append {Append {P1 TokenList} {P2 TokenList}} {P3 TokenList}}
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

fun {PExpression TokenList}
    {PAlt3 PBinopExpression PFunctionCall PAtomicExpression TokenList}
end

fun {PBinop TokenList}
    P = fun {$ Tokens} {PSat fun {$ X} {Member X BINOP} end Tokens} end
in
    {PApply fun {$ X} var({StringToAtom X}) end P TokenList}
end

fun {PBinopExpression TokenList}
    {PThen3 fun {$ X Y Z} app(app(X Y) Z) end PBinop PExpression PExpression TokenList}
end

fun {PFunctionCall TokenList}
    {PThen fun {$ Var ExprList} {FoldL ExprList fun {$ Y Z} app(Y Z) end Var} end PVar POneOrMoreExpr TokenList}
end

fun {POneOrMoreExpr TokenList}
    {POneOrMore PExpression TokenList}
end

fun {PAtomicExpression TokenList}
    {PAlt PVar PNum TokenList}
end


%%  Validate output

fun {IsExpr X}
    case X of app(L R) then
        {And {IsOperation L} {IsExpr R}}
    else
        {Or {Var X} {Num X}}
    end
end

fun {IsOperation X}
    case X of app(L R) then
        {And {IsOperation L} {IsExpr R}}
    else
        {Var X}
    end
end

fun {Var X}
    case X of var(_) then true
    else false
    end
end

fun {Num X}
    case X of num(_) then true
    else false
    end
end


%% LOCAL SCOPE TO TEST PARSING LIBRARY
local Tokens1 = ["+" "foo" "*" "1" "2" "3"]
    Parses = {PExpression Tokens1}
in
    {Browse {StringToAtom "foo ( 1 * 2 ) + 3"}}
    {Browse {Map Tokens1 fun {$ X} {StringToAtom X} end}}
    {Browse {Filter Parses fun {$ X} parse(_ B) = X in B == nil end}.1.1}
    {Browse {IsExpr {Filter Parses fun {$ X} parse(_ B) = X in B == nil end}.1.1}}
end
