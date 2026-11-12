{
  lib,
  fetchFromGitHub,
  gmp,
  postgresql,
  postgresqlBuildExtension,
  python3,
}:

postgresqlBuildExtension {
  pname = "pgmp";
  version = "1.1-unstable-2026-07-26";

  src = fetchFromGitHub {
    owner = "dvarrazzo";
    repo = "pgmp";
    rev = "1849585416f2bc3d070bf8cef6a659907687ec7f";
    hash = "sha256-D0zdDXFf8XJkRKOvxGuhy/sWAWoEquRmYv1wnD3Vz+I=";
  };

  nativeBuildInputs = [ python3 ];
  buildInputs = [ gmp ];

  # The extension's install scripts are generated from its sources.
  preBuild = ''
    python3 tools/unmix.py < sql/pgmp.pysql > sql/pgmp--1.1.sql
    python3 tools/sql2extension.py --extname pgmp sql/pgmp--1.1.sql > sql/pgmp--unpackaged--1.1.sql
  '';
  makeFlags = [ "with_llvm=no" ];

  meta = {
    description = "Arbitrary precision integers and rationals for PostgreSQL";
    homepage = "https://github.com/dvarrazzo/pgmp";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ athanclark ];
    platforms = postgresql.meta.platforms;
  };
}
