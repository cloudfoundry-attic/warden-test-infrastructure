WARDEN_PATH = "/warden"
ROOT_FS = "/var/warden/rootfs"
ROOT_FS_URL = "http://d31qcsjlqa9q7y.cloudfront.net/lucid64.latest.tgz"
OLD_CONFIG_FILE_PATH = "#{WARDEN_PATH}/warden/config/linux.yml"
NEW_CONFIG_FILE_PATH = "#{WARDEN_PATH}/warden/config/test_vm.yml"

git WARDEN_PATH do
  repository "git://github.com/cloudfoundry/warden.git"
  revision "0293814d6cc591cc5029e66188495fac7ceed4f2"
  action :sync
end

ruby_block "configure warden to put its rootfs outside of /tmp" do
  block do
    require "yaml"
    config = YAML.load_file(OLD_CONFIG_FILE_PATH)
    config["server"]["container_rootfs_path"] = ROOT_FS
    File.open(NEW_CONFIG_FILE_PATH, 'w') { |f| YAML.dump(config, f) }
  end
  action :create
end

execute "setup_warden" do
  cwd "#{WARDEN_PATH}/warden"
  command "bundle install && bundle exec rake setup:bin[#{NEW_CONFIG_FILE_PATH}]"
  action :run
end

execute "download warden rootfs from s3" do
  command <<-BASH
    rm -rf #{ROOT_FS}
    mkdir -p #{ROOT_FS}
    curl -s #{ROOT_FS_URL} | tar xzf - -C #{ROOT_FS}
  BASH
end

execute "copy resolv.conf from outside container" do
  command "cp /etc/resolv.conf #{ROOT_FS}/etc/resolv.conf"
end


