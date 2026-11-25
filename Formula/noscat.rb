# Homebrew formula template for the Letdown2491 tap (homebrew-tap).
# The release workflow fills the version and sha256 placeholders and uploads
# the generated formula (noscat.rb) as a release asset; copy it into the tap
# repo: https://github.com/Letdown2491/homebrew-tap (Formula/noscat.rb).
class Noscat < Formula
  desc "Like netcat, but over your own device mesh: npub-addressed, end-to-end encrypted, no root, no accounts"
  homepage "https://github.com/Letdown2491/noscat"
  version "0.5.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-aarch64-apple-darwin.tar.gz"
      sha256 "a05430a356e7f093e4fea605e234458888ec18ac5c36fb71bfc53b4008612977"
    else
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-x86_64-apple-darwin.tar.gz"
      sha256 "98ee6bad05d5627e257f5e7df6e9aa4e660d0de4cd418e5503a0bd306e29de9b"
    end
  end

  # The Linux binaries are static musl builds: no runtime deps on any distro.
  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-x86_64-unknown-linux-musl.tar.gz"
      sha256 "254fac175486cda0cde07e72b50266beedac9e094037c5ea1137409eb10a65c6"
    else
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-aarch64-unknown-linux-musl.tar.gz"
      sha256 "4637c3e9618f3b947e4b26bfac3ff08addd616e31eae60b0c80d35813e81cad3"
    end
  end

  # Linux bottles pour without a C toolchain (the binary is static musl);
  # macOS Homebrew always has CLT, so plain-URL installs are fine there.
  bottle do
    root_url "https://github.com/Letdown2491/noscat/releases/download/v0.5.0"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "5cf23dc04d20f56cbe087a9910d16af52711b047c766a51d7a6af4f170a3ef31"
    sha256 cellar: :any_skip_relocation, arm64_linux: "3c165458379f31f027b215f68f79cb81505d220eb8d8ffaf1b2e7250aed024ea"
  end

  def install
    bin.install "noscat"
    man1.install "noscat.1"
    bash_completion.install "completions/noscat.bash" => "noscat"
    zsh_completion.install "completions/_noscat"
    fish_completion.install "completions/noscat.fish"
  end

  # `brew services start noscat` runs `noscat up` at login. For options
  # (--reachable, --to), use `noscat service install` instead.
  service do
    run [opt_bin/"noscat", "up"]
    keep_alive successful_exit: false
    log_path var/"log/noscat.log"
    error_log_path var/"log/noscat.log"
  end

  def caveats
    <<~EOS
      Each device keeps its identity and mesh in
      ~/Library/Application Support/noscat (~/.local/share/noscat on Linux).
      To keep this device running in the background with your options:
        noscat --reachable service install
    EOS
  end

  test do
    assert_match(/^npub1/, shell_output("#{bin}/noscat keygen"))
  end
end
