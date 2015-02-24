WARDEN_PATH = "/warden"
ROOT_FS_PATH_LUCID = "/var/warden/rootfs_lucid"
ROOT_FS_PATH_CFLINUXFS2 = "/var/warden/rootfs_cflinuxfs2"
ROOT_FS_URL_LUCID =  "http://cf-runtime-stacks.s3.amazonaws.com/lucid64.dev.tgz"
ROOT_FS_URL_CFLINUXFS2 = "http://cf-runtime-stacks.s3.amazonaws.com/cflinuxfs2.dev.tgz"
DEFAULT_ROOT_FS_PATH = ROOT_FS_PATH_LUCID
OLD_CONFIG_FILE_PATH = "#{WARDEN_PATH}/warden/config/linux.yml"
NEW_CONFIG_FILE_PATH = "#{WARDEN_PATH}/warden/config/test_vm.yml"

package "quota" do
  action :install
end

package "apparmor" do
  action :remove
end

execute "remove remove all remnants of apparmor" do
  command "sudo dpkg --purge apparmor"
end

directory WARDEN_PATH do
  owner node.warden.user
end

git WARDEN_PATH do
  repository "git://github.com/cloudfoundry/warden.git"
  action :sync
  user node.warden.user
end

ruby_block "configure warden to put its rootfs outside of /tmp" do
  block do
    require "yaml"
    config = YAML.load_file(OLD_CONFIG_FILE_PATH)
    config["server"]["container_rootfs_path"] = DEFAULT_ROOT_FS_PATH
    File.open(NEW_CONFIG_FILE_PATH, 'w') { |f| YAML.dump(config, f) }
  end
  action :create
end

execute "setup_warden" do
  command "su #{node.warden.user} -l -c 'cd #{WARDEN_PATH}/warden && bundle install && bundle exec rake setup:bin[#{NEW_CONFIG_FILE_PATH}]'"
  action :run
end

execute "download warden cflinuxfs2 rootfs from s3" do
  command <<-BASH
    rm -rf #{ROOT_FS_PATH_CFLINUXFS2}
    mkdir -p #{ROOT_FS_PATH_CFLINUXFS2}
    curl -s #{ROOT_FS_URL_CFLINUXFS2} | tar xzf - -C #{ROOT_FS_PATH_CFLINUXFS2}
  BASH
end

execute "download warden lucid rootfs from s3" do
  command <<-BASH
    rm -rf #{ROOT_FS_PATH_LUCID}
    mkdir -p #{ROOT_FS_PATH_LUCID}
    curl -s #{ROOT_FS_URL_LUCID} | tar xzf - -C #{ROOT_FS_PATH_LUCID}
  BASH
end

execute "copy resolv.conf from lucid outside container" do
  command "cp /etc/resolv.conf #{ROOT_FS_PATH_LUCID}/etc/resolv.conf"
end

execute "copy resolv.conf from cflinuxfs2 outside container" do
  command "cp /etc/resolv.conf #{ROOT_FS_PATH_CFLINUXFS2}/etc/resolv.conf"
end
