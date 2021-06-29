unit module Tree;

=begin pod
=head1 Data::Tree

A B<Raku> (rooted) tree data structure modelled on B<Haskell>'s L<Data.Tree|https://hackage.haskell.org/package/containers-0.6.4.1/docs/Data-Tree.html>.
=end pod

#| RTree: rooted tree containing data and children (other rooted trees)
class RTree is export {
    has $.data is rw;
    has RTree @.children is rw = [];

    multi method map(&f --> RTree) {
	return RTree.new(data => f($.data), children => $.children.map({ $_.map(&f) }).Array);
    }

    multi method grep(&f) {
	return self.&grep(&f);
    }
}

#| Forest: container class for an array of trees
class Forest is export {
    has RTree @.trees is rw = [];

    multi method map(&f --> Forest) {
	return Forest.new(trees => $.trees.map({ $_.map(&f) }).Array);
    }

    multi method grep(&f --> Forest) {
	return Forest.new(trees => $.trees.map({ |$_.grep(&f).trees }).Array);
    }
}

=begin pod

=head2 Installation

Using L<zef|https://github.com/ugexe/zef>: clone this repo and

=item run C<zef install <path-to-repo>>;
=item or C<cd> into it and run C<zef install .>.

=head2 Usage

The examples below are run in a C<Raku> REPL with access to this module. So assume you've run C<use Data::Tree> successfully in your REPL session. 

Construct a tree from a nested list structure (list-of-lists, or lol) and then draw it:

=begin code
> [1,[2,4,[5,6,7,8]],3].&lol2tree.&drawTree
1
|
+-2
| |
| +-4
| |
| `-5
|   |
|   +-6
|   |
|   +-7
|   |
|   `-8
|
`-3
=end code

"Unfold" a tree using a function C<&f> that produces leaves from a seed, and then draw it:

=begin code
> sub f($x) {
* 2*$x+1 > 7 && return ($x, []);
* return ($x, [2*$x, 2*$x+1]);
* }
&f

> unfoldTree(&f,1).&drawTree
1
|
+-2
| |
| +-4
| |
| `-5
|
`-3
  |
  +-6
  |
  `-7
=end code 

Show the levels of that same last tree, as a list of lists:

=begin code
> unfoldTree(&f,1).&levels
[[1] [2 3] [4 5 6 7]]
=end code

Or flatten it into a pre-order-traversal list:

=begin code
> unfoldTree(&f,1).&flatten
[1 2 4 5 3 6 7]
=end code

Or compute the sum of its vertex values, by folding it with a summation "folder" function:

=begin code
> sub folder($head, @rest) { $head + @rest.sum }
&folder

> foldTree(&folder, unfoldTree(&f,1))
28
=end code

(sanity check: yes, 1+2+3+4+5+6+7 equals 7 * 8 / 2 = 28). 

There's also a C<map> method that both the classes overload, which does what (I think) you think it should. Using that same C<&f> I have been in this running example:

=begin code
> unfoldTree(&f,1).map(* ** 2).&drawTree
1
|
+-4
| |
| +-16
| |
| `-25
|
`-9
  |
  +-36
  |
  `-49  
=end code

Ditto for C<grep>:

=begin code
> unfoldTree(&f,1).grep({ $_.data != 2|3 }).&drawForest
1
|
+-4
|
+-5
|
+-6
|
`-7
=end code

C<grep> always returns a C<Forest>, hence the need to call C<&drawForest> on the result.

What happened there is that 

=item The predicate I passed identified via a L<junction|https://docs.raku.org/type/Junction> which nodes have their C<data> attrebute equal to either 2 or 3;

=item Those nodes were eliminated;

=item The remaining nodes got stitched together into a forest (consisting of a single tree in this case) via the closest-ancestor relationship.

Whether this is what C<grep> I<should> be doing to a tree is debatable: it could, for instance, simply throw out the relevant nodes and leave it at that, without re-attaching (hence producing a bunch of isolated nodes in this case).

In any case, this is the built-in behavior at present.
=end pod

=begin pod
Finally, here is a list of exported (or exportable) functions, with links to their cousins' documentation from B<Haskell> or B<Perl>.

=end pod

=begin pod
=head2 Creation
=end pod

my multi method grep(RTree:D $t: &f --> Forest) {
    (! $t.&f) && return Forest.new(trees => $t.children).grep(&f);
    my $tree = RTree.new(data => $t.data, children => $t.children.map({ |$_.grep(&f).trees }).Array);
    return Forest.new(trees => [$tree,]);
}

#| lol2tree
sub lol2tree(@a --> RTree) is export {
    (! @a.elems) && return RTree.new();
    return RTree.new(data => @a[0], children => @a.[1..*].map({ ($_ ~~ Array) ?? ($_) !! ([$_]) }).map(*.&lol2tree).Array);
}

=begin pod

L<original inspiration|https://metacpan.org/pod/Tree::DAG_Node#lol_to_tree($lol)>

=end pod

#| unfoldTree
sub unfoldTree(&unFolder, $root --> RTree) is export {
    my $data = $root.&unFolder.[0];
    my @subTrees = $root.&unFolder.[1].map({ unfoldTree(&unFolder, $_) });
    return RTree.new(data => $data, children => @subTrees);
}

=begin pod
L<original inspiration|https://hackage.haskell.org/package/containers-0.6.4.1/docs/Data-Tree.html#v:unfoldTree>
=end pod

#| unfoldForest
sub unfoldForest(&unFolder, @roots --> Forest) is export {
    my @trees = @roots.map({ unfoldTree(&unFolder, $_) });
    return Forest.new(trees => @trees);
}

=begin pod
L<original inspiration|https://hackage.haskell.org/package/containers-0.6.4.1/docs/Data-Tree.html#v:unfoldForest>
=end pod

=begin pod
=head2 Reduction
=end pod

#| foldTree
sub foldTree(&folder, RTree $t) is export {
    return &folder($t.data, $t.children.map({ foldTree(&folder, $_) }))
}

=begin pod
L<original inspiration|https://hackage.haskell.org/package/containers-0.6.4.1/docs/Data-Tree.html#v:foldTree>
=end pod

#| flatten
sub flatten(RTree $t --> Array) is export {
    return [$t.data, |$t.children.map({ $_.&flatten }).map(|*) ]
}

=begin pod
L<original inspiration|https://hackage.haskell.org/package/containers-0.6.4.1/docs/Data-Tree.html#v:flatten>
=end pod

#| levels
sub levels(RTree $t --> Array) is export {
    (! $t.data) && return [];
    return [[$t.data], |roundrobin($t.children.map({ $_.&levels })).map(*.map(|*).Array).Array]
}

=begin pod
L<original inspiration|https://hackage.haskell.org/package/containers-0.6.4.1/docs/Data-Tree.html#v:levels>
=end pod

=begin pod
=head2 Display
=end pod

#| drawTree
sub drawTree(RTree $t --> Str) is export {
    return $t.&drawTreeLines.join("\n");
}

=begin pod
L<original inspiration|https://hackage.haskell.org/package/containers-0.6.4.1/docs/Data-Tree.html#v:drawTree>
=end pod

#| drawTreeLines
sub drawTreeLines(RTree $t --> Array) {
    return [|$t.data.Str.lines, |drawSubTrees($t.children)]
}

=begin pod
L<original inspiration|https://hackage.haskell.org/package/containers-0.6.4.1/docs/src/Data.Tree.html#draw>
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
L<original inspiration|https://hackage.haskell.org/package/containers-0.6.4.1/docs/src/Data.Tree.html#local-6989586621679098624>
=end pod

#| drawForest
sub drawForest(Forest $f --> Str) is export {
    return $f.trees.map({ .&drawTree }).join("\n\n");
}

=begin pod
L<original inspiration|https://hackage.haskell.org/package/containers-0.6.4.1/docs/Data-Tree.html#v:drawForest>
=end pod
