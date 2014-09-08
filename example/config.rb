set :storage, {
  type: :s3,
  bucket: ENV["MAMIYA_S3_BUCKET"] || ENV["S3_BUCKET"],
  region: ENV["AWS_REGION"] || 'ap-northeast-1',
}

set :packages_dir, "#{File.dirname(__FILE__)}/packages"
set :prereleases_dir, "#{File.dirname(__FILE__)}/target/prereleases"

# To test
Dir.mkdir packages_dir unless File.exist?(packages_dir)
Dir.mkdir prereleases_dir unless File.exist?(prereleases_dir)

set :keep_packages, 3
set :keep_prereleases, 3
set :fetch_sleep, 2
