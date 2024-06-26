class Mx < Formula
  desc "Command-line tool used for the development of Graal projects"
  homepage "https://github.com/graalvm/mx"
  url "https://github.com/graalvm/mx/archive/refs/tags/7.26.1.tar.gz"
  sha256 "37c6bb73f830271a09a28692e356666332866fb9815e60c1438acb4d4e696d67"
  license "GPL-2.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "42665c0211e49ed5539f930ccbc0659406c4a4983ca2225a6f1fae8f134d2f6d"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "42665c0211e49ed5539f930ccbc0659406c4a4983ca2225a6f1fae8f134d2f6d"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "42665c0211e49ed5539f930ccbc0659406c4a4983ca2225a6f1fae8f134d2f6d"
    sha256 cellar: :any_skip_relocation, sonoma:         "42665c0211e49ed5539f930ccbc0659406c4a4983ca2225a6f1fae8f134d2f6d"
    sha256 cellar: :any_skip_relocation, ventura:        "42665c0211e49ed5539f930ccbc0659406c4a4983ca2225a6f1fae8f134d2f6d"
    sha256 cellar: :any_skip_relocation, monterey:       "42665c0211e49ed5539f930ccbc0659406c4a4983ca2225a6f1fae8f134d2f6d"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "23b0ea280b8aa4cbfca51579ed80d0562137132f605f14564d034064edcd3aee"
  end

  depends_on "openjdk" => :test
  depends_on "python@3.12"

  def install
    libexec.install Dir["*"]
    (bin/"mx").write_env_script libexec/"mx", MX_PYTHON: "#{Formula["python@3.12"].opt_libexec}/bin/python"
    bash_completion.install libexec/"bash_completion/mx" => "mx"
  end

  def post_install
    # Run a simple `mx` command to create required empty directories inside libexec
    Dir.mktmpdir do |tmpdir|
      with_env(HOME: tmpdir) do
        system bin/"mx", "--user-home", tmpdir, "version"
      end
    end
  end

  test do
    resource "homebrew-testdata" do
      url "https://github.com/oracle/graal/archive/refs/tags/vm-22.3.2.tar.gz"
      sha256 "77c7801038f0568b3c2ef65924546ae849bd3bf2175e2d248c35ba27fd9d4967"
    end

    ENV["JAVA_HOME"] = Language::Java.java_home
    ENV["MX_ALT_OUTPUT_ROOT"] = testpath

    testpath.install resource("homebrew-testdata")
    cd "vm" do
      output = shell_output("#{bin}/mx suites")
      assert_match "distributions:", output
    end
  end
end
