functor
import
    System
    Application
define

class GetOpTree
    attr arityMap root nodes edges counter vacantAt previousAt newAt arity children newOp
    meth init(ArityMap Root)
        arityMap := {Record.toDictionary ArityMap}
        root := Root
        nodes := [Root]
        edges := nil
        counter := 1
        vacantAt := [node(value: Root children: 2)]
        previousAt := Root
        newAt := nil
        arity := 0
        children := 0
        newOp := nil
    end
    
    meth getEdges($)
        @edges
    end
    
    meth assembleBinaryTreeNodesEdges(L)
        for X in L do
            if {List.member X {Dictionary.keys @arityMap}} then
                arity := {Dictionary.get @arityMap X}
                newOp := {String.toAtom {List.append {List.append {Atom.toString X} "-"} {Int.toString @counter}}}
                for Y in 1..(@arity) do
                    newAt := {String.toAtom {List.append "@-" {Int.toString @counter}}}
                    nodes := {List.append @nodes [@newAt]}
                    previousAt := {List.last @vacantAt}
                    children := @previousAt.children
                    edges := {List.append @edges [edge(@previousAt.value @newAt)]}
                    if @children == 1 then
                        vacantAt := {List.append {List.take @vacantAt ({List.length @vacantAt} - 1)} [node(value: @newAt children: 2)]}
                    else
                        vacantAt := {List.append {List.take @vacantAt ({List.length @vacantAt} - 1)} [node(value: @previousAt.value children: (@children - 1)) node(value: @newAt children: 2)]}
                    end
                    counter := @counter + 1
                end
                previousAt := {List.last @vacantAt}
                children := @previousAt.children
                edges := {List.append @edges [edge(@previousAt.value @newOp)]}
                if @children == 1 then
                    vacantAt := {List.take @vacantAt ({List.length @vacantAt} - 1)}
                else
                    vacantAt := {List.append {List.take @vacantAt ({List.length @vacantAt} - 1)} [node(value: @previousAt.value children: (@children - 1))]}
                end
            else
                newOp := X
                previousAt := {List.last @vacantAt}
                children := @previousAt.children
                edges := {List.append @edges [edge(@previousAt.value @newOp)]}
                if @children == 1 then
                    vacantAt := {List.take @vacantAt ({List.length @vacantAt} - 1)}
                else
                    vacantAt := {List.append {List.take @vacantAt ({List.length @vacantAt} - 1)} [node(value: @previousAt.value children: (@children - 1))]}
                end
            end
            if {List.member @newOp @nodes} then
                nodes := @nodes
            else
                nodes := {List.append @nodes [@newOp]}
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
    {System.show {BinTree getEdges($)}}
end
    {Application.exit 0}
end
