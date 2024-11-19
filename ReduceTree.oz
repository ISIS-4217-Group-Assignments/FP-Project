declare

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



%fun {Reduce Tree}
%    
%end


local Tree = app(app(var('+') num(1)) num(2))
    TreeComplex = app(app(var('+') app(app(var('*') num(2)) num(3))) num(4))
    {Browse {IsExpr Tree}}
    {Browse {IsExpr TreeComplex}}
in
    {Browse Tree}
    {Browse TreeComplex}
    %{Browse {Reduce Tree}}
end