# Homebrew formula template for the Letdown2491 tap (homebrew-tap).
# The release workflow fills the version and sha256 placeholders and uploads
# the generated formula (noscat.rb) as a release asset; copy it into the tap
# repo: https://github.com/Letdown2491/homebrew-tap (Formula/noscat.rb).
class Noscat < Formula
  desc "Like netcat, but over your own device mesh: npub-addressed, end-to-end encrypted, no root, no accounts"
  homepage "https://github.com/Letdown2491/noscat"
  version "0.6.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-aarch64-apple-darwin.tar.gz"
      sha256 "0c75769f2e869f884a6fa399020bc714b088481803814b853796890f7996b094"
    else
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-x86_64-apple-darwin.tar.gz"
      sha256 "5666af9c1784f53f14b17d6e192e24c022726f20369841414d2dabb5202893d8"
    end
  end

  # The Linux binaries are static musl builds: no runtime deps on any distro.
  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-x86_64-unknown-linux-musl.tar.gz"
      sha256 "fc335f8a284aa895e3631a8c3c22561808e18a275b4ccdf6ed477c521696a945"
    else
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-aarch64-unknown-linux-musl.tar.gz"
      sha256 "7f0477d62d54784b973258edc23c75c022d47438c12f1e8c99212977c3d60588"
    end
  end

  # Linux bottles pour without a C toolchain (the binary is static musl);
  # macOS Homebrew always has CLT, so plain-URL installs are fine there.
  bottle do
    root_url "https://github.com/Letdown2491/noscat/releases/download/v0.6.0"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "624cf245a7e5f2ebbd62b99ff572453113c6a4e2cff4185dbde03d098b2a9fc6"
    sha256 cellar: :any_skip_relocation, arm64_linux: "c0e090a6d5497741c64e9b51d35608076ce28fa7756032ca62273c6d2428d4c8"
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
