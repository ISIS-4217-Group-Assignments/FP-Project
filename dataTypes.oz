%% Auxiliary Functions
declare Separate

proc {Separate Stack Res Cond Before After}
    case Stack of H|T then
        if {Cond H} then 
            {Separate T {Append Res [H]} Cond Before After}
        else
            %[Res Stack.2]
            Before = Res
            After = Stack.2
        end
    else
        %[Res Stack]
        Before = Res
        After = Stack
    end
end

%local COCO = [1 2 3 4 5 6 7 8 9]
%in
%    {Browse hola}
    %{Browse {Separate COCO nil fun {$ X} {Not X==69} end}}
%end




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
                sc(name:{StringToAtom Name} args:ArgList defns:{Defns Definitions} body:{Expr Expresions})
            end
        else
            sc(name:'--MAIN--' args:nil defns:nil body:{Expr LineList})
        end
    else
        sc(name:nil args:nil body:nil)
    end
end


fun {Expr ExprList}
    {Map ExprList fun {$ X} {StringToAtom X} end}
end

fun {Defns DefnsList}
    {Map DefnsList fun {$ X} {StringToAtom X} end}
end



local Main = ["x" "+" "y"]
    Foo = ["fun" "foo" "x" "=" "var" "y" "=" "x" "*" "x" "in" "y"]
    Foo2 = ["fun" "foo2" "=" "var" "y" "=" "2" "*" "5" "in" "y" "/" "5"]
in
    {Browse {SC Main}}
    {Browse {SC Foo}}
    {Browse {SC Foo2}}
end