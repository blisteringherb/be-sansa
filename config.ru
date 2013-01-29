# Start app in prod with thin -C config/thin-production.yml -R config.ru start

# config.ru
require 'rubygems'
require 'bundler'
require 'pp'

Bundler.require

require './app'
run DeploymentApp