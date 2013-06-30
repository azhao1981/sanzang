#!/usr/bin/env ruby
# -*- encoding: UTF-8 -*-
#--
# Copyright (C) 2012 Lapis Lazuli Texts
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

require "optparse"
require "parallel"

require_relative "reflow"
require_relative "translate"
require_relative "batch"

require_relative File.join("..", "version")

module Sanzang::Command

  # This class provides a frontend for all Sanzang operations and subcommands.
  #
  class SanzangCmd

    # Create a new instance of the sanzang command
    #
    def initialize
      @name = "sanzang"
      @commands = [
        ["batch", Sanzang::Command::Batch],
        ["reflow", Sanzang::Command::Reflow],
        ["translate", Sanzang::Command::Translate]
      ]
    end

    # Run the sanzang command with the given arguments. If the first argument
    # is the name of a sanzang subcommand or the beginning of a subcommand,
    # then that subcommand is executed. The sanzang command also accepts
    # several options such as showing usage and platform information.
    #
    def run(args)
      parser = option_parser

      if args.length < 1
        $stderr.puts parser
        return 1
      end

      @commands.each do |key,cmd|
        if key.start_with?(args[0])
          return cmd.new.run(args[1..-1])
        end
      end

      parser.parse!(args)

      $stderr.puts parser
      return 1
    rescue SystemExit => err
      return err.status
    rescue Errno::EPIPE 
      return 0
    rescue Exception => err
      $stderr.puts "#{@name}: #{err.inspect}"
      return 1
    end

    # A string giving a listing of platform information
    #
    def platform_info
      info = "Ruby platform: #{RUBY_PLATFORM}\n"
      info << "Ruby version: #{RUBY_VERSION}\n"
      info << "External encoding: #{Encoding.default_external}\n"
      info << "Internal encoding: #{Encoding.default_internal or 'none'}\n"
      info << "Fork implemented: #{Process.respond_to?(:fork)}\n"
      info << "Parallel version: #{Parallel::VERSION}\n"
      info << "Processors found: #{Parallel.processor_count}\n"
      info << "Sanzang version: #{Sanzang::VERSION}\n"
    end

    # This is a string giving a brief one-line summary of version information
    #
    def version_info
      "sanzang #{Sanzang::VERSION} [ruby_#{RUBY_VERSION}] [#{RUBY_PLATFORM}]"
    end

    private

    # An OptionParser object for parsing command options and parameters
    #
    def option_parser
      OptionParser.new do |op|
        op.banner = "Usage: #{@name} [options]\n"
        op.banner << "Usage: #{@name} <command> [options] [args]\n\n"

        op.banner << "Use \"--help\" with commands for usage information.\n"

        op.banner << "\nSanzang commands:\n"
        op.banner << "    batch       translate many files in parallel\n"
        op.banner << "    reflow      format CJK text for translation\n"
        op.banner << "    translate   standard single text translation\n"
        op.banner << "\nOptions:\n"

        op.on("-h", "--help", "show this help message and exit") do |v|
          puts op
          exit 0
        end
        op.on("-P", "--platform", "show platform information and exit") do |v|
          puts platform_info
          exit 0
        end
        op.on("-V", "--version", "show version number and exit") do |v|
          puts version_info
          exit 0
        end
      end
    end

    # Name of the command
    #
    attr_reader :name

  end
end
