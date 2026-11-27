# Homebrew formula template for the Letdown2491 tap (homebrew-tap).
# The release workflow fills the version and sha256 placeholders and uploads
# the generated formula (noscat.rb) as a release asset; copy it into the tap
# repo: https://github.com/Letdown2491/homebrew-tap (Formula/noscat.rb).
class Noscat < Formula
  desc "Like netcat, but over your own device mesh: npub-addressed, end-to-end encrypted, no root, no accounts"
  homepage "https://github.com/Letdown2491/noscat"
  version "0.7.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-aarch64-apple-darwin.tar.gz"
      sha256 "a18856c098814274d57ccaeb036d05a26982acdd1743017a68865c4e1c1b0cb1"
    else
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-x86_64-apple-darwin.tar.gz"
      sha256 "c7ac00737019b98baec1970d9b525cdce8b61728d8a2914423b8b1e7515ec14b"
    end
  end

  # The Linux binaries are static musl builds: no runtime deps on any distro.
  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-x86_64-unknown-linux-musl.tar.gz"
      sha256 "d31cfe94bebdf0b651e57ffadf3437089a8c66fb0c1023e906d72fa6f4ddcdf9"
    else
      url "https://github.com/Letdown2491/noscat/releases/download/v#{version}/noscat-v#{version}-aarch64-unknown-linux-musl.tar.gz"
      sha256 "88a9c6aa60ef74f37a8c83187d094a8b345cf83aa02fc3a02bdc23781104c526"
    end
  end

  # Linux bottles pour without a C toolchain (the binary is static musl);
  # macOS Homebrew always has CLT, so plain-URL installs are fine there.
  bottle do
    root_url "https://github.com/Letdown2491/noscat/releases/download/v0.7.0"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "147d26f2df3bb2c848a04d5f595bc904c93abd3059cc18d436611973407af59c"
    sha256 cellar: :any_skip_relocation, arm64_linux: "91a938799f1196ed49b0742b54d819dcbbcf972997dee3019fabeec991c953ea"
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
