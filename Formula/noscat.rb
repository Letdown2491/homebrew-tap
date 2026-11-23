# Homebrew formula template for the Letdown2491 tap (homebrew-tap).
# The release workflow fills the version and sha256 placeholders and uploads
# the generated formula (noscat.rb) as a release asset; copy it into the tap
# repo: https://github.com/Letdown2491/homebrew-tap (Formula/noscat.rb).
class Noscat < Formula
  desc "Like netcat, but over a Nostr-native mesh: npub-addressed tunnels, no root, no accounts"
  homepage "https://github.com/Letdown2491/noscat"
  version "0.4.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-aarch64-apple-darwin.tar.gz"
      sha256 "d50218b47bfe0447172b830344f958c8b556235663ceab8662d1030f18e1ade2"
    else
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-x86_64-apple-darwin.tar.gz"
      sha256 "8eb86bfe1ef4b0d68f330feb286cb78b6f4053c2137f3dfcc51dc6c4c3dd231d"
    end
  end

  # The Linux binaries are static musl builds: no runtime deps on any distro.
  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-x86_64-unknown-linux-musl.tar.gz"
      sha256 "b481055f815e189da5fbbb119b266385564e72a1a7b8feeb8ef2b5844d6a285f"
    else
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-aarch64-unknown-linux-musl.tar.gz"
      sha256 "e54f8e6d23ea783f35770605f15d2bc2de68daf042d105704fc3234a8f944947"
    end
  end

  # Linux bottles pour without a C toolchain (the binary is static musl);
  # macOS Homebrew always has CLT, so plain-URL installs are fine there.
  bottle do
    root_url "https://github.com/Letdown2491/noscat/releases/download/v0.4.1"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "cc5d20e0585986c50890ab677483b6b9ea30c247bc9c90ba46add99d5621bf43"
    sha256 cellar: :any_skip_relocation, arm64_linux: "2891166315285f6f009b738956a623a19bfc0a99ca507ce3c0780e2bcc9a2f35"
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
      Identities are ephemeral by default; pin them with --identity (or the
      NOSCAT_IDENTITY variable). Mesh commands use ~/.noscat/device by
      default; override with --dir.
    EOS
  end

  test do
    assert_match(/^nsc/, shell_output("#{bin}/noscat keygen"))
  end
end
