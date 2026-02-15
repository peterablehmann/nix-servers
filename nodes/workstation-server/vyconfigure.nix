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
    rev = "5d667cab185ee7920bd7cd86506313474a33c823";
    hash = "sha256-EavGfcey0tGqGU7EFf7HT83JKyTM4SZ21vl+SM/rSNw=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = "sha256-7ZhS3RHIq68q22J5jEjCAVyf7PMLETKM1a0vqyzgHWA=";

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
