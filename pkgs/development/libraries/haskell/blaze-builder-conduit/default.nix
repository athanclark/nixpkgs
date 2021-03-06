{ cabal, conduit }:

cabal.mkDerivation (self: {
  pname = "blaze-builder-conduit";
  version = "1.1.0";
  sha256 = "0xxyn3lhcn1bkybhrl5dx68d0adf26ilf34gv0mxkwpfj7m7d3k3";
  buildDepends = [ conduit ];
  noHaddock = true;
  meta = {
    homepage = "http://github.com/snoyberg/conduit";
    description = "Convert streams of builders to streams of bytestrings. (deprecated)";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
    maintainers = [ self.stdenv.lib.maintainers.andres ];
  };
})
