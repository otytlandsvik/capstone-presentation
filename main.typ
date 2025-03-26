#import "@preview/touying:0.6.1": *
#import themes.simple: *

#let title = "Simplifying Unstructured Grids for Oceanographic Visualizations"
#let author = "Ole Tytlandsvik"
#let date = datetime(year: 2024, month: 12, day: 6)

#set document(title: title, author: author, date: date)
#set page(paper: "presentation-16-9")

#show: simple-theme.with(footer: none)

// Use lighter gray color for table stroke
#set table(
  inset: 7pt,
  stroke: (0.5pt + luma(200)),
)
// Show table header in small caps
#show table.cell.where(y: 0): smallcaps

#title-slide[
  = #title

  #image("figures/logo.png", width: 20%)

  #set text(16pt)

  #author

  #date.display("[month repr:long] [day padding:none], [year]")
]

== Oceanbox

#grid(
  columns: (1fr, 30%), gutter: 2.5cm,
)[
  - Tromso-based
  - Interactive oceanographic simulations
  - Oceanography as a Service
  - Web-Based Geographic Information System (Web GIS)
  - Digital twin of the coastal ocean
][
  #image("figures/oceanbox-high-res.png")
]

== The Problem

- Large data sets
  - High resolution (millions of spatial points)
  - Multi-dimensional
  - Payloads of 20Mb+
  - Unresponsive web application
  - Increased bandwidth costs

== The Solution: Lossy Compression

- Traditional approaches tricky
  - Accuracy of coordinates are important
  - Tiling/Multi-resolution not trivial with _unstructured grids_
  - Inflated data size should be smaller on the client

== The Solution: Lossy Compression

*Hybrid approach*:

#grid(
  columns: (1fr, 1fr), gutter: 1.0cm,
)[
  - Grid simplification
    - Remove vertices/nodes
    - Maintain visualization quality
    - *Angle bounded edge collapse*
][
  - Floating-point compression
    - Compress one-dimensional vectors
    - Retain enough precision for visualization
    - The #smallcaps[zfp] compressor
]



== FVCOM grids

#grid(
  columns: 2,
  gutter: 1.5cm,
  [
    #image("figures/oceanbox-tromso-speed.png", width: 90%)
  ],
  [
    #image("figures/grid-dimension.svg", width: 80%)
  ],
  [
    - Unstructured grid
      - Variable resolution
  ],
  [
    - Multiple dimensions
      - Coordinates, depth, time
  ],
)

== Related Work

#grid(columns: 2, gutter: 1.5cm,
  [
    *Rasterization-based approaches*
    - Good compression rates (90%)
    - Requires _structured_ grid layout

    *Tiling approaches*
    - Load only what you need
    - Varying resolution
    - Also requires structured grids
  ], 
  [
    *Mesh simplification*
    - More suited for unstructured grids
    - Popular in literature: _3D mesh decimation_
    - Not necessarily directly applicable...
  ]
)


== Related Work: Mesh Simplification
#grid(columns: 2, gutter: 1.5cm, 
  [
    #image("figures/mesh-opt.png")
  ], 
  [
    - Approximate a surface 
    - Preserve topology
    - Good reduction #footnote[Figure from Hoppe et al. "Mesh Optimization", _ACM_, 1993, pp. 19-26]

    *However*
    - Not ideal for 2D grids
    - Need even resolution
  ],
)

// == Related Work: Mesh Simplification Operators
//   *Vertex Clustering*
//
//   Identify a "cluster" of vertices and represent them all with one vertex
//   #image("figures/vertex-clustering.svg", width: 70%)

// == Related Work: Mesh Simplification Operators
//   *Edge Collapse*
//
//   Collapse an edge between two vertices, representing them with one vertex
//   #image("figures/edge-collapse.svg")

== In the Capstone: Angle Bounded Half-edge Collapse
  Adaptation from previous work.
  #footnote[Hinderink et al. "Angle-Bounded 2D Mesh Simplification." _Computer Aided Geometric Design_, vol 95, May 2022, p. 102085]

  _Half-edge collapse_ with a minimum angle criterion to inner angles
  #image("figures/half-edge-collapse.svg", width: 70%)

== In the Capstone: Angle Bounded Half-edge Collapse
#grid(columns: (1fr, 55%), gutter: 1.5cm,
  [
    - We collapse $v$ into $v'$ by collapsing the half-edge $v -> v'$
    - We define a strict angle bound $theta$
    - We ensure inner angles $theta_n$ respect $theta_n > theta$
  ],
  [
    #image("figures/half-edge-collapse.svg")
    #image("figures/half-edge-bad-angles.svg")
  ]
)
== Improvement: Angle Bounded Edge Collapse
  - Can be seen as a direct advancement of the half-edge collapse
  - Simply use the average position of $v$ and $v'$

  #image("figures/edge-collapse.svg")

== Improvement: Angle Bounded Edge Collapse
  - Still enforce the same angle bound $theta$
  - More collapses possible, quality better preserved
  #image("figures/edge-bad-angles.svg")

== Architecture Overview
#grid(columns: (1fr, 42%),
  [
    We concentrate on the data flow of _Archives_.

    - _Hindcast_ simulations
    - _User invoked_ simulations

    Hindcasts are periodically produced, and are the basis of visualizations.

    _These are the archives we aim to compress/reduce._
  ],
  [#image("figures/oceanbox-arch.svg")],
)

#grid(columns: (1fr, 53%), gutter: 1.5cm, 
    [#image("figures/oceanbox-arch.svg")],
    [#image("figures/shaver-arch.svg")],
  )

== Implementation Details

*Two-fold design:*
#grid(columns: 2, gutter: 1.5cm, 
  [
    _Grid Simplification_
    - Once per grid geometry
      - Can be slow
    - Boundary nodes preserved
  ],
  [
    _Archive Application_
    - Picking out values from full res -> compressed
    - Vertices a proper subset of original vertices
    - Also truncate depth dimension
  ],
)

== Evaluation

#grid(columns: 2, gutter: 1.5cm,
  [
    *Visualization similarity*
    - Inspection of raster images
  ],
  [
    *Compression/Speedup*
    - Compression ratio of payloads
    - Transfer speed
  ],
  [
    *Geometric Error*
    - Angle distribution
    - Triangulation inspection
  ],
  [
    _For the Master:_
    - Pixel-by-pixel comparison
    - Client execution time
    - Hausdorff distance
  ],
)

== Evaluation
#grid(columns: 2, gutter: 1.5cm,
  [
    *Grids*
    - Buksnes Waste (test)
    - PO5 (prod)
    - PO6 (prod)
  ],
  [
    *Comparison*
    + Original grid
    + Randomly reduced #footnote[Triangulated with Delaunay]
    + Angle bound, $theta = 28degree$
    + Angle bound, $theta = 30degree$
  ],
)

== Visualization Similarity: Speed, Buksnes Waste
#grid(columns: (23%, 23%, 23%, 23%) , gutter: .5cm,
  [
    #image("figures/napp-1-speed.png")
    Original grid
  ],
  [
    #image("figures/napp-4-speed.png")
    Random reduction
  ],
  [
    #image("figures/napp-2-speed.png")
    Angle bound, 28$degree$
  ],
  [
    #image("figures/napp-3-speed.png")
    Angle bound, 30$degree$
  ],
)

== Visualization Similarity: Temperature, PO5
#grid(columns: (1fr, 1fr), gutter: 1.5cm,
  [
    #image("figures/PO5-original-temp-2.png")
    Original grid
  ],
  [
    #image("figures/PO5-28-temp-2.png")
    Angle bound, 28$degree$
  ]
)

== Visualization Similarity: Streams, PO5
#grid(columns: (1fr, 1fr), gutter: 1.5cm,
  [
    #image("figures/PO5-original-streams.png")
    Original grid
  ],
  [
    #image("figures/PO5-28-streams.png")
    Angle bound, 28$degree$
  ]
)

== Geometric Similarity: Angle Distribution
#[
  #set text(size: 18pt)
  #grid(columns: (23%, 23%, 23%, 23%) , gutter: .5cm,
    [
      #image("figures/buksnes-angles.svg")
      Original grid
    ],
    [
      #image("figures/buksnes-angles-random.svg")
      Random reduction
    ],
    [
      #image("figures/buksnes-angles-28.svg")
      Angle bound, 28$degree$
    ],
    [
      #image("figures/buksnes-angles-30.svg")
      Angle bound, 30$degree$
    ],
  )
]

== Geometric Similarity: Triangulation
#[
  #set text(size: 18pt)
  #grid(columns: (23%, 23%, 23%, 23%) , gutter: .5cm,
    [
      #image("figures/napp-1-grid.png")
      Original grid
    ],
    [
      #image("figures/napp-random-grid.png")
      Random reduction
    ],
    [
      #image("figures/napp-2-grid.png")
      Angle bound, 28$degree$
    ],
    [
      #image("figures/napp-3-grid.png")
      Angle bound, 30$degree$
    ],
  )
]

== Compression Ratio
#[
  #set text(size: 20pt)
  #table(
    columns: 6,
    align: center + horizon,
    /* --- header --- */
    table.header(
      // table.cell lets us access properties such as rowspan and colspan to customize the cells
      table.cell([*Data set*], rowspan: 2),
      table.cell([*Size / Compression Ratio*], colspan: 5),
      [Nodes],
      [Elements],
      [Geometry],
      [Nodal variable],
      [On disk],
    ),
    fill: (_, y) => if y == 2 or y == 6 or y == 8 {
      gray.lighten(75%)
    },
    /* --- body --- */
    [Buksnes Waste],
    [25 136],
    [48 332],
    [762 KiB],
    [98 KiB],
    [475 686 KiB],
    [Random],
    [1.87],
    [1.93],
    [1.91],
    [1.88],
    [29.27],
    [SHAVER 28$degree$],
    [1.71],
    [1.76],
    [1.74],
    [1.72],
    [26.62],
    [SHAVER 30$degree$],
    [1.43],
    [1.45],
    [1.45],
    [1.44],
    [22.05],
    [PO5],
    [459 242],
    [869 324],
    [13 669 KiB],
    [1 793 KiB],
    [8 473 272 KiB],
    [SHAVER 28$degree$],
    [1.67],
    [1.74],
    [1.71],
    [1.67],
    [26.03],
    [PO6],
    [1 691 194],
    [3 251 577],
    [51 317 KiB],
    [6 606 KiB],
    [32 002 309 KiB],
    [SHAVER 28$degree$],
    [1.64],
    [1.69],
    [1.67],
    [1.64],
    [25.58],
  )
]

== Compression Ratio

#grid(columns: (1fr, 55%), gutter: 1.5cm, 
  [
    - External factors
      - Lossless compression
    - Nodal variable closer to theoretic
  ],
  [
    #set text(size: 20pt)
    #table(
      columns: 3,
      align: center + horizon,
      /* --- header --- */
      table.header(
        // table.cell lets us access properties such as rowspan and colspan to customize the cells
        table.cell([*Data set*], rowspan: 2),
        table.cell([*Size*], colspan: 2),
        [Geometry],
        [Nodal variable],
      ),
      fill: (_, y) => if y == 2 or y == 6 or y == 8 {
        gray.lighten(75%)
      },
      /* --- body --- */
      [Buksnes Waste],
      [363 KiB],
      [126 KiB],
      [Random],
      [71.2%],
      [98.4%],
      [SHAVER 28$degree$],
      [93.1%],
      [98.8%],
      [SHAVER 30$degree$],
      [93.8%],
      [99.3%],
      [PO5],
      [7 250 KiB],
      [2 300 KiB],
      [SHAVER 28$degree$],
      [93.0%],
      [100.6%],
      [PO6],
      [26 200 KiB],
      [8 460 KiB],
      [SHAVER 28$degree$],
      [91.6%],
      [100%],
    )
  ],
)

== Speedup
#grid(columns: (55%, 1fr), gutter: 1.5cm, 
  [
    #set text(size: 20pt)
    #table(
      columns: 3,
      align: center + horizon,
      /* --- header --- */
      table.header(
        table.cell([*Data set*], rowspan: 2),
        table.cell([*Speed / Speedup*], colspan: 2),
        [Geometry],
        [Nodal variable],
      ),
      fill: (_, y) => if y == 2 or y == 6 or y == 8 {
        gray.lighten(75%)
      },
      /* --- body --- */
      [Buksnes Waste],
      [140 ms],
      [22 ms],
      [Random],
      [3.68],
      [2.44],
      [SHAVER 28$degree$],
      [3.5],
      [1.57],
      [SHAVER 30$degree$],
      [2.92],
      [1.47],
      [PO5],
      [2 700 ms],
      [340 ms],
      [SHAVER 28$degree$],
      [1.99],
      [1.29],
      [PO6],
      [10 000 ms],
      [950 ms],
      [SHAVER 28$degree$],
      [1.85],
      [0.84],
    )
  ],
  [
    - Unexpected results
      - Geometry vs Nodal variable
      - Buksnes vs PO5/PO6

    *Theory:*
    Discrepancies in NetCDF _Chunk Size_
  ],
)

== Summary
#grid(columns: (1fr, 25%, 25%), gutter: .5cm, 
  [
    - Compression by Grid Simplification
    - Angle bound half-edge collapse

    - Varying results
      - Jagged visualizations
      - Only 1.7x compression
  ],
  [
    #image("figures/napp-1-grid.png")
  ],
  [ 
    #image("figures/napp-2-grid.png")
  ],
)

== Future Work
- Angle bound _edge_ collapse
- Investigate other methods
  - Spring constant
- "Conventional" lossy compression for variables

#image("figures/edge-collapse.svg")

#slide[
  #align(center)[
    = Questions
  ]
]
