# frozen_string_literal: true

# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "google/gapic/template/segment"

module Google
  module Gapic
    module Template
      # A URI template parser.
      #
      # @!attribute [r] template
      #   @return [String] The template to be parsed.
      # @!attribute [r] segments
      #   @return [Array<Segment|String>] The segments of the parsed template.
      class Parser
        # @private
        # /((?<positional>\*\*?)|{(?<name>[^\/]+?)(?:=(?<template>.+?))?})/
        TEMPLATE = %r{
          (
            (?<positional>\*\*?)
            |
            {(?<name>[^\/]+?)(?:=(?<template>.+?))?}
          )
        }x.freeze

        attr_reader :template, :segments

        # Create a new URI template parser.
        #
        # @param template [String] The template to be parsed.
        def initialize template
          @template = template
          @segments = parse! template
        end

        protected

        def parse! template
          # segments contain either Strings or segment objects
          segments = []
          segment_pos = 0

          while (match = TEMPLATE.match template)
            # The String before the match needs to be added to the segments
            segments << match.pre_match unless match.pre_match.empty?

            segment, segment_pos = segment_and_pos_from_match match, segment_pos
            segments << segment

            template = match.post_match
          end

          # Whatever String is unmatched needs to be added to the segments
          segments << template unless template.empty?

          segments
        end

        def segment_and_pos_from_match match, pos
          if match[:positional]
            [Segment.new(pos, match[:positional]), pos + 1]
          else
            [Segment.new(match[:name], match[:template]), pos]
          end
        end
      end
    end
  end
end
