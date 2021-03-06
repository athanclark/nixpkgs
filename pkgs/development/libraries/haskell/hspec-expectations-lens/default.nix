{ cabal, hspec, hspecExpectations, HUnit, lens, silently }:

cabal.mkDerivation (self: {
  pname = "hspec-expectations-lens";
  version = "0.3.0.0";
  sha256 = "1v6j4z3gv41jlhbi8ngx7h6d78l1fazvd3bw3c67zsnlgqrvl1x5";
  buildDepends = [ hspec hspecExpectations HUnit lens ];
  testDepends = [ hspec lens silently ];
  meta = {
    homepage = "http://supki.github.io/hspec-expectations-lens/";
    description = "Hspec expectations for the lens stuff";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
  };
})
