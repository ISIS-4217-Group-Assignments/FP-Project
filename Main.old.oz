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
    Ret={Map {Infix2Prefix ExprList} fun {$ X} {StringToAtom X} end}
in
    %{FoldL Ret.2 fun {$ Acum X} app(Acum X) end Ret.1}
    %{Infix2Prefix ExprList} DEBUG
    Ret
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
%%  TREE REPRESENTATIONS
%%  Search: main.oz
%%
%% /////////////////////////////////////////////////////////////////////////

%% Placeholders
fun {Adds Args}
    case Args of
        nil then 0
        [] H|T then H + {Adds T}
    end
end

fun {Subs Args}
    case Args of
        nil then 0
        [] H|T then H - {Adds T}
    end
end

fun {ApplyOp Op Args}
    if Op == "+" then
        {Adds Args}
    else
        if Op == "-" then
            {Subs Args}
        else
            {System.show 'Unsupported operation!'}
        end
    end
end

fun {GetId Rec}
    Rec.id
end

fun {IsApplication Rec}
    Rec.kind == 'application'
end

fun {IsPrimitive Op}
    {List.member Op ['+' '-' '*' '/']}
end

fun {ExecutionGraph Body OpCounter LastAtConstant LastAtOperation Edges Nodes}
    %%{System.show LastAtConstant}
    %%{System.show LastAtOperation}
    %%{System.show Nodes}
    %%{System.show Edges}
    case Body of nil then graph(nodes: nil edges: nil)
    [] Val|Rest then
    TempNodes TempEdges Graph NodeId AtId in
        if {IsPrimitive Val} then
            AtId = {String.toAtom {List.append "@-" {Int.toString OpCounter}}}
            NodeId = {String.toAtom {List.append {Atom.toString Val} {List.append "-" {Int.toString OpCounter}}}}
            %%TempEdges = {List.append Edges [edge(AtId NodeId)]}
            TempEdges = [edge(AtId NodeId)]
            %%TempNodes = {List.append Nodes [node(id: NodeId value: Val kind: 'function') node(id: AtId value:'@' kind: 'application')]}
            TempNodes = [node(id: NodeId value: Val kind: 'function') node(id: AtId value:'@' kind: 'application')]
            Graph = {ExecutionGraph Rest OpCounter+1 LastAtConstant AtId TempEdges {List.append Nodes TempNodes}}
        else
            NodeId = Val
            if {List.member NodeId {List.map Nodes GetId}} then
                %%TempNodes = Nodes
                TempNodes = nil
            else
                %%TempNodes = {List.append Nodes [node(id: NodeId value: Val kind: 'value')]}
                TempNodes = [node(id: NodeId value: Val kind: 'value')]
            end
            if {List.length Rest} > 0 then
                if {List.member {List.nth Rest 1} ['+' '-' '*' '/']} then
                    %%TempEdges = {List.append Edges [edge(LastAtOperation Val) edge(LastAtConstant LastAtOperation)]}
                    TempEdges = [edge(LastAtOperation Val) edge(LastAtConstant LastAtOperation)]
                    Graph = {ExecutionGraph Rest OpCounter+1 LastAtConstant LastAtOperation TempEdges {List.append Nodes TempNodes}}
                else
                    %%if {List.length {List.filter Rest IsPrimitive}} > 0 then
                    if OpCounter > 3 then
                        AtId = {String.toAtom {List.append "@-" {Int.toString OpCounter}}}
                        %%TempEdges = {List.append Edges [edge(AtId NodeId) edge(LastAtConstant AtId)]}
                        TempEdges = [edge(AtId NodeId) edge(LastAtConstant AtId)]
                        Graph = {ExecutionGraph Rest OpCounter+1 AtId LastAtOperation TempEdges {List.append Nodes {List.append TempNodes [node(id: AtId value:'@' kind: 'application')]}}}
                    else
                        TempEdges = [edge(LastAtConstant NodeId)]
                        Graph = {ExecutionGraph Rest OpCounter+1 LastAtConstant LastAtOperation TempEdges {List.append Nodes TempNodes}}
                    end
                end
            else
                %%TempEdges = {List.append Edges [edge(LastAtOperation Val) edge(LastAtConstant LastAtOperation)]}
                TempEdges = [edge(LastAtOperation NodeId) edge(LastAtConstant LastAtOperation)]
                Graph = {ExecutionGraph Rest OpCounter+1 LastAtConstant LastAtOperation TempEdges {List.append Nodes TempNodes}}
            end
        end
        graph(nodes: {List.append Graph.nodes TempNodes} edges: {List.append Graph.edges TempEdges})
    end
end
            
        


%% /////////////////////////////////////////////////////////////////////////
%%
%%  MAIN EXECUTION
%%  Search: main.oz
%%
%% /////////////////////////////////////////////////////////////////////////


local Main = {Str2Lst "foo ( 1 * 2 ) + 3"}
    Foo = {Str2Lst "fun foo x = var y = x * x + x in y + y * y"}
    Foo2 = {Str2Lst "fun foo2 = var y = 2 * 5 in y / x"}
in
    {Browse {SC Main}}
    %{Browse {ExecutionGraph {SC Main}.body 1 '@-0' '@-nil' nil [node(id: '@-0' value: '@' kind: 'application')]}}
    %{Browse {SC Foo}}
    %{Browse {ExecutionGraph {SC Foo}.body 1 '@-0' '@-nil' nil [node(id: '@-0' value: '@' kind: 'application')]}}
    %{Browse {SC Foo2}}
end
