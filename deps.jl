Pkg.add("MetadataTools")
# Pkg.test("MetadataTools")
Pkg.add("MetaGraphs")
Pkg.add("GraphPlot")
using MetadataTools
using LightGraphs
using MetaGraphs
using GraphPlot

pkgmeta = get_all_pkg()
pg = make_dep_graph(pkgmeta)
pkg_graph = get_pkg_dep_graph("LightGraphs", pg)
pg
pg.pkgnames
pg.adjlist

g = DiGraph(length(pg.adjlist))
mg = MetaDiGraph(g)
for i in 1:length(pg.adjlist)
    for j in pg.adjlist[i]
        add_edge!(mg, j, i)
    end
end
for v in 1:nv(mg)
    val = pg.pkgnames[v]
    set_prop!(mg, v, :name, val)
end

lgv = find(x->x=="LightGraphs", pg.pkgnames)[1]
t = bfs_tree(mg, lgv)
tvertices = [v for v in vertices(t) if degree(t, v) > 0]
subg = induced_subgraph(mg, tvertices)[1]
tnames = pg.pkgnames[tvertices]
tnamesmeta = [prop[:name] for (v, prop) in subg.vprops]
sort(tnamesmeta) == sort(tnames)

fname = "graph.plot.svg"
gplot_kwargs = Dict(:nodelabel=>tnames,
                    # :nodesize=> Float64[sqrt(degree(subg, v))/10 for v in vertices(subg)])
                    :nodesize=>100)
draw(SVG(fname, 8inch, 8inch), gplot(subg; gplot_kwargs...))

