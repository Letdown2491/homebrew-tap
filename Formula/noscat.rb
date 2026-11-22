class Noscat < Formula
  desc "Like netcat, but over a Nostr-native mesh: npub-addressed tunnels, no root, no accounts"
  homepage "https://github.com/Letdown2491/noscat"
  version "0.1.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-aarch64-apple-darwin.tar.gz"
      sha256 "462835e8d2a7599d22ea3cd5be64d1bca615eb9adb88c8971d8a1033ae8cf4c5"
    else
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-x86_64-apple-darwin.tar.gz"
      sha256 "77d71959ff7e6fcc7af15e773736fec58b52734aaf8684cdd56ff803de30c45f"
    end
  end

  # The Linux binaries are static musl builds: no runtime deps on any distro.
  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-x86_64-unknown-linux-musl.tar.gz"
      sha256 "6c2bd680ac5303e85d0eb10783c009b5d26ec529ab0c52a69526f0f615abe0b4"
    else
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-aarch64-unknown-linux-musl.tar.gz"
      sha256 "6f2cd025ee1717de2f72dd3c5935610687b535c62d240e3f648c72fb7d0be3b8"
    end
  end

  # Linux bottles pour without a C toolchain (the binary is static musl);
  # macOS Homebrew always has CLT, so plain-URL installs are fine there.
  bottle do
    root_url "https://github.com/Letdown2491/noscat/releases/download/v#{version}"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "3e301aa9ae95897a7194c3441dba022e6e19f225d9c51b04c5e5f503670d33fe"
    sha256 cellar: :any_skip_relocation, arm64_linux: "0f03fd65f15d5e75f1f6c5d6ff1d860e411ceab3b05c60f269b3f964d57fb96d"
  end

  def install
    bin.install "noscat"
    man1.install "noscat.1"
    bash_completion.install "completions/noscat.bash" => "noscat"
    zsh_completion.install "completions/_noscat"
    fish_completion.install "completions/noscat.fish"
  end

  def caveats
    <<~EOS
      Identities are ephemeral by default; pin them with --identity.
      Tailnet commands keep state under --dir (default ./noscat-device).
    EOS
  end

  test do
    assert_match(/^nsc/, shell_output("#{bin}/noscat keygen"))
  end
end
