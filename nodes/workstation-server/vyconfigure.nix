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
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "offline-kollektiv";
    repo = "vyconfigure";
    rev = "v${version}";
    hash = "sha256-Vq1aCs3aSs24S9n7YZTNCPpdbE70Qf+FDjWGe7eVTM0=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = "sha256-hbdetqQ5Oz+ys7hH51pi8lCQiIGj8Rje38sNFK4KSrg=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/offline-kollektiv/vyconfigure/cmd.Version=${version}"
  ];

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
