(lang dune 3.17)

(name nixosmgr)

(generate_opam_files true)

(source
 (github travgm/nixosmgr))

(authors "Travis Montoya <travis@travgm.org>")

(maintainers "Travis Montoya <mtravis@travgm.org>")

(license MIT)

(documentation https://github.com/travgm/nixosmgr)

(package
 (name nixosmgr)
 (synopsis "Small tool to help manage your nix system")
 (description "Cleans, adds packages, optimizes your nix system without having to remember various commands")
 (depends ocaml dune)
 (tags
  ("nixosmgr" "tool")))
