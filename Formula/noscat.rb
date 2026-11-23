# Homebrew formula template for the Letdown2491 tap (homebrew-tap).
# The release workflow fills the version and sha256 placeholders and uploads
# the generated formula (noscat.rb) as a release asset; copy it into the tap
# repo: https://github.com/Letdown2491/homebrew-tap (Formula/noscat.rb).
class Noscat < Formula
  desc "Like netcat, but over a Nostr-native mesh: npub-addressed tunnels, no root, no accounts"
  homepage "https://github.com/Letdown2491/noscat"
  version "0.4.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-aarch64-apple-darwin.tar.gz"
      sha256 "f392397392382f35e86ab4fc383f2f7fbce51e56a917114a8cf709eb11a0e90c"
    else
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-x86_64-apple-darwin.tar.gz"
      sha256 "df6b15cb32e9e8bbccc5f02892b9ca414cea856ba33b6b5188a94882d0dd39ef"
    end
  end

  # The Linux binaries are static musl builds: no runtime deps on any distro.
  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-x86_64-unknown-linux-musl.tar.gz"
      sha256 "a77865dcd1a406ba8e061567df4183cecd29c209a9fd2e346d44458a35df478b"
    else
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-aarch64-unknown-linux-musl.tar.gz"
      sha256 "2880382c9681c172b215798952d4016cd4f67c13f6b312702c3338efe1de485f"
    end
  end

  # Linux bottles pour without a C toolchain (the binary is static musl);
  # macOS Homebrew always has CLT, so plain-URL installs are fine there.
  bottle do
    root_url "https://github.com/Letdown2491/noscat/releases/download/v0.4.0"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "7d72b188a45f0b820864b4c91efae91018da3f89c93b1359f58bcce758aed73a"
    sha256 cellar: :any_skip_relocation, arm64_linux: "f1398809eed359aa5217425cc98f8d07417f14a75fb1485b41a916e14d75859b"
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
