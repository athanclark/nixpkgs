{ cabal, cabalMacosx, reactiveBanana, wx, wxcore }:

cabal.mkDerivation (self: {
  pname = "reactive-banana-wx";
  version = "0.8.0.0";
  sha256 = "0qfd839nm2ppjhhhnn6s1hbx1mnrzjqx450p4jadsrs1y2403c9n";
  isLibrary = true;
  isExecutable = true;
  buildDepends = [ cabalMacosx reactiveBanana wx wxcore ];
  configureFlags = "-f-buildExamples";
  meta = {
    homepage = "http://haskell.org/haskellwiki/Reactive-banana";
    description = "Examples for the reactive-banana library, using wxHaskell";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
    maintainers = [ self.stdenv.lib.maintainers.andres ];
  };
})
