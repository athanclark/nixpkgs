{ cabal, conduit, controlMonadLoop, hspec, mtl, resourcet
, shakespeare, shakespeareText, text
}:

cabal.mkDerivation (self: {
  pname = "process-conduit";
  version = "1.1.0.0";
  sha256 = "1b3snck651cpb7i3c78cn264zrjan3lzydf59209abkvb6fv1hql";
  buildDepends = [
    conduit controlMonadLoop mtl resourcet shakespeare shakespeareText
    text
  ];
  testDepends = [ conduit hspec ];
  meta = {
    homepage = "http://github.com/tanakh/process-conduit";
    description = "Conduits for processes";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
  };
})
