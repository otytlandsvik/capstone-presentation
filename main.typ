#import "@preview/touying:0.6.1": *
#import themes.simple: *
#import "figures/fan-intersection.typ": fan-intersection

#let title = "Simplifying Unstructured Grids for Oceanographic Visualization"
#let author = "Ole Tytlandsvik"
#let date = datetime(year: 2025, month: 4, day: 28)

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
    - *The #smallcaps[zfp] compressor*
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

== Merger Vertex Optimization
  - Trivial optimization is using the centroid (what we just saw)
  - The next step: _Kernel mean construction_
  #image("figures/fan-intersection-paper.png")

== Merger Vertex Optimization
  #image("figures/kernel-paper.png")

== Merger Vertex Optimization
  #grid(columns: (1fr, 1fr), gutter: 1.5cm)[

  - Yields better results in the paper
  - If a solution exists, collapse is guaranteed

  #text(fill: orange)[Orange] is centroid, #text(fill: blue)[blue] is kernel mean construction $->$
  ][#image("figures/kmean-results-paper.png")]

== Floating-point Compression
  #grid(columns: (1fr, 1fr), gutter: 1.5cm)[
    - Interactive visualizations:
      - Each frame is one value per node
      - One-dimensional array slices
      - Floating-point values (doubles)
      - *Challenge:* compress doubles on server, decompress on client
  ][
    #image("figures/grid-dimension.svg")
    #v(1cm)
    - #smallcaps[zfp] is `C++`
      - Was able to compile to #smallcaps[wasm]!
  ]

// == Architecture Overview
// #grid(columns: (1fr, 42%),
//   [
//     We concentrate on the data flow of _Archives_.
//
//     - _Hindcast_ simulations
//     - _User invoked_ simulations
//
//     Hindcasts are periodically produced, and are the basis of visualizations.
//
//     _These are the archives we aim to compress/reduce._
//   ],
//   [#image("figures/oceanbox-arch.svg")],
// )
//
// #grid(columns: (1fr, 53%), gutter: 1.5cm, 
//     [#image("figures/oceanbox-arch.svg")],
//     [#image("figures/shaver-arch.svg")],
//   )
//
// == Implementation Details
//
// *Two-fold design:*
// #grid(columns: 2, gutter: 1.5cm, 
//   [
//     _Grid Simplification_
//     - Once per grid geometry
//       - Can be slow
//     - Boundary nodes preserved
//   ],
//   [
//     _Archive Application_
//     - Picking out values from full res -> compressed
//     - Vertices a proper subset of original vertices
//     - Also truncate depth dimension
//   ],
// )

== Evaluation (so far)

#grid(columns: 2, gutter: 2.5cm,
  [
    *Visualization similarity*
    - Inspection of raster images
      - Grid compression
      - Floating-point compression
  ],
  [
    *Compression*
    - Grid geometry
    - Floating-point slices
    - Combined
  ],
  // [
  //   *Geometric Error*
  //   - Angle distribution
  //   - Triangulation inspection
  // ],
  // [
  //   _For the Master:_
  //   - Pixel-by-pixel comparison
  //   - Client execution time
  //   - Hausdorff distance
  // ],
)

== Evaluation (so far)
  *Grid:* Buksnes waste (Nappstraumen in Lofoten)

  *Comparison*
  - Original grid
  // - Randomly reduced #footnote[Triangulated with Delaunay]
  - Angle Bounded Half-edge Collapse
  - Angle Bounded Edge Collapse
  - Both with a range of values for $theta$
  #v(1cm)


  - _Kernel Mean Optimization not quite working yet_

== Visualization Similarity: Speed
#[
  #set text(size: 18pt)
  #grid(columns: (23%, 23%, 23%, 23%) , gutter: .5cm,
    [
      #image("figures/napp-full-speed.png")
      Original grid
    ],
    [
      #image("figures/napp-random-speed.png")
      Random reduction
    ],
    [
      #image("figures/napp-half-28-speed.png")
      Half-edge, 28$degree$
    ],
    [
      #image("figures/napp-full-28-speed.png")
      Full-edge, 28$degree$
    ],
  )
]

== Visualization Similarity: Speed
#[
  #set text(size: 18pt)
  #grid(columns: (1fr, 1fr, 1fr) , gutter: .5cm,
    [
      #image("figures/napp-half-28-speed.png")
      Half-edge, 28$degree$
    ],
    [
      #image("figures/napp-full-28-speed.png")
      Full-edge, 28$degree$
    ],
    [
      #image("figures/napp-full-40-speed.png")
      Full-edge, 40$degree$
    ],
  )
]

== Visualization Similarity: Triangulation
#[
  #set text(size: 18pt)
  #grid(columns: (23%, 23%, 23%, 23%) , gutter: .5cm,
    [
      #image("figures/napp-full-grid.png")
      Original grid
    ],
    [
      #image("figures/napp-random-grid.png")
      Random reduction
    ],
    [
      #image("figures/napp-half-28-grid.png")
      Half-edge, 28$degree$
    ],
    [
      #image("figures/napp-full-28-grid.png")
      Full-edge, 28$degree$
    ],
  )
]

== Visualization Similarity: Triangulation
#[
  #set text(size: 18pt)
  #grid(columns: (1fr, 1fr, 1fr) , gutter: .5cm,
    [
      #image("figures/napp-half-28-grid.png")
      Half-edge, 28$degree$
    ],
    [
      #image("figures/napp-full-28-grid.png")
      Full-edge, 28$degree$
    ],
    [
      #image("figures/napp-full-40-grid.png")
      Full-edge, 40$degree$
    ],
  )
]

//
// == Visualization Similarity: Temperature, PO5
// #grid(columns: (1fr, 1fr), gutter: 1.5cm,
//   [
//     #image("figures/PO5-original-temp-2.png")
//     Original grid
//   ],
//   [
//     #image("figures/PO5-28-temp-2.png")
//     Angle bound, 28$degree$
//   ]
// )
//
// == Visualization Similarity: Streams, PO5
// #grid(columns: (1fr, 1fr), gutter: 1.5cm,
//   [
//     #image("figures/PO5-original-streams.png")
//     Original grid
//   ],
//   [
//     #image("figures/PO5-28-streams.png")
//     Angle bound, 28$degree$
//   ]
// )
//
// == Geometric Similarity: Angle Distribution
// #[
//   #set text(size: 18pt)
//   #grid(columns: (23%, 23%, 23%, 23%) , gutter: .5cm,
//     [
//       #image("figures/buksnes-angles.svg")
//       Original grid
//     ],
//     [
//       #image("figures/buksnes-angles-random.svg")
//       Random reduction
//     ],
//     [
//       #image("figures/buksnes-angles-28.svg")
//       Angle bound, 28$degree$
//     ],
//     [
//       #image("figures/buksnes-angles-30.svg")
//       Angle bound, 30$degree$
//     ],
//   )
// ]
//
// == Geometric Similarity: Triangulation
// #[
//   #set text(size: 18pt)
//   #grid(columns: (23%, 23%, 23%, 23%) , gutter: .5cm,
//     [
//       #image("figures/napp-1-grid.png")
//       Original grid
//     ],
//     [
//       #image("figures/napp-random-grid.png")
//       Random reduction
//     ],
//     [
//       #image("figures/napp-2-grid.png")
//       Angle bound, 28$degree$
//     ],
//     [
//       #image("figures/napp-3-grid.png")
//       Angle bound, 30$degree$
//     ],
//   )
// ]

== Compression Ratio
#[
  #set text(size: 20pt)
  #table(
    columns: 5,
    align: center + horizon,
    /* --- header --- */
    table.header(
      table.cell([*Angle Bound*], rowspan: 3),
      table.cell([*Size / Compression Ratio*], colspan: 4),
      table.cell([Half-edge], colspan: 2),
      table.cell([Full-edge], colspan: 2),
      [Nodes],
      [Elements],
      [Nodes],
      [Elements],
    ),
    fill: (_, y) => if y == 3 {
      gray.lighten(75%)
    },
    /* --- body --- */
    [Full resolution],
    [25 136],
    [48 332],
    [25 136],
    [48 332],
    [28$degree$],
    [1.71],
    [1.76],
    [1.80],
    [1.86],
    [30$degree$],
    [1.43],
    [1.45],
    [1.77],
    [1.82],
    [34$degree$],
    [1.09],
    [1.09],
    [1.74],
    [1.79],
    [40$degree$],
    [1.00],
    [1.00],
    [1.43],
    [1.46],
  )
]

== Compression Ratio
#[
  #set text(size: 20pt)
  #table(
    columns: 5,
    align: center + horizon,
    /* --- header --- */
    table.header(
      table.cell([*Angle Bound*], rowspan: 3),
      table.cell([*Size / Compression Ratio*], colspan: 4),
      table.cell([Half-edge], colspan: 2),
      table.cell([Full-edge], colspan: 2),
      [No #smallcaps[zfp]],
      [#smallcaps[zfp]],
      [No #smallcaps[zfp]],
      [#smallcaps[zfp]],
    ),
    fill: (_, y) => if y == 3 {
      gray.lighten(75%)
    },
    /* --- body --- */
    [Full resolution],
    table.cell([98KiB], colspan: 4),
    [28$degree$],
    [1.71],
    [5.76],
    [1.80],
    [6.12],
    [30$degree$],
    [1.43],
    [5.16],
    [1.77],
    [6.13],
    [34$degree$],
    [1.09],
    [3.92],
    [1.74],
    [5.76],
    [40$degree$],
    [1.00],
    [3.63],
    [1.43],
    [4.90],
  )
]


== Summary
#grid(columns: (1fr, 25%), gutter: .5cm, 
  [
    - *Grid Simplification* and *Floating-point Compression*
    - Angle bound half-edge collapse vs edge collapse
      - Edge collapse significantly better

    - Improved results so far
      - Better visualizations
      - 1.7x $->$ 6x compression (array slices)
  ],
  [
    #image("figures/napp-full-grid.png")
    #image("figures/napp-full-40-grid.png")
  ],
)

== Remaining Work
- Working Kernel Mean Optimization
- Explore #smallcaps[zfp] configuration
- Evaluation
  - Visualization results for #smallcaps[zfp]
  - Pixelwise difference
  - Timings

#slide[
  #align(center)[
    = Questions
  ]
]
