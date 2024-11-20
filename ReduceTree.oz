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



fun {Reduce Tree}
    case Tree of 
       % reduce op binarias con numeros
       app(app(var(Op) Left) Right) andthen {Num Left} andthen {Num Right} then
          case Op of
             '+' then num(Left.1 + Right.1)
             [] '-' then num(Left.1 - Right.1)
             [] '*' then num(Left.1 * Right.1)
             [] '/' then num(Left.1 / Right.1)
             else Tree
          end
       % recursivo izq
       [] app(app(var(Op) Left) Right) then
          app(app(var(Op) {Reduce Left}) Right)
       % recursivo der
       [] app(app(var(Op) Left) Right) then
          app(app(var(Op) Left) {Reduce Right})
       % op nesteadas
       [] app(L R) then
          app({Reduce L} {Reduce R})
       else 
          Tree
      end
 end
 
 fun {FullReduce Tree}
    local ReducedTree = {Reduce Tree} in
       if ReducedTree == Tree then 
          Tree
       else 
          {FullReduce ReducedTree}
       end
    end
 end


local Tree = app(app(var('+') num(1)) num(2))
    TreeComplex = app(app(var('+') app(app(var('*') num(2)) num(3))) num(4))
    % {Browse {IsExpr Tree}}
    % {Browse {IsExpr TreeComplex}}
in
    % {Browse Tree}
    % {Browse TreeComplex}
    %{Browse {Reduce Tree}}
    {Browse {FullReduce Tree}}        
    {Browse {Reduce TreeComplex}} % Gradually reduces complex tree: app(app(var('+') num(6)) num(4))
    {Browse {FullReduce TreeComplex}}
end