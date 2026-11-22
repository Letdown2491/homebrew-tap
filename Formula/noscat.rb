# Homebrew formula template for the Letdown2491 tap (homebrew-tap).
# The release workflow fills the version and sha256 placeholders and uploads
# the generated formula (noscat.rb) as a release asset; copy it into the tap
# repo: https://github.com/Letdown2491/homebrew-tap (Formula/noscat.rb).
class Noscat < Formula
  desc "Like netcat, but over a Nostr-native mesh: npub-addressed tunnels, no root, no accounts"
  homepage "https://github.com/Letdown2491/noscat"
  version "0.1.3"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-aarch64-apple-darwin.tar.gz"
      sha256 "41b8fa7055aa94ba09d8aaa93b64bf10a7cb4f69830c347dcef3118431cb381d"
    else
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-x86_64-apple-darwin.tar.gz"
      sha256 "3fac4610a6b40bf4b39ded5ab0842ab6c5ce511d21d1685af7ad6bf3766891f7"
    end
  end

  # The Linux binaries are static musl builds: no runtime deps on any distro.
  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-x86_64-unknown-linux-musl.tar.gz"
      sha256 "d10c653561aad16ff3d24fe157536c174ae1e2a156314950747c97656526c72f"
    else
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-aarch64-unknown-linux-musl.tar.gz"
      sha256 "1871a464f3c9bdffcc70344e3cf21b86d0e6267fc68aadb1a1953d9b0f84fdc4"
    end
  end

  # Linux bottles pour without a C toolchain (the binary is static musl);
  # macOS Homebrew always has CLT, so plain-URL installs are fine there.
  bottle do
    root_url "https://github.com/Letdown2491/noscat/releases/download/v0.1.3"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "0009dd6c863a48e95e63bd5d46c756f457bba15bd455c476475616cacb8d8369"
    sha256 cellar: :any_skip_relocation, arm64_linux: "418de5eb1bd947f9f953827b5af1b4d16b5a6de37c3d441c8f778f4fca385e92"
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
