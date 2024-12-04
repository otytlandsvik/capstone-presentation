#import "@preview/touying:0.5.2": *
#import themes.simple: *

#let title = "Simplifying Unstructured Grids for Oceanographic Visualizations"
#let author = "Ole Tytlandsvik"
#let date = datetime(year: 2024, month: 12, day: 6)

#set document(title: title, author: author, date: date)
#set page(paper: "presentation-16-9")

#show: simple-theme.with(footer: none)


#title-slide[
  = #title

  #image("figures/logo.png", width: 20%)

  #set text(16pt)

  #author

  #date.display("[month repr:long] [day padding:none], [year]")
]

#slide[
  == Oceanbox

  #grid(
    columns: (1fr, 30%), gutter: 2.5cm,
  )[
    // FIXME: Norwegian letters
    - Tromso-based
    - Interactive oceanographic simulations
    - Oceanography as a Service
    - Web-Based Geographic Information System (Web GIS)
    - Digital twin of the coastal ocean
  ][
    #image("figures/oceanbox-high-res.png")
  ]
]

#slide[
  == The Problem

  - Large data sets
    - High resolution (millions of spatial points)
    - Multi-dimensional
    - Payloads of 20Mb+
    - Unresponsive web application
    - Increased bandwidth costs

]

#slide[
  == The Solution: Lossy Compression

  - Traditional approaches tricky
    - Accuracy of coordinates are important
    - Tiling/Multi-resolution not trivial with _unstructured grids_
    - Inflated data size should be smaller on the client


  - Grid simplification
    - Remove vertices/nodes
    - Maintain visualization quality
    - *Angle bound half-edge collapse*

]

#slide[
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
]
#slide[
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
]

#slide[
  == Related Work: Mesh Simplification
  #grid(columns: 2, gutter: 1.5cm, 
    [
      #image("figures/mesh-opt.png")
    ], 
    [
      - Approximate a surface #footnote[Figure from Hoppe et al. "Mesh Optimization", _ACM_, 1993, pp. 19-26]
      - Preserve topology
      - Good reduction

      *However*
      - Not ideal for 2D grids
      - Need even resolution
    ],
  )
]

#slide[
  == Related Work: Mesh Simplification Operators
    *Vertex Clustering*

    Identify a "cluster" of vertices and represent them all with one vertex
    #image("figures/vertex-clustering.svg", width: 70%)
]

#slide[
  == Related Work: Mesh Simplification Operators
    *Edge Collapse*

    Collapse an edge between two vertices, representing them with one vertex
    #image("figures/edge-collapse.svg")
]

#slide[
  == Our Approach: Angle Bound Half-edge Collapse
    Adaptation from previous work.
    #footnote[Hinderink et al. "Angle-Bounded 2D Mesh Simplification." _Computer Aided Geometric Design_, vol 95, May 2022, p. 102085]

    _Half-edge collapse_ with a minimum angle criterion to inner angles
    #image("figures/half-edge-bad-angles.svg", width: 70%)
]

#slide[
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
]

#slide[
  #grid(columns: (1fr, 53%), gutter: 1.5cm, 
      [#image("figures/oceanbox-arch.svg")],
      [#image("figures/shaver-arch.svg")],
    )
]

