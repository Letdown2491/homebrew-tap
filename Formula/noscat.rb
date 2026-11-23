# Homebrew formula template for the Letdown2491 tap (homebrew-tap).
# The release workflow fills the version and sha256 placeholders and uploads
# the generated formula (noscat.rb) as a release asset; copy it into the tap
# repo: https://github.com/Letdown2491/homebrew-tap (Formula/noscat.rb).
class Noscat < Formula
  desc "Like netcat, but over a Nostr-native mesh: npub-addressed tunnels, no root, no accounts"
  homepage "https://github.com/Letdown2491/noscat"
  version "0.2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-aarch64-apple-darwin.tar.gz"
      sha256 "89789b793b186353f16398339c872be0d4aebe6355837958de9f217496a385f1"
    else
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-x86_64-apple-darwin.tar.gz"
      sha256 "ce5dd08e30713fa2997be71fb30680b22346e53ed7c4c4de16ece0a1ff091fc1"
    end
  end

  # The Linux binaries are static musl builds: no runtime deps on any distro.
  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-x86_64-unknown-linux-musl.tar.gz"
      sha256 "9956a311b9998acf81bcc043ef02c02226cfea91723eccc6469f828162bee39c"
    else
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-aarch64-unknown-linux-musl.tar.gz"
      sha256 "93431211ef75420d605c3fceff6280757071f572478dfeb57fb04d5925bf1190"
    end
  end

  # Linux bottles pour without a C toolchain (the binary is static musl);
  # macOS Homebrew always has CLT, so plain-URL installs are fine there.
  bottle do
    root_url "https://github.com/Letdown2491/noscat/releases/download/v0.2.0"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "f708fd5854687d675b517ec8b2d1317d875ba70a8dae52d80f3b073c0e3b26ef"
    sha256 cellar: :any_skip_relocation, arm64_linux: "e8acee61625d4e50fa776c4ab98ad77fd296b4fd2ea338e91fb466f1d701dc3e"
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
