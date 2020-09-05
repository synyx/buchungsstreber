# The MIT License (MIT)
#
# Copyright (c) 2016 Skye Shaw
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# See: https://github.com/sshaw/i18n-env-config/
require "i18n"

module I18n
  module Env
    class Config < I18n::Config
      VERSION = "0.0.1".freeze

      # Order is important
      VARS = %w[LANGUAGE LC_ALL LC_MESSAGES LANG].freeze

      def locale
        @locale ||= find_user_locale || super
      end

      private

      def find_user_locale
        find_primary || find_secondary
      end

      def find_primary
        locales.find { |l| I18n.locale_available?(l) }
      end

      def find_secondary
        tag = nil

        locales.each do |l|
          tag = I18n::Locale::Tag.tag(l).parents.map(&:to_sym).find { |parent| I18n.locale_available?(parent) }
          break if tag
        end

        tag
      end

      def locales
        @locales ||= VARS.reject { |name| !ENV[name] || ENV[name] == "C" }.flat_map do |name|
          # LANGUAGE's value can be delimited by ":"
          ENV[name].split(":").map { |l| normalize(l) }
        end
      end

      def normalize(lang)
        # Remove encoding
        lang = lang.split(".").first
        lang.tr!("_", "-")
        lang.to_sym
      end
    end
  end
end
