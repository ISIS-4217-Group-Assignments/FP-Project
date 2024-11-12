functor
import
    System
    Application
define

class GetOpTree
    attr arityMap root nodes edges counter vacantAt
    meth init(ArityMap Root)
        arityMap := {Record.toDictionary ArityMap}
        root := Root
        nodes := [Root]
        edges := nil
        counter := 1
        vacantAt := [node(value: Root children: 2)]
    end
    
    meth getEdges($)
        @edges
    end
    
    meth assembleBinaryTreeNodesEdges(L)
        for X in L do
            Arity NewAt NewOp PreviousAt Children Tail in
            if {List.member X {Dictionary.keys @arityMap}} then
                Arity = {Dictionary.get @arityMap X}
                NewOp = {String.toAtom {List.append {List.append {Atom.toString X} "-"} {Int.toString @counter}}}
                for Y in 1..(Arity-1) do
                    NewAt = {String.toAtom {List.append "@-" {Int.toString @counter}}}
                    {System.show NewAt}
                    nodes := {List.append @nodes [NewAt]}
                    PreviousAt = {List.last @vacantAt}
                    Children = PreviousAt.children
                    edges := {List.append @edges [edge(NewAt PreviousAt.value)]}
                    if Children == 1 then
                        vacantAt := {List.append {List.take @vacantAt ({List.length @vacantAt} - 1)} [node(value: NewAt children: 2)]}
                    else
                        vacantAt := {List.append {List.take @vacantAt ({List.length @vacantAt} - 1)} [node(value: PreviousAt children: (Children - 1)) node(value: NewAt children: 2)]}
                    end
                    counter := @counter + 1
                end
                PreviousAt = {List.last @vacantAt}
                Children = PreviousAt.children
                edges := {List.append @edges edge(PreviousAt NewOp)}
                if Children == 1 then
                    vacantAt := {List.take @vacantAt ({List.length @vacantAt} - 1)}
                else
                    vacantAt := {List.append {List.take @vacantAt ({List.length @vacantAt} - 1)} [node(value: PreviousAt children: (Children - 1))]}
                end
            else
                NewOp = X
                PreviousAt|Tail = @vacantAt
                Children = PreviousAt.children
                edges := {List.append @edges edge(PreviousAt NewOp)}
                if Children == 1 then
                    @vacantAt := Tail
                else
                    @vacantAt := node(value:PreviousAt children: (Children - 1))
                end
            end
            if {List.member NewOp @nodes} then
                nodes := @nodes
            else
                nodes := {List.append @nodes [NewOp]}
            end
        end
    end
    
    meth EdgesToBinaryTree(Nodes Edges $)
        1
    end
end

local BinTree in
    BinTree = {New GetOpTree init(arity('+': 2 '*': 2) '@-0')}
    {BinTree assembleBinaryTreeNodesEdges(['*' 'z' '+' 'x' 'y'])}

    {System.showInfo 'Welcome to JDoodle!'}
    {System.show ['*' 'z' '+' 'x' 'y']}
end
    {Application.exit 0}
end
