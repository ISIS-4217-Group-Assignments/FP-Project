declare BINOP = ["+" "-" "/" "*"]


fun {Satisfies TheList Cond}
    case TheList of H|T then
        if {Cond H} then H
        else
            {Satisfies T Cond}
        end
    else
        nil
    end
end


fun {IndexSatisfies TheList Cond State}
    case TheList of H|T then
        if {Cond H} then State
        else
            {IndexSatisfies T Cond State+1}
        end
    else
        ~1
    end
end


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


fun {ReplaceParemeters Tree Stack ParameterList SCList}
    case Tree of app(L R) then app({ReplaceParemeters L Stack ParameterList SCList} {ReplaceParemeters R Stack ParameterList SCList})
    [] var(Name) then
        local Position = {IndexSatisfies ParameterList fun {$ X} Name==X end 1}

        in
            if Position>=1 then {Nth Stack Position}.2 
            else
                Tree
            end
        end
    else
        Tree
    end
end



fun {BinopOperation Stack Op SCList}
    First = {Reduce {Nth Stack 1}.2 nil SCList}
    Second = {Reduce {Nth Stack 2}.2 nil SCList}
in
    if {Or First==error Second==error} then {Browse error} error
    else
        local num(FParameter) = First
            num(SParameter) = Second
            FirstParameter = {StringToFloat {AtomToString FParameter}}
            SecondParameter = {StringToFloat {AtomToString SParameter}}
        in
            case Op of '/' then num({StringToAtom {FloatToString FirstParameter/SecondParameter}})
            else
                num({StringToAtom {FloatToString {Number.Op FirstParameter SecondParameter}}})
            end
        end
    end
end



fun {Reduce Tree Stack SCList}
    case Tree of 
    app(L _) then
        {Reduce L Tree|Stack SCList}
    [] var(Op) then 
        if {Member Op {Map BINOP fun {$ X} {StringToAtom X} end}} then
            %{Browse Stack}
            {BinopOperation Stack Op SCList}
        else
            local
                SCContent = {Satisfies SCList fun {$ X} X.name==Op end}
                SCBody = SCContent.body.1
            in
                {Reduce {ReplaceParemeters SCBody Stack SCContent.args SCList} nil SCList}
            end
        end
    [] num(_) then Tree
    else
        error
    end
 end
 

local Tree = app(app(var(timer) num('3')) num('2'))
    TreeComplex = app(app(var('/') app(app(var('*') num('5')) num('2'))) app(app(var('-') app(app(var('*') num('2')) num('10'))) num('6')))
    SCLister = [sc(args:[x y] body:[app(app(var('-') var(y)) var(x))] name:timer)]
    % {Browse {IsExpr Tree}}
    % {Browse {IsExpr TreeComplex}}
in
    % {Browse Tree}
    % {Browse TreeComplex}
    %{Browse {Reduce Tree}}
    {Browse {Reduce Tree nil SCLister}}
    {Browse {IsExpr {Reduce Tree nil SCLister}}}       
    %{Browse {Reduce TreeComplex nil nil}} % Gradually reduces complex tree: app(app(var('+') num(6)) num(4))
    %{Browse {FullReduce TreeComplex}}
end