WARDEN_PATH = "/warden"
ROOT_FS = "/var/warden/rootfs"
ROOT_FS_URL = "http://cfstacks.s3.amazonaws.com/lucid64.dev.tgz"
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
  command "gem install bundler && bundle install && bundle exec rake setup:bin[#{NEW_CONFIG_FILE_PATH}]"
  action :run
end

execute "download warden rootfs from s3" do
  command <<-BASH
    rm -rf #{ROOT_FS}
    mkdir -p #{ROOT_FS}
    curl -s #{ROOT_FS_URL} | tar xzf - -C #{ROOT_FS}
    (
      # In dea_ng, there is a java_with_oome fixture. The java buildpack depends on a buildpack_cache
      # to exist as well as this single jar file. So, let's fake that out here so that the jar file
      # can be found when the buildpack runs. Fugly? Yes.
      mkdir -p #{ROOT_FS}/var/vcap/packages/buildpack_cache
      cd #{ROOT_FS}/var/vcap/packages/buildpack_cache
      curl http://repo.springsource.org/milestone/org/cloudfoundry/auto-reconfiguration/0.6.6/auto-reconfiguration-0.6.6.jar
    )
  BASH
end

execute "copy resolv.conf from outside container" do
  command "cp /etc/resolv.conf #{ROOT_FS}/etc/resolv.conf"
end
