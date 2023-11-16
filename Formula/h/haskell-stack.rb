class HaskellStack < Formula
  desc "Cross-platform program for developing Haskell projects"
  homepage "https://haskellstack.org/"
  url "https://github.com/commercialhaskell/stack/archive/refs/tags/v2.13.1.tar.gz"
  sha256 "00333782b1bda3bda02ca0c1bbc6becdd86e5a39f6448b0df788b634e1bde692"
  license "BSD-3-Clause"
  head "https://github.com/commercialhaskell/stack.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "b81fc81d3662235af6f1fed0d1f960fc728ffbd2eaa4e963ba7024227da4435d"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "b0d96a8ca7778d812662071c191dab3c588138a5327041842edfbd56378ca999"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "d4fcc4cf54e777f2358c7c8437101efb72f2b84a0945f9e24bf813b4f4b233ba"
    sha256 cellar: :any_skip_relocation, ventura:        "95f4fd991821862e3ea548a96a7cd93abeffbc22e0912de8bafec85d22f20d9d"
    sha256 cellar: :any_skip_relocation, monterey:       "96e78b944ced64a81d399f3770ef55424b9664e541d90d2b07b8647c8862567c"
    sha256 cellar: :any_skip_relocation, big_sur:        "36bbb67964219186feacbc1860b4430962f2eb7bdae2295f7752e9f8b8fab99c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "1a7f98a6502cfd4dac42e044caa745b13a8d06b91f6b994255390ebce8cd50b9"
  end

  depends_on "cabal-install" => :build
  depends_on "ghc" => :build

  uses_from_macos "zlib"

  def install
    # Remove locked dependencies which only work with a single patch version of GHC.
    # If there are issues resolving dependencies, then can consider bootstrapping with stack instead.
    (buildpath/"cabal.project").unlink
    (buildpath/"cabal.project").write <<~EOS
      packages: .
    EOS

    system "cabal", "v2-update"
    system "cabal", "v2-install", *std_cabal_v2_args
  end

  def caveats
    on_macos do
      on_arm do
        <<~EOS
          All GHC versions before 9.2.1 requires LLVM Code Generator as a backend
          on ARM. If you are using one of those GHC versions with `haskell-stack`,
          then you may need to install a supported LLVM version and add its bin
          directory to the PATH.
        EOS
      end
    end
  end

  test do
    system bin/"stack", "new", "test"
    assert_predicate testpath/"test", :exist?
    assert_match "# test", (testpath/"test/README.md").read
  end
end
