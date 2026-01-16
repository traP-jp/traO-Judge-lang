{
  flake-parts-lib,
  config,
  ...
}: let
  cfg = config.trao;
in {
  options.perSystem = flake-parts-lib.mkPerSystemOption ({lib, ...}:
    with lib; {
      options.trao = {
        languages = mkOption {
          type = types.lazyAttrsOf (
            types.submodule ({...}: {
              options = {
                builder = mkOption {
                  type = types.functionTo types.package;
                  description = "Represents compile-phase. { source: string } -> package";
                };
                sampleSource = mkOption {
                  type = types.str;
                  description = "A sample source code file for prefetching.";
                };
                displayName = mkOption {
                  type = types.str;
                  description = "A human-readable name for the language.";
                };
                checks = mkOption {
                  type = types.lazyAttrsOf (types.submodule ({...}: {
                    options = {
                      source = mkOption {
                        type = types.str;
                        description = "The source code to run the check against.";
                      };
                      input = mkOption {
                        type = types.str;
                        description = "The input to provide to the program.";
                      };
                      expectedOutput = mkOption {
                        type = types.str;
                        description = "The expected output from the program.";
                      };
                    };
                  }));
                  description = "A set of checks to validate the builder.";
                };
              };
            })
          );
          default = {};
        };
      };
    });

  config.perSystem = {
    pkgs,
    lib,
    config,
    ...
  }:
    with lib; let
      cfg = config.trao;
    in {
      packages."trao:prefetchAll" = pkgs.symlinkJoin {
        name = "trao-prefetch-all";
        paths =
          builtins.map (
            kv: let
              lang = kv.value;
            in
              lang.builder {
                name = "prefetch-${kv.name}";
                source = lang.sampleSource;
              }
          ) (
            attrsToList cfg.languages
          );
      };

      checks = modules.mkMerge (
        mapAttrsToList (
          langName: lang: (
            mapAttrs (
              checkName: check: let
                binName = "trao-check-build-${langName}:${checkName}";
                builtPackage = lang.builder {
                  name = binName;
                  source = check.source;
                };
                inputFile = pkgs.writeText "input-${langName}-${checkName}.txt" check.input;
                expectedFile = pkgs.writeText "expected-${langName}-${checkName}.txt" check.expectedOutput;
              in
                pkgs.runCommand "trao-check-run-${langName}:${checkName}" {
                  inherit builtPackage;
                } ''
                  mkdir -p $out
                  result=$(${builtPackage}/bin/${binName} < ${inputFile})
                  expected=$(cat ${expectedFile})
                  if [ "$result" != "$expected" ]; then
                    echo "Check failed for ${langName}:${checkName}"
                    echo "Expected: $expected"
                    echo "Got: $result"
                    exit 1
                  fi
                  echo "Check passed for ${langName}:${checkName}" > $out/result.txt
                ''
            )
            lang.checks
          )
        )
        cfg.languages
      );
    };
}
