#!/usr/bin/env ruby

if !(2..3).include?(ARGV.length) || !File.exist?(ARGV[0])
  puts "Usage: handbrake-batch-convert.rb SRC_PATH DEST_PATH [BASE_PATH]"
  exit false
end

@src = File.expand_path(ARGV[0])
@target = File.expand_path(ARGV[1])
@base = (ARGV[2] && File.expand_path(ARGV[2])) || File.dirname(@src)
@exts = ['avi', 'mkv']


  
def target_file(f)
  File.join(@target, f.sub(@base, '').sub(/\.\w+$/,'.m4v')) 
end

src_files = @exts.map{|ext| Dir[File.join(@src, "**/*.#{ext}")] }.flatten
puts "#{src_files.length} source files"

src_target_map = src_files.inject({}) {|m, src| m.merge(src => target_file(src)) }
src_files.each {|src| src_target_map.delete(src) if File.exists?(src_target_map[src]) }

puts "#{src_target_map.length} target files (#{src_files.length - src_target_map.length}) already exist in target)"

src_target_map.keys.sort.each_with_index do |src, index|
  target = src_target_map[src]
  `mkdir -p "#{File.dirname(target)}"`
  $stdout << "Converting #{File.basename(src)} #{index + 1}/#{src_target_map.length}..."
  $stdout.flush
  `HandBrakeCLI -i "#{src}" -o "#{target}" -Z "AppleTV 2" > /dev/null 2>&1`
  puts "done"
end

puts "#{src_target_map.length} files converted"
