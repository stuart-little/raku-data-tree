Data::Tree
==========

A **Raku** (rooted) tree data structure modelled on **Haskell**'s [Data.Tree](https://hackage.haskell.org/package/containers-0.6.4.1/docs/Data-Tree.html).

class Tree::RTree
-----------------

RTree: rooted tree containing data and children (other rooted trees)

class Tree::Forest
------------------

Forest: container class for an array of trees

Installation
------------

Using [zef](https://github.com/ugexe/zef): clone this repo and

  * run `zef install <path-to-repo>`;

  * or `cd` into it and run `zef install .`.

Usage
-----

The examples below are run in a `Raku` REPL with access to this module. So assume you've run `use Data::Tree` successfully in your REPL session. 

Construct a tree from a nested list structure (list-of-lists, or lol) and then draw it:

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

"Unfold" a tree using a function `&f` that produces leaves from a seed, and then draw it:

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

Show the levels of that same last tree, as a list of lists:

    > unfoldTree(&f,1).&levels
    [[1] [2 3] [4 5 6 7]]

Or flatten it into a pre-order-traversal list:

    > unfoldTree(&f,1).&flatten
    [1 2 4 5 3 6 7]

Or compute the sum of its vertex values, by folding it with a summation "folder" function:

    > sub folder($head, @rest) { $head + @rest.sum }
    &folder

    > foldTree(&folder, unfoldTree(&f,1))
    28

(sanity check: yes, 1+2+3+4+5+6+7 equals 7 * 8 / 2 = 28). 

There's also a `map` method that both the classes overload, which does what (I think) you think it should. Using that same `&f` I have been in this running example:

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

Finally, here is a list of exported (or exportable) functions, with links to their cousins' documentation from **Haskell** or **Perl**.

Creation
--------

### sub lol2tree

```raku
sub lol2tree(
    @a
) returns Tree::RTree
```

lol2tree

[original inspiration](https://metacpan.org/pod/Tree::DAG_Node#lol_to_tree($lol))

### sub unfoldTree

```raku
sub unfoldTree(
    &unFolder,
    $root
) returns Tree::RTree
```

unfoldTree

[original inspiration](https://hackage.haskell.org/package/containers-0.6.4.1/docs/Data-Tree.html#v:unfoldTree)

### sub unfoldForest

```raku
sub unfoldForest(
    &unFolder,
    @roots
) returns Tree::Forest
```

unfoldForest

[original inspiration](https://hackage.haskell.org/package/containers-0.6.4.1/docs/Data-Tree.html#v:unfoldForest)

Reduction
---------

### sub foldTree

```raku
sub foldTree(
    &folder,
    Tree::RTree $t
) returns Mu
```

foldTree

[original inspiration](https://hackage.haskell.org/package/containers-0.6.4.1/docs/Data-Tree.html#v:foldTree)

### sub flatten

```raku
sub flatten(
    Tree::RTree $t
) returns Array
```

flatten

[original inspiration](https://hackage.haskell.org/package/containers-0.6.4.1/docs/Data-Tree.html#v:flatten)

### sub levels

```raku
sub levels(
    Tree::RTree $t
) returns Array
```

levels

[original inspiration](https://hackage.haskell.org/package/containers-0.6.4.1/docs/Data-Tree.html#v:levels)

Display
-------

### sub drawTree

```raku
sub drawTree(
    Tree::RTree $t
) returns Str
```

drawTree

[original inspiration](https://hackage.haskell.org/package/containers-0.6.4.1/docs/Data-Tree.html#v:drawTree)

### sub drawTreeLines

```raku
sub drawTreeLines(
    Tree::RTree $t
) returns Array
```

drawTreeLines

[original inspiration](https://hackage.haskell.org/package/containers-0.6.4.1/docs/src/Data.Tree.html#draw)

### multi sub drawSubTrees

```raku
multi sub drawSubTrees(
    @ ()
) returns Mu
```

drawSubTrees

[original inspiration](https://hackage.haskell.org/package/containers-0.6.4.1/docs/src/Data.Tree.html#local-6989586621679098624)

### sub drawForest

```raku
sub drawForest(
    Tree::Forest $f
) returns Str
```

drawForest

[original inspiration](https://hackage.haskell.org/package/containers-0.6.4.1/docs/Data-Tree.html#v:drawForest)

