{ cabal, accelerate, accelerateCuda, gloss, glossAccelerate }:

cabal.mkDerivation (self: {
  pname = "gloss-raster-accelerate";
  version = "1.8.0.0";
  sha256 = "17545lb99iszhmx8f8fan0dm76ps6bc977zs2ramycnybzbb3kyc";
  buildDepends = [ accelerate accelerateCuda gloss glossAccelerate ];
  meta = {
    description = "Parallel rendering of raster images using Accelerate";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
    hydraPlatforms = self.stdenv.lib.platforms.none;
  };
})