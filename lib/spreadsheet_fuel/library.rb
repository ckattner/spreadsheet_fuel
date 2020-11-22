# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'library/deserialize/xlsx'
require_relative 'library/serialize/xlsx'

module Burner
  # Open up the Burner::Jobs class and register our jobs.
  class Jobs
    register 'spreadsheet_fuel/deserialize/xlsx', SpreadsheetFuel::Library::Deserialize::Xlsx
    register 'spreadsheet_fuel/serialize/xlsx',   SpreadsheetFuel::Library::Serialize::Xlsx
  end
end
