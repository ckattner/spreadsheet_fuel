# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'acts_as_hashable'
require 'burner'
require 'fast_excel'
require 'roo'

# Require modeling first, which can be used across any job classes.
require_relative 'spreadsheet_fuel/modeling'

require_relative 'spreadsheet_fuel/library'
