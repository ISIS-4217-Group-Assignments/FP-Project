%% /////////////////////////////////////////////////////////////////////////
%%
%%  AUXILIARY FUNCTIONS DEFINITIONS
%%  Search: functions.oz
%%
%% /////////////////////////////////////////////////////////////////////////


declare Separate Env Str2Lst Parse ParseFun Infix2Prefix 

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

declare

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

%% /////////////////////////////////////////////////////////////////////////
%%
%%  SYNTAX FUNCTIONS DEFINITIONS
%%  Search: syntax.oz
%%
%% /////////////////////////////////////////////////////////////////////////



declare SC Expr AExpr Defns Defn

fun {SC LineList}
    case LineList of H|T then
        if H == "fun" then
            local Name|Remainder = T
                ArgList After
                Definitions Expresions
            in
                {Separate Remainder nil fun {$ X} {Not X=="="} end ArgList After}
                {Separate After nil fun {$ X} {Not X=="in"} end Definitions Expresions}
                %sc(name:Name args:ArgList defns:{Defns Definitions} body:{Expr Expresions}) DEBUG
                sc(name:{StringToAtom Name} args:{Map ArgList fun {$ X} {StringToAtom X} end} defns:{Defns Definitions} body:{Expr Expresions})
            end
        else
            sc(name:'--MAIN--' args:nil defns:nil body:{Expr LineList})
        end
    else
        sc(name:nil args:nil body:nil)
    end
end


fun {Expr ExprList}
    {Map {Infix2Prefix ExprList} fun {$ X} {StringToAtom X} end}
    %{Infix2Prefix ExprList} DEBUG
end

fun {Defns DefnsList}
    SeparatedDefns = {RecursiveSeparate DefnsList fun {$ X} {Not X=="var"} end nil}
in
    {Map SeparatedDefns fun {$ X} {Defn X} end}
end

fun {Defn DefnList}
    Before After
in
    {Separate DefnList nil fun {$ X} {Not X=="="} end Before After}
    %defn(var:Before.1 body:{Infix2Prefix After}) DEBUG
    defn(var:{StringToAtom Before.1} body:{Map {Infix2Prefix After} fun {$ X} {StringToAtom X} end})
end



%% /////////////////////////////////////////////////////////////////////////
%%
%%  MAIN EXECUTION
%%  Search: main.oz
%%
%% /////////////////////////////////////////////////////////////////////////


local Main = {Str2Lst "x + y"}
    Foo = {Str2Lst "fun foo x = var y = x * x in y + y"}
    Foo2 = {Str2Lst "fun foo2 = var y = 2 * 5 in y / x"}
in
    {Browse {SC Main}}
    {Browse {SC Foo}}
    {Browse {SC Foo2}}
end