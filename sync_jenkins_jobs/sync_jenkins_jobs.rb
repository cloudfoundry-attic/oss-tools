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

def rsync_live_configs(logger, jenkins_ip)
  job_dir = Dir.mktmpdir

  cmd = ["rsync -e ssh -az --exclude '*/builds'",
         "vcap@#{jenkins_ip}:/var/vcap/store/jenkins/jobs/",
         job_dir].join(" ")
  system!(logger, cmd)

  job_dir
end

def convert_config_to_template(logger, job, live_configs_dir, jobs_src_dir)
  live_config_path = File.join(live_configs_dir, job, "config.xml")
  template_path = File.join(jobs_src_dir, job, "config.xml.erb")
  system!(logger, "cp #{live_config_path} #{template_path}")

  # Rewrite git url so it is deployment agnostic
  template = File.read(template_path)
  if template =~ /<url>(.*)<\/url>/m
    parts = $1.split("/")
    if repo = parts.last
      url = "ssh://<%= ENV['CF_CI_USER'] %>@<%= ENV['CF_GERRIT_ADDRESS'] %>:" \
            + "<%= ENV['CF_GERRIT_PORT'] %>/#{repo}"
      template.gsub!(/<url>(.*)<\/url>/m, "<url>#{url}</url>")
    end
  end

  File.open(template_path, "w") do |f|
   f.write(template)
  end
end

def sync_configs(logger, live_configs_dir, jobs_src_dir)
  live_jobs = Set.new(Dir.glob("#{live_configs_dir}/*").map {|j| File.basename(j) })
  src_jobs = Set.new(Dir.glob("#{jobs_src_dir}/*").map {|j| File.basename(j) })

  to_add = live_jobs - src_jobs
  to_add.each do |job|
    logger.info("Adding #{job} to release")
    system!(logger, "mkdir #{jobs_src_dir}/#{job}")
    convert_config_to_template(logger, job, live_configs_dir, jobs_src_dir)
  end

  to_remove = src_jobs - live_jobs
  to_remove.each do |job|
    logger.info("Removing #{job} from release")
    system!(logger, "cd #{jobs_src_dir} && git rm -rf ./#{job}")
  end

  to_sync = live_jobs & src_jobs
  to_sync.each do |job|
    logger.info("Syncing #{job}")
    convert_config_to_template(logger, job, live_configs_dir, jobs_src_dir)
  end
end

opts = {
  :verbose => false,
}

opt_parser = OptionParser.new do |op|
  op.banner = "Synchronize live Jenkins job configs with a release repo\n\n"

  op.on("-v", "--verbose", "Print debugging information") do
    opts[:verbose] = true
  end


end

opt_parser.parse!(ARGV)

unless ARGV.length == 2
  puts "Usage: sync_jenkins_jobs.rb [/path/to/deployment_manifest] [/path/to/job_src_dir]"
  puts
  puts opt_parser.help
  exit 1
end

logger = Logger.new(STDOUT)
if opts[:verbose]
  logger.level = Logger::DEBUG
else
  logger.level = Logger::INFO
end

manifest_path, jobs_src_dir = ARGV

begin
  jenkins_ip = parse_jenkins_ip(manifest_path)
  logger.info("Found jenkins ip: #{jenkins_ip}")

  logger.info("Rsyncing job configs")
  live_configs_dir = rsync_live_configs(logger, jenkins_ip)

  logger.info("Synchronizing configs")
  sync_configs(logger, live_configs_dir, jobs_src_dir)

  logger.info("Done")
rescue => e
  logger.error(e.to_s)
  logger.debug(e.backtrace.join("\n")) if e.backtrace
end
