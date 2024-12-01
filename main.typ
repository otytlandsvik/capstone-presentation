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
  == The "Solution"

  Functions:

  #grid(
    columns: 2, gutter: 2.5cm,
  )[
    ```nix
    { inputs = { ... }; }
    ```

    - Dependencies are inputs
    - Usually tarballs or git repos
    - Pinned and hashed
  ][
    ```nix
    { outputs = inputs: { ... }; }
    ```

    - Outputs are functions of inputs// or contents of other outputs, or nothing
    - Can be anything
    - Lazily evaluated// evaluated only when needed
  ]
]

#slide[
  == What is Nix?

  - Just a programming language
  - Functional
    - lazy
    - everything is an expression
  - Turing complete
  - Made to configure environments
    - native paths
    - tooling for environments -> nixos etc
]

#slide[
  == Trinity

  #grid(
    columns: 2,
    gutter: 1.5cm,
    [
      - Nix: the package manager
      - NixDSL: the programming language
      - Nixpkgs: the repository
      - NixOS: the operating system
    ],
    [#image("figures/logo.png", width: 75%)],
  )
]
#slide[
  == Nix REPL

  The Nix REPL (Read-Eval-Print Loop) is an interactive environment for evaluating Nix expressions.

  ```bash
  nix repl -f '<nixpkgs>'
  ```

  Useful commands:
  - `:l <path>`: load a file
  - `:q`: quit
  - `:t`: show type of expression
  - `:t <expr>`: show type of expression

]

#slide[
  == Language Basics

  #grid(columns: 2, gutter: 6cm)[
    Integers:

    ```nix
    > x = 1 + 1
    > x
    2
    ```

    Floats:

    ```nix
    > y = 1.0 + 1.0
    > y
    2.0
    ```
  ][
    Strings:

    ```nix
    > z = "world"
    > "hello ${z}"
    "hello world"
    ```

    Attribute sets:

    ```nix
    > s = { a = { b = 1; }; }
    > s.a.b
    1
    ```
  ]
]

#slide[
  == Language Basics

  #grid(columns: 2, gutter: 3cm)[
    Lists:

    ```nix
    > [ 1 "2" (_: 3) ]
    [ 1 "2" <thunk> ]
    ```

    Recursive attrsets:

    ```nix
    > rec { x = 1; y = x; }
    { x = 1; y = 1; }
    ```
  ][
    Bindings:

    ```nix
    > let x = 1; in x + 1
    2
    ```

    Inherits:

    ```nix
    > let x = 1; y = x; in
        { inherit x y; }
    { x = 1; y = 1; }
    ```
  ]
]

#slide[
  == Language Basics

  #grid(columns: 2, gutter: 3cm)[
    Functions 1:

    ```nix
    > f = x: x + 1
    > f 2
    3
    > g = g': x: g' x + 1
    > g f 2
    4
    ```
  ][
    Functions 2:

    ```nix
    > h = { x ? 1 }: x + 1
    > h
    <function>
    > h { }
    2
    > h { x = 2; }
    3
    ```
  ]
]

#slide[
  == Derivation

  A _derivation_

  #grid(columns: 2, gutter: 3cm)[
    - is a plan / blueprint
    - it's used for producing
      - `lib`: library outputs
      - `bin`: binary outputs
      - `dev`: header files, etc.
      - `man`: man page entries
      - ...
  ][
    ```hs
    derivation ::
      { system    : String
      , name      : String
      , builder   : Path | Drv
      , ? args    : [String]
      , ? outputs : [String]
      } -> Drv
    ```
  ]
]

#slide[
  == Derivation

  Example:

  #grid(columns: 2, gutter: 0.75cm)[
    ```hs
    derivation ::
      { system    : String
      , name      : String
      , builder   : Path | Drv
      , ? args    : [String]
      , ? outputs : [String]
      } -> Drv
    ```
  ][
    ```nix
    derivation {
      system = "aarch64-linux";
      name = "hi";
      builder = "/bin/sh";
      args = ["-c" "echo hi >$out"];
      outputs = ["out"];
    }
    ```
  ]
]

#slide[
  == Derivation

  Special _variables_:

  #grid(columns: 2, gutter: 0.75cm)[
    ```nix
    derivation {
      system = "aarch64-linux";
      name = "hi";
      builder = "/bin/sh";
      args = ["-c" "echo hi >$out"];
      outputs = ["out"];     ^^^^
    }             ^^^
    ```
  ][
    - `$src`: build source
    - `$out`: build output (default)
    - custom outputs

  ]

]

#slide[
  == Nix Store

  ```nix
  /nix/store/l2h1lyz50rz6z2c8jbni9daxjs39wmn3-hi
  |---------|--------------------------------|--|
  store     hash                             name
  prefix
  ```

  - Store prefix can be either local or remote (`binary cache`)
  - Hash either derived from input (`default`) or output (`CA derivation`)
  - The hash ensures two realised derivations with the same name have different
    paths if the inputs differ at all
]

#slide[
  == Packaging

  The process of: Nix expressions $arrow.r.double$ derivation(s)

  - `builtins.derivation`
  - `stdenv.mkDerivation` (from `nixpkgs`)
  - `pkgs.buildDotnetModule` (from `nixpkgs`)
  - ...
]

#slide[
  == Packaging #footnote("Example 1")

  #set text(18pt)

  #v(1cm)

  #grid(
    columns: 2,
    gutter: 4cm,
    [
      ```nix
      { stdenv
      , lib
      , pkgs
      }:
      pkgs.writeShellApplication {
          name = "moo";
          version = "0.0.1";
          runtimeInputs = [ pkgs.cowsay ];
          text = "cowsay moo";
      }
      ```
    ],
    [
      #v(1.5cm)
      ```txt
       _____
      < moo >
       -----
              \   ^__^
               \  (oo)\_______
                  (__)\       )\/\
                      ||----w |
                      ||     ||
      ```
    ],
  )
  // https://nix.dev/tutorials/nix-language
]

#slide[
  == Development #footnote("Example 2")

  #set text(14pt)

  #grid(
    columns: 2,
    gutter: 2cm,
    [
      *Shell*:

      - `nix develop` // starts a bash, cleans everything
      - `direnv` // keep your current shell, enter a dir, it auto activates, leaves the dir, auto deactivates

      #v(2em)

      ```nix
      pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          cargo
          rustc
          rustfmt
        ];
      };
      ```
    ],
    [
      *Formatter*:

      - `nixfmt`
      - a single package, or $arrow.b$

      #v(2em)

      ```nix
      formatter = pkgs.writeShellScriptBin "formatter" ''
        set -eoux pipefail
        shopt -s globstar
        ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt .
        ${pkgs.rustfmt}/bin/rustfmt **/*.rs
      '';
      ```
    ],
  )
]

#slide[
  == Pinning

  #set text(14pt)

  #grid(
    columns: 2,
    gutter: 2cm,
    [
      *w/ builtin versions*: // for most critical and popular packages: llvm, gcc, node, ...

      ```bash
      nix-repl> pkgs.coq_8_
      pkgs.coq_8_10  pkgs.coq_8_12
      pkgs.coq_8_14  pkgs.coq_8_16
      pkgs.coq_8_18  pkgs.coq_8_5
      pkgs.coq_8_7   pkgs.coq_8_9
      ...
      ```

      #v(2em)

      *w/ `nix shell`*:

      ```bash
      nix shell nixpkgs/<hash>#{pkg1,...}
      ```

      #v(2em)

      *or DIY!* #footnote[https://github.com/andir/npins]
    ],
    [
      *w/ npins or niv*:

      ```nix
      let
        sources = import ./nix;
        pkgs = import sources.nixpkgs {};
      in {
        # Use pinned packages
        hello = pkgs.hello;
      }
      ```

      Initialize npins with:
      ```bash
      npins init
      # Channel
      npins add channel 24.05
      # GitHub
      npins add github cachix/git-hooks.nix
      ```
    ],
  )
]

#slide[
  == System Configuration

  i.e. NixOS

  - A GNU/Linux distribution
  - Fundamentally different file system design
    - nix store
    - otherwise just like any penguin variant
  - Only configures and installs system wide programs
    - use home-manager for user-based configuration
]

#slide[
  == System Configuration

  #set text(18pt)

  ```nix
  outputs = { nixpkgs, ... }: {
    nixosConfigurations."coolpc" = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs pkgs;
      };
      modules = [ /* A list of modules goes here */ ];
    };
  };
  ```

  *System Closure*:
  ```bash
  nix build -f . nixosConfigurations.coolpc.config.system.build.toplevel
  ```

  *Rebuild*:
  ```bash
  nixos-rebuild <switch|boot|...>
  ```
]

#slide[
  == What else is Nix good for?

  - CI/CD
    - declarative and reproducible pipelines
    - no version mismatch due to nix
    - available as a github runner -> nix-run
  - Kubernetes
    - declarative/reproducible deployments
    - easily convertible to and from docker files/images
]

#let slides = "https://github.com/mrtz-j/nix-workshop"

#let starter = "https://github.com/mrtz-j/nix-workshop/starter"

#slide[
  == Challenge

  - Create hello world apps in whatever language you want
  - Package it in nix
    - `default.nix`
    - direnv with `shell.nix`
  - Have everyone else make them work by just entering your folder
  - Try adding dependencies
  - Starter is provided in the #link(starter)[`starter` folder]
]

#slide[
  == Resources

  - Installer: https://nix.dev/install-nix
  - REPL is your friend: `nix repl`
  - Intro: https://nix.dev/tutorials/first-steps/
  - Manual: https://nixos.org/manual/nix/unstable/
  - Forum: https://discourse.nixos.org
  - Options: https://mynixos.com
  - Source code search:
    - https://github.com/features/code-search
]
