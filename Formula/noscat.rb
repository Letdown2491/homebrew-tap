# Homebrew formula template for the Letdown2491 tap (homebrew-tap).
# The release workflow fills the version and sha256 placeholders and uploads
# the generated formula (noscat.rb) as a release asset; copy it into the tap
# repo: https://github.com/Letdown2491/homebrew-tap (Formula/noscat.rb).
class Noscat < Formula
  desc "Like netcat, but over your own device mesh: npub-addressed, end-to-end encrypted, no root, no accounts"
  homepage "https://github.com/Letdown2491/noscat"
  version "0.7.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-aarch64-apple-darwin.tar.gz"
      sha256 "04f910c713a7f59b51a161299c93ad9b29b17c0c8f2557cd665b8f6f0ebe2e71"
    else
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-x86_64-apple-darwin.tar.gz"
      sha256 "d5dfc792d0b2f1583583d8d6bf27ba7981f962a5b925fa6c4fe8b306ae6b0a6b"
    end
  end

  # The Linux binaries are static musl builds: no runtime deps on any distro.
  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-x86_64-unknown-linux-musl.tar.gz"
      sha256 "1efe8126d4d0f954ddbae35bbd992c042c1914cbb20dc694530a4a385aca3307"
    else
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-aarch64-unknown-linux-musl.tar.gz"
      sha256 "d41ad3740069276678c653de877a7d5aa9e7075239183ed24a89057e7daec2ce"
    end
  end

  # Linux bottles pour without a C toolchain (the binary is static musl);
  # macOS Homebrew always has CLT, so plain-URL installs are fine there.
  bottle do
    root_url "https://github.com/Letdown2491/noscat/releases/download/v0.7.1"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "78ec1c8bdf6c262f769fe09550973fa2e06cfa5250fd80ed325515fe8e953118"
    sha256 cellar: :any_skip_relocation, arm64_linux: "d14013df3c0e53d0537d01860c1aa35a05d6b4a9305d6d3aca4b7483d31bb6a5"
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
