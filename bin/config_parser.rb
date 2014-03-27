#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require 'optparse'
require 'yaml'

options = {}

OptionParser.new do |opts|
  opts.banner = 'Usage: config_parser.rb [options]'

  opts.on('-h', '--host [HOST]', 'Host') do |v|
    options[:host] = v
  end

  opts.on('-p', '--port [PORT]', 'Port') do |v|
    options[:port] = v
  end

  opts.on('-l', '--list', 'List') do |v|
    options[:list] = v
  end

  opts.on('-c', '--conf [CONF]', 'Configuration File') do |v|
    options[:conf] = v
  end
end.parse!

def list(conf)
  print conf['nodes'].map { |e| e['host'] + ':' + e['port'].to_s }.join(' ')
end

def option(conf, host, port)
  host = conf['nodes'].find { |e| e['host'] == host && e['port'].to_i == port.to_i }
  fail "#{host}:#{port} is not found" unless host
  print [host['java-opts'], conf['common-java-opts']].join(' ')
end

conf = YAML.load_file(options[:conf])

if options[:list]
  list(conf)
  exit
end

option(conf, options[:host], options[:port])
