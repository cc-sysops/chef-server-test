# This file aggregates all the different configs for the tests

require 'mixlib/config'
require 'pathname'
require 'chef/json_compat'

module ChefServerTest
  module Config
    extend Mixlib::Config
    config_strict_mode true  # will see how annoying this is

    # Sets the base path. Usually called from bin/validate
    def self.with_base_path(path)
      self.base_path path
      self
    end

    # Sets the candidate path. Usually called from bin/validate
    def self.with_candidate_pkg(pkg)
      self.candidate_pkg pkg
      self
    end

    # Base Path points to the root of the chef-server-test repo
    # By default, the bin/validate script will set this to the parent
    # dir of bin
    default :base_path, nil

    # Chef Client flags gets added for each chef-client operations
    # These defaults are set for a dev environment, and may need to
    # be tweaked if used with CI.
    default :chef_client_flags, '-z -l info -F doc --color --no-fork'

    # Sets the candidate package for install and upgrade tests
    # bin/validate will accept this in the command line option
    configurable :candidate_pkg

    # This sets the released version from which upgrade tests
    # should upgrade from.
    configurable :upgrade_from_version

    # Derived values
    default(:vms_path)       { File.join base_path, 'vms' }
    default(:cluster_repo)   { File.join vms_path, 'repo' }

    default(:cache_path)     { File.join base_path, 'cache' }
    default(:releases_path)  { File.join cache_path, 'releases' }
    default(:data_bags_path) { File.join base_path, 'data_bags' }

    # Internal settings, usually test-dependent

    # If a candidate package is available, install it.
    # Upgrade tests will set set this to false.
    default :install_candidate, true

    # Glue layer for generating config for chef-client

    def self.to_hash
      # TODO: Make candidate_pkg always required and cut out the fat here
      package_info = ChefServerTest::PackageInfo.new(File.basename(candidate_pkg)) if candidate_pkg && !candidate_pkg.empty?

      {
        'id'            => 'default',
        'base_path'     => base_path,
        'vms_path'      => vms_path,
        'cluster_repo'  => cluster_repo,
        'cache_path'    => cache_path,
        'releases_path' => releases_path,

        'host_candidate_pkg_path' => candidate_pkg,
        'candidate_pkg'           => (package_info ? package_info.package_name : nil ),
        'install_candidate'       => install_candidate,
        'upgrade_from_version'    => upgrade_from_version,

        'package_info' => (package_info ? package_info.to_hash : nil )
      }
    end

    # TODO: Check what parser we are supposed to be using
    def self.to_json
      Chef::JSONCompat.to_json_pretty(to_hash)
    end

    def self.ensure_root_dirs_exist!
      ensure_test_data_bag_dir!
      ensure_cache_path_dir!
      ensure_releases_path_dir!
      ensure_vms_path_dir!
      ensure_cluster_repo_dir!
      ensure_nodes_dir!
      ensure_client_dir!
    end

    def self.generate_data_bag!
      ensure_test_data_bag_dir!
      File.open(File.join(data_bags_path, 'tests', 'default.json'), "w") do |f|
        f.puts to_json
      end
    end

    def self.normalize_candidate_pkg(pkg_path)
      if Pathname.new(pkg_path).absolute?
        return pkg_path if File.exists? pkg_path
        return nil # Always return nil if package does not exist
      end
      return File.join cache_path, pkg_path if File.exists?(File.join(cache_path, pkg_path))
      return File.join base_path,  pkg_path if File.exists?(File.join(base_path, pkg_path))
    end

    private

    def self.ensure_data_bags_path_dir!
      Pathname.new(data_bags_path).mkpath
    end

    def self.ensure_test_data_bag_dir!
      Pathname.new(File.join(base_path, 'data_bags', 'tests')).mkpath
    end

    def self.ensure_cache_path_dir!
      Pathname.new(releases_path).mkpath
    end

    def self.ensure_release_path_dir!
      Pathname.new(releases_path).mkpath
    end

    def self.ensure_vms_path_dir!
      Pathname.new(vms_path).mkpath
    end

    def self.ensure_cluster_repo_dir!
      Pathname.new(cluster_repo).mkpath
    end

    def self.ensure_nodes_dir!
      Pathname.new(File.join(base_path, 'nodes')).mkpath
    end

    def self.ensure_client_dir!
      Pathname.new(File.join(base_path, 'client')).mkpath
    end

  end
end
