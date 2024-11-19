%functor
%import
%    System
%    Application
%define

%% /////////////////////////////////////////////////////////////////////////
%%
%%  AUXILIARY FUNCTIONS DEFINITIONS
%%  Search: functions.oz
%%
%% /////////////////////////////////////////////////////////////////////////
declare

proc {Separate Stack Res Cond Before After}
    case Stack of H|T then
        if {Cond H} then 
            {Separate T {Append Res [H]} Cond Before After}
        else
            Before = Res
            After = Stack.2
        end
    else
        Before = Res
        After = Stack
    end
end

fun {RecursiveSeparate Stack Cond State}
    Before After
in
    case Stack of nil then
        State
    else
        {Separate Stack nil Cond Before After}
        %{Browse Before}
        %{Browse After}
        case Before of nil then {RecursiveSeparate After Cond State}
        else {RecursiveSeparate After Cond {Append State Before|nil}}
        end
    end
end

%% Split a string by spaces
fun {Str2Lst Data}
    {String.tokens Data & }
end

%% Data is a list of the form ["(", "X", "+", "Y", ")"] en returns id prefix form ["+" "X" "Y"]
fun {Infix2Prefix Data}
    local Reverse Infix2Postfix in
        fun {Reverse Data Ans}
            case Data of H|T then
                case H of "(" then
                    {Reverse T ")"|Ans}
                []  ")" then
                    {Reverse T "("|Ans}
                else
                    {Reverse T H|Ans}
                end
            else
                Ans
            end
        end
        fun {Infix2Postfix Data Stack Res}
            local PopWhile in
                fun {PopWhile Stack Res Cond}
                    case Stack of H|T then
                        if {Cond H} then
                            {PopWhile T H|Res Cond}
                        else
                            [Res Stack]
                        end
                    else
                        [Res Stack]
                    end
                end
                case Data of H|T then
                    case H of "(" then
                        {Infix2Postfix T H|Stack Res}
                    [] ")" then
                        local H2 T2 T3 in
                            H2|T2|nil = {PopWhile Stack Res fun {$ X} {Not X=="("} end}
                            _|T3 = T2
                            {Infix2Postfix T T3 H2}
                        end 
                    [] "+" then
                        local H2 T2 in
                            H2|T2|nil = {PopWhile Stack Res fun {$ X} {List.member X ["*" "/"]} end}
                            {Infix2Postfix T H|T2 H2}
                        end
                    [] "-" then
                        local H2 T2 in
                            H2|T2|nil = {PopWhile Stack Res fun {$ X} {List.member X ["*" "/"]} end}
                            {Infix2Postfix T H|T2 H2}
                        end
                    [] "*" then
                        local H2 T2 in
                            H2|T2|nil = {PopWhile Stack Res fun {$ X} {List.member X nil} end}
                            {Infix2Postfix T H|T2 H2}
                        end
                    [] "/" then
                        local H2 T2 in
                            H2|T2|nil = {PopWhile Stack Res fun {$ X} {List.member X nil} end}
                            {Infix2Postfix T H|T2 H2}
                        end
                    else
                        {Infix2Postfix T Stack H|Res}
                    end
                else 
                    Res
                end
            end
        end
        {Infix2Postfix "("|{Reverse "("|Data nil} nil nil}
    end
end


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

%%SC

%fun {PSuperComb TokenList}
%
%end


%% Defns

%fun {PDefns TokenList}
%    PIn = fun {$ Tokens} {PLit "in" Tokens} end
%    POneOrMoreDefns = fun {$ Tokens} {POneOrMore PDefn Tokens} end
%    Combinator = fun {$ DefnsList Equal} DefnsList end
%in
%    {PThen Combinator POneOrMoreDefns PIn}
%end

%fun {PDefn TokenList}
%    PSymbol = fun {$ Tokens} {PLit "var" Tokens} end
%    PGetVarName = fun {$ Tokens} {PApply fun {$ X} var(Name)=X in Name end PVar Tokens}
%    PEqual = fun {$ Tokens} {PLit "=" Tokens} end
%in
%
%end



%% EXPRESSIONS

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

%% Filter parse outputs
fun {GetParse ParseList}
    {Map ParseList fun {$ Parse} parse(X _)=Parse in X end}
end

fun {GetTokens ParseList}
    {Map ParseList fun {$ Parse} parse(_ X)=Parse in X end}
end


%%  Validate output

fun {IsExpr X VarList}
    case X of app(L R) then
        {And {IsOperation L VarList} {IsExpr R VarList}}
    else
        {Or {Var X 'var'|VarList} {Num X}}
    end
end

fun {IsOperation X VarList}
    case X of app(L R) then
        {And {IsOperation L VarList} {IsExpr R VarList}}
    else
        {Var X 'fun'|VarList}
    end
end

fun {Var X VarList}
    case X of var(Y) then
        case VarList of 'var'|_ then {Member Y VarList}
        else {Not {Member Y VarList}}
        end
    else false
    end
end

fun {Num X}
    case X of num(_) then true
    else false
    end
end


%% LOCAL SCOPE TO TEST PARSING LIBRARY
%local Tokens1 = ["+" "foo" "*" "1" "2" "3"]
%    Parses = {PExpression Tokens1}
%in
%    {Browse {StringToAtom "foo ( 1 * 2 ) + 3"}}
%    {Browse {Map Tokens1 fun {$ X} {StringToAtom X} end}}
%    {Browse {Filter Parses fun {$ X} parse(_ B) = X in B == nil end}.1.1}
%    {Browse {IsExpr {Filter Parses fun {$ X} parse(_ B) = X in B == nil end}.1.1}}
%end



%% /////////////////////////////////////////////////////////////////////////
%%
%%  READ FILE
%%  Search: ReadFile.oz
%%
%% /////////////////////////////////////////////////////////////////////////
fun {ReadCoreFile Path}

    F = {New Open.file init(name:Path flags:[read])}
    Ls
    Lines
in
    {F read(list:Ls)}
    Lines = {String.tokens Ls &\n}
    {Filter {Map Lines fun {$ X} {Str2Lst {List.subtract X 13}} end} fun {$ X} {Not X==nil} end}

end
%% /////////////////////////////////////////////////////////////////////////
%%
%%  SYNTAX FUNCTIONS DEFINITIONS
%%  Search: syntax.oz
%%
%% /////////////////////////////////////////////////////////////////////////


fun {SC LineList}
    case LineList of H|T then
        if H == "fun" then
            local Name|Remainder = T
                Before1 After1
                Before2 After2
            in
                {Separate Remainder nil fun {$ X} {Not X=="="} end Before1 After1}
                %case of After 
                {Separate After1 nil fun {$ X} {Not X=="in"} end Before2 After2}
                case After2 of nil then
                    local ArgList = {Map Before1 fun {$ X} {StringToAtom X} end}
                    in
                        sc(name:{StringToAtom Name} args:ArgList defns:nil body:{Expr Before2 ArgList})
                    end
                else
                    local ArgList = {Map Before1 fun {$ X} {StringToAtom X} end}
                        DefnsList = {Defns Before2 ArgList}
                        VarList = {Map DefnsList fun {$ X} defn(body:_ varName:Ret)=X in Ret end}
                        VarArgList = {Append ArgList VarList}
                    in
                        sc(name:{StringToAtom Name} args:{Map Before1 fun {$ X} {StringToAtom X} end} defns:DefnsList body:{Expr After2 VarArgList})
                    end
                end
            end
        else
            local Before After
            in
                {Separate LineList nil fun {$ X} {Not X=="in"} end Before After}
                case After of nil then sc(name:'--MAIN--' args:nil defns:nil body:{Expr Before nil})
                else
                    local DefnsList = {Defns Before nil}
                        VarList = {Map DefnsList fun {$ X} defn(body:_ varName:Ret)=X in Ret end}
                    in
                        sc(name:'--MAIN--' args:nil defns:DefnsList body:{Expr After VarList})
                    end
                end
            end
        end
    else
        sc(name:nil args:nil body:nil)
    end
end

fun {Expr ExprList VarArgList}
    EvaluatedExprList = {PExpression {Infix2Prefix ExprList}}
    ValidExpressions = {Filter EvaluatedExprList fun {$ Parse} parse(A B) = Parse in {And {IsExpr A VarArgList} B==nil} end}
in
    {GetParse ValidExpressions}
end

fun {Defns DefnsList ArgList}
    SeparatedDefns = {RecursiveSeparate DefnsList fun {$ X} {Not X=="var"} end nil}
in
    {Map SeparatedDefns fun {$ X} {Defn X ArgList} end}
end

fun {Defn DefnList ArgList}
    Before After
in
    {Separate DefnList nil fun {$ X} {Not X=="="} end Before After}
    defn(varName:{StringToAtom Before.1} body:{Expr After ArgList})
end

%% /////////////////////////////////////////////////////////////////////////
%%
%%  MAIN EXECUTION
%%  Search: main.oz
%%
%% /////////////////////////////////////////////////////////////////////////


local Program = {Map {ReadCoreFile "Main.core"} fun {$ X} {SC X} end}
in
    {Browse Program}
end
