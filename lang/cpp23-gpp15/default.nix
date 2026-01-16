{pkgs, ...}: {
  trao.languages.cpp23-gpp15 = {
    builder = {
      source,
      name,
      ...
    }: let
      src = pkgs.writeTextDir "main.cpp" source;
    in
      pkgs.stdenv.mkDerivation {
        pname = name;
        version = "1.0.0";
        inherit src;
        buildInputs = with pkgs; [
          gcc15
          boost
          eigen
          gmp
          ac-library
        ];
        buildPhase = ''
          g++ -std=c++23 -o main main.cpp -lgmp -lgmpxx
        '';
        installPhase = ''
          mkdir -p $out/bin
          cp main $out/bin/$pname
        '';
      };
    sampleSource = builtins.readFile ./main.cpp;
    displayName = "C++23 (g++ 15)";
    checks = {
      main = {
        source = builtins.readFile ./main.cpp;
        input = "";
        expectedOutput = builtins.readFile ./main-expected.txt;
      };
    };
  };
}
