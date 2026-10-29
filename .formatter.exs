[
  import_deps: [:phoenix],
  inputs: ["{mix,.formatter,.credo}.exs", "{config,lib,test,credo}/**/*.{ex,exs}"],
  locals_without_parens: [fablebook: 2, fablebook: 3],
  export: [locals_without_parens: [fablebook: 2, fablebook: 3]]
]
