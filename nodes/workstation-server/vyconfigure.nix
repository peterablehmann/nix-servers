{
  lib,
  installShellFiles,
  gitMinimal,
  buildGoModule,
  fetchFromGitHub,
  stdenv,
}:

buildGoModule rec {
  pname = "vyconfigure";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "offline-kollektiv";
    repo = "vyconfigure";
    rev = "v${version}";
    hash = "sha256-k8xYh8NrGOHT56umXJrr3QJPBXJDw/351Ig1+V13FPI=";
    leaveDotGit = true;
  };

  nativeBuildInputs = [
    gitMinimal
    installShellFiles
  ];

  vendorHash = "sha256-Ne9DORv3uRj/w/cEH/oMaeeGwYKsBfZWXi2NU/0Tp34=";

  preBuild = ''
    git config user.email "nixbld@nixbld.nixbld"
    git config user.name "nixbld"
    git add .
    git commit -m "v${version}"
    git tag v${version}
  '';

  GOFLAGS = [ "-buildvcs=true" ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    local INSTALL="$out/bin/vyconfigure"
    installShellCompletion --cmd vyconfigure \
      --bash <($out/bin/vyconfigure completion bash) \
      --fish <($out/bin/vyconfigure completion fish) \
      --zsh <($out/bin/vyconfigure completion zsh)
  '';

  meta = with lib; {
    description = "Declarative YAML configuration for VyOS";
    homepage = "https://github.com/offline-kollektiv/vyconfigure";
    changelog = "https://github.com/offline-kollektiv/vyconfigure/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ xgwq ];
    mainProgram = "vyconfigure";
  };
}
