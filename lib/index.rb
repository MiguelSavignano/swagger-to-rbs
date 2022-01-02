# frozen_string_literal: true
require 'pry'
require 'dotenv/load'
require_relative 'swagger2_rbs'
require_relative './swagger2_rbs/cli'

Swagger2Rbs::Cli.start(ARGV)
