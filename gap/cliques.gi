#############################################################################
##
#W  cliques.gi
#Y  Copyright (C) 2015-16                                Markus Pfeiffer
##                                                       Raghav Mehra
##                                                       Wilfred A. Wilson
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# IsIndependentSet: Check that the set is a duplicate-free subset of vertices
#                   and that no vertex is an out-neighbour of another.

InstallMethod(IsIndependentSet, "for a digraph and a homogeneous list",
[IsDigraph, IsHomogeneousList],
function(gr, set)
  if not IsDuplicateFreeList(set)
      or not ForAll(set, x -> x in DigraphVertices(gr)) then
    ErrorMayQuit("Digraphs: IsIndependentSet: usage,\n",
                 "the second argument <set> must be a duplicate-free list of ",
                 "vertices of the\ndigraph <gr>,");
  fi;
  return ForAll(set, x -> IsEmpty(Intersection(OutNeighboursOfVertex(gr, x),
                                               set)));
end);

# IsMaximalIndependentSet: Check that the set is indeed an independent set.
#                          Then repeatedly look through a vertex which is
#                          not out-neighbours of the set, and see whether it
#                          has an out-neighbour in the set.

InstallMethod(IsMaximalIndependentSet, "for a digraph and a homogeneous list",
[IsDigraph, IsHomogeneousList],
function(gr, set)
  local nbs, try, v;

  if not IsIndependentSet(gr, set) then
    return false;
  fi;

  nbs := Unique(Concatenation(List(set, v -> OutNeighboursOfVertex(gr, v))));
  nbs := Concatenation(nbs, set);
  try := Difference(DigraphVertices(gr), nbs);
  while not IsEmpty(try) do
    v := Remove(try);
    if IsEmpty(Intersection(set, OutNeighboursOfVertex(gr, v))) then
      return false;
    fi;
    try := Difference(try, OutNeighboursOfVertex(gr, v));
  od;
  return true;
end);

# IsClique: Check that the set is a duplicate-free subset of vertices
#           and that every vertex is an out-neighbour of the others.

InstallMethod(IsClique, "for a digraph and a homogeneous list",
[IsDigraph, IsHomogeneousList],
function(gr, clique)
  local nbs, v;

  if not IsDuplicateFreeList(clique)
      or not ForAll(clique, x -> x in DigraphVertices(gr)) then
    ErrorMayQuit("Digraphs: IsClique: usage,\n",
                 "the second argument <clique> must be a duplicate-free list ",
                 "of vertices of the\ndigraph <gr>,");
  fi;
  nbs := OutNeighbours(gr);
  for v in clique do
    if not ForAll(clique, x -> x = v or x in nbs[v]) then
      return false;
    fi;
  od;
  return true;
end);

# IsMaximalClique: Check that the set is indeed a clique.
#                  Then find the intersection of the out-neighbours of the
#                  vertices of the clique. If there are no vertices; it's a max
#                  clique. Otherwise check for any vertex whose out-neighbours
#                  include the clique: the clique is maximal if and only if
#                  there are no such vertices.

InstallMethod(IsMaximalClique, "for a digraph and a homogeneous list",
[IsDigraph, IsHomogeneousList],
function(gr, clique)
  local nbs, try, n, i;

  if not IsClique(gr, clique) then
    return false;
  fi;

  nbs := OutNeighbours(gr);
  try := DigraphVertices(gr);
  n := Length(clique);
  i := 0;
  while i < n and Length(try) > 0 do
    i := i + 1;
    try := Intersection(try, nbs[clique[i]]);
  od;
  if IsSubset(clique, try) then
    return true;
  fi;

  return not ForAny(Difference(try, clique),
                    v -> ForAll(clique, x -> x = v or x in nbs[v]));
end);

################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################

InstallGlobalFunction(DigraphMaximalClique,
function(arg)
  if IsEmpty(arg) then
    ErrorMayQuit("Digraphs: DigraphMaximalClique: usage,\n",
                 "this function takes at least one argument,");
  fi;
  return DIGRAPHS_Clique(Concatenation([true], arg));
end);

#

InstallGlobalFunction(DigraphClique,
function(arg)
  if IsEmpty(arg) then
    ErrorMayQuit("Digraphs: DigraphClique: usage,\n",
                 "this function takes at least one argument,");
  fi;
  return DIGRAPHS_Clique(Concatenation([false], arg));
end);

#

InstallGlobalFunction(DIGRAPHS_Clique,
function(arg)
  local maximal, gr, G, include, exclude, size, out, try, include_copy, v;

  arg := arg[1];
  maximal := arg[1];

  # Validate arg[2]
  gr := arg[2];
  if not IsDigraph(gr) then
    ErrorMayQuit("Digraphs: DIGRAPHS_Clique: usage,\n",
                 "the first argument <gr> must be a digraph,");
  fi;

  G := DigraphGroup(gr);

  # Validate arg[3]
  if IsBound(arg[3]) then
    include := arg[3];
    if not IsHomogeneousList(include) or not IsDuplicateFreeList(include)
        or not IsSubset(DigraphVertices(gr), include) then
      ErrorMayQuit("Digraphs: DIGRAPHS_Clique: usage,\n",
                   "the optional second argument <include> must be a ",
                   "duplicate-free set of vertices\nof <gr>,");
    fi;
  else
    include := [];
  fi;


  # Validate arg[4]
  if IsBound(arg[4]) then
    exclude := arg[4];
    if not IsHomogeneousList(exclude) or not IsDuplicateFreeList(exclude)
        or not IsSubset(DigraphVertices(gr), exclude) then
      ErrorMayQuit("Digraphs: DIGRAPHS_Clique: usage,\n",
                   "the optional third argument <exclude> must be a ",
                   "duplicate-free set of verticies\nof <gr>,");
    fi;
  else
    exclude := [];
  fi;

  # Validate arg[5]
  if IsBound(arg[5]) then
    size := arg[5];
    if not IsPosInt(size) then
      ErrorMayQuit("Digraphs: DIGRAPHS_Clique: usage,\n",
                   "the optional fourth argument <size> must be a positive ",
                   "integer,");
    fi;
  fi;

  if not IsClique(gr, include) then
    return fail;
  elif not IsEmpty(Intersection(include, exclude)) then
    return fail;
  fi;

  # Perform 4-argument version of the function
  if IsBound(size) then
    if maximal then
      out := DigraphMaximalCliques(gr, include, exclude, 1, size);
    else
      out := DigraphCliquesOfSize(gr, size, include, exclude, 1);
    fi;
    if IsEmpty(out) then
      return fail;
    fi;
    return out[1];
  fi;

  # Perform 3-argument version if maximal = true
  if IsBound(arg[4]) and maximal then
    out := DigraphMaximalCliques(gr, include, exclude, 1);
    if IsEmpty(out) then
      return false;
    fi;
    return out[1];
  fi;

  # Do a greedy search to find a clique of <gr> containing <include> and
  # excluding <exclude> (which is necessarily maximal if <exclude> is empty)
  gr := MaximalSymmetricSubdigraph(gr);
  out := OutNeighbours(gr);
  try := Difference(DigraphVertices(gr), Concatenation(include, exclude));
  include_copy := ShallowCopy(include);

  while not IsEmpty(include_copy) and not IsEmpty(try) do
    v := Remove(include_copy);
    try := Intersection(try, out[v]);
  od;

  while not IsEmpty(try) do
    v := Remove(try);
    Add(include, v);
    try := Intersection(try, out[v]);
  od;
  return include;
end);

#

InstallMethod(DigraphMaximalCliquesRepsAttr,
"for a digraph",
[IsDigraph],
function(gr)
  return DigraphMaximalCliquesReps(gr);
end);

#

InstallGlobalFunction(DigraphMaximalCliquesReps,
function(arg)
  local digraph, include, exclude, limit, size, out;

  if IsEmpty(arg) then
    ErrorMayQuit("Digraphs: DigraphMaximalCliquesReps: usage,\n",
                 "this function takes at least one argument,");
  fi;

  digraph := arg[1];

  if IsBound(arg[2]) then
    include := arg[2];
  else
    include := [];
  fi;

  if IsBound(arg[3]) then
    exclude := arg[3];
  else
    exclude := [];
  fi;

  if IsBound(arg[4]) then
    limit := arg[4];
  else
    limit := infinity;
  fi;

  if IsBound(arg[5]) then
    size := arg[5];
  else
    size := fail;
  fi;

  if IsList(include) and IsEmpty(include) and IsList(exclude)
    and IsEmpty(exclude) and limit = infinity and size = fail
    and HasDigraphMaximalCliquesAttr(digraph) then
      return DigraphMaximalCliquesAttr(digraph);
    fi;
  fi;

  out := [];
  CliquesFinder(digraph, fail, out, limit, include, exclude, true, size, true);

  # Store the result if appropriate
  if IsEmpty(include) and IsEmpty(exclude) and limit = infinity
      and size = fail then
    SetDigraphMaximalCliquesRepsAttr(digraph, out);
    if IsTrivial(DigraphGroup(digraph)) then
      SetDigraphMaximalCliquesAttr(digraph, out);
    fi;
  fi;
  return out;
end);

# Maximal cliques

InstallMethod(DigraphMaximalCliquesAttr,
"for a digraph",
[IsDigraph],
function(gr)
  return DigraphMaximalCliques(gr);
end);

#

InstallGlobalFunction(DigraphMaximalCliques,
function(arg)
  local digraph, include, exclude, limit, size, out;

  if IsEmpty(arg) then
    ErrorMayQuit("Digraphs: DigraphMaximalCliquesReps: usage,\n",
                 "this function takes at least one argument,");
  fi;

  digraph := arg[1];

  if IsBound(arg[2]) then
    include := arg[2];
  else
    include := [];
  fi;

  if IsBound(arg[3]) then
    exclude := arg[3];
  else
    exclude := [];
  fi;

  if IsBound(arg[4]) then
    limit := arg[4];
  else
    limit := infinity;
  fi;

  if IsBound(arg[5]) then
    size := arg[5];
  else
    size := fail;
  fi;

  if IsList(include) and IsEmpty(include) and IsList(exclude) and
      IsEmpty(exclude) and limit = infinity and size = fail then
    if HasDigraphMaximalCliquesAttr(digraph) then
      return DigraphMaximalCliquesAttr(digraph);
    fi;
    out := DigraphMaximalCliquesReps(digraph);
    if IsTrivial(DigraphGroup(digraph)) then
      return out;
    fi;
    G := DigraphGroup(digraph);
    out := Concatenation(List(out, x -> Orbit(G, x)));
  fi;

  out := [];
  CliquesFinder(digraph, fail, out, limit, include, exclude, true, size, false);

  # Store the result if appropriate
  if IsEmpty(include) and IsEmpty(exclude) and limit = infinity
      and size = fail then
    SetDigraphMaximalCliquesAttr(digraph, out);
    if IsTrivial(DigraphGroup(digraph)) then
      SetDigraphMaximalCliquesRepsAttr(digraph, out);
    fi;
  fi;
  return out;
end);

################################################################################

InstallGlobalFunction(CliquesFinder,
function(gr, hook, user_param, limit, include, exclude, max, size, reps)
  local n, group, invariant_include, invariant_exclude, include_variant,
  exclude_variant, x, v, o, i;

  if not IsDigraph(gr) then
    ErrorMayQuit("Digraphs: CliquesFinder: usage,\n",
                 "the first argument <gr> must be a digraph,");
  fi;

  if hook <> fail then
    if not (IsFunction(hook) and NumberArgumentsFunction(hook) = 2) then
      ErrorMayQuit("Digraphs: CliquesFinder: usage,\n",
                   "the second argument <hook> has to be either fail, or a ",
                   "function with two\narguments,");
    fi;
  elif not IsList(user_param) then
    ErrorMayQuit("Digraphs: CliquesFinder: usage,\n",
                 "when the fourth argument <hook> is fail, the third ",
                 "argument <user_param> has\nto be a list,");
  fi;

  if limit <> infinity and not IsPosInt(limit) then
    ErrorMayQuit("Digraphs: CliquesFinder: usage,\n",
                 "the fourth argument <limit> has to be either infinity, or ",
                 "a positive integer,");
  fi;

  n := DigraphNrVertices(gr);
  if not (IsHomogeneousList(include)
          and ForAll(include, x -> IsPosInt(x) and x <= n)
          and IsDuplicateFreeList(include))
      or not (IsHomogeneousList(exclude)
              and ForAll(exclude, x -> IsPosInt(x) and x <= n)
              and IsDuplicateFreeList(exclude))
      then
    ErrorMayQuit("Digraphs: CliquesFinder: usage,\n",
                 "the fifth argument <include> and the sixth argument ",
                 "<exclude> have to be\n(possibly empty) duplicate-free lists ",
                 "of vertices of the digraph in the first\nargument <gr>,");
  fi;

  if not max in [true, false] then
    ErrorMayQuit("Digraphs: CliquesFinder: usage,\n",
                 "the seventh argument <max> must be either true or false,");
  fi;

  if size <> fail and not IsPosInt(size) then
    ErrorMayQuit("Digraphs: CliquesFinder: usage,\n",
                 "the eighth argument <size> has to be either fail, or a ",
                 "positive integer,");
  fi;

  if not reps in [true, false] then
    ErrorMayQuit("Digraphs: CliquesFinder: usage,\n",
                 "the ninth argument <reps> must be either true or false,");
  fi;

  # Investigate whether <include> and <exclude> are invariant under <grp>
  group := DigraphGroup(gr);

  invariant_include := true;
  invariant_exclude := true;
  include_variant := [];
  exclude_variant := [];

  if not IsTrivial(group) and (not IsEmpty(include) or not IsEmpty(exclude))
      then
    if not ForAll(GeneratorsOfGroup(group),
                  x -> IsSubset(include, OnTuples(include, x))) then
      invariant_include := false;
      if not reps then
        x := ShallowCopy(include);
        while not IsEmpty(x) do
          v := x[1];
          o := List(Orbit(group, v));
          i := Intersection(x, o);
          if not IsSubset(x, o) then
            Append(include_variant, i);
          fi;
          x := Difference(x, i);
        od;
      fi;
    fi;
    if not ForAll(GeneratorsOfGroup(group),
                  x -> IsSubset(exclude, OnTuples(exclude, x))) then
      invariant_exclude := false;
      if not reps then
        x := ShallowCopy(exclude);
        while not IsEmpty(x) do
          v := x[1];
          o := List(Orbit(group, v));
          i := Intersection(x, o);
          if not IsSubset(x, o) then
            Append(exclude_variant, i);
          fi;
          x := Difference(x, i);
        od;
      fi;
    fi;

    if reps and not (invariant_include and invariant_exclude) then
      ErrorMayQuit("Digraphs: CliquesFinder: usage,\n",
                   "if the ninth argument <reps> is true then the fourth and ",
                   "fifth arguments\n<include> and <exclude> must be ",
                   "invariant under the action of the DigraphGroup\nof <gr>,");
    fi;
  fi;

  return DIGRAPHS_BronKerbosch(gr, hook, user_param, limit, include, exclude,
                               max, size, reps, include_variant,
                               exclude_variant);
end);

InstallGlobalFunction(DIGRAPHS_BronKerbosch,
function(gr, hook, user_param, lim, inc, exc, max, size, reps, inc_var, exc_var)
  local vtx, grp, invariant_inc, invariant_exc, invariant, adj, exc_inv, start,
  possible, add, bk, num, x;

  # Arguments should be:
  # gr   - a digraph
  # hook - fail or a function
  # user-param - a list or the first argument of hook
  # inc  - a duplicate-free list of vertices of <gr>
  # exc  - a duplicate-free list of vertices of <gr>
  # lim  - a positive integer or infinity
  # size - a positive integer
  # max  - do we care whether the results are maximal?
  # reps - do we want to return all valid results or orbit representatives?

  # Test for easy cases
  if size <> fail and Length(inc) > size then
    return [];
  elif ForAny(exc, x -> x in inc) then
    # the clique contains excluded vertices
    return [];
  elif size <> fail
      and size > DigraphNrVertices(gr) - Length(exc) then
    # the desired clique size is too big
    return [];
  elif not IsClique(gr, inc) then
    # the set we wish to extend is not a clique
    return [];
  fi;

  if hook = fail then
    hook := Add;
  fi;

  vtx := DigraphVertices(gr);
  grp := DigraphGroup(gr);

  invariant_inc := Length(inc_var) = 0;
  invariant_exc := Length(exc_var) = 0;
  invariant := invariant_inc and invariant_exc;

  gr := MaximalSymmetricSubdigraphWithoutLoops(gr);
  adj := BooleanAdjacencyMatrix(gr);

  # Variables
  # gr    - a symmetric digraph without loops and multiple edges whose cliques
  #         coincide with those of the original digraph
  # adj   - boolean adjacency matrix of <gr>
  # vtx   - DigraphVertices(gr)
  # num   - number of results found so far
  # grp   - a perm group, a subgroup of the automorphism group of <gr>
  # invariant_inc - is inc invariant under grp?
  # invariant_exc - is exc invariant under grp?
  # inc_var - the subset of inc whose orbit is not contained in inc
  # exc_var - the subset of exc whose orbit is not contained in exc
  # exc_inv - the subset of exc whose orbit is contained in exc

  ##############################################################################
  # Preparation, and processing of variables

  inc_var  := BlistList(vtx, inc_var);
  exc_var  := BlistList(vtx, exc_var);
  exc_inv  := DifferenceBlist(BlistList(vtx, exc), exc_var);
  start    := BlistList(vtx, inc);
  possible := BlistList(vtx, vtx);
  SubtractBlist(possible, start);
  for x in inc do
    IntersectBlist(possible, adj[x]);
  od;

  # Function to find the valid cliques of an orbit given an orbit rep
  add := function(c)
    local orb, n, i;

    c := ListBlist(vtx, c);
    if reps then # we are only looking for orbit reps, so add the rep
      hook(user_param, c);
      num := num + 1;
      return;
    fi;

    orb := Orbit(grp, c, OnSets);
    n := Length(orb);
    if invariant then # we're not just looking for orbit reps, but inc and exc
                      # are invariant so there is nothing extra to check
      n := Minimum(lim - num, n);
      for c in orb{[1 .. n]} do
        hook(user_param, c);
      od;
      num := num + n;
      return;
    fi;

    if invariant_inc then
      # Cliques in the orbit might contain forbidden vertices
      i := 0;
      while i < n and num < lim do
        i := i + 1;
        c := BlistList(vtx, orb[i]);
        if SizeBlist(IntersectionBlist(exc_var, c)) = 0 then
          hook(user_param, orb[i]);
          num := num + 1;
        fi;
      od;
    elif invariant_exc then
      # Cliques in the orbit might not contain all required vertices
      i := 0;
      while i < n and num < lim do
        i := i + 1;
        c := BlistList(vtx, orb[i]);
        if IsSubsetBlist(c, inc_var) then
          hook(user_param, orb[i]);
          num := num + 1;
        fi;
      od;
    else
      # Cliques in the orbit might contain forbidden vertices
      # Cliques in the orbit might not contain all required vertices
      i := 0;
      while i < n and num < lim do
        i := i + 1;
        c := BlistList(vtx, orb[i]);
        if SizeBlist(IntersectionBlist(exc_var, c)) = 0
            and IsSubsetBlist(c, inc_var) then
          hook(user_param, orb[i]);
          num := num + 1;
        fi;
      od;
    fi;
    return;
  end;

  # Main recursive function
  bk := function(c, try, ban, G, d)
    local orb, try_orb, top, piv, m, to_try, C, g, v;

    # <c> is a new clique rep
    if d > 0 and not max and (size = fail or size = d) then
      # <c> has the desired size (if any) and we don't care about maximality
      add(c);
      if max or size <> fail then
        return;
      fi;
      # we continue if we're looking for all cliques, not just maximal

    elif SizeBlist(ban) = 0 and SizeBlist(try) = 0 then
      # <c> is a new maximal clique
      if (size = fail or size = d) then
        # <c> is a new maximal clique rep and it has the right size (if req)
        add(c);
        return;
      fi;
      return;
    fi;

    d := d + 1;
    if size <> fail and size < d then
      return;
    fi;

    # TODO should this come after choosing the pivot or before?
    orb := ListBlist(vtx, UnionBlist(try, ban));
    if not G = fail then # Use the group <G> to prune the vertices to try
      orb := Orbits(G, orb);
      orb := List(orb, x -> x[1]);
      try_orb := IntersectionBlist(BlistList(vtx, orb), try);
    else
      try_orb := ShallowCopy(try);
    fi;

    # If we are searching for *maximal* cliques then choose a pivot
    if max then
      # Choose a pivot: choose a vertex with maximum out-degree in try or ban
      # TODO optimise choice of pivot

      # Strategy 1: choose vertex in orb (try union ban, mod G) of max degree
      #top := -1;
      #piv := 0;
      #for v in orb do
      #  if deg[v] > top then # where #deg = OutDegrees(gr)
      #    piv := v;
      #    top := deg[v];
      #  fi;
      #od;

      # Is this a better way of choosing a pivot?
      # Strategy 2: choose vertex in orb (try union ban, mod G) with max number
      #             of neighbours in try_orb (try mod G)
      top := -1;
      piv := 0;
      for v in orb do
        m := SizeBlist(IntersectionBlist(try_orb, adj[v]));
        if m > top then
          piv := v;
          top := m;
        fi;
      od;

      # Strategy 3: choose vertex in orb (try union ban, mod G) with max number
      #             of neighbours in try
      # NOT YET IMPLEMENTED OR TESTED

      to_try := ShallowCopy(ListBlist(vtx, DifferenceBlist(try_orb,
                                                           adj[piv])));
    else
      # If we are searching for cliques (not necessarily maximal) of a given
      # size then the logic of using a pivot doesn't work
      to_try := ListBlist(vtx, try_orb);
    fi;

    # Try to extend <c> and recurse
    for v in to_try do
      if not exc_inv[v] then # We are allowed to add <v> to <c>
        C := ShallowCopy(c);
        C[v] := true;
        if G = fail then
          g := fail;
        else
          g := Stabilizer(G, v); # Calculate the stabilizer of <v> in <G>
          if IsTrivial(g) then
            g := fail; # Discard the group from this point as it is trivial
          fi;
        fi;
        bk(C, IntersectionBlist(try, adj[v]), IntersectionBlist(ban, adj[v]),
           g, d); # Recurse
      fi;
      try[v] := false;
      ban[v] := true;
      if lim = num then
        return; # The limit of cliques has been reached
      fi;
    od;
  end;

  num := 0;
  bk(start, possible, BlistList(vtx, []), grp, Length(inc));
  return user_param;
end);
