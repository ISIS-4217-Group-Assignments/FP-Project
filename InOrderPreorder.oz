functor
import
    System
    Application
define

fun {FindIndex L Element}
    case L of
    nil then 0
    [] First|Rest then
    Counter in
        if First == Element then
            1
        else
            Counter = {FindIndex Rest Element}
            if Counter == 0 then
                Counter
            else
                1 + Counter
            end
        end
    end
end

fun {Slice L Starts Ends Index}
   case L of
   nil then nil
   [] First|Rest then
      if {And (Index >= Starts) (Index =< Ends)} then
         First | {Slice Rest Starts Ends (Index+1)}
      else
         {Slice Rest Starts Ends (Index+1)}
      end
   end
end

fun {InorderPreorder2BT InOrder PreOrder}
    case PreOrder of
    nil then nil
    [] FirstIn|RestIn then
    Index Leftb Rightb in
        Index = {FindIndex InOrder FirstIn}
        if Index > 0 then
            {System.show Index}
            {System.show FirstIn}
            {System.show RestIn}
            {System.show {Slice InOrder 1 (Index-1) 1}}
            {System.show {Slice InOrder (Index+1) {List.length InOrder} 1}}
            Leftb = {InorderPreorder2BT {Slice InOrder 1 (Index-1) 1} RestIn}
            Rightb = {InorderPreorder2BT {Slice InOrder (Index+1) {List.length InOrder} 1} RestIn}
            node(data: FirstIn left: Leftb right: Rightb)
        else
            nil
        end
    end
end

{System.show {InorderPreorder2BT [3 1 4 0 5 2] [0 1 3 4 2 5]}}
    {Application.exit 0}
end