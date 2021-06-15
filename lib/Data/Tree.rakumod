unit module Tree;

class RTree is export {
    has $.data is rw;
    has RTree @.children is rw = [];
}

class Forest is export {
    has RTree @.trees is rw;
}

=begin pod
=head1 Data::Tree

A B<Raku> (rooted) tree data structure modelled on B<Haskell>'s L<Data.Tree|https://hackage.haskell.org/package/containers-0.6.4.1/docs/Data-Tree.html>.
=end pod

=begin pod
=head2 Creation
=end pod

#| lol2tree
sub lol2tree(@a --> RTree) is export {
    (! @a.elems) && return RTree.new();
    return RTree.new(data => @a[0], children => @a.[1..*].map({ ($_ ~~ Array) ?? ($_) !! ([$_]) }).map(*.&lol2tree).Array);
}

=begin pod

L<inspired by|https://metacpan.org/pod/Tree::DAG_Node#lol_to_tree($lol)>

=end pod

#| unfoldTree
sub unfoldTree(&unFolder, $root --> RTree) is export {
    my $data = $root.&unFolder.[0];
    my @subTrees = $root.&unFolder.[1].map({ unfoldTree(&unFolder, $_) });
    return RTree.new(data => $data, children => @subTrees);
}

=begin pod
L<inspired by|https://hackage.haskell.org/package/containers-0.6.4.1/docs/Data-Tree.html#v:unfoldTree>
=end pod

#| unfoldForest
sub unfoldForest(&unFolder, @roots --> Forest) is export {
    my @trees = @roots.map({ unfoldTree(&unFolder, $_) });
    return Forest.new(trees => @trees);
}

=begin pod
L<inspired by|https://hackage.haskell.org/package/containers-0.6.4.1/docs/Data-Tree.html#v:unfoldForest>
=end pod

=begin pod
=head2 Reduction
=end pod

#| foldTree
sub foldTree(&folder, RTree $t) is export {
    return &folder($t.data, $t.children.map({ foldTree(&folder, $_) }))
}

=begin pod
L<inspired by|https://hackage.haskell.org/package/containers-0.6.4.1/docs/Data-Tree.html#v:foldTree>
=end pod

#| flatten
sub flatten(RTree $t) is export {
    return [$t.data, |$t.children.map({ $_.&flatten }).map(|*) ]
}

=begin pod
L<inspired by|https://hackage.haskell.org/package/containers-0.6.4.1/docs/Data-Tree.html#v:flatten>
=end pod

#| levels
sub levels(RTree $t) is export {
    (! $t.data) && return [];
    return [[$t.data], |roundrobin($t.children.map({ $_.&levels })).map(*.map(|*).Array).Array]
}

=begin pod
L<inspired by|https://hackage.haskell.org/package/containers-0.6.4.1/docs/Data-Tree.html#v:levels>
=end pod

=begin pod
=head2 Display
=end pod

#| drawTree
sub drawTree(RTree $t) is export {
    return $t.&drawTreeLines.join("\n");
}

=begin pod
L<inspired by|https://hackage.haskell.org/package/containers-0.6.4.1/docs/Data-Tree.html#v:drawTree>
=end pod

#| drawTreeLines
sub drawTreeLines(RTree $t) {
    return [|$t.data.Str.lines, |drawSubTrees($t.children)]
}

=begin pod
L<inspired by|https://hackage.haskell.org/package/containers-0.6.4.1/docs/src/Data.Tree.html#draw>
=end pod

#| drawSubTrees
multi sub drawSubTrees([]) { return [] }
multi sub drawSubTrees([$t]) {
    return ["|", |(("`-", "  ", {$_} ... *) Z~ ($t.&drawTreeLines))]
}
multi sub drawSubTrees(@ts) {
    return ["|", |(("+-", "| ", {$_} ... *) Z~ (@ts.[0].&drawTreeLines)), |(drawSubTrees(@ts[1..*]))]
}

=begin pod
L<inspired by|https://hackage.haskell.org/package/containers-0.6.4.1/docs/src/Data.Tree.html#local-6989586621679098624>
=end pod

#| drawForest
sub drawForest(Forest $f --> Str) is export {
    return $f.trees.map({ .&drawTree }).join("\n");
}

=begin pod
L<inspired by|https://hackage.haskell.org/package/containers-0.6.4.1/docs/Data-Tree.html#v:drawForest>
=end pod
