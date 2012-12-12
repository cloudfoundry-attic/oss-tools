require "logger"
require "optparse"
require "set"
require "tmpdir"
require "yaml"

def system!(logger, cmd)
  logger.info("+ #{cmd}")
  unless system(cmd)
    raise "Failed executing '#{cmd}'"
  end

  true
end

def parse_jenkins_ip(manifest_path)
  manifest = YAML.load_file(manifest_path)
  unless jobs = manifest["jobs"]
    raise "No jobs found in manifest"
  end

  jenkins_job = jobs.select {|j| j["name"] == "jenkins"}.first
  unless jenkins_job
    raise "Jenkins job not found in manifest"
  end

  unless networks = jenkins_job["networks"]
    raise "No networks found for jenkins"
  end

  nets = Set.new(%w[jenkins default])
  net = networks.select {|n| nets.include?(n["name"]) }.first
  unless net
    raise "No network found"
  end

  unless ips = net["static_ips"]
    raise "No static ips found in jenkins default network"
  end

  ips.first
end
