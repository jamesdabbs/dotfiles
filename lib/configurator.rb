class Configurator
  attr_reader :name, :username, :email, :github_username, :data_directory

  def initialize opts={}, &block
    @name            = opts.fetch :name
    @username        = opts.fetch :username
    @email           = opts.fetch :email
    @github_username = opts.fetch :github_username

    # All data needing to be backed up _should_ be under this directory
    # (though it quite likely isn't, so be careful)
    @data_directory = opts.fetch :data_directory

    instance_eval &block
  end

  def home
    "/Users/#{username}"
  end

  def ssh_key_path
    "#{home}/.ssh/id_rsa"
  end
  def public_ssh_key_path
    "#{ssh_key_path}.pub"
  end

  def ssh_dir
    File.dirname ssh_key_path
  end

  def ensure_dir dir
    FileUtils.mkdir_p dir
  end

  def computer_name
    @_computer_name ||= `hostname`.strip
  end

  def assert_equal a,b
    if a == b
      puts "[OK] #{a} == #{b}"
    else
      raise "[ERR] Expected #{a} to equal #{b}"
    end
  end

  def run *args
    puts "==> #{args.join ' '}"
    out, err, status = Open3.capture3 *args
    puts out
    unless status.success?
      warn "~~ ERROR! ~~"
      warn err
      raise
    end
  end

  def link h
    raise unless h.is_a?(Hash) && h.length == 1
    from, to = h.first
    raise "Can't link to #{to} - it doesn't exist" unless File.exists? to
    return if File.exists? from
    run "ln", "-s", to, from
  end

  def brew_install package
    unless system "which #{package}"
      run "brew", "install", package
      yield if block_given?
    end
  end

  def github
    Github::Client.new(username: github_username)
  end

  def template_path name
    File.expand_path "../../templates/#{name}", __FILE__
  end
end
